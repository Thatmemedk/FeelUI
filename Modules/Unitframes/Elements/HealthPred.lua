local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreateHealthPrediction(Frame)
    if (Frame.HealthPrediction) then
        return
    end
    
    local HealthPrediction = {}
    HealthPrediction.OverFlowAmount = 1

    HealthPrediction.HealingPlayer = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.HealingPlayer:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.HealingPlayer:SetStatusBarColor(0, 1, 0, 0.25)

    HealthPrediction.HealingOther = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.HealingOther:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.HealingOther:SetStatusBarColor(0, 1, 0, 0.25)

    HealthPrediction.DamageAbsorb = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.DamageAbsorb:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.DamageAbsorb:SetStatusBarColor(1, 0.82, 0, 0.25)

    HealthPrediction.HealAbsorb = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.HealAbsorb:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.HealAbsorb:SetStatusBarColor(1, 0, 0, 0.25)

    HealthPrediction.OverHealIndicator = Frame.Health:CreateTexture(nil, "OVERLAY", nil, 7)
    HealthPrediction.OverHealIndicator:SetBlendMode("BLEND")
    HealthPrediction.OverHealIndicator:SetTexture(Media.Global.Blank)
    HealthPrediction.OverHealIndicator:SetColorTexture(0, 1, 0, 0.5)

    HealthPrediction.OverDamageAbsorbIndicator = Frame.Health:CreateTexture(nil, "OVERLAY", nil, 7)
    HealthPrediction.OverDamageAbsorbIndicator:SetBlendMode("BLEND")
    HealthPrediction.OverDamageAbsorbIndicator:SetTexture(Media.Global.Blank)
    HealthPrediction.OverDamageAbsorbIndicator:SetColorTexture(1, 1, 0, 0.5)

    HealthPrediction.OverHealAbsorbIndicator = Frame.Health:CreateTexture(nil, "OVERLAY", nil, 7)
    HealthPrediction.OverHealAbsorbIndicator:SetBlendMode("BLEND")
    HealthPrediction.OverHealAbsorbIndicator:SetTexture(Media.Global.Blank)
    HealthPrediction.OverHealAbsorbIndicator:SetColorTexture(1, 0, 0, 0.5)

    if (HealthPrediction.Calculator) then
        HealthPrediction.Calculator:ResetPredictedValues()
    else
        HealthPrediction.Calculator = CreateUnitHealPredictionCalculator()
    end

    HealthPrediction.Calculator:SetMaximumHealthMode(Enum.UnitMaximumHealthMode.WithAbsorbs)
    -- Enum.UnitMaximumHealthMode.Default
    -- Enum.UnitMaximumHealthMode.WithAbsorbs

    -- Incoming heals → AllHeals / PlayerHeals / OtherHeals
    HealthPrediction.Calculator:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MaximumHealth)
    -- Enum.UnitIncomingHealClampMode.MissingHealth
    -- Enum.UnitIncomingHealClampMode.MaximumHealth

    HealthPrediction.Calculator:SetIncomingHealOverflowPercent(HealthPrediction.OverFlowAmount)

    -- Damage absorbs → AllAbsorbs
    HealthPrediction.Calculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MaximumHealth)
    -- Enum.UnitDamageAbsorbClampMode.MissingHealth
    -- Enum.UnitDamageAbsorbClampMode.MissingHealthWithoutIncomingHeals
    -- Enum.UnitDamageAbsorbClampMode.MaximumHealth

    -- Heal absorbs → HealAbsorbs
    HealthPrediction.Calculator:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.MaximumHealth)
    -- Enum.UnitHealAbsorbClampMode.CurrentHealth
    -- Enum.UnitHealAbsorbClampMode.MaximumHealth

    HealthPrediction.Calculator:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.Total)
    -- Enum.UnitHealAbsorbMode.ReducedByIncomingHeals
    -- Enum.UnitHealAbsorbMode.Total
    
    Frame.HealthPrediction = HealthPrediction
end