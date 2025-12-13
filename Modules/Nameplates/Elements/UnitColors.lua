local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:GetUnitColor(Unit, IsCaster)
    if (not UnitExists(Unit)) then
        return
    end

    local InInstance, InstanceType = IsInInstance()
    local Reaction = UnitReaction(Unit, "player") or 5
    local Color = UI.Colors.Reaction[Reaction]

    if not (InInstance and InstanceType == "party") then
        return Color
    end

    local Level = UnitLevel(Unit)
    local Classific = UnitClassification(Unit)
    local IsBoss = UnitIsBossMob(Unit)
    local _, PowerType = UnitPowerType(Unit)

    if (IsBoss) then
        return UI.Colors.Classification.BOSS
    end

    if (Level == 91 and Classific == "elite") then
        return UI.Colors.Classification.RARE
    end

    if (Level == 90 and Classific == "elite") then
        if (PowerType == "MANA" or IsCaster) then
            return UI.Colors.Classification.CASTER
        else
            return UI.Colors.Classification.ELITE
        end
    end

    return Color
end

function NP:SetNameplateColor(Unit, IsCaster)
    if (not Unit or not UnitIsEnemy("player", Unit)) then
        return
    end

    local NamePlates = C_NamePlate.GetNamePlateForUnit(Unit)

    if (not NamePlates) then 
        return 
    end

    local Frame = NamePlates.FeelUINameplatesEnemy

    if (not Frame or not Frame.Health) then 
        return 
    end

    local Color = self:GetUnitColor(Unit, IsCaster)

    if (not Color) then
        return
    end

    Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.70)
end