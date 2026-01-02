local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local RuneBar = UI:RegisterModule("RuneBar")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local GetRuneCooldown = GetRuneCooldown
local GetTime = GetTime
local UnitClass = UnitClass
local GetSpecialization = GetSpecialization

-- Locals
local Class = select(2, UnitClass("player"))

-- Color Tabels
local Mult = 2.5
local BloodColor = { 1 * Mult, 0, 0 }
local FrostColor = { 0, 0.35 * Mult, 1 * Mult }
local UnholyColor = { 0.25 * Mult, 0.55 * Mult, 0.10 * Mult }

function RuneBar:CreateBar()
    local Bar = CreateFrame("StatusBar", nil, _G.UIParent)
    Bar:Size(242, 8)
    Bar:Point(unpack(DB.Global.DataBars.RuneBarPoint))

    self.Bar = Bar
end

function RuneBar:OnUpdate(Elapsed)
    self.Duration = self.Duration + Elapsed

    if (self.Duration >= self.Max) then
        self.Duration = self.Max
        
        self:SetValue(self.Max)
        self:SetScript("OnUpdate", nil)
    else
        self:SetValue(self.Duration, UI.SmoothBars)
    end
end

function RuneBar:Update()
    if (not self.Segment) then 
        self.Segment = {} 
    end 

    if (not self.Backdrops) then 
        self.Backdrops = {} 
    end

    local BarCount = 6
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

        if (i <= 2) then
            Segment:SetStatusBarColor(unpack(BloodColor))
            Backdrop:SetStatusBarColor(1 * Mult, 0, 0, 0.5)
        elseif (i <= 4) then
            Segment:SetStatusBarColor(unpack(FrostColor))
            Backdrop:SetStatusBarColor(0, 0.35 * Mult, 1 * Mult, 0.5)
        else
            Segment:SetStatusBarColor(unpack(UnholyColor))
            Backdrop:SetStatusBarColor(0.25 * Mult, 0.55 * Mult, 0.10 * Mult, 0.5)
        end

        local Start, Duration, RuneIsReady = GetRuneCooldown(i)

        if (Start and Duration) then
            local Elapsed = GetTime() - Start
            Segment.Duration = Elapsed
            Segment.Max = Duration
            Segment:SetMinMaxValues(0, Duration)

            if (RuneIsReady) then
                Segment:SetValue(Duration, UI.SmoothBars)
                Segment:SetScript("OnUpdate", nil)

                UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
            else
                Segment:SetValue(Elapsed, UI.SmoothBars)
                Segment:SetScript("OnUpdate", self.OnUpdate)

                UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0.50)
            end
        else
            Segment:SetMinMaxValues(0, 1)
            Segment:SetValue(1, UI.SmoothBars)
            Segment:SetScript("OnUpdate", nil)
        end
    end
end

function RuneBar:OnEvent(event)
    self:Update()
end

function RuneBar:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("RUNE_POWER_UPDATE")
    self:RegisterEvent("RUNE_TYPE_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
end

function RuneBar:Initialize()
    if (not DB.Global.DataBars.RuneBar or Class ~= "DEATHKNIGHT") then
        return
    end

    self:CreateBar()
    self:RegisterEvents()
end