local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateHealthPrediction(Frame)
    local AbsorbBar = CreateFrame("StatusBar", nil, Frame.Health)
    AbsorbBar:SetStatusBarTexture(Media.Global.Texture)
    AbsorbBar:SetStatusBarColor(0, 1, 0.5, 0.25)
    AbsorbBar:Hide()

    Frame.AbsorbBar = AbsorbBar
end