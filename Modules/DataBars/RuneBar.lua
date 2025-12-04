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
    Bar:Size(222, 8)
    Bar:Point(unpack(DB.Global.DataBars.RuneBarPoint))
    
    local RunesBars = {}
    local RunesBarsBackdrop = {}

    for i = 1, 6 do
        local Bars = CreateFrame("StatusBar", nil, Bar)
        Bars:Size(212/6, 8)
        Bars:SetStatusBarTexture(Media.Global.Texture)

        local Backdrop = CreateFrame("StatusBar", nil, Bar)
        Backdrop:Size(212/6, 8)
        Backdrop:SetStatusBarTexture(Media.Global.Texture)
        Backdrop:CreateBackdrop()
        Backdrop:CreateShadow()
        
        if (i == 1) then
            Bars:Point("LEFT", Bar, 0, 0)
            Backdrop:Point("LEFT", Bar, 0, 0)
        else
            Bars:Point("LEFT", RunesBars[i-1], "RIGHT", 2, 0)
            Backdrop:Point("LEFT", RunesBarsBackdrop[i-1], "RIGHT", 2, 0)
        end
        
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
            Bar:SetValue(Elapsed, UI.SmoothBars)

            if (RuneIsReady) then
                Bar:SetScript("OnUpdate", nil)
                Bar:SetValue(Duration, UI.SmoothBars)

                UI:UIFrameFadeIn(Bar, 0.25, Bar:GetAlpha(), 1)
            else
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

        Backdrop[1]:SetStatusBarColor(1 * Mult, 0, 0, 0.25)
        Backdrop[2]:SetStatusBarColor(1 * Mult, 0, 0, 0.25)
        Backdrop[3]:SetStatusBarColor(0, 0.35 * Mult, 1 * Mult, 0.25)
        Backdrop[4]:SetStatusBarColor(0, 0.35 * Mult, 1 * Mult, 0.25)
        Backdrop[5]:SetStatusBarColor(0.25 * Mult, 0.55 * Mult, 0.10 * Mult, 0.25)
        Backdrop[6]:SetStatusBarColor(0.25 * Mult, 0.55 * Mult, 0.10 * Mult, 0.25)
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