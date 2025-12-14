local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CastStarted(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    local Name, Icon, StartTime, EndTime, Interrupt, EmpowerStages

    -- Try normal cast first
    if (Event == "UNIT_SPELLCAST_START") then
        Name, _, Icon, StartTime, EndTime, _, _, Interrupt = UnitCastingInfo(Unit)
    end

    -- Fallback to channel / empower if normal cast is nil
    if (not Name) then
        Name, _, Icon, StartTime, EndTime, _, Interrupt, _, _, EmpowerStages = UnitChannelInfo(Unit)
        
        -- Dynamically set the event
        if (Unit == "player" and EmpowerStages and EmpowerStages > 0) then
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
    Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_START")
    Castbar.Empower = (Event == "UNIT_SPELLCAST_EMPOWER_START")
    Castbar.Interrupt = Interrupt

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        Castbar.Text:SetText(Name)
    end

    if (Unit == "player") then
        -- Empower
        if (Castbar.Empower) then
            EndTime = EndTime + GetUnitEmpowerHoldAtMaxTime(Unit)
        end

        -- Convert milliseconds to seconds
        EndTime = EndTime / 1000
        StartTime = StartTime / 1000

        -- Cache
        Castbar.Max = EndTime - StartTime
        Castbar.StartTime = StartTime
        Castbar.EndTime = EndTime
        Castbar.CastDelayed = 0
        Castbar.CastHold = 0

        if (Castbar.Channel) then
            Castbar.Duration = EndTime - GetTime()
        else
            Castbar.Duration = GetTime() - StartTime
        end

        -- Set Values
        Castbar:SetMinMaxValues(0, Castbar.Max)
        Castbar:SetValue(Castbar.Duration)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))

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

        -- Call On Update
        Castbar:SetScript("OnUpdate", UF.CastBarOnUpdate)
    else
        if (Castbar.Channel) then
            Castbar.Duration = UnitChannelDuration(Unit)

            Castbar:SetReverseFill(true)
            Castbar:SetStatusBarColor(unpack(DB.Global.General.BackdropColor))
            Castbar:SetBackdropColorTemplate(unpack(DB.Global.UnitFrames.CastBarColor))
        else
            Castbar.Duration = UnitCastingDuration(Unit)

            Castbar:SetReverseFill(false)
            Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
            Castbar:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))
        end

        -- Set Values
        Castbar:SetTimerDuration(Castbar.Duration)

        -- Call On Update
        Castbar:SetScript("OnUpdate", UF.OnUpdate)
    end

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 1)
end

function UF:CastStopped(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    -- Clear Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.Interrupt = nil

    if (Unit == "player") then
        -- Set Value
        Castbar:SetMinMaxValues(0, 1)
        Castbar:SetValue(1)
    end

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
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
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))
    elseif (Event == "UNIT_SPELLCAST_INTERRUPTED") then
        Castbar.Text:SetText(INTERRUPTED)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))
    else
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
    end

    Castbar.CastHold = Castbar.CastHold or 0

    -- Clear Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.Interrupt = nil

    if (Unit == "player") then
        -- Set Value
        Castbar:SetValue(1)
    end

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
end

function UF:CastNonInterruptable(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    if (Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))
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
    local Value

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

    if (Unit == "player") then
        -- Empower
        if (Castbar.Empower) then
            EndTime = EndTime + GetUnitEmpowerHoldAtMaxTime(Unit)
        end

        -- Convert milliseconds to seconds
        StartTime = StartTime / 1000 
        EndTime = EndTime / 1000 

        if (Castbar.Channel) then
            Value = Castbar.StartTime - StartTime
            Castbar.Duration = EndTime - GetTime()
        else
            Value = StartTime - Castbar.StartTime
            Castbar.Duration = GetTime() - StartTime
        end

        if (Value < 0) then 
            Value = 0 
        end

        -- Cache
        Castbar.Max = EndTime - StartTime
        Castbar.StartTime = StartTime
        Castbar.EndTime = EndTime
        Castbar.CastDelayed = Castbar.CastDelayed + Value

        -- Set Values
        Castbar:SetMinMaxValues(0, Castbar.Max or 1)
        Castbar:SetValue(Castbar.Duration or 1)
    else
        if (Castbar.Channel) then
            Castbar.Duration = UnitChannelDuration(Unit)

            Castbar:SetReverseFill(true)
            Castbar:SetStatusBarColor(unpack(DB.Global.General.BackdropColor))
            Castbar:SetBackdropColorTemplate(unpack(DB.Global.UnitFrames.CastBarColor))
        else
            Castbar.Duration = UnitCastingDuration(Unit)

            Castbar:SetReverseFill(false)
            Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
            Castbar:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))
        end

        -- Set Values
        Castbar:SetTimerDuration(Castbar.Duration)
    end
end

function UF:CastBarOnUpdate(Elapsed)
    local Castbar = self

    if (Castbar.Casting or Castbar.Channel or Castbar.Empower) then
        if (Castbar.Casting or Castbar.Empower) then
            Castbar.Duration = Castbar.Duration + Elapsed

            if (Castbar.Duration >= Castbar.Max) then
                -- Clear Cache
                Castbar.Casting = nil
                Castbar.Channel = nil
                Castbar.Empower = nil
                Castbar.Interrupt = nil

                -- Call On Update
                Castbar:SetScript("OnUpdate", nil)

                -- Call Fade
                UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)

                return
            end
        else
            Castbar.Duration = Castbar.Duration - Elapsed

            if (Castbar.Duration <= 0) then
                -- Clear Cache
                Castbar.Casting = nil
                Castbar.Channel = nil
                Castbar.Empower = nil
                Castbar.Interrupt = nil

                -- Call On Update
                Castbar:SetScript("OnUpdate", nil)

                -- Call Fade
                UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)

                return
            end
        end

        if (Castbar.Time) then
            if (Castbar.CastDelayed ~= 0) then
                Castbar.Time:SetFormattedText("%.1f|cffff0000%s%.2f|r", Castbar.Duration, Castbar.Casting and "+" or "-", Castbar.CastDelay)
            else
                Castbar.Time:SetFormattedText("%.1f / %.1f", Castbar.Duration, Castbar.Max)
            end
        end

        Castbar:SetMinMaxValues(0, Castbar.Max)
        Castbar:SetValue(Castbar.Duration)

    elseif (Castbar.CastHold and Castbar.CastHold > 0) then
        Castbar.CastHold = Castbar.CastHold - Elapsed
    else
        -- Clear Cache
        Castbar.Casting = nil
        Castbar.Channel = nil
        Castbar.Empower = nil
        Castbar.Interrupt = nil

        -- Call On Update
        Castbar:SetScript("OnUpdate", nil)

        -- Call Fade
        UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
    end
end

function UF.OnUpdate(Castbar)
    Castbar.Time:SetFormattedText("%.1fs", Castbar:GetTimerDuration():GetRemainingDuration())
end

function UF:ClearCastbar(Unit)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then 
        return 
    end

    -- Clear Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.Interrupt = nil
    Castbar.CastDelayed = 0
    Castbar.CastHold = 0

    -- Call On Update
    Castbar:SetScript("OnUpdate", nil)

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
    Frame.Castbar.CastHold = 0
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
    Frame.Castbar.CastHold = 0
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
    Frame.Castbar.CastHold = 0
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
    Frame.Castbar.CastHold = 0
end

function UF:CreateBossCastbar(Frame)
    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(204, 20)
    Castbar:Point("BOTTOM", Frame, 0, -22)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    
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
    Frame.Castbar.CastHold = 0
end