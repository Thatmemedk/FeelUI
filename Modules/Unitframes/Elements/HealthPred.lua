local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateHealthPrediction(Frame)
    local HealthPrediction = {}

    HealthPrediction.MyHeals = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.MyHeals:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.MyHeals:SetStatusBarColor(0, 1, 0.5, 0.25)
    HealthPrediction.MyHeals:Hide()
    
    HealthPrediction.OtherHeals = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.OtherHeals:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.OtherHeals:SetStatusBarColor(0, 1, 0, 0.25)
    HealthPrediction.OtherHeals:Hide()

    HealthPrediction.Absorbs = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.Absorbs:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.Absorbs:SetStatusBarColor(1, 1, 0, 0.25)
    HealthPrediction.Absorbs:Hide()

    HealthPrediction.HealAbsorbs = CreateFrame("StatusBar", nil, Frame.Health)
    HealthPrediction.HealAbsorbs:SetStatusBarTexture(Media.Global.Texture)
    HealthPrediction.HealAbsorbs:SetStatusBarColor(1, 0, 0, 0.25)
    HealthPrediction.HealAbsorbs:Hide()

    Frame.HealthPrediction = HealthPrediction
end