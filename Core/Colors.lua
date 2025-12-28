local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local floor = math.floor
local min = math.min
local format = string.format

-- Locals
local ClassID = select(2, UnitClass("player"))

-- CREATE COLORS

function UI:CreateColor(R, G, B, A)
    R = R or 1
    G = G or 1
    B = B or 1
    A = A or 1

    if (R > 1 or G > 1 or B > 1) then
        R, G, B = R / 255, G / 255, B / 255
    end

    local color = {
        r = min(R, 1),
        g = min(G, 1),
        b = min(B, 1),
        a = min(A, 1)
    }

    color[1] = color.r
    color[2] = color.g
    color[3] = color.b

    local R255 = floor(color.r * 255 + 0.5)
    local G255 = floor(color.g * 255 + 0.5)
    local B255 = floor(color.b * 255 + 0.5)
    color.hex = format("ff%02x%02x%02x", R255, G255, B255)

    return color
end

-- COLOR CURVES

local DEBUFF_DISPLAY_COLOR_INFO = {
    [0] = DEBUFF_TYPE_NONE_COLOR,
    [1] = DEBUFF_TYPE_MAGIC_COLOR,
    [2] = DEBUFF_TYPE_CURSE_COLOR,
    [3] = DEBUFF_TYPE_DISEASE_COLOR,
    [4] = DEBUFF_TYPE_POISON_COLOR,
    [9] = DEBUFF_TYPE_BLEED_COLOR, -- Enrage Color
    [11] = DEBUFF_TYPE_BLEED_COLOR, -- Bleed Color
}

UI.DispelColorCurve = C_CurveUtil.CreateColorCurve()
UI.DispelColorCurve:SetType(Enum.LuaCurveType.Step)

for i, c in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
    UI.DispelColorCurve:AddPoint(i, c)
end

-- Gradient Color Green To Red
UI.HealthColorCurve = C_CurveUtil.CreateColorCurve()
UI.HealthColorCurve:SetType(Enum.LuaCurveType.Cosine)
UI.HealthColorCurve:AddPoint(0, CreateColor(0.38, 0, 0, 0.7))
UI.HealthColorCurve:AddPoint(0.5, CreateColor(0.46, 0.40, 0, 0.7))
UI.HealthColorCurve:AddPoint(0.9, CreateColor(0, 0.20, 0, 0.7))
UI.HealthColorCurve:AddPoint(1, CreateColor(0.10, 0.10, 0.10, 0.7))

-- COLOR TABLES

UI.Colors = {
	EmpowerStagesColors = {
	    [1] = UI:CreateColor(0, 0.82, 0),
	    [2] = UI:CreateColor(0.82, 0, 0),
	    [3] = UI:CreateColor(1, 0.42, 0),
	    [4] = UI:CreateColor(1, 0.82, 0),
	    [5] = UI:CreateColor(1, 1, 0.42),
	},

    Reaction = {
        [1] = UI:CreateColor(0.80, 0.30, 0.22),
        [2] = UI:CreateColor(0.80, 0.30, 0.22),
        [3] = UI:CreateColor(0.80, 0.30, 0.22),
        [4] = UI:CreateColor(0.90, 0.70, 0.00),
        [5] = UI:CreateColor(0.00, 0.60, 0.10),
        [6] = UI:CreateColor(0.00, 0.60, 0.10),
        [7] = UI:CreateColor(0.00, 0.60, 0.10),
        [8] = UI:CreateColor(0.00, 0.60, 0.10),
    },

    Classification = {
	    BOSS = UI:CreateColor(1, 0.2, 0),
	    RARE = UI:CreateColor(0.9, 0.2, 0.9),
	   	ELITE = UI:CreateColor(0.8, 0, 0.8),
	    CASTER = UI:CreateColor(0, 0.7, 1),
    },

    Power = {
	    MANA = UI:CreateColor(0.31, 0.45, 0.63),
	    RAGE = UI:CreateColor(0.69, 0.31, 0.31),
	    FOCUS = UI:CreateColor(1.00, 0.50, 0.25),
	    ENERGY = UI:CreateColor(0.65, 0.63, 0.35),
	    COMBO_POINTS = UI:CreateColor(1.00, 0.96, 0.41),
	    RUNES = UI:CreateColor(0.50, 0.50, 0.50),
	    RUNIC_POWER = UI:CreateColor(0.00, 0.82, 1.00),
	    SOUL_SHARDS = UI:CreateColor(0.50, 0.32, 0.55),
	    LUNAR_POWER = UI:CreateColor(0.93, 0.51, 0.93),
	    HOLY_POWER = UI:CreateColor(0.96, 0.55, 0.73),
	    MAELSTROM = UI:CreateColor(0.00, 0.50, 1.00),
	    CHI = UI:CreateColor(0.00, 1.00, 0.59),
	    INSANITY = UI:CreateColor(0.40, 0.00, 0.80),
	    ARCANE_CHARGES = UI:CreateColor(0.20, 0.30, 1.00),
	    FURY = UI:CreateColor(0.78, 0.26, 0.99),
	    PAIN = UI:CreateColor(1.00, 0.61, 0.00),
	    ESSENCE = UI:CreateColor(0.39, 0.68, 0.81),
	    ALTERNATE = UI:CreateColor(0.70, 0.70, 0.60),
    },

	Class = {
	    WARRIOR = UI:CreateColor(0.78, 0.61, 0.43),
	    MAGE = UI:CreateColor(0.25, 0.78, 0.92),
	    ROGUE = UI:CreateColor(1.00, 0.96, 0.41),
	    DRUID = UI:CreateColor(1.00, 0.49, 0.04),
	    HUNTER = UI:CreateColor(0.67, 0.83, 0.45),
	    SHAMAN = UI:CreateColor(0.00, 0.44, 0.87),
	    PRIEST = UI:CreateColor(0.659, 0.843, 1),
	    WARLOCK = UI:CreateColor(0.53, 0.53, 0.93),
	    PALADIN = UI:CreateColor(0.96, 0.55, 0.73),
	    MONK = UI:CreateColor(0.00, 1.00, 0.59),
	    DEATHKNIGHT = UI:CreateColor(0.77, 0.12, 0.23),
	    DEMONHUNTER = UI:CreateColor(0.64, 0.19, 0.79),
	    EVOKER = UI:CreateColor(0.20, 0.58, 0.50),
	},
}

UI.GetClassColors = UI.Colors.Class[ClassID]