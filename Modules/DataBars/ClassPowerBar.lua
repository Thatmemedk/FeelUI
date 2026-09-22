local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ClassPowerBar = UI:RegisterModule("ResourceBar")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local UnitClass = UnitClass
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

-- WoW Globals
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetSpecialization = C_SpecializationInfo.GetSpecialization()

-- WoW Globals
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

function ClassPowerBar:CreateBar()
    local Bar = CreateFrame("Frame", "FeelUI_ClassPowerBar", _G.UIParent)
    Bar:Size(263, 8)
    Bar:Point(unpack(DB.Global.DataBars.ClassPowerPoint))
    Bar:Hide()

    local InvisFrame = CreateFrame("Frame", nil, Bar)
    InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Bar, 0, 6)
    Text:SetFontTemplate("Default", 16)

    -- Cache
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
    local Min = UnitPower("player", self.ClassPowerType)
    local Max = UnitPowerMax("player", self.ClassPowerType)
    local BarCount = Max or 0

    if (not self.ClassPowerType) then
        self.ClassPowerType = self:GetClassPowerType()
    end

    if (not self.ClassPowerType) then
        return
    end

    if (not BarCount or BarCount == 0) then
        return
    end

    if (not self.Segment) then
        self.Segment = {}
    end

    if (not self.Backdrops) then
        self.Backdrops = {}
    end

    local BarWidth = 263
    local SegmentSpacing = 2
    local TotalSpacing = (BarCount -1) * SegmentSpacing

    for i = 1, BarCount do
        local Segment = self.Segment[i]
        local Backdrop = self.Backdrops[i]

        if (not Segment) then
            Segment = CreateFrame("StatusBar", nil, self.Bar)
            Segment:SetStatusBarTexture(Media.Global.Texture)

            self.Segment[i] = Segment
        end

        if (not Backdrop) then
            Backdrop = CreateFrame("StatusBar", nil, self.Bar)
            Backdrop:SetStatusBarTexture(Media.Global.Texture)
            Backdrop:SetTemplate()
            Backdrop:CreateShadow()

            self.Backdrops[i] = Backdrop
        end

        local SegmentWidth = math.floor((BarWidth - TotalSpacing) * i / BarCount) - math.floor((BarWidth - TotalSpacing) * (i - 1) / BarCount)

        if (IsMaelstrom) then
            Segment:Size(SegmentWidth, 12)
            Backdrop:Size(SegmentWidth, 12)
        else
            Segment:Size(SegmentWidth, 8)
            Backdrop:Size(SegmentWidth, 8)
        end

        Segment:ClearAllPoints()
        Backdrop:ClearAllPoints()

        if (i == 1) then
            Segment:Point("LEFT", self.Bar, "LEFT", 0, 0)
            Backdrop:Point("LEFT", self.Bar, "LEFT", 0, 0)
        elseif (i == BarCount) then
            Segment:Point("RIGHT", self.Bar, "RIGHT", 0, 0)
            Segment:Point("LEFT", self.Segment[i - 1], "RIGHT", SegmentSpacing, 0)
            Backdrop:Point("RIGHT", self.Bar, "RIGHT", 0, 0)
            Backdrop:Point("LEFT", self.Backdrops[i - 1], "RIGHT", SegmentSpacing, 0)
        else
            Segment:Point("LEFT", self.Segment[i - 1], "RIGHT", SegmentSpacing, 0)
            Backdrop:Point("LEFT", self.Backdrops[i - 1], "RIGHT", SegmentSpacing, 0)
        end

        if (i == 1) then
            Segment:SetStatusBarColor(R1, G1, B1)
            Backdrop:SetStatusBarColor(R1 * 0.5, G1 * 0.5, B1 * 0.5, 0.7)
        elseif (i == 2) then
            Segment:SetStatusBarColor(R2, G2, B2)
            Backdrop:SetStatusBarColor(R2 * 0.5, G2 * 0.5, B2 * 0.5, 0.7)
        elseif (i == 3) then
            Segment:SetStatusBarColor(R3, G3, B3)
            Backdrop:SetStatusBarColor(R3 * 0.5, G3 * 0.5, B3 * 0.5, 0.7)
        elseif (i == 4) then
            Segment:SetStatusBarColor(R4, G4, B4)
            Backdrop:SetStatusBarColor(R4 * 0.5, G4 * 0.5, B4 * 0.5, 0.7)
        elseif (i == 5) then
            Segment:SetStatusBarColor(R5, G5, B5)
            Backdrop:SetStatusBarColor(R5 * 0.5, G5 * 0.5, B5 * 0.5, 0.7)
        elseif (i == 6 or i == 7) then
            Segment:SetStatusBarColor(R6, G6, B6)
            Backdrop:SetStatusBarColor(R6 * 0.5, G6 * 0.5, B6 * 0.5, 0.7)
        end

        if (i <= Min) then
            UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
        else
            UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0)
        end

        self.Bar[i] = Segment
    end
end

function ClassPowerBar:UpdateSpec()
    if (Class == "ROGUE") then
        self.Bar:Show()
    elseif (Class == "DRUID" and UnitPowerType("player") == SPELL_POWER_ENERGY) then
        self.Bar:Show()
    else
        self.Bar:Hide()
    end
end

function ClassPowerBar:OnEvent(event)
    self:Update()
    self:UpdateSpec()
end

function ClassPowerBar:RegisterEvents()
    -- PLAYER
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- UNIT EVENTS
    self:RegisterEvent("UNIT_DISPLAYPOWER", "player")
    self:RegisterEvent("UNIT_MAXPOWER", "player")
    self:RegisterEvent("UNIT_POWER_FREQUENT", "player")
    self:RegisterEvent("UNIT_POWER_UPDATE", "player")
    -- ON EVENT
    self:SetScript("OnEvent", self.OnEvent)
end

function ClassPowerBar:Initialize()
    if (not DB.Global.DataBars.ClassPowerBar) then
        return
    end

    self:CreateBar()
    self:RegisterEvents()
end