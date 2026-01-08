local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- DISPELL CURVE

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

for DebuffType, ColorInfo in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
    UI.DispelColorCurve:AddPoint(DebuffType, ColorInfo)
end

-- HEALTH CURVE

UI.HealthColorCurve = C_CurveUtil.CreateColorCurve()
UI.HealthColorCurve:SetType(Enum.LuaCurveType.Cosine)
UI.HealthColorCurve:AddPoint(0, CreateColor(0.6, 0, 0, 0.7))
UI.HealthColorCurve:AddPoint(0.90, CreateColor(0.6, 0.6, 0, 0.7))
UI.HealthColorCurve:AddPoint(1, CreateColor(unpack(DB.Global.UnitFrames.HealthBarColor)))

-- COOLDOWN CURVE

UI.CooldownColorCurve = C_CurveUtil.CreateColorCurve()
UI.CooldownColorCurve:SetType(Enum.LuaCurveType.Step)
UI.CooldownColorCurve:AddPoint(0,  CreateColor(unpack(DB.Global.CooldownFrame.ExpireColor)))
UI.CooldownColorCurve:AddPoint(9,  CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor)))
UI.CooldownColorCurve:AddPoint(29, CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor2)))
UI.CooldownColorCurve:AddPoint(59, CreateColor(unpack(DB.Global.CooldownFrame.NormalColor)))