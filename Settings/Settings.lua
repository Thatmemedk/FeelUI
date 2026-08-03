local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Locals
local R, G, B = unpack(UI.GetClassColors)

--------------------------------
-- Default Settings of FeelUI --
--------------------------------

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
		IconZoom = { 0.20 },
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
		Bar1Point = { "BOTTOM", _G.UIParent, 0, 122 },
	},

	Auras = {
		Enable = true,
		-- Size Settings
		ButtonSize = { 36, 18 },
		ButtonSpacing = 4,
		ButtonPerRow = 12,
		ButtonRowSpacing = 12,
		-- Points Settings
		Point = { "TOPLEFT", _G.Minimap, -46, 4 },
	},

	AFK = {
		Enable = true,
	},

	Bags = {
		Enable = true,
	},

	Chat = {
		Enable = true,
		TimeStamps = true,
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
		-- Size Settings
		BuffViewerButtonSize = { 38, 18 },
		EssentialViewerButtonSize = { 32, 18 },
		UtilityViewerButtonSize = { 32, 18 },
		ButtonSpacing = 2,
		-- Points Settings
		BuffViewerPoint = { "CENTER", _G.UIParent, 0, -170 },
		EssentialViewerPoint = { "CENTER", _G.UIParent, 0, -222 },
		UtilityViewerPoint = { "CENTER", _G.UIParent, 0, -246 },
	},

	PotionButtonMenu = {
		ButtonSize = { 36, 18 },
		ButtonSpacing = 2,
		Point = { "BOTTOMLEFT", _G.UIParent, 482, 282 },
	},

	ScrollingCombatText = {
		Enable = true,
	},

	DataBars = {
		ExperienceBar = true,
		ReputationBar = false,
		ClassPowerBar = true,
		PowerBar = true,
		TotemBar = false,
		-- Points Settings
		PowerBarPoint = { "CENTER", _G.UIParent, 0, -204 },
		ClassPowerPoint = { "CENTER", _G.UIParent, 0, -192 },
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
		Enable = false,
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
		ButtonSize = { 26, 12 },
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
		Size = { 182, 12 },
		-- Colors
		HealthBarColor = { 0.5, 0.4, 1, 0.7 },
		UnitColors = true,
		ReactionColor = false,
		-- Target Indicator Color
		TargetIndicatorColor = { 0.30, 0.70, 1 },
	},

	UnitFrames = {
		Enable = true,
		BossFrames = true,
		PartyFrames = false,
		RaidFrames = true,
		-- Health / Power
		HealthBarColor = { 0.1, 0.1, 0.1, 0.7 },
		ClassColor = false,
		PowerBar = false,
		AdditionalPower = false,
		-- Castbar
		CastBarDetached = true,
		CastBarColor = { 0.45, 0.45, 0.45, 0.7 },
		CastBarInterruptColor = { 0.67, 0, 0, 0.70 },
		CastBarSucceededColor = { 0, 0.67, 0, 0.70 },
		-- Portraits
		Portraits = false,
		-- Icons
		RoleIcons = false,
		-- Points Settings
		PlayerPoint = { "BOTTOMLEFT", _G.UIParent, 482, 244 },
		TargetPoint = { "BOTTOMRIGHT", _G.UIParent, -482, 244 },
		BossPoint = { "RIGHT", _G.UIParent, -252, -122 },
		PartyPoint = { "LEFT", _G.UIParent, 219, 1 },
		RaidPoint = { "LEFT", _G.UIParent, 78, -1 },
		-- Points Settings
		CastBarPlayerPoint = { "CENTER", _G.UIParent, 0, -288 },
	},
}