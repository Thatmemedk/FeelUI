local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local SoulFragmentsBar = UI:RegisterModule("SoulFragmentsBar")

-- WoW Globals
local UnitClass = UnitClass
local GetSpecialization = GetSpecialization
local DemonHunterSoulFragmentsBar = _G.DemonHunterSoulFragmentsBar

-- Locals
local Class = select(2, UnitClass("player"))

function SoulFragmentsBar:CreateBar()
    local Bar = CreateFrame("StatusBar", nil, _G.UIParent)
    Bar:Size(222, 8)
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

    DemonHunterSoulFragmentsBar:Show()
    DemonHunterSoulFragmentsBar:SetParent(_G.UIParent)
    DemonHunterSoulFragmentsBar:ClearAllPoints()
    DemonHunterSoulFragmentsBar:Point(unpack(DB.Global.DataBars.SoulFragmentsBarPoint))
    DemonHunterSoulFragmentsBar:SetAlpha(0)

    self.Bar = Bar
    self.Text = Text
end

function SoulFragmentsBar:Update()
    local Min, Max = DemonHunterSoulFragmentsBar:GetMinMaxValues()
    local Current = DemonHunterSoulFragmentsBar:GetValue() 

    self.Bar:SetMinMaxValues(0, Max)
    self.Bar:SetValue(Current, UI.SmoothBars)
    self.Text:SetText(Current)
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
    self:RegisterEvent("UNIT_POWER_FREQUENT")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("UNIT_POWER_UPDATE")
    self:RegisterEvent("UNIT_DISPLAYPOWER")
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
