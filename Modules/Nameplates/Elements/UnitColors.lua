local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local UnitReaction = UnitReaction
local UnitClassification = UnitClassification
local UnitIsBossMob = UnitIsBossMob
local UnitPowerType = UnitPowerType
local UnitIsLieutenant = UnitIsLieutenant
local UnitLevel = UnitLevel
local UnitClass = UnitClass
local UnitEffectiveLevel = UnitEffectiveLevel

function NP:GetUnitColor(Unit, IsCaster)
    if (not Unit) then
        return
    end

    local InInstance, InstanceType = IsInInstance()
    local Reaction = UnitReaction(Unit, "player")
    local Classif = UnitClassification(Unit)
    local Level = UnitEffectiveLevel(Unit)
    local _, PowerType = UnitPowerType(Unit)
    local PlayerLevel = UnitLevel("player")

    -- Outside party instances, use reaction color.
    if (not InInstance or InstanceType ~= "party") then
        return UI.Colors.Reaction[Reaction]
    end

    if (IsCaster) then
        return UI.Colors.Classification.CASTER
    end

    if (UnitIsBossMob(Unit)) then
        return UI.Colors.Classification.BOSS
    end

    if (UnitIsLieutenant(Unit)) then
        return UI.Colors.Classification.RARE
    end

    if (not UnitAffectingCombat(Unit) and Reaction == 4) then
        return UI.Colors.Reaction[Reaction]
    end

    if (Classif == "elite") then
        if (Level >= PlayerLevel + 2) then
            return UI.Colors.Classification.BOSS
        elseif (Level == PlayerLevel + 1) then
            return UI.Colors.Classification.RARE
        elseif (Level <= PlayerLevel and PowerType == Enum.PowerType.Mana) then
            return UI.Colors.Classification.CASTER
        elseif (Level == PlayerLevel) then
            return UI.Colors.Classification.ELITE
        end
    end

    -- Guaranteed fallback.
    return UI.Colors.Reaction[Reaction]
end