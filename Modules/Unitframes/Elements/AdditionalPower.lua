local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateAdditionalPower(Frame)
    local AdditionalPower = CreateFrame("StatusBar", nil, Frame)
    AdditionalPower:SetFrameStrata(Frame:GetFrameStrata())
    AdditionalPower:SetFrameLevel(Frame:GetFrameLevel() + 8)
    AdditionalPower:Size(228, 8)
    AdditionalPower:Point("BOTTOM", Frame, 0, -12)
    AdditionalPower:SetStatusBarTexture(Media.Global.Texture)
    AdditionalPower:SetStatusBarColor(0.31, 0.45, 0.63)
    AdditionalPower:CreateBackdrop()
    AdditionalPower:CreateShadow()
    AdditionalPower:SetAlpha(0)

    local AdditionalPowerText = Frame.InvisFrameHigher:CreateFontString(nil, "OVERLAY")
    AdditionalPowerText:SetFontTemplate("Default", 14)
    AdditionalPowerText:Point("CENTER", AdditionalPower, 0, 0)
    AdditionalPowerText:SetTextColor(1, 1, 1)
    AdditionalPowerText:SetAlpha(0)

    Frame.AdditionalPower = AdditionalPower
    Frame.AdditionalPowerText = AdditionalPowerText
end