local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

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
    if (not UnitExists(Unit)) then
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

    return UI.Colors.Reaction[Reaction]
end

function NP:SetNameplateColor(Unit, IsCaster)
    if (not DB.Global.Nameplates.UnitColors) then
        return
    end

    if (not Unit or not UnitIsEnemy("player", Unit)) then
        return
    end

    local NamePlate = C_NamePlate.GetNamePlateForUnit(Unit)
    
    if (not NamePlate) then
        return
    end

    local EnemyFrame = NamePlate.FeelUINameplatesEnemy

    if (not EnemyFrame or not EnemyFrame.Health) then
        return
    end

    -- Update persistent caster cache
    if (IsCasting) then
        NP.ForcedCasters[Unit] = true
    end

    -- Determine final caster flag: currently casting OR persistent
    local FinalIsCaster = IsCaster or IsCasting or NP.ForcedCasters[Unit]

    -- Get the color from your dungeon-only logic
    local Color = self:GetUnitColor(Unit, FinalIsCaster)

    if (not Color) then
        return
    end

    EnemyFrame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.7)
end

function NP:ClearForcedCasters(Unit)
    if (NP.ForcedCasters[Unit]) then
        NP.ForcedCasters[Unit] = nil
    end
end