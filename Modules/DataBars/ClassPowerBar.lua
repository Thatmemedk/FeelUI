local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ClassPowerBar = UI:RegisterModule("ResourceBar")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitClass = UnitClass
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetSpecialization = GetSpecialization
local UnitPowerType = UnitPowerType

-- WoW Globals
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

-- WoW Globals
local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints
local SPELL_POWER_ENERGY = Enum.PowerType.Energy
local SPELL_POWER_SOUL_SHARDS = Enum.PowerType.SoulShards
local SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower
local SPELL_POWER_CHI = Enum.PowerType.Chi
local SPELL_POWER_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges
local SPELL_POWER_ESSENCE = Enum.PowerType.Essence
local SPELL_POWER_MAELSTROM = Enum.PowerType.Maelstrom

-- Locals
local Class = select(2, UnitClass("player"))

-- Colors
local R, G, B = unpack(UI.GetClassColors)

-- Colors
local R1, G1, B1 = 0.67, 0.43, 0.32
local R2, G2, B2 = 0.65, 0.56, 0.33
local R3, G3, B3 = 0.58, 0.62, 0.33
local R4, G4, B4 = 0.45, 0.60, 0.33
local R5, G5, B5 = 0.33, 0.59, 0.33
local R6, G6, B6 = 0.33, 0.59, 0.33

-- Colors
local BloodColor = { 1 * 2, 0, 0 }
local FrostColor = { 0, 0.35 * 2.5, 1 * 2.5 }
local UnholyColor = { 0.25 * 2.5, 0.55 * 2.5, 0.10 * 2.5 }

function ClassPowerBar:CreateBar()
    local Bar = CreateFrame("Frame", "FeelUI_ClassPowerBar", _G.UIParent)
    Bar:Size(242, 8)
    Bar:Point(unpack(DB.Global.DataBars.ClassPowerPoint))
    Bar:Hide()

    local InvisFrame = CreateFrame("Frame", nil, Bar)
    InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local Text = InvisFrame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Bar, 0, 6)
    Text:SetFontTemplate("Default", 16)

    -- ANIMATION
    Bar.Fade = UI:CreateAnimationGroup(Bar)

    Bar.FadeIn = UI:CreateAnimation(Bar.Fade, "Fade")
    Bar.FadeIn:SetDuration(0.25)
    Bar.FadeIn:SetChange(1)
    Bar.FadeIn:SetEasing("In-SineEase")

    Bar.FadeOut = UI:CreateAnimation(Bar.Fade, "Fade")
    Bar.FadeOut:SetDuration(0.25)
    Bar.FadeOut:SetChange(0)
    Bar.FadeOut:SetEasing("Out-SineEase")

    -- Cache
    self.Bar = Bar
    self.Text = Text
end

function ClassPowerBar:GetClassPowerType()
    if (Class == "ROGUE" or Class == "DRUID") then
        return SPELL_POWER_COMBO_POINTS
    elseif (Class == "WARLOCK") then
        return SPELL_POWER_SOUL_SHARDS
    elseif (Class == "PALADIN") then
        return SPELL_POWER_HOLY_POWER
    elseif (Class == "MONK") then
        return SPELL_POWER_CHI
    elseif (Class == "MAGE") then
        return SPELL_POWER_ARCANE_CHARGES
    elseif (Class == "EVOKER") then
        return SPELL_POWER_ESSENCE
    end
end

function ClassPowerBar:OnUpdate(Elapsed)
    self.Duration = self.Duration + Elapsed

    if (self.Duration >= self.Max) then
        self.Duration = self.Max
        
        self:SetValue(self.Max)
        self:SetScript("OnUpdate", nil)
    else
        self:SetValue(self.Duration, UI.SmoothBars)
    end
end

function ClassPowerBar:Update()
    local Min, Max, BarCount
    local Spec = GetSpecialization()
    local IsMaelstrom = (Class == "SHAMAN")
    local IsRuneBar = (Class == "DEATHKNIGHT")

    if (IsMaelstrom) then
        local Aura = GetPlayerAuraBySpellID(344179)
        Min = Aura and Aura.applications or 0

        BarCount = 10
    elseif (IsRuneBar) then
        BarCount = 6
    else
        if (not self.ClassPowerType) then
            self.ClassPowerType = self:GetClassPowerType()
        end

        if (not self.ClassPowerType) then
            return
        end

        if (Class == "WARLOCK" and Spec == 3) then
            Min = UnitPower("player", self.ClassPowerType, true)
            BarCount = 5
        else
            Min = UnitPower("player", self.ClassPowerType)
            Max = UnitPowerMax("player", self.ClassPowerType)
            BarCount = Max or 0
        end
    end

    if (not BarCount or BarCount == 0) then
        return
    end

    if (not self.Segment) then
        self.Segment = {}
    end

    if (not self.Backdrops) then
        self.Backdrops = {}
    end

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

        if (IsMaelstrom) then
            Segment:Size(SegmentWidth, 12)
            Backdrop:Size(SegmentWidth, 12)
        else
            Segment:Size(SegmentWidth, 8)
            Backdrop:Size(SegmentWidth, 8)
        end

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

        if (IsRuneBar) then
            if (i <= 2) then
                Segment:SetStatusBarColor(unpack(BloodColor))
                Backdrop:SetStatusBarColor(1 * 2.5, 0, 0, 0.5)
            elseif (i <= 4) then
                Segment:SetStatusBarColor(unpack(FrostColor))
                Backdrop:SetStatusBarColor(0, 0.35 * 2.5, 1 * 2.5, 0.5)
            else
                Segment:SetStatusBarColor(unpack(UnholyColor))
                Backdrop:SetStatusBarColor(0.25 * 2.5, 0.55 * 2.5, 0.10 * 2.5, 0.5)
            end

            local Start, Duration, RuneIsReady = GetRuneCooldown(i)

            if (Start and Duration) then
                local Elapsed = GetTime() - Start
                Segment.Duration = Elapsed
                Segment.Max = Duration
                Segment:SetMinMaxValues(0, Duration, UI.SmoothBars)

                if (RuneIsReady) then
                    Segment:SetValue(Duration, UI.SmoothBars)
                    Segment:SetScript("OnUpdate", nil)

                    UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
                else
                    Segment:SetValue(Elapsed, UI.SmoothBars)
                    Segment:SetScript("OnUpdate", self.OnUpdate)

                    UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0.5)
                end
            end
        elseif (IsMaelstrom) then
            Segment:SetStatusBarColor(R * 1.5, G * 1.5, B * 1.5)
            Backdrop:SetStatusBarColor(R * 0.5, G * 0.5, B * 0.5, 0.5)
            
            if (i <= Min) then 
                UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1) 
            else 
                UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0) 
            end
        else
            if (i == 1) then
                Segment:SetStatusBarColor(R1, G1, B1)
                Backdrop:SetStatusBarColor(R1 * 0.5, G1 * 0.5, B1 * 0.5, 0.5)
            elseif (i == 2) then
                Segment:SetStatusBarColor(R2, G2, B2)
                Backdrop:SetStatusBarColor(R2 * 0.5, G2 * 0.5, B2 * 0.5, 0.5)
            elseif (i == 3) then
                Segment:SetStatusBarColor(R3, G3, B3)
                Backdrop:SetStatusBarColor(R3 * 0.5, G3 * 0.5, B3 * 0.5, 0.5)
            elseif (i == 4) then
                Segment:SetStatusBarColor(R4, G4, B4)
                Backdrop:SetStatusBarColor(R4 * 0.5, G4 * 0.5, B4 * 0.5, 0.5)
            elseif (i == 5) then
                Segment:SetStatusBarColor(R5, G5, B5)
                Backdrop:SetStatusBarColor(R5 * 0.5, G5 * 0.5, B5 * 0.5, 0.5)
            elseif (i == 6 or i == 7) then
                Segment:SetStatusBarColor(R6, G6, B6)
                Backdrop:SetStatusBarColor(R6 * 0.5, G6 * 0.5, B6 * 0.5, 0.5)
            end

            if (Class == "MAGE" or Class == "WARLOCK" or Class == "MONK" or Class == "EVOKER") then
                Segment:SetStatusBarColor(R, G, B)
                Backdrop:SetStatusBarColor(R * 0.5, G * 0.5, B * 0.5, 0.5)
            elseif (Class == "PALADIN") then
                Segment:SetStatusBarColor(1, 0.82, 0)
                Backdrop:SetStatusBarColor(1 * 0.5, 0.82 * 0.5, 0 * 0.5, 0.5)
            end

            if (Class == "WARLOCK" and Spec == 3) then
                local BarMin = (i - 1) * 10
                local BarMax = i * 10

                Segment:SetMinMaxValues(0, 10, UI.SmoothBars)

                if (Min >= BarMax) then
                    Segment:SetValue(10, UI.SmoothBars)
                    UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
                elseif (Min <= BarMin) then
                    Segment:SetValue(0, UI.SmoothBars)
                    UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0)
                else
                    Segment:SetValue(Min - BarMin, UI.SmoothBars)
                    UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
                end
            else
                if (i <= Min) then
                    UI:UIFrameFadeIn(Segment, 0.25, Segment:GetAlpha(), 1)
                else
                    UI:UIFrameFadeOut(Segment, 0.25, Segment:GetAlpha(), 0)
                end
            end
        end

        self.Bar[i] = Segment
    end
end

function ClassPowerBar:UpdateSpec()
    local Spec = GetSpecialization()

    if (Class == "ROGUE" or Class == "WARLOCK" or Class == "PALADIN" or Class == "EVOKER" or Class == "DEATHKNIGHT") then
        self.Bar:Show()
    elseif (Class == "DRUID" and UnitPowerType("player") == SPELL_POWER_ENERGY) then
        self.Bar:Show()
    elseif (Class == "MONK" and Spec == 3) then
        self.Bar:Show()
    elseif (Class == "MAGE" and Spec == 1) then
        self.Bar:Show()
    elseif (Class == "SHAMAN" and Spec == 2) then
        self.Bar:Show()
    else
        self.Bar:Hide()
    end
end

function ClassPowerBar:OnEvent(event)
    self:Update()
    self:UpdateSpec()
end

function ClassPowerBar:RegisterEvents()
    -- PLAYER
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    -- UNIT EVENTS
    self:RegisterEvent("UNIT_AURA", "player")
    self:RegisterEvent("UNIT_DISPLAYPOWER", "player")
    self:RegisterEvent("UNIT_MAXPOWER", "player")
    self:RegisterEvent("UNIT_POWER_FREQUENT", "player")
    self:RegisterEvent("UNIT_POWER_UPDATE", "player")
    -- RUNES
    self:RegisterEvent("RUNE_POWER_UPDATE")
    self:RegisterEvent("RUNE_TYPE_UPDATE")
    -- SPELLS
    self:RegisterEvent("SPELLS_CHANGED")
    -- ON EVENT
    self:SetScript("OnEvent", self.OnEvent)
end

function ClassPowerBar:GlidingState()
    local IsGliding = C_PlayerInfo.GetGlidingInfo()

    if (IsGliding and not self.IsFlying) then
        self.IsFlying = true

        if (self.Bar.FadeIn:IsPlaying()) then
            self.Bar.FadeIn:Stop()
        end

        self.Bar.FadeOut:Play()
    elseif (not IsGliding and self.IsFlying) then
        self.IsFlying = false

        if (self.Bar.FadeOut:IsPlaying()) then
            self.Bar.FadeOut:Stop()
        end

        self.Bar.FadeIn:Play()
    end
end

function ClassPowerBar:CheckDragonflying()
    C_Timer.NewTicker(0.2, function()
        self:GlidingState()
    end)
end

function ClassPowerBar:Initialize()
    if (not DB.Global.DataBars.ClassPowerBar) then
        return
    end

    self:CreateBar()
    self:RegisterEvents()
    self:CheckDragonflying()
end