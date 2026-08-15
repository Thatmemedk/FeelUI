local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreateHealth(Frame, Size, Orientation)
    if (Frame.Health) then
        return
    end
    
    local Health = CreateFrame("StatusBar", nil, Frame)
    Health:Height(Size or 36)
    Health:Point("TOPRIGHT", Frame, 0, 0)
    Health:Point("TOPLEFT", Frame, 0, 0)
    Health:SetOrientation(Orientation or "HORIZONTAL")
    Health:SetStatusBarTexture(Media.Global.Texture)

    if (Health.Value) then
        Health.Value:ResetPredictedValues()
    else
        Health.Value = CreateUnitHealPredictionCalculator()
    end

    Frame.Health = Health
end