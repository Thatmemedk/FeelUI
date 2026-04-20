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
    local Reaction = UnitReaction(Unit, "player") or 5
    local Classif = UnitClassification(Unit)
    local Level = UnitEffectiveLevel(Unit)
    local _, PowerType = UnitPowerType(Unit)
    local Class = select(2, UnitClass(Unit))

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

    if (not UnitAffectingCombat(Unit) and UnitReaction(Unit, "player") == 4) then
        return UI.Colors.Reaction[Reaction]
    end

    if (Classif == "elite") then
        if (Level >= UnitLevel("player") + 2) then
            return UI.Colors.Classification.BOSS
        end

        if (Level == UnitLevel("player") + 1 or Class == "ROGUE") then
            return UI.Colors.Classification.RARE
        end

        if (Level <= UnitLevel("player") and PowerType == Enum.PowerType.Mana or Class == "PALADIN") then
            return UI.Colors.Classification.CASTER
        end

        if (Level == UnitLevel("player")) then
            return UI.Colors.Classification.ELITE
        end
    elseif (Classif == "normal" or Classif == "trivial") then
        return UI.Colors.Reaction[Reaction]
    end
end