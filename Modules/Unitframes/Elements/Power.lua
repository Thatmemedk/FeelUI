local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreatePower(Frame, Orientation)
    if (Frame.Power) then
        return
    end

    if (not DB.Global.UnitFrames.PowerBar) then
        return
    end
    
    local Power = CreateFrame("StatusBar", nil, Frame.Health)
    Power:SetFrameStrata(Frame.Health:GetFrameStrata())
    Power:SetFrameLevel(Frame.Health:GetFrameLevel() + 1)
    Power:Height(Size or 4)
    Power:Point("TOPLEFT", Frame.Health, "BOTTOMLEFT", 0, 0)
    Power:Point("TOPRIGHT", Frame.Health, "BOTTOMRIGHT", 0, 0)
    Power:SetOrientation(Orientation or "HORIZONTAL")
    Power:SetStatusBarTexture(Media.Global.Texture)
    Power:SetTemplate()

    local Backdrop = CreateFrame("StatusBar", nil, Power)
    Backdrop:SetFrameStrata(Power:GetFrameStrata())
    Backdrop:SetFrameLevel(Power:GetFrameLevel() - 1)
    Backdrop:SetInside()
    Backdrop:SetOrientation(Orientation or "HORIZONTAL")
    Backdrop:SetStatusBarTexture(Media.Global.Texture)

    Frame.Power = Power
    Frame.Power.Backdrop = Backdrop
end