local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local StaggerBar = UI:RegisterModule("StaggerBar")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local select = select
local unpack = unpack
local floor = math.floor

-- WoW Globals
local UnitStagger = UnitStagger
local UnitHealthMax = UnitHealthMax
local STAGGER_YELLOW_TRANSITION =  _G.STAGGER_YELLOW_TRANSITION or 0.3
local STAGGER_RED_TRANSITION = _G.STAGGER_RED_TRANSITION or 0.6

-- Locals
local Class = select(2, UnitClass("player"))

function StaggerBar:CreateBar()
	local Bar = CreateFrame("StatusBar", nil, _G.UIParent)
	Bar:Size(242, 8)
	Bar:Point(unpack(DB.Global.DataBars.StaggerBarPoint))
	Bar:SetStatusBarTexture(Media.Global.Texture)
	Bar:CreateBackdrop()
	Bar:CreateShadow()
	Bar:Hide()
	
	local InvisFrame = CreateFrame("Frame", nil, Bar)
	InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
	InvisFrame:SetInside()
	
	local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
	Text:Point("LEFT", Bar, 6, 6)
	Text:SetFontTemplate("Default", 16)
	
	local TextPer = InvisFrame:CreateFontString(nil, "OVERLAY")
	TextPer:Point("RIGHT", Bar, -6, 6)
	TextPer:SetFontTemplate("Default", 16)
	
	-- Cache
	self.Bar = Bar
	self.Text = Text
	self.TextPer = TextPer
end

function StaggerBar:Update()
	local Min, Max = UnitStagger("player"), UnitHealthMax("player")
	local Percent = Min/Max

	-- Set Values
	self.Bar:SetMinMaxValues(0, Max)
	self.Bar:SetValue(Min, UI.SmoothBars)

	if (Percent >= STAGGER_RED_TRANSITION) then
		self.Bar:SetStatusBarColor(1, 0.52, 0.52)
	elseif (Percent > STAGGER_YELLOW_TRANSITION) then
		self.Bar:SetStatusBarColor(1, 0.82, 0.52)
	else
		self.Bar:SetStatusBarColor(0.52, 1, 0.52)
	end

	-- Set Text
	self.Text:SetText(Min)
	self.TextPer:SetText(floor(Min/Max*1000)/10 .. "%")
end

function StaggerBar:UpdateSpec(event)
	local GetSpecialization = GetSpecialization()
	
	if (Class == "MONK" and GetSpecialization == 1) then
		self.Bar:Show()
	else
		self.Bar:Hide()
	end
end

function StaggerBar:OnEvent(event)
	self:Update()
	self:UpdateSpec()
end

function StaggerBar:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_POWER_FREQUENT", "player")
	self:RegisterEvent("UNIT_MAXPOWER", "player")
	self:RegisterEvent("UNIT_DISPLAYPOWER", "player")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("SPELLS_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)
end

function StaggerBar:Initialize()
	if (not DB.Global.DataBars.StaggerBar or Class ~= "MONK") then
		return
	end

	self:CreateBar()
	self:RegisterEvents()
end