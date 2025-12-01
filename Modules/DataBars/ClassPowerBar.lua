local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ClassPowerBar = UI:RegisterModule("ResourceBar")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitClass = UnitClass
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetSpecialization = GetSpecialization
local UnitPowerType = UnitPowerType

local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints
local SPELL_POWER_ENERGY = Enum.PowerType.Energy
local SPELL_POWER_SOUL_SHARDS = Enum.PowerType.SoulShards
local SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower
local SPELL_POWER_CHI = Enum.PowerType.Chi
local SPELL_POWER_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges
local SPELL_POWER_ESSENCE = Enum.PowerType.Essence
local SPELL_POWER_MAELSTROM = Enum.PowerType.Maelstrom

-- Locals
local Class = select(2, UnitClass("player"))

-- Colors
local R, G, B = unpack(UI.GetClassColors)

function ClassPowerBar:CreateBar()
    local Bar = CreateFrame("Frame", nil, _G.UIParent)
    Bar:SetFrameStrata("LOW")
    Bar:Size(222, 8)
    Bar:Point(unpack(DB.Global.DataBars.ClassPowerPoint))
    Bar:CreateBackdrop()
    Bar:CreateShadow()
    Bar:Hide()

    local Fill = CreateFrame("StatusBar", nil, Bar)
    Fill:SetInside()
    Fill:SetStatusBarTexture(Media.Global.Texture)
    Fill:SetFrameLevel(Bar:GetFrameLevel())
    Fill:Hide()

    local InvisFrame = CreateFrame("Frame", nil, Bar)
    InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Bar, 0, 6)
    Text:SetFontTemplate("Default", 16)

    self.Bar = Bar
    self.Fill = Fill
    self.Text = Text
end

function ClassPowerBar:GetClassPowerType()
    if (Class == "ROGUE" or Class == "DRUID") then
        return SPELL_POWER_COMBO_POINTS
    elseif (Class == "WARLOCK") then
        return SPELL_POWER_SOUL_SHARDS
    elseif (Class == "PALADIN") then
        return SPELL_POWER_HOLY_POWER
    elseif (Class == "MONK") then
        return SPELL_POWER_CHI
    elseif (Class == "MAGE") then
        return SPELL_POWER_ARCANE_CHARGES
    elseif (Class == "EVOKER") then
        return SPELL_POWER_ESSENCE
    end
end

function ClassPowerBar:Update()
    if not (self.ClassPowerType) then 
        self.ClassPowerType = self:GetClassPowerType()
    end

    if not (self.ClassPowerType) then 
        return 
    end

    local Spec = GetSpecialization()
    local Min, Max, BarCount

    if (Class == "WARLOCK" and Spec == 3) then
        Min = UnitPower("player", self.ClassPowerType, true)
        Max = UnitPowerMax("player", self.ClassPowerType, true)
        BarCount = 5
    else
        Min = UnitPower("player", self.ClassPowerType)
        Max = UnitPowerMax("player", self.ClassPowerType)
        BarCount = Max
    end

    if (BarCount < 2) then 
        return 
    end

    if not (self.Separators) then 
        self.Separators = {}
    end

    for _, SepX in ipairs(self.Separators) do
        SepX:Hide()
    end

    local BarWidth, Spacing = 0, 2

    if (BarCount == 4) then
        BarWidth, Spacing = 214/BarCount, 3
    elseif (BarCount == 5) then
        BarWidth, Spacing = 206/BarCount, 4
    elseif (BarCount == 6) then
        BarWidth, Spacing = 212/BarCount, 2
    elseif (BarCount == 7) then
        BarWidth, Spacing = 206/BarCount, 3
    end

    local CurrentX = 0

    for i = 1, BarCount -1 do
        CurrentX = CurrentX + BarWidth + Spacing

        local SeperatorX = self.Separators[i]

        if not (SeperatorX) then
            SeperatorX = CreateFrame("Frame", nil, self.Bar)
            SeperatorX:Size(1, 8)
            SeperatorX:SetFrameLevel(self.Bar:GetFrameLevel() + 10)

            SeperatorX.Texture = SeperatorX:CreateTexture(nil, "OVERLAY")
            SeperatorX.Texture:SetInside()
            SeperatorX.Texture:SetColorTexture(0, 0, 0, 1)

            self.Separators[i] = SeperatorX
        end

        SeperatorX:ClearAllPoints()
        SeperatorX:Point("LEFT", self.Bar, "LEFT", CurrentX - Spacing/2, 0)
        SeperatorX:Show()
    end

    local FillMax = (Class == "WARLOCK" and Spec == 3) and UnitPowerMax("player", self.ClassPowerType, true) or Max

    if (Class == "PALADIN") then
        self.Fill:SetStatusBarColor(1, 0.82, 0)
    else    
        self.Fill:SetStatusBarColor(R, G, B)
    end

    self.Fill:SetMinMaxValues(0, FillMax)
    self.Fill:SetValue(Min)
    self.Fill:Show()

    self.Text:SetText(Min)
end

function ClassPowerBar:UpdateSpec()
    local Spec = GetSpecialization()

    if (Class == "ROGUE" or Class == "WARLOCK" or Class == "PALADIN" or Class == "EVOKER") then
        self.Bar:Show()
    elseif (Class == "DRUID" and UnitPowerType("player") == SPELL_POWER_ENERGY) then
        self.Bar:Show()
    elseif (Class == "MONK" and Spec == 3) then
        self.Bar:Show()
    elseif (Class == "MAGE" and Spec == 1) then
        self.Bar:Show()
    else
        self.Bar:Hide()
    end
end

function ClassPowerBar:OnEvent(event)
    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        self:Update()
    end

    self:UpdateSpec()
end

function ClassPowerBar:RegisterEvents()
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("UNIT_DISPLAYPOWER")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("UNIT_POWER_FREQUENT")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", self.OnEvent)
end

function ClassPowerBar:Initialize()
    if (not DB.Global.DataBars.ClassPowerBar) then
        return
    end

    self:CreateBar()
    self:RegisterEvents()
end
