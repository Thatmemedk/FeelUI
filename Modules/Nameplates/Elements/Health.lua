local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreateHealth(Frame)
    local Health = CreateFrame("StatusBar", nil, Frame)
    Health:SetInside()
    Health:SetStatusBarTexture(Media.Global.Texture)
    Health:CreateBackdrop()
    Health:CreateShadow()

    Frame.Health = Health
end