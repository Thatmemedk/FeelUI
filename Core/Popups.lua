local UI, DB, Media, Language = select(2, ...):Call()

StaticPopupDialogs["ELVUI_INCOMPATIBLE"] = {
	text = Language.ElvUI.Enabled,
	OnAccept = function() DisableAddOn("ElvUI") DisableAddOn("ElvUI_OptionsUI") ReloadUI() end,
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