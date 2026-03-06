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
local UnitStagger = UnitStagger
local UnitHealthMax = UnitHealthMax

-- WoW Globals
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

-- WoW Globals
local STAGGER_YELLOW_TRANSITION =  _G.STAGGER_YELLOW_TRANSITION or 0.3
local STAGGER_RED_TRANSITION = _G.STAGGER_RED_TRANSITION or 0.6

-- Locals
local Class = select(2, UnitClass("player"))

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function PowerBar:CreateBar(Name)
	local Bar = CreateFrame("StatusBar", "FeelUI_" .. Name, _G.UIParent)
	Bar:Size(242, 8)

	if (Name == "PowerBar") then
		Bar:Point(unpack(DB.Global.DataBars.PowerBarPoint))
	else
		Bar:Point(unpack(DB.Global.DataBars.ClassPowerPoint))
	end

	Bar:SetStatusBarTexture(Media.Global.Texture)
	Bar:CreateBackdrop()
	Bar:CreateShadow()
	Bar:Hide()
	
	Bar.InvisFrame = CreateFrame("Frame", nil, Bar)
	Bar.InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
	Bar.InvisFrame:SetInside()

	Bar.Text = Bar.InvisFrame:CreateFontString(nil, "OVERLAY")
	Bar.Text:SetFontTemplate("Default", 16)
	Bar.Text:Point("CENTER", Bar, 0, 6)

	-- ANIMATION
    Bar.Fade = UI:CreateAnimationGroup(Bar)

    Bar.FadeIn = UI:CreateAnimation(Bar.Fade, "Fade")
    Bar.FadeIn:SetDuration(0.25)
    Bar.FadeIn:SetChange(1)
    Bar.FadeIn:SetEasing("In-SineEase")

    Bar.FadeOut = UI:CreateAnimation(Bar.Fade, "Fade")
    Bar.FadeOut:SetDuration(0.25)
    Bar.FadeOut:SetChange(0)
    Bar.FadeOut:SetEasing("Out-SineEase")
    
    return Bar
end

function PowerBar:PowerUpdate()
	local Bar = self.Power

    if (not Bar) then
    	return
    end

    local Spec = GetSpecialization()

    if (Class == "MAGE" or Class == "WARLOCK") then
        Bar:Hide()
    elseif (Class == "PALADIN" and (Spec == 2 or Spec == 3)) then
        Bar:Hide()
    elseif (Class == "SHAMAN" and (Spec == 2)) then
    	Bar:Hide()
    elseif (Class == "EVOKER" and (Spec == 1 or Spec == 3)) then
    	Bar:Hide()
    else
        Bar:Show()
    end

	local PowerType, PowerToken = UnitPowerType("player")
	local Min, Max = UnitPower("player", PowerType), UnitPowerMax("player", PowerType)
	local Percent = UnitPowerPercent("player", PowerType, false, UI.CurvePercent)
	local PowerColor = UI.Colors.Power[PowerToken]

	-- Set Values
	Bar:SetMinMaxValues(0, Max, UI.SmoothBars)
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
		Bar:SetStatusBarColor(unpack(PowerColor))
	end
end

function PowerBar:StaggerUpdate()
	local Bar = self.Stagger

    if (not Bar) then
    	return
    end

    local Spec = GetSpecialization()

    if (Class ~= "MONK" or Spec ~= 1) then
        Bar:Hide()
        return
    end

	local Min, Max = UnitStagger("player"), UnitHealthMax("player")
	local Percent = Min/Max

	-- Set Values
	Bar:SetMinMaxValues(0, Max, UI.SmoothBars)
	Bar:SetValue(Min, UI.SmoothBars)

	-- Set Text
	Bar.Text:SetText(AbbreviateNumbers(Min))

	-- Set Colors
	if (Percent >= STAGGER_RED_TRANSITION) then
		Bar:SetStatusBarColor(1, 0.52, 0.52)
	elseif (Percent > STAGGER_YELLOW_TRANSITION) then
		Bar:SetStatusBarColor(1, 0.82, 0.52)
	else
		Bar:SetStatusBarColor(0.52, 1, 0.52)
	end
end

function PowerBar:SoulFragmentsUpdate()
	local Bar = self.SoulFragments

    if (not Bar) then
    	return
    end

    local Spec = GetSpecialization()

    if (Class ~= "DEMONHUNTER" or Spec ~= 2) then
        Bar:Show()
    else
        Bar:Hide()
    end

    local Aura = GetPlayerAuraBySpellID(1225789) or GetPlayerAuraBySpellID(1227702)
    local Min = Aura and Aura.applications or 0
    local Max = 50

    -- Set Values
    Bar:SetMinMaxValues(0, Max, UI.SmoothBars)
    Bar:SetValue(Min, UI.SmoothBars)

    -- Set Text
    Bar.Text:SetText(Min)

    -- Set Colors
    Bar:SetStatusBarColor(0.55, 0.25, 1 * 2)
end
function PowerBar:OnEvent(event)
   	self:PowerUpdate()
   	self:StaggerUpdate()
   	self:SoulFragmentsUpdate()
end

function PowerBar:RegisterEvents()
	-- PLAYER
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    -- UNIT
	self:RegisterEvent("UNIT_AURA", "player")
	self:RegisterEvent("UNIT_SPELLCAST_START", "player")
	self:RegisterEvent("UNIT_POWER_FREQUENT", "player")
	self:RegisterEvent("UNIT_MAXPOWER", "player")
	self:RegisterEvent("UNIT_POWER_UPDATE", "player")
	self:RegisterEvent("UNIT_DISPLAYPOWER", "player")
	-- SPELLS
    self:RegisterEvent("SPELLS_CHANGED")
    -- ON EVENT
	self:SetScript("OnEvent", self.OnEvent)
end

function PowerBar:GlidingState()
    local IsGliding = C_PlayerInfo.GetGlidingInfo()

    local Bars = {
        self.Power,
        self.Stagger,
        self.SoulFragments
    }

    for _, Bar in ipairs(Bars) do
        if (Bar) then
            if (IsGliding and not self.IsFlying) then
            	self.IsFlying = true

                if Bar.FadeIn:IsPlaying() then
                    Bar.FadeIn:Stop()
                end

                Bar.FadeOut:Play()

            elseif (not IsGliding and self.IsFlying) then
            	self.IsFlying = false

                if Bar.FadeOut:IsPlaying() then
                    Bar.FadeOut:Stop()
                end

                Bar.FadeIn:Play()
            end
        end
    end
end

function PowerBar:CheckDragonflying()
    C_Timer.NewTicker(0.2, function()
        self:GlidingState()
    end)
end

function PowerBar:CreatePowerBar()
    if (not DB.Global.DataBars.PowerBar) then
    	return
    end

	self.Power = self:CreateBar("PowerBar")
end

function PowerBar:CreateStaggerBar()
	if (Class ~= "MONK") then
		return
	end

	self.Stagger = self:CreateBar("StaggerBar")
end

function PowerBar:CreateSoulFragmentsBar()
    if (Class ~= "DEMONHUNTER") then
        return
    end

	self.SoulFragments = self:CreateBar("SoulFragmentsBar")
end

function PowerBar:Initialize()
    self:CreatePowerBar()
    self:CreateStaggerBar()
    self:CreateSoulFragmentsBar()
    self:RegisterEvents()
    self:CheckDragonflying()
end