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
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

function UF:CastStarted(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    -- Cache Names
    local Name, Icon, StartTime, EndTime, Interrupt, EmpowerStages

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_START") then
        Name, _, Icon, StartTime, EndTime, _, _, Interrupt = UnitCastingInfo(Unit)
    end

    -- Channel / Empower Casts
    if (not Name) then
        Name, _, Icon, StartTime, EndTime, _, Interrupt, _, _, EmpowerStages = UnitChannelInfo(Unit)
        
        if (EmpowerStages and EmpowerStages > 0) then
            Event = "UNIT_SPELLCAST_EMPOWER_START"
        else
            Event = "UNIT_SPELLCAST_CHANNEL_START"
        end
    end

    if (not Name) then
        return
    end

    -- Update Events
    Castbar.Casting = (Event == "UNIT_SPELLCAST_START")
    Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_START" or Event == "UNIT_SPELLCAST_EMPOWER_START")

    -- Convert milliseconds to seconds
    StartTime = StartTime / 1000
    EndTime = EndTime / 1000

    -- Cache
    Castbar.Max = EndTime - StartTime
    Castbar.StartTime = StartTime
    Castbar.EndTime = EndTime
    Castbar.Interrupt = Interrupt

    -- Create Empower
    self:SetupEmpowerPips(Castbar, EmpowerStages)

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        Castbar.Text:SetText(Name)
    end

    -- Safe Zone
    if (Castbar.SafeZone) then
        local _, _, MSHome, MSWorld = GetNetStats()
        local MS = (MSHome + MSWorld) / 2
        local Latency = MS / 1000
        local Ratio = math.min(Latency / Castbar.Max, 1)
        local Width = Castbar:GetWidth() * Ratio

        Castbar.SafeZone:ClearAllPoints()
        Castbar.SafeZone:Width(Width)
        Castbar.SafeZone:Show()

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

    if (Castbar.Channel) then
        Castbar.DurationNew = UnitChannelDuration(Unit)
    else
        Castbar.DurationNew = UnitCastingDuration(Unit)
    end

    -- Set Values
    Castbar:SetTimerDuration(Castbar.DurationNew, UI.SmoothBars)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))

    -- Call On Update
    Castbar:SetScript("OnUpdate", UF.OnUpdate)

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 1)
end

function UF:CastStopped(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    -- Reset CastBar
    UF:ResetCastBar(Castbar)
end

function UF:CastFailed(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
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
end

function UF:CastNonInterruptable(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    if (Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
        Castbar.Icon:SetDesaturated(true)

        Castbar.Interrupt = true
    elseif (Event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
        Castbar.Icon:SetDesaturated(false)

        Castbar.Interrupt = nil
    end
end

function UF:CastUpdated(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    local Name, StartTime, EndTime

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_DELAYED") then
        Name, _, _, StartTime, EndTime = UnitCastingInfo(Unit)

        -- Channel Casts
    elseif (Event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or Event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        Name, _, _, StartTime, EndTime = UnitChannelInfo(Unit)
    end

    if (not Name) then 
        return 
    end
end

function UF.OnUpdate(Castbar)
    local Duration = Castbar:GetTimerDuration():GetElapsedDuration()
    local Total = Castbar:GetTimerDuration():GetTotalDuration()

    Castbar.Time:SetFormattedText("%.1fs / %.1fs", Duration, Total)
end

function UF:CreateEmpowerPips(Castbar)
    if (Castbar.StagePips) then
        return
    end

    Castbar.StagePips = {}

    for i = 1, 5 do
        local Pip = CreateFrame("Frame", nil, Castbar, "CastingBarFrameStagePipTemplate")
        Pip:Hide()

        Pip.Texture = Pip:CreateTexture(nil, "BORDER", nil, 7)
        Pip.Texture:SetTexture(Media.Global.Texture)
        Pip.Texture:SetInside()

        Pip.Overlay = CreateFrame("Frame", nil, Pip)
        Pip.Overlay:SetFrameLevel(Castbar:GetFrameLevel() - 1)
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

function UF:SetupEmpowerPips(Castbar, EmpowerStages)
    if (not EmpowerStages or EmpowerStages <= 0) then
        return
    end

    self:CreateEmpowerPips(Castbar)

    local Width = Castbar:GetWidth()
    local Height = Castbar:GetHeight()
    local TotalStages = EmpowerStages + 1

    for i, Pip in ipairs(Castbar.StagePips) do
        if (i <= EmpowerStages) then
            local Offset = Width * (i / TotalStages)

            Pip:ClearAllPoints()
            Pip:Point("TOP", Castbar, "TOPLEFT", Offset, 0)
            Pip:Point("BOTTOM", Castbar, "BOTTOMLEFT", Offset, 0)

            Pip.Stage = i

            local Color = UI.Colors.EmpowerStagesColors[i]
            Pip.Texture:SetVertexColor(Color.r, Color.g, Color.b)

            Pip:Show()
        else
            Pip:Hide()
        end
    end

    Castbar.EmpowerStages = EmpowerStages
end

function UF:ResetCastBar(Castbar)
    if (not Castbar or not Castbar.StagePips) then
        return
    end

    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.EmpowerStages = nil
    Castbar.Interrupt = nil

    for _, Pip in ipairs(Castbar.StagePips) do
        if (Pip.FillPip) then
            Pip.FillPip:Hide()
        end

        Pip:Hide()
        Pip.Stage = nil
    end

    UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
end

function UF:ClearCastBarOnUnit(Unit)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    -- Reset CastBar
    UF:ResetCastBar(Castbar)
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
    CastbarIcon:Size(42, 36)
    CastbarIcon:Point("RIGHT", Castbar, "LEFT", -4, 1)
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