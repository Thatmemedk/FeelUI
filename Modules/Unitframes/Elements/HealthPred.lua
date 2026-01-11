local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateOverflowBorder(Frame)
    if (Frame.IsSkinned) then
        return
    end

    local Overlay = CreateFrame("Frame", nil, Frame)
    Overlay:SetInside(Frame:GetStatusBarTexture(), 0, 0)
    Overlay:SetTemplate()

    Frame.IsSkinned = true
end

function UF:CreateHealthPrediction(Frame)
    local HealthPrediction = {}
    HealthPrediction.OverFlowAmount = 1.2

    HealthPrediction.PlayerHeals = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.PlayerHeals:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.PlayerHeals:SetStatusBarColor(0, 1, 0, 0.25)

    HealthPrediction.OtherHeals = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.OtherHeals:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.OtherHeals:SetStatusBarColor(0, 1, 0, 0.25)

    HealthPrediction.AllAbsorbs = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.AllAbsorbs:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.AllAbsorbs:SetStatusBarColor(1, 1, 0, 0.25)

    HealthPrediction.HealAbsorbs = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.HealAbsorbs:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.HealAbsorbs:SetStatusBarColor(1, 0, 0, 0.25)

    HealthPrediction.OverHeals = Frame.Health:CreateTexture(nil, "OVERLAY", nil, 7)
    HealthPrediction.OverHeals:SetBlendMode("BLEND")
    HealthPrediction.OverHeals:Width(2)
    HealthPrediction.OverHeals:SetTexture(Media.Global.Blank)
    HealthPrediction.OverHeals:SetColorTexture(0, 1, 0, 0.5)

    HealthPrediction.OverAbsorbs = Frame.Health:CreateTexture(nil, "OVERLAY", nil, 7)
    HealthPrediction.OverAbsorbs:SetBlendMode("BLEND")
    HealthPrediction.OverAbsorbs:Width(2)
    HealthPrediction.OverAbsorbs:SetTexture(Media.Global.Blank)
    HealthPrediction.OverAbsorbs:SetColorTexture(1, 1, 0, 0.5)

    HealthPrediction.OverHealsAbsorbs = Frame.Health:CreateTexture(nil, "OVERLAY", nil, 7)
    HealthPrediction.OverHealsAbsorbs:SetBlendMode("BLEND")
    HealthPrediction.OverHealsAbsorbs:Width(2)
    HealthPrediction.OverHealsAbsorbs:SetTexture(Media.Global.Blank)
    HealthPrediction.OverHealsAbsorbs:SetColorTexture(1, 0, 0, 0.5)

    if (not HealthPrediction.Calculator) then
        HealthPrediction.Calculator = CreateUnitHealPredictionCalculator()
        HealthPrediction.Calculator = HealthPrediction.Calculator

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
    else
        HealthPrediction.Calculator:Reset()
    end

    Frame.HealthPrediction = HealthPrediction
end