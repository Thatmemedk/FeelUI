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

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

function UF:CastStarted(Event, Unit)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    -- Cache Names
    local Name, Icon, StartTime, EndTime, Interrupt, CastID, SpellID, Empowered

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_START") then
        Name, _, Icon, StartTime, EndTime, _, CastID, Interrupt, SpellID = UnitCastingInfo(Unit)

        Castbar.Duration = UnitCastingDuration(Unit)
        Castbar.Direction = UI.DirectionElapsed
    else
        -- Channel / Empower Casts
        Name, _, Icon, StartTime, EndTime, _, Interrupt, SpellID, Empowered, _, CastID = UnitChannelInfo(Unit)
        
        if (Empowered) then
            Event = "UNIT_SPELLCAST_EMPOWER_START"

            Castbar.Duration = UnitEmpoweredChannelDuration(Unit)
            Castbar.Direction = UI.DirectionElapsed
        else
            Event = "UNIT_SPELLCAST_CHANNEL_START"

            Castbar.Duration = UnitChannelDuration(Unit)
            Castbar.Direction = UI.DirectionRemaining
        end
    end

    if (not Name) then
        return
    end

    -- Update Events
    Castbar.Casting = (Event == "UNIT_SPELLCAST_START")
    Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_START")
    Castbar.Empower = (Event == "UNIT_SPELLCAST_EMPOWER_START")

    -- Cache
    Castbar.Interrupt = Interrupt
    Castbar.CastID = CastID
    Castbar.SpellID = SpellID

    -- Set Values
    Castbar:SetTimerDuration(Castbar.Duration, UI.SmoothBars, Castbar.Direction)

    -- Interrupt Color
    Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(Interrupt, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        if (Unit == "player") then
            Castbar.Text:SetText(UI:UTF8Sub(Name, 22, true))
        else
            Castbar.Text:SetText(Name)
        end
    end

    -- Safe Zone
    if (Unit == "player") then
        -- Convert milliseconds to seconds
        StartTime = StartTime / 1000
        EndTime = EndTime / 1000

        -- Cache
        Castbar.Max = EndTime - StartTime
        Castbar.StartTime = StartTime
        Castbar.EndTime = EndTime

        if (Castbar.SafeZone) then
            local _, _, MSHome, MSWorld = GetNetStats()
            local MS = (MSHome + MSWorld) / 2
            local Latency = MS / 1000
            local Ratio = math.min(Latency / Castbar.Max, 1)
            local Width = Castbar:GetWidth() * Ratio

            Castbar.SafeZone:Show()
            Castbar.SafeZone:ClearAllPoints()
            Castbar.SafeZone:Width(Width)

            Castbar.SafeZoneText:ClearAllPoints()
            Castbar.SafeZoneText:SetText(string.format("%.0f", MS).."ms")

            if (Castbar.Channel) then
                Castbar.SafeZoneText:Point("LEFT", Castbar, "BOTTOMLEFT", 0, 0)
                Castbar.SafeZone:Point("TOPLEFT", Castbar, "TOPLEFT")
                Castbar.SafeZone:Point("BOTTOMLEFT", Castbar, "BOTTOMLEFT")
            else
                Castbar.SafeZoneText:Point("RIGHT", Castbar, "BOTTOMRIGHT", 0, 0)
                Castbar.SafeZone:Point("TOPRIGHT", Castbar, "TOPRIGHT")
                Castbar.SafeZone:Point("BOTTOMRIGHT", Castbar, "BOTTOMRIGHT")
            end
        end
    end

    -- Create EmpowerPips
    if (Castbar.Empower) then
        UF:SetupEmpowerPips(Castbar, UnitEmpoweredStagePercentages(Unit))
    end

    -- Call On Update
    if (Castbar.Casting or Castbar.Channel or Castbar.Empower) then
        Castbar:SetScript("OnUpdate", UF.OnUpdate)
    else
        -- Stop Update
        Castbar:SetScript("OnUpdate", nil)
    end

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 1)
end

function UF:CastStopped(Event, Unit, _, _, ...)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        -- Reset CastBar
        UF:ResetCastBar(Castbar)
        
        -- Call Fade
        UI:UIFrameFadeOut(Castbar, UF.CastHoldTime, Castbar:GetAlpha(), 0)
    end
end

function UF:CastFailed(Event, Unit, _, _, ...)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        return
    end

    -- Update Events
    if (Event == "UNIT_SPELLCAST_FAILED") then
        Castbar.Text:SetText(FAILED)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    elseif (Event == "UNIT_SPELLCAST_INTERRUPTED") then
        Castbar.Text:SetText(INTERRUPTED)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    end

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

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
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

    -- Update Events
    Castbar.Casting = (Event == "UNIT_SPELLCAST_DELAYED")
    Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_UPDATE")
    Castbar.Empower = (Event == "UNIT_SPELLCAST_EMPOWER_UPDATE")

    Castbar:SetTimerDuration(Castbar.Duration, UI.SmoothBars, Castbar.Direction)
end

function UF:CastNonInterruptable(Event, Unit)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    -- Update Events
    if (Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(Castbar.Interrupt, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))
    end
end

function UF.OnUpdate(Castbar)
    local Duration = Castbar:GetTimerDuration():GetElapsedDuration()
    local Total = Castbar:GetTimerDuration():GetTotalDuration()
    Castbar.Time:SetFormattedText("%.1fs/%.1fs", Duration, Total)
end

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

function UF:ResetCastBar(Castbar)
    -- Reset Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.Interrupt = nil
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

-- CREATE CASTBARS

function UF:CreatePlayerCastbar(Frame)
    local Castbar = CreateFrame("StatusBar", nil, _G.UIParent)
    Castbar:Size(222, 26)
    Castbar:Point(unpack(DB.Global.UnitFrames.CastBarPlayerPoint))
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)
    
    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarIcon:Size(38, 26)
    CastbarIcon:Point("RIGHT", Castbar, "LEFT", -4, 0)
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
    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(228, 20) 
    Castbar:Point("BOTTOM", Frame, 0, -22)
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
    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(204, 20)
    Castbar:Point("BOTTOM", Frame, 0, -22)
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
    CastbarTime:Point("RIGHT", Castbar, -8, 0)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 8, 0)
    CastbarText:SetFontTemplate("Default")
    
    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
end