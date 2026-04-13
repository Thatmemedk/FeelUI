local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitChannelDuration = UnitChannelDuration
local UnitCastingDuration = UnitCastingDuration
local UnitEmpoweredChannelDuration = UnitEmpoweredChannelDuration
local UnitEmpoweredStagePercentages = UnitEmpoweredStagePercentages
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

function UF:CreateEmpowerPips(Castbar, NumStages)
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

function UF:SetupEmpowerPips(Castbar, StagePercentages)
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

function UF:CastStarted(Event, Unit)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

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
        if (Unit == "player") then
            Castbar.Text:SetText(UI:UTF8Sub(Text, 22, true))
        else
            Castbar.Text:SetText(Text)
        end
    end

    if (Unit == "player") then
        -- Convert milliseconds to seconds
        Castbar.StartTime = StartTime / 1000
    
        if (Castbar.Empower) then
            Castbar.EndTime = (EndTime + GetUnitEmpowerHoldAtMaxTime(Unit)) / 1000
        else
            Castbar.EndTime = EndTime / 1000
        end
    end

    if (Castbar.SafeZone and Unit == "player") then
        local _, _, MSHome, MSWorld = GetNetStats()
        local MS = (MSHome + MSWorld) / 2
        local Latency = MS / 1000

        if (Castbar.Empower) then
            EndTime = EndTime + GetUnitEmpowerHoldAtMaxTime(Unit)
        end

        local Ratio = (MSWorld) / (EndTime - StartTime)

        if (Ratio > 1) then
            Ratio = 1
        end

        local Width = Castbar:GetWidth() * Ratio

        Castbar.SafeZone:Show()
        Castbar.SafeZone:ClearAllPoints()
        Castbar.SafeZone:SetWidth(Width)

        Castbar.SafeZoneText:ClearAllPoints()
        Castbar.SafeZoneText:SetText(string.format("%.0fms", MS))
        Castbar.SafeZoneText:Show()

        if (Castbar.Channel) then
            Castbar.SafeZone:Point("TOPRIGHT", Castbar, "TOPRIGHT")
            Castbar.SafeZone:Point("BOTTOMRIGHT", Castbar, "BOTTOMRIGHT")

            Castbar.SafeZoneText:Point("RIGHT", Castbar, "BOTTOMRIGHT", 0, 0)
        else
            Castbar.SafeZone:Point("TOPLEFT", Castbar, "TOPLEFT")
            Castbar.SafeZone:Point("BOTTOMLEFT", Castbar, "BOTTOMLEFT")

            Castbar.SafeZoneText:Point("LEFT", Castbar, "BOTTOMLEFT", 0, 0)
        end
    end

    -- Create EmpowerPips
    if (Castbar.Empower) then
        UF:SetupEmpowerPips(Castbar, UnitEmpoweredStagePercentages(Unit))
    end

    -- Call On Update
    Castbar:SetScript("OnUpdate", UF.CastBarOnUpdate)  

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 1)
end

function UF:CastSucceeded(Event, Unit)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarSucceededColor))
end

function UF:CastStopped(Event, Unit, _, _, ...)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

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
        Castbar.Text:SetText(INTERRUPTED)

        -- Set Values
        Castbar:SetMinMaxValues(0, 1)
        Castbar:SetValue(1, UI.SmoothBars)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    end

    -- Reset CastBar
    UF:ResetCastBar(Castbar)
    
    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.CastHoldTime, Castbar:GetAlpha(), 0)
end

function UF:CastFailed(Event, Unit, _, _, ...)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

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
    UF:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.CastHoldTime, Castbar:GetAlpha(), 0)
end

function UF:CastInterrupted(Event, Unit, _, _, ...)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

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
    Castbar.Text:SetText(INTERRUPTED)

    -- Set Values
    Castbar:SetMinMaxValues(0, 1)
    Castbar:SetValue(1, UI.SmoothBars)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))

    -- Reset CastBar
    UF:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.CastHoldTime, Castbar:GetAlpha(), 0)
end

function UF:CastUpdated(Event, Unit, _, _, CastID)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

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

    Castbar:SetTimerDuration(Duration, UI.SmoothBars, Direction)
end

function UF:CastNonInterruptable(Event, Unit)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    Castbar.NotInterruptible = Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"

    Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(Castbar.NotInterruptible, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))
end

function UF.CastBarOnUpdate(Castbar)
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
                Castbar.Time:SetFormattedText("%.1fs/%.1fs |cffff0000%s%.2f|r", Duration, Total, Castbar.Channel and "-" or "+", Castbar.CastDelayed)
            else
                Castbar.Time:SetFormattedText("%.1fs/%.1fs", Duration, Total)
            end
        end
    end
end

function UF:ResetCastBar(Castbar)
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
end

function UF:ClearCastBarOnUnit(Unit)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    -- Reset CastBar
    UF:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
end

function UF:CheckUnitCasting(Unit)
    local Casting = UnitCastingInfo(Unit)
    local Channeling = UnitChannelInfo(Unit)

    if (Casting or Channeling) then
        UF:CastStarted("UNIT_SPELLCAST_START", Unit)
    else
        UF:ClearCastBarOnUnit(Unit)
    end
end

-- CREATE CASTBARS

function UF:CreatePlayerCastbar(Frame)
    if (Frame.Castbar) then
        return
    end
    
    local Castbar = CreateFrame("StatusBar", nil, _G.UIParent)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))

    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)

    if (DB.Global.UnitFrames.CastBarDetached) then
        Castbar:Size(222, 26)
        Castbar:Point(unpack(DB.Global.UnitFrames.CastBarPlayerPoint))

        CastbarIcon:Size(38, 26)
        CastbarIcon:Point("RIGHT", Castbar, "LEFT", -4, 0)
    else
        Castbar:Size(228, 20) 
        Castbar:Point("BOTTOM", Frame, 0, -24)

        CastbarIcon:Size(42, 32)
        CastbarIcon:Point("RIGHT", Castbar, "LEFT", -4, 5)
    end
    
    UI:KeepAspectRatio(CastbarIcon, CastbarIcon)

    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)

    local IconOverlay = CreateFrame("Frame", nil, Castbar)
    IconOverlay:SetInside(CastbarIcon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()
    
    local CastbarTime = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)    
    CastbarTime:Point("RIGHT", Castbar, -4, 0)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 4, 0)
    CastbarText:SetFontTemplate("Default")

    local CastbarSafeZone = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarSafeZone:SetTexture(Media.Global.Texture)
    CastbarSafeZone:SetVertexColor(1, 0.55, 0.15, 0.7)
    CastbarSafeZone:Hide()

    local CastbarSafeZoneText = Castbar.Backdrop.FrameRaised:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarSafeZoneText:SetFontTemplate("Default", 10)
    CastbarSafeZoneText:SetVertexColor(0.6, 0.6, 0.6)

    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
    Frame.Castbar.SafeZone = CastbarSafeZone
    Frame.Castbar.SafeZoneText = CastbarSafeZoneText
end

function UF:CreateTargetCastbar(Frame)
    if (Frame.Castbar) then
        return
    end

    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(228, 20) 
    Castbar:Point("BOTTOM", Frame, 0, -24)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)

    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarIcon:Size(42, 32)
    CastbarIcon:Point("LEFT", Castbar, "RIGHT", 4, 5)
    UI:KeepAspectRatio(CastbarIcon, CastbarIcon)
    
    local IconOverlay = CreateFrame("Frame", nil, Castbar)
    IconOverlay:SetInside(CastbarIcon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()
    
    local CastbarTime = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)    
    CastbarTime:Point("RIGHT", Castbar, -4, 0)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 4, 0)
    CastbarText:SetFontTemplate("Default")
    
    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
end

function UF:CreatePetCastbar(Frame)
    if (Frame.Castbar) then
        return
    end

    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(114, 20) 
    Castbar:Point("BOTTOM", Frame, 0, -22)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)

    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarIcon:Size(42, 32)
    CastbarIcon:Point("RIGHT", Castbar, "LEFT", -4, 5)
    UI:KeepAspectRatio(CastbarIcon, CastbarIcon)
    
    local IconOverlay = CreateFrame("Frame", nil, Castbar)
    IconOverlay:SetInside(CastbarIcon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()
    
    local CastbarTime = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)    
    CastbarTime:Point("RIGHT", Castbar, -4, 0)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 4, 0)
    CastbarText:SetFontTemplate("Default")
  
    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
end

function UF:CreateFocusCastbar(Frame)
    if (Frame.Castbar) then
        return
    end

    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(300, 32)
    Castbar:Point("CENTER", _G.UIParent, 0, -2)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)

    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarIcon:Size(42, 32)
    CastbarIcon:Point("RIGHT", Castbar, "LEFT", -4, 0)
    UI:KeepAspectRatio(CastbarIcon, CastbarIcon)
    
    local IconOverlay = CreateFrame("Frame", nil, Castbar)
    IconOverlay:SetInside(CastbarIcon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()
    
    local CastbarTime = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)    
    CastbarTime:Point("RIGHT", Castbar, -6, 0)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 6, 0)
    CastbarText:SetFontTemplate("Default")

    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
end

function UF:CreateBossCastbar(Frame)
    if (Frame.Castbar) then
        return
    end

    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(204, 20)
    Castbar:Point("BOTTOM", Frame, 0, -24)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)

    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarIcon:Size(42, 36)
    CastbarIcon:Point("LEFT", Castbar, "RIGHT", 4, 8)
    UI:KeepAspectRatio(CastbarIcon, CastbarIcon)
    
    local IconOverlay = CreateFrame("Frame", nil, Castbar)
    IconOverlay:SetInside(CastbarIcon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()
    
    local CastbarTime = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)    
    CastbarTime:Point("RIGHT", Castbar, -4, 0)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 4, 0)
    CastbarText:SetFontTemplate("Default")

    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
end