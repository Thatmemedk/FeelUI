local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local MaelstromBar = UI:RegisterModule("MaelstromBar")

-- WoW Globals
local CreateFrame = CreateFrame
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local UnitClass = UnitClass
local GetSpecialization = GetSpecialization

-- Locals
local Class = select(2, UnitClass("player"))

-- Colors
local R, G, B = unpack(UI.GetClassColors)

-- Colors
local Mult = 0.5

function MaelstromBar:Update()
    if not self.Bar or not self.Bar:IsShown() then 
        return 
    end

    local Maelstrom = GetPlayerAuraBySpellID(344179)
    local Stacks = Maelstrom and Maelstrom.applications or 0
    local Max = 10
    local Spacing = 2
    local BarWidth = (222 - (Max - 1) * Spacing) / Max

    self.Text:SetText(Stacks == 0 and "" or Stacks)

    for i = 1, Max do
        local Bar = self.Bars[i]
        local Backdrop = self.Backdrops[i]

        if (not Bar) then
            Bar = CreateFrame("StatusBar", nil, self.Bar)
            Bar:SetStatusBarTexture(Media.Global.Texture)

            self.Bars[i] = Bar
        end

        if (not Backdrop) then
            Backdrop = CreateFrame("StatusBar", nil, self.Backdrop)
            Backdrop:SetStatusBarTexture(Media.Global.Texture)
            Backdrop:CreateBackdrop()
            Backdrop:CreateShadow()

            self.Backdrops[i] = Backdrop
        end

        Bar:Size(BarWidth, 12)
        Backdrop:Size(BarWidth, 12)

        if (i == 1) then
            Bar:Point("LEFT", self.Bar, "LEFT", 0, 0)
            Backdrop:Point("LEFT", self.Backdrop, "LEFT", 0, 0)
        else
            Bar:Point("LEFT", self.Bars[i-1], "RIGHT", Spacing, 0)
            Backdrop:Point("LEFT", self.Backdrops[i-1], "RIGHT", Spacing, 0)
        end

        Bar:SetStatusBarColor(R, G, B)
        Backdrop:SetStatusBarColor(R * Mult, G * Mult, B * Mult, 0.5)

        if (i <= Stacks) then 
            UI:UIFrameFadeIn(Bar, 0.25, Bar:GetAlpha(), 1) 
        else 
            UI:UIFrameFadeOut(Bar, 0.25, Bar:GetAlpha(), 0) 
        end
    end

    self.Bar.Max = Max
end

function MaelstromBar:UpdateSpec()
    local Spec = GetSpecialization()

    if (Class == "SHAMAN" and Spec == 2) then
        self.Bar:Show()
        self.Backdrop:Show()
    else
        self.Bar:Hide()
        self.Backdrop:Hide()
    end
end

function MaelstromBar:OnEvent(event, unit)
    if (event == "UNIT_AURA" and unit ~= "player") then 
        return 
    end

    if (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_AURA" or event == "SPELL_UPDATE_COOLDOWN") then
        self:Update()
    end

    if (event == "PLAYER_SPECIALIZATION_CHANGED" or event == "SPELLS_CHANGED" or event == "PLAYER_TALENT_UPDATE") then
        self:UpdateSpec()
    end
end

function MaelstromBar:CreateBar()
    local Bar = CreateFrame("Frame", nil, _G.UIParent)
    Bar:SetFrameStrata("LOW")
    Bar:Size(222, 12)
    Bar:Point(unpack(DB.Global.DataBars.MaelstromBarPoint))
    Bar:Hide()

    local Backdrop = CreateFrame("Frame", nil, Bar)
    Backdrop:Size(222, 12)
    Backdrop:SetFrameLevel(Bar:GetFrameLevel() - 1)
    Backdrop:Point("CENTER", Bar, 0, 0)
    Backdrop:Hide()

    local InvisFrame = CreateFrame("Frame", nil, Bar)
    InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Bar, 0, 8)
    Text:SetFontTemplate("Default", 22)

    self.Bar = Bar
    self.Backdrop = Backdrop
    self.Text = Text
    self.Bars = {}
    self.Backdrops = {}
end

function MaelstromBar:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
end

function MaelstromBar:Initialize()
    if (not DB.Global.DataBars.MaelstromBar or Class ~= "SHAMAN") then
        return
    end

    --self:CreateBar()
    --self:RegisterEvents()
end
