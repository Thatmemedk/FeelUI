local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:RegisterModule("NamePlates")

-- WoW Globals
local UnitReaction = UnitReaction
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthPercent = UnitHealthPercent
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsConnected = UnitIsConnected
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitName = UnitName
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitThreatSituation = UnitThreatSituation
local SetCVar = C_CVar.SetCVar

-- Tables
NP.Hooked = {}
NP.Modified = {}

-- Tables
NP.UnitFrames = {}

-- Tables
NP.PlateTypes = {
    [true] = {
        Key = "FeelUINameplatesFriendly",
        Opposite = "FeelUINameplatesEnemy",
        Create = "CreateFriendlyPlates"
    },
    [false] = {
        Key = "FeelUINameplatesEnemy",
        Opposite = "FeelUINameplatesFriendly",
        Create = "CreateEnemyPlates"
    }
}

-- Locals
NP.FadeInTime = 0.5
NP.CastHoldTime = 2

-- HEALTH UPDATE

function NP:UpdateHealth(Frame, Unit)
    if (not Frame or not Unit or not Frame.Health) then 
        return 
    end

    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)
    Frame.Health:SetMinMaxValues(0, Max)
    Frame.Health:SetValue(Min, UI.SmoothBars)

    if (not UnitIsConnected(Unit) or UnitIsTapDenied(Unit) or UnitIsGhost(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    elseif (UnitIsDead(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0, 0)
        Frame.Health:SetBackdropColorTemplate(0.25, 0, 0, 0.7)
    else
        if (DB.Global.Nameplates.ReactionColor) then
            local Reaction = UnitReaction(Unit, "player")
            local Color = UI.Colors.Reaction[Reaction]

            Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.70)
        elseif (DB.Global.Nameplates.UnitColors) then
            local IsCaster = UnitCastingInfo(Unit) or UnitChannelInfo(Unit)
            local UnitClassifColor = NP:GetUnitColor(Unit, IsCaster and true)

            if (UnitClassifColor) then
                Frame.Health:SetStatusBarColor(UnitClassifColor.r, UnitClassifColor.g, UnitClassifColor.b, 0.70)
            end
        else
            Frame.Health:SetStatusBarColor(unpack(DB.Global.Nameplates.HealthBarColor))

            local CurveColor = UnitHealthPercent(Unit, true, UI.NameplatesHealthColorCurve)
            Frame.Health:GetStatusBarTexture():SetVertexColor(CurveColor:GetRGB())
        end

        Frame.Health:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))
    end
end

function NP:UpdateHealthText(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthText) then 
        return
    end

    local Percent = UnitHealthPercent(Unit, false, UI.CurvePercent)
    Frame.HealthText:SetFormattedText("%d%%", Percent or 0)
end

-- HEAL PRED

function NP:UpdateHealthPred(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthPrediction) then
        return
    end

    local Calculator = Frame.HealthPrediction.Calculator
    local PlayerHealsBar = Frame.HealthPrediction.PlayerHeals
    local OtherHealsBar = Frame.HealthPrediction.OtherHeals
    local AllAbsorbsBar = Frame.HealthPrediction.AllAbsorbs
    local HealAbsorbsBar = Frame.HealthPrediction.HealAbsorbs
    local OverHealsBar = Frame.HealthPrediction.OverHeals
    local OverAbsorbsBar = Frame.HealthPrediction.OverAbsorbs
    local OverHealsAbsorbsBar = Frame.HealthPrediction.OverHealsAbsorbs

    UnitGetDetailedHealPrediction(Unit, "player", Calculator)

    -- Calculate Predictions
    local AllHeals, PlayerHeals, OtherHeals, HealingClamped = Calculator:GetIncomingHeals()
    local AbsorbsAmount, AbsorbsClamped = Calculator:GetDamageAbsorbs()
    local HealAbsorbAmount, HealAbsorbClamped = Calculator:GetHealAbsorbs()
    local Max = UnitHealthMax(Unit)

    local Orientation = Frame.Health:GetOrientation()
    local PrevTexture = Frame.Health:GetStatusBarTexture()
    local BarWidth, BarHeight = Frame.Health:GetSize()

    PlayerHealsBar:SetOrientation(Orientation)
    PlayerHealsBar:SetMinMaxValues(0, Max)
    PlayerHealsBar:SetValue(PlayerHeals, UI.SmoothBars)

    OtherHealsBar:SetOrientation(Orientation)
    OtherHealsBar:SetMinMaxValues(0, Max)
    OtherHealsBar:SetValue(OtherHeals, UI.SmoothBars)

    AllAbsorbsBar:SetOrientation(Orientation)
    AllAbsorbsBar:SetReverseFill(true)
    AllAbsorbsBar:SetMinMaxValues(0, Max)
    AllAbsorbsBar:SetValue(AbsorbsAmount, UI.SmoothBars)

    HealAbsorbsBar:SetOrientation(Orientation)
    HealAbsorbsBar:SetReverseFill(true)
    HealAbsorbsBar:SetMinMaxValues(0, Max)
    HealAbsorbsBar:SetValue(HealAbsorbAmount, UI.SmoothBars)

    -- Healing Prediction
    PlayerHealsBar:SetAlphaFromBoolean(PlayerHeals, 1, 0)
    OtherHealsBar:SetAlphaFromBoolean(OtherHeals, 1, 0)
    AllAbsorbsBar:SetAlphaFromBoolean(AbsorbsAmount, 1, 0)
    HealAbsorbsBar:SetAlphaFromBoolean(HealAbsorbAmount, 1, 0)

    -- Over Healing/Absorbs
    OverHealsBar:SetAlphaFromBoolean(HealingClamped, 1, 0)
    OverAbsorbsBar:SetAlphaFromBoolean(AbsorbsClamped, 1, 0)
    OverHealsAbsorbsBar:SetAlphaFromBoolean(HealAbsorbClamped, 1, 0)

    if (Orientation == "HORIZONTAL") then
        PlayerHealsBar:Size(BarWidth, BarHeight)
        OtherHealsBar:Size(BarWidth, BarHeight)
        AllAbsorbsBar:Size(BarWidth, BarHeight)
        HealAbsorbsBar:Size(BarWidth, BarHeight)

        -- Player Heals
        PlayerHealsBar:SetOutsideRight(PrevTexture, 0, 0)
        -- Other Heals
        OtherHealsBar:SetOutsideRight(PlayerHealsBar:GetStatusBarTexture(), 0, 0)
        -- All Absorbs
        AllAbsorbsBar:SetInsideRight(PrevTexture, 0, 0)
        -- Heal Absorbs
        HealAbsorbsBar:SetInsideRight(PrevTexture, 0, 0)
        -- OverHeals
        OverHealsBar:SetOutsideRight(OtherHealsBar:GetStatusBarTexture(), -1, 0)
        -- OverAbsorbs
        OverAbsorbsBar:SetOutsideRight(AllAbsorbsBar:GetStatusBarTexture(), 0, 0)
        -- OverHealsAbsorbs
        OverHealsAbsorbsBar:SetOutsideRight(HealAbsorbsBar:GetStatusBarTexture(), 0, 0)
    else
        PlayerHealsBar:Size(BarHeight, BarWidth)
        OtherHealsBar:Size(BarHeight, BarWidth)
        AllAbsorbsBar:Size(BarHeight, BarWidth)
        HealAbsorbsBar:Size(BarHeight, BarWidth)

        -- Player Heals
        PlayerHealsBar:SetOutsideTop(PrevTexture, 0, 0)
        -- Other Heals
        OtherHealsBar:SetOutsideTop(PlayerHealsBar:GetStatusBarTexture(), 0, 0)
        -- All Absorbs
        AllAbsorbsBar:SetInsideTop(PrevTexture, 0, 0)
        -- Heal Absorbs
        HealAbsorbsBar:SetInsideTop(PrevTexture, 0, 0)
        -- OverHeals
        OverHealsBar:SetOutsideTop(OtherHealsBar:GetStatusBarTexture(), 0, 0)
        -- OverAbsorbs
        OverAbsorbsBar:SetOutsideTop(AllAbsorbsBar:GetStatusBarTexture(), 0, 0)
        -- OverHealsAbsorbs
        OverHealsAbsorbsBar:SetOutsideTop(HealAbsorbsBar:GetStatusBarTexture(), 0, 0)
    end
end

-- NAME UPDATE

function NP:UpdateName(Frame, Unit)
    if (not Frame or not Unit or not Frame.Name) then 
        return 
    end

    local Name = UnitName(Unit) or ""
    Frame.Name:SetText(Name)

    if (UnitIsPlayer(Unit) or UnitInPartyIsAI(Unit) or UnitPlayerControlled(Unit) and not UnitIsPlayer(Unit)) then
        local _, Class = UnitClass(Unit)
        local Color = UI.Colors.Class[Class]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    else
        local Reaction = UnitReaction(Unit, "player")
        local Color = UI.Colors.Reaction[Reaction]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    end
end

function NP:UpdateGuild(Frame, Unit)
    if (not Frame or not Unit or not Frame.Guild) then 
        return 
    end

    local GuildName, GuildRankName = GetGuildInfo(Unit)

    if (not GuildName) then 
        return 
    end

    local SameGuild = IsInGuild() and GetGuildInfo("player") == GuildName
    local ColorFormat = SameGuild and "|CFFFF66CC[%s]|r" or "|CFFFFFFFF[%s]|r"

    Frame.Guild:SetText(string.format(ColorFormat, GuildName))
end

-- ICONS

function NP:UpdateRaidIcon(Frame, Unit)
    if (not Frame or not Unit or not Frame.RaidIcon) then 
        return 
    end

    local Index = GetRaidTargetIndex(Unit)

    if (Index) then
        Frame.RaidIcon:Show()
        SetRaidTargetIconTexture(Frame.RaidIcon, Index)
    else
        Frame.RaidIcon:Hide()
    end
end

-- THREAT

function NP:UpdateThreatHighlight(Frame, Unit)
    if (not Frame or not Unit or not Frame.Threat) then 
        return 
    end

    local Threat = UnitThreatSituation("player", Unit)
    
    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        Frame.Threat.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)
        Frame.Threat:Show()
    else
        Frame.Threat:Hide()
    end
end

-- HIGHLIGHT

function NP:UpdateTargetIndicator(Frame, Unit)
    local IsTarget = UnitIsUnit("target", Unit)

    if (IsTarget) then
        Frame.TargetIndicator:Show()
    else
        Frame.TargetIndicator:Hide()
    end
end

function NP:UpdateHighlight(Frame, Unit)
    local IsTarget = UnitIsUnit("target", Unit)

    if (IsTarget) then
        Frame.Highlight:Show()
    else
        Frame.Highlight:Hide()
    end
end

function NP:UpdateHighlightMouseOver(Frame, Unit)
    local IsMouseover = UnitIsUnit("mouseover", Unit)

    if (IsMouseover) then
        Frame.HighlightMouseOver:Show()
    else
        Frame.HighlightMouseOver:Hide()
    end
end

-- FULL UPDATE

function NP:RefreshUnit(Frame, Unit)
    if (not Frame or not Unit or not UnitExists(Unit)) then
        return 
    end

    -- HEALTH
    if (Frame.Health) then self:UpdateHealth(Frame, Unit) end
    if (Frame.HealthText) then self:UpdateHealthText(Frame, Unit) end
    if (Frame.HealthPrediction) then self:UpdateHealthPred(Frame, Unit) end

    -- NAME
    if (Frame.Name) then self:UpdateName(Frame, Unit) end
    if (Frame.Guild) then self:UpdateGuild(Frame, Unit) end

    -- AURA
    if (Frame.Debuffs) then self:UpdateAuras(Frame, Unit, true, false) end
    if (Frame.CrowdControl) then self:UpdateAuras(Frame, Unit, false, true) end

    -- ICONS
    if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame, Unit) end

    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame, Unit) end

    -- HIGHLIGHT
    if (Frame.TargetIndicator) then self:UpdateTargetIndicator(Frame, Unit) end
    if (Frame.Highlight) then self:UpdateHighlight(Frame, Unit) end
    if (Frame.HighlightMouseOver) then self:UpdateHighlightMouseOver(Frame, Unit) end
end

-- EVENT UPDATES

function NP:UnitHealth(Unit)
    local Frame = self.UnitFrames[Unit]

    if (not Frame or not Unit or not UnitExists(Unit)) then
        return
    end

    if (Frame.Health) then 
        self:UpdateHealth(Frame, Unit)
    end

    if (Frame.HealthText) then 
        self:UpdateHealthText(Frame, Unit)
    end
end

function NP:UnitHealthPred(Unit)
    local Frame = self.UnitFrames[Unit]

    if (not Frame or not Unit or not UnitExists(Unit)) then
        return
    end

    if (Frame.HealthPrediction) then
        self:UpdateHealthPred(Frame, Unit)
    end
end

function NP:UnitAura(Unit)
    local Frame = self.UnitFrames[Unit]

    if (not Frame or not Unit or not UnitExists(Unit)) then
        return
    end

    if (Frame.Debuffs) then 
        self:UpdateAuras(Frame, Unit, true) 
    end

    if (Frame.CrowdControl) then
        self:UpdateAuras(Frame, Unit, false, true)
    end
end

function NP:UnitName(Unit)
    local Frame = self.UnitFrames[Unit]

    if (not Frame or not Unit or not UnitExists(Unit)) then
        return
    end

    if (Frame.Name) then
        self:UpdateName(Frame, Unit)
    end

    if (Frame.Guild) then
        self:UpdateGuild(Frame, Unit)
    end
end

function NP:UnitThreat(Unit)
    local Frame = self.UnitFrames[Unit]

    if (not Frame or not Unit or not UnitExists(Unit)) then
        return
    end

    if (Frame.Threat) then
        self:UpdateThreatHighlight(Frame, Unit)
    end
end

function NP:UnitTargetChanged()
    for Key, Frame in next, self.UnitFrames do
        if (Frame.TargetIndicator) then 
            self:UpdateTargetIndicator(Frame, Frame.unit) 
        end

        if (Frame.Highlight) then 
            self:UpdateHighlight(Frame, Frame.unit) 
        end
    end
end

function NP:UnitMouseOver()
    for Key, Frame in next, self.UnitFrames do
        if (Frame.HighlightMouseOver) then 
            self:UpdateHighlightMouseOver(Frame, Frame.unit) 
        end
    end
end

function NP:UnitRaidIcon()
    for Key, Frame in next, self.UnitFrames do
        if (Frame.RaidIcon) then 
            self:UpdateRaidIcon(Frame, Frame.unit) 
        end
    end
end

function NP:CastBarOnNamePlateUnitAdded(Unit)
    local Frame = self.UnitFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    -- Reset CastBar
    NP:ResetCastBar(Frame.Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastBarOnNamePlateUnitRemoved(Unit)
    local Frame = self.UnitFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    -- Reset CastBar
    NP:ResetCastBar(Frame.Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CheckUnitCasting(Unit)
    local Casting = UnitCastingInfo(Unit)
    local Channeling = UnitChannelInfo(Unit)

    if (Casting or Channeling) then
        NP:CastStarted("UNIT_SPELLCAST_START", Unit)
    end
end

-- EVENT HANDLER

function NP:NameplateAdded(Unit)
    local Plate = C_NamePlate.GetNamePlateForUnit(Unit)

    if (not Plate or not Plate.UnitFrame or Plate:IsForbidden()) then
        return
    end

    Plate.UnitFrame:SetAttribute("unit", Unit)

    local IsFriendly = UnitIsFriend("player", Unit)
    local Type = self.PlateTypes[IsFriendly]
    local Frame = Plate[Type.Key]

    if (not Frame) then
        Frame = self[Type.Create](self, Plate, Unit)
        Plate[Type.Key] = Frame
    end

    if (not Frame) then
        return
    end

    local Opposite = Plate[Type.Opposite]

    if (Opposite and Opposite:IsShown()) then
        Opposite:Hide()
        Opposite.Unit = nil
    end

    -- Show Unit
    Frame.unit = Unit
    Frame:Show()

    -- Cache Units
    self.UnitFrames[Unit] = Frame

    -- Refresh
    NP:RefreshUnit(Frame, Unit)
end

function NP:NameplateRemoved(Unit)
    local Plate = C_NamePlate.GetNamePlateForUnit(Unit)

    if (not Plate or not Plate.UnitFrame) then
        return
    end

    Plate.UnitFrame:SetAttribute("unit", nil)

    local Frame = self.UnitFrames[Unit]

    if (not Frame) then
        return
    end

    -- Hide Unit
    Frame.unit = nil
    Frame:Hide()

    -- Reset Unit Cache
    self.UnitFrames[Unit] = nil
end

local function IsNameplateUnit(unit)
    return unit and unit:match("^nameplate%d+$")
end

function NP:OnEvent(event, unit, ...)
    if (unit and not IsNameplateUnit(unit)) then
        return
    end

    if (event == "NAME_PLATE_UNIT_ADDED") then
        NP:NameplateAdded(unit)
        NP:CastBarOnNamePlateUnitAdded(unit)
    elseif (event == "NAME_PLATE_UNIT_REMOVED") then
        NP:NameplateRemoved(unit)
        NP:CastBarOnNamePlateUnitRemoved(unit)
    elseif (event == "PLAYER_TARGET_CHANGED") then
        NP:UnitTargetChanged()
    elseif (event == "UPDATE_MOUSEOVER_UNIT") then
        NP:UnitMouseOver()
    elseif (event == "RAID_TARGET_UPDATE") then
        NP:UnitRaidIcon()
    elseif (event == "UNIT_AURA") then
        NP:UnitAura(unit)
    elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
        NP:UnitHealth(unit)
    elseif (event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED") then
        NP:UnitHealthPred(unit)
    elseif (event == "UNIT_NAME_UPDATE") then
        NP:UnitName(unit)
    elseif (event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE") then
        NP:UnitThreat(unit)
    end

    if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
        NP:CastStarted(event, unit)
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        NP:CastStopped(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_FAILED") then
        NP:CastFailed(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
        NP:CastInterrupted(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
        --NP:CastSucceeded(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        NP:CastUpdated(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
        NP:CastNonInterruptable(event, unit)
    end
end

-- SET CVARS

function NP:SetCVarOnLogin()
    SetCVar("nameplateSelectedScaleEnabled", 1)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateSelectedScaleFactor", 1)
    SetCVar("nameplateGlobalScale", 1)
    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateMotion", 0)
    SetCVar("nameplateOverlapH", 0.8)
    SetCVar("nameplateOverlapV", 1.1)
    -- All
    SetCVar("nameplateShowAll", 1)
    -- Friendly
    SetCVar("nameplateShowFriends", 1)
    SetCVar("nameplateShowFriendlyNPCs", 0)
    SetCVar("nameplateShowFriendlyPets", 0)
    SetCVar("nameplateShowFriendlyTotems", 0)
    SetCVar("nameplateShowFriendlyMinions", 0)
    SetCVar("nameplateShowFriendlyGuardians", 0)
    -- Enemies
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("nameplateShowEnemyMinion", 1)
    SetCVar("nameplateShowEnemyMinus", 1)
    -- Names Only
    SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", 1)
    SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", 1)
    -- Never Show
    SetCVar("nameplateShowSelf", 0)
end

-- REGISTER EVENTS

function NP:RegisterEvents()
    -- NAMEPLATE
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    -- HEALTH
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    -- HEALTH PRED
    self:RegisterEvent("UNIT_HEAL_PREDICTION")
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    self:RegisterEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED")
    -- AURA
    self:RegisterEvent("UNIT_AURA")
    -- NAME
    self:RegisterEvent("UNIT_NAME_UPDATE")
    -- LEVEL
    self:RegisterEvent("UNIT_LEVEL")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    -- THREAT
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    -- CASTBAR
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("UNIT_SPELLCAST_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    -- ICONS
    self:RegisterEvent("RAID_TARGET_UPDATE")
    -- ON EVENT
    self:SetScript("OnEvent", function(_, event, ...) 
        NP:OnEvent(event, ...) 
    end)
end

-- INITIALIZE

function NP:Initialize()
    if (not DB.Global.Nameplates.Enable) then 
        return 
    end

    self:DisableBlizzard()
    self:RegisterEvents()
    self:SetCVarOnLogin()
end