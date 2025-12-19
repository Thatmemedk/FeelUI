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
    local Castbar = Frame and Frame.Castbar

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
    Castbar:SetScript("OnUpdate", NP.OnUpdate)

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, NP.FadeInTime, Castbar:GetAlpha(), 1)
end

function NP:CastStopped(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID == CastID or Castbar.SpellID == SpellID) then
        NP:ResetCastBar(Castbar)
    end
end

function NP:CastFailed(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

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
    else
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))
    end
    
    -- Reset CastBar
    NP:ResetCastBar(Castbar)
end

function NP:CastNonInterruptable(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
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

function NP:CastUpdated(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        return
    end

    local Name, StartTime, EndTime, CastID, SpellID

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_DELAYED") then
        Name, _, _, StartTime, EndTime, _, CastID, _, SpellID = UnitCastingInfo(Unit)

        -- Channel Casts
    elseif (Event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or Event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        Name, _, _, StartTime, EndTime, _, _, SpellID = UnitChannelInfo(Unit)
    end

    if (not Name) then 
        return 
    end
end

function NP.OnUpdate(Castbar)
    local Duration = Castbar:GetTimerDuration():GetElapsedDuration()
    local Total = Castbar:GetTimerDuration():GetTotalDuration()

    Castbar.Time:SetFormattedText("%.1fs / %.1fs", Duration, Total)
end

function NP:ResetCastBar(Castbar)
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
    UI:UIFrameFadeOut(Castbar, NP.FadeInTime, Castbar:GetAlpha(), 0)
end

-- CREATE CASTBAR

function NP:CreateCastBar(Frame)
    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(192, 20) 
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