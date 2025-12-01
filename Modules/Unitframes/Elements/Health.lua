local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateHealth(Frame, Size, Orientation)
    local Health = CreateFrame("StatusBar", nil, Frame)
    Health:Height(Size or 36)
    Health:Point("TOPRIGHT", Frame, 0, 0)
    Health:Point("TOPLEFT", Frame, 0, 0)
    Health:SetOrientation(Orientation or "HORIZONTAL")
    Health:SetStatusBarTexture(Media.Global.Texture)
    Health:CreateBackdrop()

    Frame.Health = Health
end

function UF:NPCreateHealth(Frame)
    local Health = CreateFrame("StatusBar", nil, Frame)
    Health:Size(Frame:GetWidth(), 14)
    Health:Point("CENTER", Frame, 0, -12)
    Health:SetStatusBarTexture(Media.Global.Texture)
    Health:CreateBackdrop()

    Frame.Health = Health
end