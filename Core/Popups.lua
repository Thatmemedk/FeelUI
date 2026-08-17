local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

StaticPopupDialogs["ELVUI_INCOMPATIBLE"] = {
	text = Language.ElvUI.Enabled,
	OnAccept = function() DisableAddOn("ElvUI") DisableAddOn("ElvUI_Options") DisableAddOn("ElvUI_Libraries") ReloadUI() end,
	button1 = Language.ElvUI.Disabled,
	whileDead = 1,
	hideOnEscape = false,
}

StaticPopupDialogs["TUKUI_INCOMPATIBLE"] = {
	text = Language.Tukui.Enabled,
	OnAccept = function() DisableAddOn("Tukui") ReloadUI() end,
	button1 = Language.Tukui.Disabled,
	whileDead = 1,
	hideOnEscape = false,
}

StaticPopupDialogs["ELLESMERESUI_INCOMPATIBLE"] = {
	text = Language.Tukui.Enabled,
	OnAccept = function() DisableAddOn("EllesmeresUI") ReloadUI() end,
	button1 = Language.Tukui.Disabled,
	whileDead = 1,
	hideOnEscape = false,
}