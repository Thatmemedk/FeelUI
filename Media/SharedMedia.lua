local UI, DB, Media, Language = select(2, ...):Call()

-- Call Libs
local LSM = UI.Libs.LSM

-- Locals
local M = [[Interface\AddOns\FeelUI\Media\]]

Media.Global = {
	-- Fonts
	Font = M..[[Fonts\FranklinGothic.ttf]],
	CombatFont = M..[[Fonts\EdoSZ.ttf]],
	-- Textures
	Blank = [[Interface\Buttons\WHITE8x8]],
	Texture = M..[[Textures\SmoothV2.tga]],
	Overlay = M..[[Textures\Overlay.tga]],
	Shadow = M..[[Textures\ShadowTex.tga]],
	ShadowBorder = M..[[Textures\ShadowBorder.tga]],
	Highlight = M..[[Textures\Highlight.tga]],
	Backdrop = M..[[Textures\BackdropBlizz.tga]],
	-- Icons/Misc
	ChatCopy = M..[[Textures\ChatCopy.blp]],
	CloseTexture = M..[[Textures\Close.tga]],
	PowerArrowUp = M..[[Textures\ArrowAbove.tga]],
	PowerArrowDown = M..[[Textures\ArrowBelow.tga]],
	PowerArrowLeft = M..[[Textures\ArrowLeft.tga]],
	PowerArrowRight = M..[[Textures\ArrowRight.tga]],
	ExitVehicle = M..[[Textures\ExitVehicle.tga]],
	-- Logo
	Logo = M..[[Logo\Logo.blp]],
}

-- FONTS --
LSM:Register("font", "Franklin Gothic", M..[[Fonts\FranklinGothic.ttf]])
LSM:Register("font", "EdoSZ", M..[[Fonts\EdoSZ.ttf]])
-- STATUSBARS --
LSM:Register("statusbar", "SmoothV2_6px", M..[[Textures\SmoothV2_6px.tga]])