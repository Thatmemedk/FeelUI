local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitChannelDuration = UnitChannelDuration
local UnitCastingDuration = UnitCastingDuration
local UnitEmpoweredChannelDuration = UnitEmpoweredChannelDuration
local UnitEmpoweredStagePercentages = UnitEmpoweredStagePercentages

-- WoW Globals
local C_ClassColor_GetClassColor = _G.C_ClassColor.GetClassColor

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

function NP:CreateEmpowerPips(Castbar, NumStages)
    Castbar.StagePips = Castbar.StagePips or {}

    for i = 1, NumStages do
        if (not Castbar.StagePips[i]) then
            local Pip = CreateFrame("Frame", nil, Castbar, "CastingBarFrameStagePipTemplate")
            Pip:Hide()

            Pip.Texture = Pip:CreateTexture(nil, "BACKGROUND", nil, 7)
            Pip.Texture:SetTexture(Media.Global.Texture)
            Pip.Texture:SetAllPoints()

            Pip.Overlay = CreateFrame("Frame", nil, Pip)
            Pip.Overlay:SetFrameLevel(Pip:GetFrameLevel() - 1)
            Pip.Overlay:SetInside(Pip.Texture)
            Pip.Overlay:SetTemplate()

            if (Pip.FillPip) then
                Pip.FillPip:Hide()
            end

            if (Pip.BasePip) then
                Pip.BasePip:SetAlpha(0)
            end

            Castbar.StagePips[i] = Pip
        end
    end

    for i = NumStages + 1, #Castbar.StagePips do
        Castbar.StagePips[i]:Hide()
    end
end

function NP:SetupEmpowerPips(Castbar, StagePercentages)
    if (type(StagePercentages) ~= "table") then
        return
    end

    local NumPips = #StagePercentages - 1

    if (NumPips <= 0) then
        return
    end

    local TotalStages = NumPips + 1
    local PipWidth = 6

    -- Create Pip Frame
    self:CreateEmpowerPips(Castbar, NumPips)

    for i = 1, NumPips do
        local Pip = Castbar.StagePips[i]
        local OffsetX = (i / TotalStages) * Castbar:GetWidth()
        local Color = UI.Colors.EmpowerStagesColors[i]

        Pip:ClearAllPoints()
        Pip:Width(PipWidth)
        Pip:Point("TOP", Castbar, "TOPLEFT", OffsetX, 0)
        Pip:Point("BOTTOM", Castbar, "BOTTOMLEFT", OffsetX, 0)
        Pip:Show()

        if (Color) then
            Pip.Texture:SetVertexColor(Color.r, Color.g, Color.b)
        end

        Pip.Stage = i
    end
end

function NP:GetInterruptedText(Castbar, InterruptedBy)
    local InterrupterName = InterruptedBy and UnitNameFromGUID(InterruptedBy)

    if (not InterrupterName) then
        return string.format("%s", INTERRUPTED)
    end

    local _, ClassFileName = UnitClassFromGUID(InterruptedBy)
    local ClassColor = C_ClassColor_GetClassColor(ClassFileName)

    if (ClassColor) then
        InterrupterName = ClassColor:WrapTextInColorCode(InterrupterName)
    end

    return string.format("%s - %s", INTERRUPTED, InterrupterName)
end

function NP:UpdateCastTarget(Castbar, Unit)
    local _, CastingInfoText = UnitCastingInfo(Unit)
    local _, ChannelInfoText = UnitChannelInfo(Unit)

    if (not CastingInfoText or ChannelInfoText) then
        Castbar.TargetName = nil
        Castbar.TargetClass = nil

        if (Castbar.Text) then
            Castbar.Text:SetText(Castbar.SpellName or "")
        end

        return
    end

    if (UnitSpellTargetName) then
        Castbar.TargetName = UnitSpellTargetName(Unit)
        Castbar.TargetClass = UnitSpellTargetClass(Unit)
    else
        Castbar.TargetName = UnitName(Unit .. "target")
        Castbar.TargetClass = UnitClassBase(Unit .. "target")
    end

    if (not Castbar.Text) then
        return
    end

    local Text = Castbar.SpellName or ""

    if (Castbar.TargetName) then
        local Target = Castbar.TargetName
        local Color = C_ClassColor_GetClassColor(Castbar.TargetClass)

        if (Color) then
            Target = Color:WrapTextInColorCode(Target)
        end

        Text = string.format("%s - %s", Text, Target)
    end

    Castbar.Text:SetText(Text)
end

function NP:CastStarted(Event, Unit)
    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    -- Reset CastBar
    NP:ResetCastBar(Castbar)

    -- Cache Names
    local Direction, Duration = Enum.StatusBarTimerDirection.ElapsedTime
    local Name, Text, Icon, StartTime, EndTime, _, _, NotInterruptible, SpellID, CastID = UnitCastingInfo(Unit)

    if (Name) then
        Castbar.Casting = true

        Duration = UnitCastingDuration(Unit)
    else
        local IsEmpowered

        Name, Text, Icon, StartTime, EndTime, _, NotInterruptible, SpellID, IsEmpowered, _, CastID = UnitChannelInfo(Unit)

        if (IsEmpowered) then
            Castbar.Empower = true

            Duration = UnitEmpoweredChannelDuration(Unit)
        else
            Castbar.Channel = true

            Duration = UnitChannelDuration(Unit)
            Direction = Enum.StatusBarTimerDirection.RemainingTime
        end
    end

    if (not Name) then
        return
    end

    -- Cache
    Castbar.NotInterruptible = NotInterruptible
    Castbar.CastID = CastID
    Castbar.SpellID = SpellID
    Castbar.SpellName = Text
    Castbar.SpellTarget = UnitSpellTargetName(Unit)
    Castbar.CastDelayed = 0

    -- Set Values
    Castbar:SetTimerDuration(Duration, UI.SmoothBars, Direction)

    -- Interrupt Color
    Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(NotInterruptible, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        Castbar.Text:SetText(Text)
        NP:UpdateCastTarget(Castbar, Unit)
    end

    -- Create EmpowerPips
    if (Castbar.Empower) then
        NP:SetupEmpowerPips(Castbar, UnitEmpoweredStagePercentages(Unit))
    end

    -- Call On Update
    Castbar:SetScript("OnUpdate", NP.CastBarOnUpdate)

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, NP.FadeInTime, Castbar:GetAlpha(), 1)
end

function NP:CastSucceeded(Event, Unit)
    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarSucceededColor))
end

function NP:CastStopped(Event, Unit, _, _, ...)
    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    local CastID, InterruptedBy

    if (Event == "UNIT_SPELLCAST_STOP") then
        CastID = ...
    elseif (Event == "UNIT_SPELLCAST_CHANNEL_STOP") then
        InterruptedBy, CastID = ...
    elseif (Event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        _, InterruptedBy, CastID = ...
    end

    if (not CastID or Castbar.CastID ~= CastID) then
        return
    end

    if (InterruptedBy) then
        -- Set Text
        Castbar.Text:SetText(self:GetInterruptedText(Castbar, InterruptedBy))

        -- Set Values
        Castbar:SetMinMaxValues(0, 1)
        Castbar:SetValue(1, UI.SmoothBars)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    end

    -- Reset CastBar
    NP:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastFailed(Event, Unit, _, _, ...)
    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    local CastID, InterruptedBy

    if (Event == "UNIT_SPELLCAST_FAILED") then
        CastID = ...
    end

    if (not CastID or Castbar.CastID ~= CastID) then
        return
    end

    -- Set Text
    Castbar.Text:SetText(FAILED)

    -- Set Values
    Castbar:SetMinMaxValues(0, 1)
    Castbar:SetValue(1, UI.SmoothBars)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))

    -- Reset CastBar
    NP:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastInterrupted(Event, Unit, _, _, ...)
    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    local CastID, InterruptedBy

    if (Event == "UNIT_SPELLCAST_INTERRUPTED") then
        InterruptedBy, CastID = ...
    end

    if (not CastID or Castbar.CastID ~= CastID) then
        return
    end

    -- Set Text
    Castbar.Text:SetText(self:GetInterruptedText(Castbar, InterruptedBy))

    -- Set Values
    Castbar:SetMinMaxValues(0, 1)
    Castbar:SetValue(1, UI.SmoothBars)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))

    -- Reset CastBar
    NP:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastUpdated(Event, Unit, _, _, CastID)
    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    if (not CastID or Castbar.CastID ~= CastID) then
        return
    end

    local Direction, Duration, Name, StartTime, _ = Enum.StatusBarTimerDirection.ElapsedTime

    if (Event == "UNIT_SPELLCAST_DELAYED") then
        Name, _, _, StartTime = UnitCastingInfo(Unit)
        Duration = UnitCastingDuration(Unit)
    else
        Name, _, _, StartTime = UnitChannelInfo(Unit)

        if (Event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
            Duration = UnitEmpoweredChannelDuration(Unit)
        else
            Duration = UnitChannelDuration(Unit)
            Direction = Enum.StatusBarTimerDirection.RemainingTime
        end
    end

    if (not Name) then
        return
    end

    if (Unit == "player") then
        -- Convert milliseconds to seconds
        StartTime = StartTime / 1000

        local Delay

        if (Castbar.Channel) then
            Delay = Castbar.StartTime - StartTime
        else
            Delay = StartTime - Castbar.StartTime
        end

        if (Delay < 0) then
            Delay = 0
        end

        Castbar.CastDelayed = Castbar.CastDelayed + Delay
    end

    -- Set Values
    Castbar:SetTimerDuration(Duration, UI.SmoothBars, Direction)
end

function NP:CastNonInterruptable(Event, Unit)
    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    Castbar.NotInterruptible = Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
    Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(Castbar.NotInterruptible, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))
end

function NP.CastBarOnUpdate(Castbar)
    if (not Castbar) then
        return
    end

    if not (Castbar.Casting or Castbar.Channel or Castbar.Empower) then
        return
    end

    if (Castbar.Time) then
        local DurationObject = Castbar:GetTimerDuration()

        if (DurationObject) then
            local Duration = DurationObject:GetElapsedDuration()
            local Total = DurationObject:GetTotalDuration()

            if (Castbar.CastDelayed ~= 0) then
                Castbar.Time:SetFormattedText("%.1fs |cffff0000%s%.2f|r", Duration, Castbar.Channel and "-" or "+", Castbar.CastDelayed)
            else
                Castbar.Time:SetFormattedText("%.1fs", Duration)
            end
        end
    end
end

function NP:ResetCastBar(Castbar)
    -- Reset Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.NotInterruptible = nil
    Castbar.CastID = nil
    Castbar.SpellID = nil
    Castbar.SpellTarget = nil
    Castbar.TargetName = nil
    Castbar.TargetClass = nil

    if (Castbar.StagePips) then
        for _, Pip in ipairs(Castbar.StagePips) do
            Pip:Hide()
        end
    end
end

function NP:CreateCastBar(Frame)
    if (Frame.Castbar) then
        return
    end

    local Width, Height = unpack(DB.Global.Nameplates.Size)

    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(Width, 20)
    Castbar:Point("BOTTOM", Frame, 0, -22)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)

    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarIcon:Size(36, 26)
    CastbarIcon:Point("LEFT", Castbar, "RIGHT", 4, 3)
    UI:KeepAspectRatio(CastbarIcon, CastbarIcon)

    local IconOverlay = CreateFrame("Frame", nil, Castbar)
    IconOverlay:SetInside(CastbarIcon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()

    local InvisFrameCastbar = CreateFrame("Frame", nil, Castbar)
    InvisFrameCastbar:SetFrameLevel(Castbar:GetFrameLevel() + 10)
    InvisFrameCastbar:SetInside()

    local CastbarTime = InvisFrameCastbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarTime:Point("RIGHT", Castbar, -4, -8)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = InvisFrameCastbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 4, -8)
    CastbarText:Point("RIGHT", CastbarTime, "LEFT", -4, 0)
    CastbarText:SetFontTemplate("Default")
    CastbarText:SetJustifyH("LEFT")
    CastbarText:SetJustifyV("MIDDLE")
    CastbarText:SetWordWrap(false)
    CastbarText:SetNonSpaceWrap(false)
    CastbarText:SetMaxLines(1)

    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
end