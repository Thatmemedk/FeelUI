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

-- Colors
local R1, G1, B1 = 0.67, 0.43, 0.32
local R2, G2, B2 = 0.65, 0.56, 0.33
local R3, G3, B3 = 0.58, 0.62, 0.33
local R4, G4, B4 = 0.45, 0.60, 0.33
local R5, G5, B5 = 0.33, 0.59, 0.33
local R6, G6, B6 = 0.33, 0.59, 0.33
local Mult = 0.5

function ClassPowerBar:CreateBar()
    local Bar = CreateFrame("Frame", nil, _G.UIParent)
    Bar:SetFrameStrata("LOW")
    Bar:Size(222, 8)
    Bar:Point(unpack(DB.Global.DataBars.ClassPowerPoint))
    Bar:Hide()

    local InvisFrame = CreateFrame("Frame", nil, Bar)
    InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Bar, 0, 6)
    Text:SetFontTemplate("Default", 16)

    self.Bar = Bar
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
    if (not self.ClassPowerType) then
        self.ClassPowerType = self:GetClassPowerType()
    end

    if (not self.ClassPowerType) then 
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

    if (not self.Segment) then
        self.Segment = {}
    end

    if (not self.Backdrops)  then
        self.Backdrops = {}
    end

    local BarWidth = 222
    local SegmentSpacing = 2
    local SegmentWidth = math.floor((BarWidth - ((BarCount - 1) * SegmentSpacing)) / BarCount + 0.5)

    for i = 1, BarCount do
        local Segment = self.Segment[i]
        local Backdrop = self.Backdrops[i]

        if (not Segment) then
            Segment = CreateFrame("StatusBar", nil, self.Bar)
            Segment:SetStatusBarTexture(Media.Global.Texture)
            Segment:SetAlpha(0)

            self.Segment[i] = Segment
        end

        if (not Backdrop) then
            Backdrop = CreateFrame("StatusBar", nil, self.Bar)
            Backdrop:SetStatusBarTexture(Media.Global.Texture)
            Backdrop:CreateBackdrop()
            Backdrop:CreateShadow()

            self.Backdrops[i] = Backdrop
        end

        Segment:Size(SegmentWidth, 8)
        Backdrop:Size(SegmentWidth, 8)

        if (i == 1) then
            Segment:Point("LEFT", self.Bar, "LEFT", 0, 0)
            Backdrop:Point("LEFT", self.Bar, "LEFT", 0, 0)
        else
            Segment:Point("LEFT", self.Segment[i-1], "RIGHT", SegmentSpacing, 0)
            Backdrop:Point("LEFT", self.Backdrops[i-1], "RIGHT", SegmentSpacing, 0)
        end

        if (i == 1) then
            Segment:SetStatusBarColor(R1, G1, B1)
            Backdrop:SetStatusBarColor(R1 * Mult, G1 * Mult, B1 * Mult, 0.5)
        elseif (i == 2) then
            Segment:SetStatusBarColor(R2, G2, B2)
            Backdrop:SetStatusBarColor(R2 * Mult, G2 * Mult, B2 * Mult, 0.5)
        elseif (i == 3) then
            Segment:SetStatusBarColor(R3, G3, B3)
            Backdrop:SetStatusBarColor(R3 * Mult, G3 * Mult, B3 * Mult, 0.5)
        elseif (i == 4) then
            Segment:SetStatusBarColor(R4, G4, B4)
            Backdrop:SetStatusBarColor(R4 * Mult, G4 * Mult, B4 * Mult, 0.5)
        elseif (i == 5) then
            Segment:SetStatusBarColor(R5, G5, B5)
            Backdrop:SetStatusBarColor(R5 * Mult, G5 * Mult, B5 * Mult, 0.5)
        elseif (i == 6) then
            Segment:SetStatusBarColor(R6, G6, B6)
            Backdrop:SetStatusBarColor(R6 * Mult, G6 * Mult, B6 * Mult, 0.5)
        elseif (i == 7) then
            Segment:SetStatusBarColor(R6, G6, B6)
            Backdrop:SetStatusBarColor(R6 * Mult, G6 * Mult, B6 * Mult, 0.5)
        end

        if (Class == "MAGE" or Class == "WARLOCK" or Class == "MONK" or Class == "EVOKER") then
            local R, G, B = unpack(UI.GetClassColors)
        
            Segment:SetStatusBarColor(R, G, B)
            Backdrop:SetStatusBarColor(R * Mult, G * Mult, B * Mult, 0.5)
        elseif (Class == "PALADIN") then
            Segment:SetStatusBarColor(1, 0.82, 0)
            Backdrop:SetStatusBarColor(1 * Mult, 0.82 * Mult, 0 * Mult, 0.5)
        end

        if (Class == "WARLOCK" and Spec == 3) then
            local BarMin = (i - 1) * 10
            local BarMax = i * 10

            Segment:SetMinMaxValues(0, 10)

            if (Min >= BarMax) then
                Segment:SetValue(10, UI.SmoothBars)
                UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
            elseif (Min <= BarMin) then
                Segment:SetValue(0, UI.SmoothBars)
                UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0)
            else
                Segment:SetValue(Min - BarMin, UI.SmoothBars)
                UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
            end
        else
            if (i <= Min) then
                UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
            else
                UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0)
            end

            --Segment:SetMinMaxValues(0, 1)
            --Segment:SetValue(i <= Min and 1 or 0, UI.SmoothBars)
        end

        self.Bar[i] = Segment
    end

    self.Text:SetText(Min == 0 and "" or Min)
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
    if (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER") then
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
