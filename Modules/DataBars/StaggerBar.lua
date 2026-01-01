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
	
	self.Bar = Bar
	self.Text = Text
	self.TextPer = TextPer
end

function StaggerBar:Update()
	local Min, Max = UnitStagger("player"), UnitHealthMax("player")
	local Percent = Min/Max

	self.Bar:SetMinMaxValues(0, Max)
	self.Bar:SetValue(Min, UI.SmoothBars)

	if (Percent >= STAGGER_RED_TRANSITION) then
		self.Bar:SetStatusBarColor(1, 0.52, 0.52)
	elseif (Percent > STAGGER_YELLOW_TRANSITION) then
		self.Bar:SetStatusBarColor(1, 0.82, 0.52)
	else
		self.Bar:SetStatusBarColor(0.52, 1, 0.52)
	end

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
	if (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER") then
		self:Update()
	end
	
	self:UpdateSpec()
end

function StaggerBar:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_POWER_FREQUENT")
	self:RegisterEvent("UNIT_MAXPOWER")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:SetScript("OnEvent", self.OnEvent)
end

function StaggerBar:Initialize()
	if (not DB.Global.DataBars.StaggerBar or Class ~= "MONK") then
		return
	end

	self:CreateBar()
	self:RegisterEvents()
end