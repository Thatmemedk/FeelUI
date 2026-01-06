local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ExperienceBar = UI:RegisterModule("ExperienceBar")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local floor = math.floor

-- WoW Globals
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local GetRestState = GetRestState
local UnitLevel = UnitLevel
local GetPetExperience = GetPetExperience
local IsXPUserDisabled = IsXPUserDisabled
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local GameTooltip = _G.GameTooltip

-- Locals
local Mult = 2.5

function ExperienceBar:CreateBar()
	local Bar = CreateFrame("StatusBar",  nil, _G.UIParent)
	Bar:Size(322, 12)
	Bar:Point("TOP", _G.UIParent, 0, -12)
	Bar:SetStatusBarTexture(Media.Global.Texture)
	Bar:SetStatusBarColor(0.6 * Mult, 0, 0.6 * Mult, 0.7)
	Bar:CreateBackdrop()
	Bar:CreateShadow()
	Bar:SetScript("OnEnter", self.OnEnter)
	Bar:SetScript("OnLeave", self.OnLeave)
	Bar:SetAlpha(0.25)
	
	local BarRested = CreateFrame("StatusBar", nil, Bar)
	BarRested:Size(171, 8)
	BarRested:SetInside()
	BarRested:SetStatusBarTexture(Media.Global.Texture) 
	BarRested:SetStatusBarColor(0, 200/255 * Mult, 1 * Mult, 0.7)
	BarRested:SetFrameLevel(Bar:GetFrameLevel() - 1)
	BarRested:Hide()

	local InvisFrame = CreateFrame("Frame", nil, Bar)
	InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
	Text:Point("CENTER", Bar, 0, 6)
	Text:SetFontTemplate("Default", 16)

	self.Bar = Bar
	self.BarRested = BarRested
	self.Text = Text
end

function ExperienceBar:GetXP(Unit)
	if (Unit == "pet") then
		return GetPetExperience()
	else
		return UnitXP(Unit), UnitXPMax(Unit)
	end
end

function ExperienceBar:OnEnter()
	local Min, Max = ExperienceBar:GetXP("player")
	local Rested = GetXPExhaustion()
	local IsRested = GetRestState()
	
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -6)
	GameTooltip:AddLine("|cffffd200Experience|r")
	GameTooltip:AddDoubleLine("Current Experience:", Min .. "/" .. Max .. " - (" .. floor(Min/Max*100) .. "%)", 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Remaining Experience:", Max - Min .. " - (" .. floor((Max - Min) / Max * 100, 20 * (Max - Min) / Max) .. "%)", 1, 1, 1, 1, 1, 1)
	
	if (IsRested == 1 and Rested) then
		GameTooltip:AddDoubleLine("Rested Experience:", Rested .. " - (" .. floor(Rested/Max*100) .. "%)", 1, 1, 1, 1, 1, 1)
	else
		GameTooltip:AddDoubleLine("Rested Experience:", "0", 1, 1, 1, 1, 1, 1)
	end

	GameTooltip:Show()
	
	UI:UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
end

function ExperienceBar:OnLeave()
	_G.GameTooltip_Hide()

	UI:UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
end

function ExperienceBar:OnEvent(event)
	local Min, Max = ExperienceBar:GetXP("player")
	local Rested = GetXPExhaustion()
	local IsRested = GetRestState()

	self.Bar:SetMinMaxValues(0, Max)
	self.Bar:SetValue(Min, UI.SmoothBars)

	if (IsRested == 1 and Rested) then
		self.BarRested:SetMinMaxValues(0, Max)
		self.BarRested:SetValue(Rested + Min, UI.SmoothBars)
		self.BarRested:Show()
	else
		self.BarRested:Hide()
	end
	
	self.Text:SetText(floor(Min/Max*100).."%")

	if (UI.MyLevel == 90 or IsXPUserDisabled()) then
		self.Bar:Hide()
	end
end

function ExperienceBar:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("UPDATE_EXHAUSTION")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:RegisterEvent("ENABLE_XP_GAIN")
	self:RegisterEvent("DISABLE_XP_GAIN")
	self:SetScript("OnEvent", self.OnEvent)
end

function ExperienceBar:Initialize()
	if (not DB.Global.DataBars.ExperienceBar) then
		return
	end

	self:CreateBar()
	self:RegisterEvents()
end