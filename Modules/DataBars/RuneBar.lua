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

    local RunesBars = {}
    local RunesBarsBackdrop = {}

    local BarCount = 6
    local BarWidth = 242
    local SegmentSpacing = 2
    local TotalSpacing = (BarCount - 1) * SegmentSpacing
    local BaseWidth = (BarWidth - TotalSpacing) / BarCount
    local Widths = {}
    local SumWidths = 0

    for i = 1, BarCount do
        Widths[i] = math.floor(BaseWidth)
        SumWidths = SumWidths + Widths[i]
    end

    local Remainder = BarWidth - TotalSpacing - SumWidths

    for i = 1, Remainder do
        Widths[i] = Widths[i] + 1
    end

    local X = 0

    for i = 1, BarCount do
        local Bars = CreateFrame("StatusBar", nil, Bar)
        Bars:SetStatusBarTexture(Media.Global.Texture)

        local Backdrop = CreateFrame("Frame", nil, Bar)
        Backdrop:CreateBackdrop()
        Backdrop:CreateShadow()

        Bars:Size(Widths[i], 8)
        Backdrop:Size(Widths[i], 8)

        Bars:ClearAllPoints()
        Bars:Point("LEFT", Bar, "LEFT", X, 0)

        Backdrop:ClearAllPoints()
        Backdrop:Point("LEFT", Bar, "LEFT", X, 0)

        X = X + Widths[i] + SegmentSpacing

        RunesBars[i] = Bars
        RunesBarsBackdrop[i] = Backdrop
    end

    self.Bar = Bar
    self.RunesBars = RunesBars
    self.RunesBarsBackdrop = RunesBarsBackdrop
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
    for i = 1, 6 do
        local Bar = self.RunesBars[i]

        if not (Bar) then
            return
        end

        local Start, Duration, RuneIsReady = GetRuneCooldown(i)

        if (Start and Duration) then
            local Elapsed = GetTime() - Start
            
            Bar.Duration = Elapsed
            Bar.Max = Duration
            Bar:SetMinMaxValues(0, Duration)

            if (RuneIsReady) then
                Bar:SetValue(Duration, UI.SmoothBars)
                Bar:SetScript("OnUpdate", nil)

                UI:UIFrameFadeIn(Bar, 0.25, Bar:GetAlpha(), 1)
            else
                Bar:SetValue(Elapsed, UI.SmoothBars)
                Bar:SetScript("OnUpdate", self.OnUpdate)

                UI:UIFrameFadeOut(Bar, 0.25, Bar:GetAlpha(), 0.50)
            end
        else
            Bar:SetMinMaxValues(0, 1)
            Bar:SetValue(1, UI.SmoothBars)
            Bar:SetScript("OnUpdate", nil)
        end
    end
end

function RuneBar:UpdateSpec()   
    local GetSpecialization = GetSpecialization()

    if (DB.Global.DataBars.RuneBarSpecColor) then
        local RuneBarColor

        if (GetSpecialization == 1) then
            RuneBarColor = BloodColor
        elseif (GetSpecialization == 2) then
            RuneBarColor = FrostColor
        elseif (GetSpecialization == 3) then
            RuneBarColor = UnholyColor
        end

        if (RuneBarColor) then
            for i = 1, 6 do
                self.RunesBars[i]:SetStatusBarColor(unpack(RuneBarColor))
            end
        end
    else
        local Bar = self.RunesBars
        local Backdrop = self.RunesBarsBackdrop

        Bar[1]:SetStatusBarColor(unpack(BloodColor))
        Bar[2]:SetStatusBarColor(unpack(BloodColor))
        Bar[3]:SetStatusBarColor(unpack(FrostColor))
        Bar[4]:SetStatusBarColor(unpack(FrostColor))
        Bar[5]:SetStatusBarColor(unpack(UnholyColor))
        Bar[6]:SetStatusBarColor(unpack(UnholyColor))
    end
end

function RuneBar:OnEvent(event)
    if (event == "RUNE_POWER_UPDATE") or (event == "RUNE_TYPE_UPDATE") then
        self:Update()
    elseif (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TALENT_UPDATE") then
        self:UpdateSpec()
    end
end

function RuneBar:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("RUNE_POWER_UPDATE")
    self:RegisterEvent("RUNE_TYPE_UPDATE")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
end

function RuneBar:Initialize()
    if (not DB.Global.DataBars.RuneBar or Class ~= "DEATHKNIGHT") then
        return
    end

    self:CreateBar()
    self:RegisterEvents()
end