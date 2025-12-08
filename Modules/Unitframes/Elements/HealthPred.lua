local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateHealthPrediction(Frame)
    local MyHeals = CreateFrame("StatusBar", nil, Frame.Health)
    MyHeals:SetStatusBarTexture(Media.Global.Texture)
    MyHeals:SetStatusBarColor(0, 1, 0.5, 0.25)
    MyHeals:Hide()
    
    local OtherHeals = CreateFrame("StatusBar", nil, Frame.Health)
    OtherHeals:SetStatusBarTexture(Media.Global.Texture)
    OtherHeals:SetStatusBarColor(0, 1, 0, 0.25)
    OtherHeals:Hide()

    local Absorbs = CreateFrame("StatusBar", nil, Frame.Health)
    Absorbs:SetStatusBarTexture(Media.Global.Texture)
    Absorbs:SetStatusBarColor(1, 1, 0, 0.25)
    Absorbs:Hide()

    local HealAbsorbs = CreateFrame("StatusBar", nil, Frame.Health)
    HealAbsorbs:SetStatusBarTexture(Media.Global.Texture)
    HealAbsorbs:SetStatusBarColor(1, 0, 0, 0.25)
    HealAbsorbs:Hide()

    Frame.MyHeals = MyHeals
    Frame.OtherHeals = OtherHeals
    Frame.Absorbs = Absorbs
    Frame.HealAbsorbs = HealAbsorbs
end