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
local UnitName = UnitName
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitThreatSituation = UnitThreatSituation
local SetCVar = C_CVar.SetCVar

-- Tables
NP.Hooked = {}
NP.ForcedCasters = {}
NP.Range = {}

-- Locals
NP.FadeInTime = 0.5
NP.CastHoldTime = 2

-- HEALTH UPDATE

function NP:UpdateHealth(Frame, Unit)
    if (not Frame or not Unit or not Frame.Health) then 
        return 
    end

    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)
    local Reaction = UnitReaction(Unit, "player")
    local Color = UI.Colors.Reaction[Reaction]

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
            Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.70)
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
    else
        Frame.Threat.Glow:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

-- HIGHLIGHT

function NP:UpdateTargetIndicator(Frame, Unit)
    if (UnitIsUnit("target", Unit)) then
        Frame.TargetIndicator:Show()
    else
        Frame.TargetIndicator:Hide()
    end
end

function NP:UpdateHighlight(Frame, Unit)
    if (UnitIsUnit("target", Unit)) then
        Frame.Highlight:Show()
    else
        Frame.Highlight:Hide()
    end
end

-- FULL UPDATE

function NP:UpdateFriendlyPlates(Frame)
    if (not Frame or not Frame.Unit) then 
        return 
    end

    -- NAME
    if (Frame.Name) then self:UpdateName(Frame, Frame.Unit) end
    -- ICONS
    if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame, Frame.Unit) end
end

function NP:UpdateEnemyPlates(Frame)
    if (not Frame or not Frame.Unit) then 
        return 
    end

    -- HEALTH
    if (Frame.Health) then self:UpdateHealth(Frame, Frame.Unit) end
    if (Frame.HealthText) then self:UpdateHealthText(Frame, Frame.Unit) end
    -- NAME
    if (Frame.Name) then self:UpdateName(Frame, Frame.Unit) end
    -- ICONS
    if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame, Frame.Unit) end
    -- TARGET INDICATOR
    if (Frame.TargetIndicator) then self:UpdateTargetIndicator(Frame, Frame.Unit) end
    -- HIGHLIGHT
    if (Frame.Highlight) then self:UpdateHighlight(Frame, Frame.Unit) end
    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame, Frame.Unit) end
    -- AURAS
    if (Frame.Debuffs) then self:UpdateAuras(Frame, Frame.Unit, true) end
end

-- EVENT HANDLER

function NP:OnEvent(event, unit, ...)
    local Plates = C_NamePlate.GetNamePlates()
    local Plate = unit and C_NamePlate.GetNamePlateForUnit(unit)

    if (event == "NAME_PLATE_UNIT_ADDED") then
        if (not Plate) then
            return
        end

        local Friendly = Plate.FeelUINameplatesFriendly
        local Enemy = Plate.FeelUINameplatesEnemy
        local IsFriend = UnitIsFriend("player", unit)

        if (IsFriend) then
            if (Enemy) then
                Enemy:Hide()
                Enemy.Unit = nil
            end
        else
            if (Friendly) then
                Friendly:Hide()
                Friendly.Unit = nil
            end
        end

        if (IsFriend) then
            if (not Friendly) then
                NP:CreateFriendlyPlates(Plate, unit)
            else
                Friendly:Show()
                Friendly.Unit = unit

                NP:UpdateFriendlyPlates(Friendly)
            end
        else
            if (not Enemy) then
                NP:CreateEnemyPlates(Plate, unit)
            else
                Enemy:Show()
                Enemy.Unit = unit

                NP:UpdateEnemyPlates(Enemy)
                NP:SetNameplateColor(unit, false)
            end
        end
    end

    if (event == "NAME_PLATE_UNIT_REMOVED") then
        if (not Plate) then 
            return
        end

        if (Plate.FeelUINameplatesFriendly) then
            Plate.FeelUINameplatesFriendly.Unit = nil
        end

        if (Plate.FeelUINameplatesEnemy) then
            Plate.FeelUINameplatesEnemy.Unit = nil
        end

        NP:ClearForcedCasters(unit)
    end

    if (event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGETABLE_CHANGED") then
        for _, Plate in ipairs(Plates) do
            local Friendly = Plate.FeelUINameplatesFriendly
            local Enemy = Plate.FeelUINameplatesEnemy

            if (Friendly and Friendly.Unit) then
                NP:UpdateFriendlyPlates(Friendly)
            end

            if (Enemy and Enemy.Unit) then
                NP:UpdateEnemyPlates(Enemy)
                NP:SetNameplateColor(Enemy.Unit, false)
            end
        end
    end

    if (event == "RAID_TARGET_UPDATE") then
        for _, Plate in ipairs(Plates) do
            local Friendly = Plate.FeelUINameplatesFriendly
            local Enemy = Plate.FeelUINameplatesEnemy

            if (Friendly and Friendly.Unit) then
                NP:UpdateRaidIcon(Friendly, Friendly.Unit)
            end

            if (Enemy and Enemy.Unit) then
                NP:UpdateRaidIcon(Enemy, Enemy.Unit)
            end
        end
    end

    if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
        NP:CastStarted(event, unit)
        NP:SetNameplateColor(unit, true)
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        NP:CastStopped(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        NP:CastUpdated(event, unit)
    elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then
        NP:CastFailed(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
        NP:CastNonInterruptable(event, unit)
    end

    if (not Plate) then
        return
    end

    local Friendly = Plate.FeelUINameplatesFriendly
    local Enemy = Plate.FeelUINameplatesEnemy
    local IsFriend = UnitIsFriend("player", unit)

    if (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
        if (IsFriend) then
            if (Friendly) then
                NP:UpdateFriendlyPlates(Friendly)
            end
        else
            if (Enemy) then
                NP:UpdateEnemyPlates(Enemy)
                NP:SetNameplateColor(unit, false)
            end
        end
    end

    if (event == "UNIT_AURA") then
        if (Enemy and Enemy.Unit) then
            NP:UpdateAuras(Enemy, Enemy.Unit, true)
        end
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
    self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
    -- HEALTH
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    -- AURA
    self:RegisterEvent("UNIT_AURA")
    -- CASTBAR
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
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