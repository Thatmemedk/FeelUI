local UI, DB, Media, Language = select(2, ...):Call()

--------------------------------
-- Default Settings of FeelUI --
--------------------------------

-- Locals
local R, G, B = unpack(UI.GetClassColors)

DB.Global = {
	General = {
		-- UIScale Settings
		UseUIScale = true,
		UIScaleMax = 0.80,
		UIScaleMin = 0.64,
		-- Color Settings
		BorderColor = { 0, 0, 0, 1 },
		BackdropColor = { 0.1, 0.1, 0.1, 0.70 },
		PanelColor = { 0.2, 0.2, 0.2, 0.70 },
		ShadowColor = { 0.05, 0.05, 0.05, 0.5 },
	},

	ActionBars = {
		Enable = true,
		-- Size Settings
		ButtonSize = { 32, 18 },
		StanceButtonSize = { 36, 18 },
		PetButtonSize = { 28, 14 },
		ButtonSpacing = 2,
		ButtonPerRow = 12,
		-- Bars
		Bar3 = false,
		Bar4 = true,
		Bar5 = true,
		StanceBar = true,
		-- Misc
		HotKey = false,
		AddNewSpells = false,
		-- Colors Settings
		PushedColor = { 1, 0.8, 0, 0.2 },
		CheckedColor = { 1, 1, 1, 0.2 },
		HighlightColor = { 1, 1, 1, 0.2 },
		EquipColor = { 0.64, 0.19, 0.79, 0.5 },
		OverlayGlowColor = { R, G, B, 0.80 },
		-- Points Settings
		Bar1Point = { "BOTTOM", _G.UIParent, 0, 122 }
	},

	Auras = {
		Enable = true,
		-- Size Settings
		ButtonSize = { 36, 18 },
		ButtonSpacing = 4,
		ButtonPerRow = 12,
		ButtonRowSpacing = 8,
		-- Points Settings
		AuraPoint = { "TOPRIGHT", _G.UIParent, -188, 5 },
	},

	AFK = {
		Enable = true,
	},

	Bags = {
		Enable = true,
	},

	Chat = {
		Enable = true,
	},

	CooldownFrame = {
		Enable = true,
		-- Colors Settings
		NormalColor = { 1, 1, 1 },
		ExpireColor = { 1, 0, 0 },
		SecondsColor = { 1, 0.42, 0 },
		SecondsColor2 = { 1, 0.82, 0 },
	},

	CooldownManager = {
		Enable = true,
		ButtonSize = { 36, 18 },
		ButtonSpacing = 2,
		ButtonRowSpacing = -22,
		AnchorPoint = { "CENTER", _G.UIParent, 0, -136 },
	},

	DataBars = {
		ExperienceBar = true,
		ClassPowerBar = true,
		PowerBar = true,
		RuneBar = true,
		RuneBarSpecColor = false,
		StaggerBar = true,
		SoulFragmentsBar = true,
		MaelstromBar = true,
		TotemBar = true,
		-- Points Settings
		PowerBarPoint = { "BOTTOM", _G.UIParent, 0, 250 },
		ClassPowerPoint = { "BOTTOM", _G.UIParent, 0, 266 },
		RuneBarPoint = { "BOTTOM", _G.UIParent, 0, 266 },
		StaggerBarPoint = { "BOTTOM", _G.UIParent, 0, 266 },
		SoulFragmentsBarPoint = { "BOTTOM", _G.UIParent, 0, 266 },
		MaelstromBarPoint = { "BOTTOM", _G.UIParent, 0, 266 },
	},

	DataTexts = {
		Date = true,
		Durability = true,
		Memory = true,
		System = true,
		Time = true,
		-- Colors Settings
		TextColor = { R, G, B },
	},

	ErrorsFrame = {
		Enable = true,
		-- Colors Settings
		TextColor = { 1, 1, 1 },
	},

	Loot = {
		Enable = true,
	},

	Merchant = {
		AutoRepair = true,
		GuildRepair = true,
		AutoSellJunk = true,
	},

	MinimapButtonBar = {
		Enable = true,
		-- Size Settings
		ButtonSize = { 26, 16 },
		ButtonSpacing = 2,
		ButtonsPerRow = 6,
	},

	ObjectiveTracker = {
		Enable = true,
	},

	Tooltip = {
		Enable = true, 
		TooltipOnMouseOver = false,
	},

	Theme = {
		Enable = true,
	},

	Nameplates = {
		Enable = true,
		-- Colors
		UnitColors = false,
		-- Target Indicator Color
		TargetIndicatorColor = { 0.30, 0.70, 1 },
	},

	UnitFrames = {
		Enable = true,
		BossFrames = true,
		PartyFrames = true,
		RaidFrames = false,
		-- Health / Power
		HealthBarColor = { 0.1, 0.1, 0.1, 1 },
		ClassColor = false,
		-- Castbar
		CastBarColor = { 0.45, 0.45, 0.45, 0.7 },
		CastBarInterruptColor = { 0.67, 0, 0, 0.70 },
		-- Portraits
		Portraits = true,
		-- Points Settings
		PlayerPoint = { "BOTTOMLEFT", _G.UIParent, 482, 244 },
		TargetPoint = { "BOTTOMRIGHT", _G.UIParent, -482, 244 },
		BossPoint = { "RIGHT", _G.UIParent, -252, -122 },
		PartyPoint = { "LEFT", _G.UIParent, 219, 1 },
		RaidPoint = { "LEFT", _G.UIParent, 78, -1 },
		-- Points Settings
		CastBarPlayerPoint = { "CENTER", _G.UIParent, 0, -282 },
	},
}