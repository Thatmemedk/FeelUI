local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local SoulFragmentsBar = UI:RegisterModule("SoulFragmentsBar")

-- WoW Globals
local GetSpecialization = GetSpecialization
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetSpellMaxCumulativeAuraApplications = C_Spell.GetSpellMaxCumulativeAuraApplications

-- Locals
local Class = select(2, UnitClass("player"))

function SoulFragmentsBar:CreateBar()
    local Bar = CreateFrame("StatusBar", nil, _G.UIParent)
    Bar:Size(242, 8)
    Bar:Point(unpack(DB.Global.DataBars.SoulFragmentsBarPoint))
    Bar:SetStatusBarTexture(Media.Global.Texture)
    Bar:SetStatusBarColor(0.55, 0.25, 1 * 2)
    Bar:CreateBackdrop()
    Bar:CreateShadow()
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
    self.InVoidMeta = false
end

function SoulFragmentsBar:Update()
    local InVoidMeta = GetPlayerAuraBySpellID(1217607) ~= nil
    local Min, Max = 0, 0

    if (InVoidMeta ~= self.InVoidMeta) then
        self.InVoidMeta = InVoidMeta
    end

    if (self.InVoidMeta) then
        local CollapsingStar = GetPlayerAuraBySpellID(1225789)
        Min = CollapsingStar and CollapsingStar.applications or 0
        Max = GetCollapsingStarCost()
    else
        local VoidMeta = GetPlayerAuraBySpellID(1225789)
        Min = VoidMeta and VoidMeta.applications or 0
        Max = GetSpellMaxCumulativeAuraApplications(1225789)
    end

    -- Set Values
    self.Bar:SetMinMaxValues(0, Max)
    self.Bar:SetValue(Min, UI.SmoothBars)

    -- Set Text
    self.Text:SetText(Min)
end

function SoulFragmentsBar:UpdateSpec()
    local Spec = GetSpecialization()

    if (Class == "DEMONHUNTER" and Spec == 3) then
        self.Bar:Show()
    else
        self.Bar:Hide()
    end
end

function SoulFragmentsBar:OnEvent(event, ...)
    self:Update()
    self:UpdateSpec()
end

function SoulFragmentsBar:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA", "player")
    self:RegisterEvent("UNIT_SPELLCAST_START", "player")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("SPELLS_CHANGED")
    self:SetScript("OnEvent", self.OnEvent)
end

function SoulFragmentsBar:Initialize()
    if (not DB.Global.DataBars.SoulFragmentsBar or Class ~= "DEMONHUNTER") then
        return
    end

    self:CreateBar()
    self:RegisterEvents()
end