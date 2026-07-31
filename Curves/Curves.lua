local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- DISPELL CURVE

local DEBUFF_DISPLAY_COLOR_INFO = {
    [0] = _G.DEBUFF_TYPE_NONE_COLOR,
    [1] = _G.DEBUFF_TYPE_MAGIC_COLOR,
    [2] = _G.DEBUFF_TYPE_CURSE_COLOR,
    [3] = _G.DEBUFF_TYPE_DISEASE_COLOR,
    [4] = _G.DEBUFF_TYPE_POISON_COLOR,
    [11] = _G.DEBUFF_TYPE_BLEED_COLOR, -- Bleed Color
    [9] = CreateColor(243, 95, 245), -- Enrage Color
}

UI.DispelColorCurve = C_CurveUtil.CreateColorCurve()
UI.DispelColorCurve:SetType(Enum.LuaCurveType.Step)

for DebuffType, ColorInfo in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
    UI.DispelColorCurve:AddPoint(DebuffType, ColorInfo)
end

-- HEALTH CURVE

UI.UnitFramesHealthColorCurve = C_CurveUtil.CreateColorCurve()
UI.UnitFramesHealthColorCurve:SetType(Enum.LuaCurveType.Cosine)
UI.UnitFramesHealthColorCurve:AddPoint(0, CreateColor(0.6, 0, 0, 0.7))
UI.UnitFramesHealthColorCurve:AddPoint(0.90, CreateColor(0.6, 0.6, 0, 0.7))
UI.UnitFramesHealthColorCurve:AddPoint(1, CreateColor(unpack(DB.Global.UnitFrames.HealthBarColor)))

-- NAMEPLATES CURVE

UI.NameplatesHealthColorCurve = C_CurveUtil.CreateColorCurve()
UI.NameplatesHealthColorCurve:SetType(Enum.LuaCurveType.Cosine)
UI.NameplatesHealthColorCurve:AddPoint(0, CreateColor(0.6, 0, 0, 0.7))
UI.NameplatesHealthColorCurve:AddPoint(0.90, CreateColor(0.6, 0.6, 0, 0.7))
UI.NameplatesHealthColorCurve:AddPoint(1, CreateColor(unpack(DB.Global.Nameplates.HealthBarColor)))

-- COOLDOWN CURVE

UI.CooldownColorCurve = C_CurveUtil.CreateColorCurve()
UI.CooldownColorCurve:SetType(Enum.LuaCurveType.Step)
UI.CooldownColorCurve:AddPoint(0,  CreateColor(unpack(DB.Global.CooldownFrame.ExpireColor)))
UI.CooldownColorCurve:AddPoint(9,  CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor)))
UI.CooldownColorCurve:AddPoint(29, CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor2)))
UI.CooldownColorCurve:AddPoint(59, CreateColor(unpack(DB.Global.CooldownFrame.NormalColor)))