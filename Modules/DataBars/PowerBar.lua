local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local PowerBar = UI:RegisterModule("PowerBar")

-- Lib Globals
local select = select
local unpack = unpack
local floor = math.floor

-- WoW Globals
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local CreateFrame = CreateFrame

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function PowerBar:CreateBar()
	local Bar = CreateFrame("StatusBar", nil, _G.UIParent)
	Bar:Size(242, 8)
	Bar:Point(unpack(DB.Global.DataBars.PowerBarPoint))
	Bar:SetStatusBarTexture(Media.Global.Texture)
	Bar:CreateBackdrop()
	Bar:CreateShadow()
	
	local InvisFrame = CreateFrame("Frame", nil, Bar)
	InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
	Text:SetFontTemplate("Default", 16)
	
	self.Bar = Bar
	self.Text = Text
end

function PowerBar:Update()
	local PowerType, PowerToken = UnitPowerType("player")
	local Min, Max = UnitPower("player", PowerType), UnitPowerMax("player", PowerType)
	local Percent = UnitPowerPercent("player", PowerType, false, UI.CurvePercent)
	local PowerColor = UI.Colors.Power[PowerToken]

	self.Bar:SetMinMaxValues(0, Max)
	self.Bar:SetValue(Min, UI.SmoothBars)

	if (PowerType == Enum.PowerType.Mana) then
		self.Text:SetFormattedText("%.0f%%", Percent)
		self.Text:Point("CENTER", Bar, 2, 6)
	else
		self.Text:SetText(Min)
		self.Text:Point("CENTER", Bar, 0, 6)
	end

	if (PowerColor) then
		self.Bar:SetStatusBarColor(unpack(PowerColor))
	end
end

function PowerBar:OnEvent(event)
	self:Update()
end

function PowerBar:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_POWER_FREQUENT")
	self:RegisterEvent("UNIT_MAXPOWER")
	self:RegisterEvent("UNIT_POWER_UPDATE")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	self:SetScript("OnEvent", self.OnEvent)
end

function PowerBar:Initialize()
	if (not DB.Global.DataBars.PowerBar) then
		return
	end

	self:CreateBar()
	self:RegisterEvents()
end