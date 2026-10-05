local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CharacterFrame = UI:RegisterModule("CharacterFrame")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function CharacterFrame:Skin(Frame)
	if (self.IsSkinned) then
		return
	end

	-- Hide
	_G.CharacterFrameTitleText:Hide()

	-- NameText
	local NameText = _G.CharacterFrame.TitleContainer:CreateFontString(nil, "OVERLAY", nil, 7)
	NameText:Point("CENTER", _G.CharacterFrame.TitleContainer, 0, 2)
	NameText:SetFontTemplate("Default", 20)
	NameText:SetTextColor(unpack(DB.Global.DataTexts.TextColor))
	NameText:SetText(UI.MyName)

	self.IsSkinned = true
end

function CharacterFrame:Initialize()
	if (not DB.Global.Theme.Enable) then
		return
	end

	self:Skin()
end