local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreateHealth(Frame)
    local Health = CreateFrame("StatusBar", nil, Frame)
    Health:Size(Frame:GetWidth(), 14)
    Health:Point("CENTER", Frame, 0, -4)
    Health:SetStatusBarTexture(Media.Global.Texture)
    Health:CreateBackdrop()

    Frame.Health = Health
end