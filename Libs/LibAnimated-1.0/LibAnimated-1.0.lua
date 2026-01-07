local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local LibAnimated = CreateFrame("Frame")

-- Lib Global
local Pi = math.pi
local Cos = math.cos
local Sin = math.sin
local TableInsert = table.insert
local TableRemove = table.remove
local Lower = string.lower

-- Tables
LibAnimated.Running = {}
LibAnimated.Constructors = {}
LibAnimated.Lookup = {}

-- Callbacks
LibAnimated.Callbacks = {
    ["OnPlay"] = {},
    ["OnPause"] = {},
    ["OnResume"] = {},
    ["OnStop"] = {},
    ["OnReset"] = {},
    ["OnFinished"] = {}
}

-- Easing
LibAnimated.Easing = {
    ["LinearEase"] = function(TimeElapsed, Start, Delta, Duration)
        return Delta * TimeElapsed / Duration + Start
    end,

    ["InSineEase"] = function(TimeElapsed, Start, Delta, Duration)
        return -Delta * Cos(TimeElapsed / Duration * (Pi / 2)) + Delta + Start
    end,

    ["OutSineEase"] = function(TimeElapsed, Start, Delta, Duration)
        return Delta * Sin(TimeElapsed / Duration * (Pi / 2)) + Start
    end,
}

-- Groups
LibAnimated.Groups = {
    Play = function(self)
        if (self.Stopped or not self.Playing) then
            LibAnimated.Constructors[self.Type](self)
            self:Callback("OnPlay")
        elseif (self.Paused) then
            self:StartUpdating()
            self:Callback("OnResume")
        end

        self.Playing = true
        self.Paused = false
        self.Stopped = false
    end,

    Pause = function(self)
        for i, Frames in ipairs(LibAnimated.Running) do
            if (Frames == self) then
                TableRemove(LibAnimated.Running, i)

                break
            end
        end

        self.Playing = false
        self.Paused = true
        self:Callback("OnPause")
    end,

    Stop = function(self)
        for i, Frames in ipairs(LibAnimated.Running) do
            if (Frames == self) then
                TableRemove(LibAnimated.Running, i)

                break
            end
        end

        self.Playing = false
        self.Paused = false
        self.Stopped = true
        self.Timer = 0
        self.CurrentValue = self.EndAlpha
        self.Parent:SetAlpha(self.EndAlpha)
        self:Callback("OnStop")
    end,

    SetEasing = function(self, EasingName)
        EasingName = Lower(EasingName or "")

        for Key, _ in pairs(LibAnimated.Easing) do
            if (Lower(Key) == EasingName) then
                self.Easing = Key
                
                return
            end
        end

        self.Easing = "LinearEase"
    end,

    SetDuration = function(self, Duration)
        self.Duration = Duration or 0.25
    end,

    SetChange = function(self, Alpha)
        self.TargetAlpha = Alpha or 0
    end,

    GetChange = function(self)
        return self.TargetAlpha
    end,

    GetProgress = function(self)
        return self.CurrentValue or self.Parent:GetAlpha()
    end,

    Reset = function(self)
        self.Timer = 0
        self.CurrentValue = self.StartAlpha or self.Parent:GetAlpha()
        self.Parent:SetAlpha(self.CurrentValue)
        self:Callback("OnReset")
    end,

    Finish = function(self)
        self:Stop()
        self.CurrentValue = self.EndAlpha
        self.Parent:SetAlpha(self.EndAlpha)
    end,

    SetScript = function(self, Handler, Func)
        if (LibAnimated.Callbacks[Handler]) then
            LibAnimated.Callbacks[Handler][self] = Func
        end
    end,

    Callback = function(self, Handler)
        if (LibAnimated.Callbacks[Handler] and LibAnimated.Callbacks[Handler][self]) then
            LibAnimated.Callbacks[Handler][self](self)
        end
    end,

    StartUpdating = function(self)
        for _, Frames in ipairs(LibAnimated.Running) do
            if (Frames == self) then 
                return 
            end
        end

        TableInsert(LibAnimated.Running, self)
    end,

    GetParent = function(self)
        return self.Parent
    end
}

LibAnimated.Constructors["Fade"] = function(Frame)
    Frame.Timer = 0
    Frame.StartAlpha = Frame.Parent:GetAlpha() or 1
    Frame.EndAlpha = Frame.TargetAlpha or 0
    Frame.DeltaAlpha = Frame.EndAlpha - Frame.StartAlpha

    for _, Frames in ipairs(LibAnimated.Running) do
        if (Frames == Frame) then
            return
        end
    end

    -- Insert Table
    TableInsert(LibAnimated.Running, Frame)

    if (not LibAnimated.Updater) then
        LibAnimated.Updater = CreateFrame("Frame")
        LibAnimated.Updater:SetScript("OnUpdate", function(_, Elapsed)
            for i = #LibAnimated.Running, 1, -1 do
                LibAnimated.Running[i]:Update(Elapsed, i)
            end
        end)
    end
end

local function FadeUpdate(Frame, DeltaTime, Index)
    Frame.Timer = Frame.Timer + DeltaTime

    if (Frame.Timer >= Frame.Duration) then
        TableRemove(LibAnimated.Running, Index)

        Frame.CurrentValue = Frame.EndAlpha
        Frame.Parent:SetAlpha(Frame.EndAlpha)
        Frame.Playing = false
        Frame.Stopped = true
        Frame:Callback("OnFinished")
    else
        Frame.CurrentValue = LibAnimated.Easing[Frame.Easing](Frame.Timer, Frame.StartAlpha, Frame.DeltaAlpha, Frame.Duration)
        Frame.Parent:SetAlpha(Frame.CurrentValue)
    end
end

function UI:CreateAnimationGroup(Parent)
    return {Parent = Parent, Animations = {}} 
end

function UI:CreateAnimation(Group, Style)
    if (next(LibAnimated.Lookup) == nil) then
        for Name, _ in pairs(LibAnimated.Constructors) do
            LibAnimated.Lookup[Lower(Name)] = Name
        end
    end

    local FoundKey = LibAnimated.Lookup[Lower(Style)]

    if (not FoundKey) then 
        return 
    end

    local AnimObject = {}

    for FuncName, Func in pairs(LibAnimated.Groups) do
        AnimObject[FuncName] = Func
    end

    AnimObject.Parent = Group.Parent
    AnimObject.Type = FoundKey
    AnimObject.Duration = 0.25
    AnimObject.Easing = "LinearEase"
    AnimObject.TargetAlpha = 0
    AnimObject.CurrentValue = AnimObject.Parent:GetAlpha() or 1
    AnimObject.Update = FadeUpdate
    AnimObject.Playing = false
    AnimObject.Paused = false
    AnimObject.Stopped = false
    AnimObject.Group = Group

    -- Insert Table
    TableInsert(Group.Animations, AnimObject)

    return AnimObject
end