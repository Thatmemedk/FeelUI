local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local PowerBar = UI:RegisterModule("PowerBar")
local PP = UI:CallModule("PowerPrediction")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local floor = math.floor

-- WoW Globals
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

-- Locals
local Class = select(2, UnitClass("player"))

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function PowerBar:CreateBar(Name)
	local Bar = CreateFrame("StatusBar", "FeelUI_" .. Name, _G.UIParent)
	Bar:Size(263, 8)

	if (Name == "PowerBar") then
		Bar:Point(unpack(DB.Global.DataBars.PowerBarPoint))
	else
		Bar:Point(unpack(DB.Global.DataBars.ClassPowerPoint))
	end

	Bar:SetStatusBarTexture(Media.Global.Texture)
	Bar:Hide()
	
    Bar.Backdrop = CreateFrame("StatusBar", nil, Bar)
    Bar.Backdrop:SetFrameStrata(Bar:GetFrameStrata())
    Bar.Backdrop:SetFrameLevel(Bar:GetFrameLevel() - 1)
    Bar.Backdrop:Size(263, 8)
    Bar.Backdrop:Point("CENTER", Bar, 0, 0)
    Bar.Backdrop:SetStatusBarTexture(Media.Global.Texture)
    Bar.Backdrop:SetTemplate()
	Bar.Backdrop:CreateShadow()

	Bar.InvisFrame = CreateFrame("Frame", nil, Bar)
	Bar.InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
	Bar.InvisFrame:SetInside()

	Bar.Text = Bar.InvisFrame:CreateFontString(nil, "OVERLAY")
	Bar.Text:SetFontTemplate("Default", 16)
	Bar.Text:Point("CENTER", Bar, 0, 6)

    return Bar
end

function PowerBar:PowerUpdate()
	local Bar = self.Power

    if (not Bar) then
    	return
    end

	local PowerType, PowerToken = UnitPowerType("player")
	local Min, Max = UnitPower("player", PowerType), UnitPowerMax("player", PowerType)
	local Percent = UnitPowerPercent("player", PowerType, true, UI.CurvePercent)
	local PowerColor = UI.Colors.Power[PowerToken]

	-- Set Values
	Bar:Show()
	Bar:SetMinMaxValues(0, Max)
	Bar:SetValue(Min, UI.SmoothBars)

	-- Set Text
	if (PowerType == Enum.PowerType.Mana) then
		Bar.Text:SetFormattedText("%.0f%%", Percent)
		Bar.Text:Point("CENTER", Bar, 2, 6)
	else
		Bar.Text:SetText(Min)
		Bar.Text:Point("CENTER", Bar, 0, 6)
	end

	-- Set Color
	if (PowerColor) then
		Bar:SetStatusBarColor(R, G, B)
		Bar.Backdrop:SetStatusBarColor(R * 0.25, G * 0.25, B * 0.25, 0.7)
	end
end

function PowerBar:OnEvent(event)
   	self:PowerUpdate()
end

function PowerBar:RegisterEvents()
	-- PLAYER
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- UNIT
	self:RegisterEvent("UNIT_POWER_FREQUENT", "player")
	self:RegisterEvent("UNIT_MAXPOWER", "player")
	self:RegisterEvent("UNIT_POWER_UPDATE", "player")
	self:RegisterEvent("UNIT_DISPLAYPOWER", "player")
    -- ON EVENT
	self:SetScript("OnEvent", self.OnEvent)
end


function PowerBar:CreatePowerBar()
    if (not DB.Global.DataBars.PowerBar) then
    	return
    end

	self.Power = self:CreateBar("PowerBar")
end

function PowerBar:Initialize()
    self:CreatePowerBar()
    self:RegisterEvents()
end