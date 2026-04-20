local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function NP:CreateHealth(Frame)
    if (Frame.Health) then
        return
    end
    
    local Health = CreateFrame("StatusBar", nil, Frame)
    Health:SetInside()
    Health:SetStatusBarTexture(Media.Global.Texture)
    Health:CreateBackdrop()
    Health:CreateShadow()

    Frame.Health = Health
end