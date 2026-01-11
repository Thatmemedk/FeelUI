local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local MaelstromBar = UI:RegisterModule("MaelstromBar")

-- WoW Globals
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

-- Locals
local Class = select(2, UnitClass("player"))

-- Colors
local R, G, B = unpack(UI.GetClassColors)
local Mult = 0.5

function MaelstromBar:CreateBar()
    local Bar = CreateFrame("Frame", nil, _G.UIParent)
    Bar:Size(242, 12)
    Bar:Point(unpack(DB.Global.DataBars.MaelstromBarPoint))
    Bar:Hide()

    local InvisFrame = CreateFrame("Frame", nil, Bar)
    InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Bar, 0, 8)
    Text:SetFontTemplate("Default", 22)

    -- Cache
    self.Bar = Bar
    self.Text = Text
end

function MaelstromBar:Update()
    local Maelstrom = GetPlayerAuraBySpellID(344179)
    local Stacks = Maelstrom and Maelstrom.applications or 0

    if (not self.Segment) then 
        self.Segment = {} 
    end 

    if (not self.Backdrops) then 
        self.Backdrops = {} 
    end

    local BarCount = 10
    local BarWidth = 242
    local SegmentSpacing = 2
    local TotalSpacing = (BarCount - 1) * SegmentSpacing

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
            Backdrop:CreateBackdrop()
            Backdrop:CreateShadow()

            self.Backdrops[i] = Backdrop
        end

        local SegmentWidth = math.floor((BarWidth - TotalSpacing) * i / BarCount) - math.floor((BarWidth - TotalSpacing) * (i - 1) / BarCount)

        Segment:Size(SegmentWidth, 8)
        Backdrop:Size(SegmentWidth, 8)

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

        Segment:SetStatusBarColor(R, G, B)
        Backdrop:SetStatusBarColor(R * Mult, G * Mult, B * Mult, 0.5)

        if (i <= Stacks) then 
            UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1) 
        else 
            UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0) 
        end
    end

    self.Text:SetText(Stacks == 0 and "" or Stacks)
end

function MaelstromBar:UpdateSpec()
    local Spec = GetSpecialization()

    if (Class == "SHAMAN" and Spec == 2) then
        self.Bar:Show()
    else
        self.Bar:Hide()
    end
end

function MaelstromBar:OnEvent(event, unit)
    self:Update()
    self:UpdateSpec()
end

function MaelstromBar:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA", "player")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("SPELLS_CHANGED")
    self:SetScript("OnEvent", self.OnEvent)
end

function MaelstromBar:Initialize()
    if (not DB.Global.DataBars.MaelstromBar or Class ~= "SHAMAN") then
        return
    end

    self:CreateBar()
    self:RegisterEvents()
end