local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitChannelDuration = UnitChannelDuration
local UnitCastingDuration = UnitCastingDuration
local UnitEmpoweredChannelDuration = UnitEmpoweredChannelDuration

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

    local NumPips = #StagePercentages -1

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

function NP:GetFrameForUnit(Unit)
    for Frame in next, NP.ActivePlates do
        if (Frame and Frame.Unit == Unit) then
            return Frame
        end
    end

    return nil
end

function NP:CastStarted(Event, Unit)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar or not Unit) then
        return
    end

    -- Cache Names
    local Name, Text, Icon, StartTime, EndTime, IsTradeSkill, CastID, NotInterruptible, SpellID = UnitCastingInfo(Unit)

    -- Normal Casts
    if (Name) then
        Castbar.Casting = true

        Castbar.Duration = UnitCastingDuration(Unit)
        Castbar.Direction = UI.DirectionElapsed
    else
        -- Channel / Empower Casts
        local Empowered
        Name, Text, Icon, StartTime, EndTime, IsTradeSkill, NotInterruptible, SpellID, Empowered, _, CastID = UnitChannelInfo(Unit)
        
        if (Empowered) then
            Castbar.Empower = true

            Castbar.Duration = UnitEmpoweredChannelDuration(Unit)
            Castbar.Direction = UI.DirectionElapsed
        else
            Castbar.Channel = true

            Castbar.Duration = UnitChannelDuration(Unit)
            Castbar.Direction = UI.DirectionRemaining
        end
    end

    if (not Name) then
        if (Event ~= "PLAYER_TARGET_CHANGED") then
            -- Reset CastBar
            NP:ResetCastBar(Castbar)
            
            -- Call Fade
            Castbar:SetAlpha(0)
        end

        return
    end

    -- Cache
    Castbar.NotInterruptible = NotInterruptible
    Castbar.CastID = CastID
    Castbar.SpellID = SpellID
    Castbar.SpellName = Text
    Castbar.CastDelayed = 0

    -- Set Values
    Castbar:SetTimerDuration(Castbar.Duration, UI.SmoothBars, Castbar.Direction)

    -- Interrupt Color
    Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(NotInterruptible, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        Castbar.Text:SetText(Text)
    end

    -- Create EmpowerPips
    if (Castbar.Empower) then
        NP:SetupEmpowerPips(Castbar, UnitEmpoweredStagePercentages(Unit))
    end

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, NP.FadeInTime, Castbar:GetAlpha(), 1)
end

function NP:CastSucceeded(Event, Unit, _, _, CastID)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar or not Unit) then
        return
    end

    if (CastID and Castbar.CastID and Castbar.CastID ~= CastID) then
        return
    end

    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarSucceededColor))

    -- Reset CastBar
    NP:ResetCastBar(Castbar)
    
    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastStopped(Event, Unit, _, _, ...)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar or not Unit) then
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

    if (CastID and Castbar.CastID and Castbar.CastID ~= CastID) then
        return
    end

    if (InterruptedBy) then
        -- Set Text
        Castbar.Text:SetText(INTERRUPTED)

        -- Set Values
        Castbar:SetMinMaxValues(0, 1, UI.SmoothBars)
        Castbar:SetValue(1, UI.SmoothBars)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    end

    -- Reset CastBar
    NP:ResetCastBar(Castbar)
    
    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastFailed(Event, Unit, _, _, ...)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar or not Unit) then
        return
    end

    local CastID, InterruptedBy

    if (Event == "UNIT_SPELLCAST_INTERRUPTED") then
        InterruptedBy, CastID = ...
    elseif (Event == "UNIT_SPELLCAST_FAILED") then
        CastID = ...
    end

    if (CastID and Castbar.CastID and Castbar.CastID ~= CastID) then
        return
    end

    -- Set Text
    Castbar.Text:SetText(Event == "UNIT_SPELLCAST_FAILED" and FAILED or INTERRUPTED)

    -- Set Values
    Castbar:SetMinMaxValues(0, 1, UI.SmoothBars)
    Castbar:SetValue(1, UI.SmoothBars)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))

    -- Reset CastBar
    NP:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastUpdated(Event, Unit, _, _, CastID)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar or not Unit) then
        return
    end

    if (CastID and Castbar.CastID and Castbar.CastID ~= CastID) then
        return
    end

    -- Cache Names
    local Name, Icon, StartTime, EndTime

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_DELAYED") then
        Name, _, _, StartTime, EndTime = UnitCastingInfo(Unit)

        Castbar.Duration = UnitChannelDuration(Unit)
        Castbar.Direction = UI.DirectionElapsed
    else
        -- Channel Casts / Empower Casts
        Name, _, _, StartTime, EndTime = UnitChannelInfo(Unit)

        if (Event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
            Castbar.Duration = UnitEmpoweredChannelDuration(Unit)
            Castbar.Direction = UI.DirectionElapsed
        else
            Castbar.Duration = UnitChannelDuration(Unit)
            Castbar.Direction = UI.DirectionRemaining
        end
    end

    if (not Name) then
        return
    end

    -- Set Values
    Castbar:SetTimerDuration(Castbar.Duration, UI.SmoothBars, Castbar.Direction)
end

function NP:CastNonInterruptable(Event, Unit)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar or not Unit) then   
        return
    end

    Castbar.NotInterruptible = Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"

    Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(Castbar.NotInterruptible, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))
end

function NP.CastBarOnUpdate(Castbar)
    if (not Castbar) then
        return
    end

    if (not Castbar.Casting or not Castbar.Channel or not Castbar.Empower) then
        return
    end

    if (Castbar.Time) then
        local DurationObject = Castbar:GetTimerDuration()

        if (DurationObject) then
            if (Castbar.CastDelayed ~= 0) then
                local Duration = Castbar:GetTimerDuration():GetElapsedDuration()
                local Total = Castbar:GetTimerDuration():GetTotalDuration()
                
                Castbar.Time:SetFormattedText("%.1fs/%.1fs |cffff0000%s%.2f|r", Duration, Total, Castbar.Channel and "-" or "+", Castbar.CastDelayed)
            else
                local Duration = Castbar:GetTimerDuration():GetElapsedDuration()
                local Total = Castbar:GetTimerDuration():GetTotalDuration()

                Castbar.Time:SetFormattedText("%.1fs/%.1fs", Duration, Total)
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

    if (Castbar.StagePips) then
        for _, Pip in ipairs(Castbar.StagePips) do
            Pip:Hide()
        end
    end

    Castbar:SetScript("OnUpdate", nil)
end

-- CREATE CASTBAR

function NP:CreateCastBar(Frame)
    local Width, Height = unpack(DB.Global.Nameplates.Size)

    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(Width, Height+2)
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
    CastbarTime:Point("RIGHT", Castbar, -2, -8)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = InvisFrameCastbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 2, -8)
    CastbarText:SetFontTemplate("Default")
    
    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText

    -- Call On Update
    Castbar:SetScript("OnUpdate", NP.CastBarOnUpdate)
end