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

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

function NP:GetFrameForUnit(Unit)
    for _, Plate in ipairs(C_NamePlate.GetNamePlates()) do
        local Frame = Plate.FeelUINameplatesEnemy

        if (Frame and Frame.Unit == Unit) then
            return Frame
        end
    end

    return nil
end

function NP:CastStarted(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)

    if (not Frame or not Frame.Castbar) then
        return
    end

    local Name, Icon, StartTime, EndTime, Interrupt

    -- Try normal cast first
    if (Event == "UNIT_SPELLCAST_START") then
        Name, _, Icon, StartTime, EndTime, _, _, Interrupt = UnitCastingInfo(Unit)
    end

    -- Fallback to channel / empower if normal cast is nil
    if (not Name) then
        Name, _, Icon, StartTime, EndTime, _, Interrupt = UnitChannelInfo(Unit)
        Event = "UNIT_SPELLCAST_CHANNEL_START"
    end

    if (not Name) then
        return
    end

    -- Update Events
    Frame.Castbar.Casting = (Event == "UNIT_SPELLCAST_START")
    Frame.Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_START")

    -- Icon
    if (Frame.Castbar.Icon) then
        Frame.Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Frame.Castbar.Text) then
        Frame.Castbar.Text:SetText(Name)
    end

    -- Interrupt
    --if (Interrupt) then
    --    Frame.Castbar.Interrupt = Interrupt
    --end

    if (Frame.Castbar.Channel) then
        Frame.Castbar.Duration = UnitChannelDuration(Unit)

        Frame.Castbar:SetReverseFill(true)
        Frame.Castbar:SetStatusBarColor(unpack(DB.Global.General.BackdropColor))
        Frame.Castbar:SetBackdropColorTemplate(unpack(DB.Global.UnitFrames.CastBarColor))
    else
        Frame.Castbar.Duration = UnitCastingDuration(Unit)

        Frame.Castbar:SetReverseFill(false)
        Frame.Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
        Frame.Castbar:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))
    end

    -- Set Values
    Frame.Castbar:SetTimerDuration(Frame.Castbar.Duration)

    -- Call On Update
    Frame.Castbar:SetScript("OnUpdate", NP.OnUpdate)

    -- Call Fade
    UI:UIFrameFadeIn(Frame.Castbar, NP.FadeInTime, Frame.Castbar:GetAlpha(), 1)
end

function NP:CastStopped(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)

    if (not Frame or not Frame.Castbar) then
        return
    end

    -- Clear Cache
    Frame.Castbar.Casting = nil
    Frame.Castbar.Channel = nil
    Frame.Castbar.Interrupt = nil

    -- Call Fade
    UI:UIFrameFadeOut(Frame.Castbar, NP.FadeInTime, Frame.Castbar:GetAlpha(), 0)
end

function NP:CastFailed(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)

    if (not Frame or not Frame.Castbar) then 
        return 
    end

    -- Update Events
    if (Event == "UNIT_SPELLCAST_FAILED") then
        Frame.Castbar.Text:SetText(FAILED)
        Frame.Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    elseif (Event == "UNIT_SPELLCAST_INTERRUPTED") then
        Frame.Castbar.Text:SetText(INTERRUPTED)
        Frame.Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    end

    -- Clear Cache
    Frame.Castbar.Casting = nil
    Frame.Castbar.Channel = nil
    Frame.Castbar.Interrupt = nil

    -- Call Fade
    UI:UIFrameFadeOut(Frame.Castbar, NP.FadeInTime, Frame.Castbar:GetAlpha(), 0)
end

function NP:CastNonInterruptable(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)

    if (not Frame or not Frame.Castbar) then
        return
    end

    if (Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        Frame.Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
        Frame.Castbar.Icon:SetDesaturated(true)

        Frame.Castbar.Interrupt = true
    elseif (Event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
        Frame.Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
        Frame.Castbar.Icon:SetDesaturated(false)

        Frame.Castbar.Interrupt = nil
    end
end

function NP:CastUpdated(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)

    if (not Frame or not Frame.Castbar) then
        return
    end

    local Name, StartTime, EndTime

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_DELAYED") then
        Name, _, _, StartTime, EndTime = UnitCastingInfo(Unit)

        -- Channel Casts
    elseif (Event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then
        Name, _, _, StartTime, EndTime = UnitChannelInfo(Unit)
    end

    if (not Name) then 
        return 
    end

    -- Set Values
    Frame.Castbar:SetTimerDuration(Frame.Castbar.Duration)
end

function NP.OnUpdate(Castbar)
    local Duration = Castbar:GetTimerDuration():GetRemainingDuration()
    Castbar.Time:SetFormattedText("%.1fs", Duration)
end

-- CREATE CASTBAR

function NP:CreateNamePlateCastBar(Frame)
    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(Frame:GetWidth() + 18, 20) 
    Castbar:Point("BOTTOM", Frame, 0, -6)
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