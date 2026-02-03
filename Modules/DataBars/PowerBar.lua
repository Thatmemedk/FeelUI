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
local _, Class = UnitClass("player")

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function PowerBar:CreateBar()
	local Bar = CreateFrame("StatusBar", nil, _G.UIParent)
	Bar:Size(242, 8)
	Bar:Point(unpack(DB.Global.DataBars.PowerBarPoint))
	Bar:SetStatusBarTexture(Media.Global.Texture)
	Bar:CreateBackdrop()
	Bar:CreateShadow()
	Bar:Hide()
	
	local InvisFrame = CreateFrame("Frame", nil, Bar)
	InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
	Text:SetFontTemplate("Default", 16)
	
	-- Cache
	self.Bar = Bar
	self.Text = Text
end

function PowerBar:Update()
	local PowerType, PowerToken = UnitPowerType("player")
	local Min, Max = UnitPower("player", PowerType), UnitPowerMax("player", PowerType)
	local Percent = UnitPowerPercent("player", PowerType, false, UI.CurvePercent)
	local PowerColor = UI.Colors.Power[PowerToken]

	-- Set Values
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

function PowerBar:UpdateSpec()
    local Spec = GetSpecialization()

    if (Class == "MAGE" or Class == "WARLOCK") then
        self.Bar:Hide()
    elseif (Class == "PALADIN" and (Spec == 2 or Spec == 3)) then
        self.Bar:Hide()
    elseif (Class == "SHAMAN" and (Spec == 2)) then
    	self.Bar:Hide()
    elseif (Class == "EVOKER" and (Spec == 1 or Spec == 3)) then
    else
        self.Bar:Show()
    end
end

function PowerBar:OnEvent(event, unit)
   	self:Update()
    self:UpdateSpec()
end

function PowerBar:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_POWER_FREQUENT", "player")
	self:RegisterEvent("UNIT_MAXPOWER", "player")
	self:RegisterEvent("UNIT_POWER_UPDATE", "player")
	self:RegisterEvent("UNIT_DISPLAYPOWER", "player")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("SPELLS_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)
end

function PowerBar:CheckDragonflying()
    local IsGliding = C_PlayerInfo.GetGlidingInfo()

    if (IsGliding and not self.IsFlying) then
        self.IsFlying = true

        UI:UIFrameFadeOut(self.Bar, 0.25, self.Bar:GetAlpha(), 0)
    elseif (not IsGliding and self.IsFlying) then
        self.IsFlying = false

        UI:UIFrameFadeIn(self.Bar, 0.25, self.Bar:GetAlpha(), 1)
    end
end

function PowerBar:Initialize()
	if (not DB.Global.DataBars.PowerBar) then
		return
	end

	self:CreateBar()
	self:RegisterEvents()

    C_Timer.NewTicker(0.2, function()
        self:CheckDragonflying()
    end)
end