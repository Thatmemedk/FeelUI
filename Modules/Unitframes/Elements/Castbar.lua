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
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then 
        return 
    end

    -- Cache Names
    local Name, Icon, StartTime, EndTime, Interrupt, CastID, SpellID, EmpowerStages

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_START") then
        Name, _, Icon, StartTime, EndTime, _, CastID, Interrupt, SpellID = UnitCastingInfo(Unit)
    end

    -- Channel / Empower Casts
    if (not Name) then
        Name, _, Icon, StartTime, EndTime, _, Interrupt, SpellID, _, EmpowerStages = UnitChannelInfo(Unit)
        
        if (EmpowerStages) then
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

    -- Cache
    Castbar.Interrupt = Interrupt
    Castbar.CastID = CastID
    Castbar.SpellID = SpellID

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        Castbar.Text:SetText(Name)
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

    if (Castbar.Channel) then
        Castbar.Duration = UnitChannelDuration(Unit)

        Castbar:SetReverseFill(true)
    else
        Castbar.Duration = UnitCastingDuration(Unit)
    
        Castbar:SetReverseFill(false)
    end

    -- Set Values
    Castbar:SetTimerDuration(Castbar.Duration)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))

    -- Call On Update
    Castbar:SetScript("OnUpdate", UF.OnUpdate)

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 1)
end

function UF:CastStopped(Unit, Event)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        UF:ResetCastBar(Castbar)
    end
end

function UF:CastFailed(Unit, Event)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        return
    end

    -- Update Events
    Castbar.Text:SetText(Event == "UNIT_SPELLCAST_FAILED" and FAILED or INTERRUPTED)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))

    -- Reset CastBar
    UF:ResetCastBar(Castbar)
end

function UF:CastNonInterruptable(Unit, Event)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
        return
    end

    -- Update Events
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

function UF.OnUpdate(Castbar)
    local Duration = Castbar:GetTimerDuration():GetElapsedDuration()
    local Total = Castbar:GetTimerDuration():GetTotalDuration()

    Castbar.Time:SetFormattedText("%.1fs/%.1fs", Duration, Total)
end

function UF:ResetCastBar(Castbar)
    if (not Castbar) then    
        return
    end

    -- Reset Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Interrupt = nil
    Castbar.CastID = nil
    Castbar.SpellID = nil

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
end

function UF:ClearCastBarOnUnit(Unit)
    local Castbar = self.Frames[Unit] and self.Frames[Unit].Castbar

    if (not Castbar) then
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