local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local VB = UI:RegisterModule("VigorBar")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GetSpellCharges = _G.C_Spell.GetSpellCharges
local GetSpellChargeDuration = _G.C_Spell.GetSpellChargeDuration
local GetSpellCooldownDuration = _G.C_Spell.GetSpellCooldownDuration
local GetUnitAuraBySpellID = _G.C_UnitAuras.GetUnitAuraBySpellID

-- Locals
VB.VigorSpell = 372610
VB.ThrillSpell = 377234
VB.CooldownSpells = { 425782, 361584 }
VB.Spacing = 2
VB.Count = 0

-- Colors
local R, G, B = unpack(UI.GetClassColors)

function VB:CreateBar()
    -- FRAMES
    local VigorBars = CreateFrame("Frame", nil, _G.UIParent)
    VigorBars:Size(242, 8)
    VigorBars:Point("CENTER", _G.UIParent, 0, -212)
    VigorBars:SetAlpha(0)

    local CooldownsBars = CreateFrame("Frame", nil, VigorBars)
    CooldownsBars:Size(242, 8)
    CooldownsBars:Point("BOTTOM", VigorBars, 0, -14)

    local InvisFrame = CreateFrame("Frame", nil, VigorBars)
    InvisFrame:SetFrameLevel(VigorBars:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local SpeedText = InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    SpeedText:Point("CENTER", VigorBars, 0, 6)
    SpeedText:SetFontTemplate("Default", 16)

    -- ANIMATION
    VigorBars.Fade = UI:CreateAnimationGroup(VigorBars)

    VigorBars.FadeIn = UI:CreateAnimation(VigorBars.Fade, "Fade")
    VigorBars.FadeIn:SetDuration(0.25)
    VigorBars.FadeIn:SetChange(1)
    VigorBars.FadeIn:SetEasing("In-SineEase")

    VigorBars.FadeOut = UI:CreateAnimation(VigorBars.Fade, "Fade")
    VigorBars.FadeOut:SetDuration(1)
    VigorBars.FadeOut:SetChange(0)
    VigorBars.FadeOut:SetEasing("Out-SineEase")

    -- CACHE
    self.VigorBars = VigorBars
    self.CooldownsBars = CooldownsBars
    self.InvisFrame = InvisFrame
    self.SpeedText = SpeedText
end

function VB:CreateSegementBars(Frame, Index)
    local SegmentBar = CreateFrame("StatusBar", nil, Frame)
    SegmentBar:SetStatusBarTexture(Media.Global.Texture)
    SegmentBar:Height(Frame:GetHeight())
    SegmentBar:SetStatusBarColor(R, G, B)
    SegmentBar:CreateBackdrop()
    SegmentBar:CreateShadow()

    SegmentBar.Text = self.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    SegmentBar.Text:Point("CENTER", SegmentBar, 0, 6)
    SegmentBar.Text:SetFontTemplate("Default", 16)

    if (Index == 1) then
        SegmentBar:Point("LEFT", Frame, 0, 0)
    else
        SegmentBar:Point("LEFT", Frame[Index -1], "RIGHT", self.Spacing, 0)
    end

    Frame[Index] = SegmentBar

    return SegmentBar
end

function VB:ResizeBars(Frame, Num)
    local MaxWidth = math.floor(Frame:GetWidth())
    local BarWidth = math.floor((MaxWidth / Num) - self.Spacing + (self.Spacing / Num))
    local NewWidth = MaxWidth - ((BarWidth * Num) + (self.Spacing * (Num - 1)))

    for Index = 1, Num do
        if (NewWidth > Num - Index) then
            Frame[Index]:Width(BarWidth + 1)
        else
            Frame[Index]:Width(BarWidth)
        end
    end
end

function VB:UpdateCooldowns()
    self.NeedsResize = false

    for Index, SpellID in ipairs(self.CooldownSpells) do
        local SegmentBar = self.CooldownsBars[Index]

        if (not SegmentBar) then
            SegmentBar = self:CreateSegementBars(self.CooldownsBars, Index)

            self.NeedsResize = true
        end

        local Charges = GetSpellCharges(SpellID)
        local CurCharges = Charges and Charges.currentCharges or 0

        if (Charges) then
            SegmentBar.Text:SetText(CurCharges)
        end

        if (Charges and CurCharges > 0) then
            self.Duration = GetSpellChargeDuration(SpellID)
        else
            self.Duration = GetSpellCooldownDuration(SpellID)
        end

        if (self.Duration and not self.Duration:IsZero()) then
            SegmentBar:SetTimerDuration(self.Duration)
        else
            SegmentBar:SetMinMaxValues(0, 1, UI.SmoothBars)
            SegmentBar:SetValue(1, UI.SmoothBars)
        end
    end

    if (self.NeedsResize) then
        self:ResizeBars(self.CooldownsBars, #self.CooldownSpells)
    end
end

function VB:UpdateVigor()
    local Charges = GetSpellCharges(self.VigorSpell)

    if (not Charges) then 
        return 
    end

    local MaxCharges = Charges.maxCharges
    local CurCharges = Charges.currentCharges

    for Index = 1, MaxCharges do
        local SegmentBar = self.VigorBars[Index] or self:CreateSegementBars(self.VigorBars, Index)

        if (CurCharges >= Index) then
            SegmentBar:SetMinMaxValues(0, 1, UI.SmoothBars)
            SegmentBar:SetValue(1, UI.SmoothBars)
        elseif (CurCharges + 1 == Index) then
            local Duration = GetSpellChargeDuration(self.VigorSpell)

            if (Duration) then
                SegmentBar:SetTimerDuration(Duration)
            end
        else
            SegmentBar:SetMinMaxValues(0, 1, UI.SmoothBars)
            SegmentBar:SetValue(0, UI.SmoothBars)
        end
    end

    if (self.Count ~= MaxCharges) then
        self.Count = MaxCharges

        self:ResizeBars(self.VigorBars, self.Count)
    end
end

function VB:UpdateVigorColor()
    if (GetUnitAuraBySpellID("player", self.ThrillSpell, "HELPFUL")) then
        self.Color = UI.Colors.Vigor.THRILL
    else
        self.Color = UI.Colors.Vigor.NORMAL
    end

    for Index = 1, self.Count do
        self.VigorBars[Index]:SetStatusBarColor(self.Color.r, self.Color.g, self.Color.b)
    end
end

function VB:UpdateSpeed()
    local _, _, Speed = C_PlayerInfo.GetGlidingInfo()
    self.SpeedText:SetFormattedText("%d%%", Speed / BASE_MOVEMENT_SPEED * 100 + 0.5)
end

function VB:CheckDragonflying()
    local IsGliding = C_PlayerInfo.GetGlidingInfo()

    if (IsGliding and not self.IsFlying) then
        self.IsFlying = true

        if (self.VigorBars.FadeOut:IsPlaying()) then
            self.VigorBars.FadeOut:Stop()
        end

        self.VigorBars.FadeIn:Play()
        self:StartSpeedTicker()
    elseif (not IsGliding and self.IsFlying) then
        self.IsFlying = false

        if (self.VigorBars.FadeIn:IsPlaying()) then
            self.VigorBars.FadeIn:Stop()
        end

        self.VigorBars.FadeOut:Play()
        self:StopSpeedTicker()
        self.SpeedText:SetText("")
    end
end

function VB:StartSpeedTicker()
    if (self.SpeedTicker) then
        return
    end

    self.SpeedTicker = C_Timer.NewTicker(0.05, function()
        VB:UpdateSpeed()
    end)
end

function VB:StopSpeedTicker()
    if (not self.SpeedTicker) then 
        return 
    end

    self.SpeedTicker:Cancel()
    self.SpeedTicker = nil
end

function VB:OnEvent(event)
    if (event == "SPELL_UPDATE_COOLDOWN") then
        self:UpdateCooldowns()
    elseif (event == "SPELL_UPDATE_CHARGES") then
        self:UpdateVigor()
    elseif (event == "UNIT_AURA") then
        self:UpdateVigorColor()
    end
end

function VB:RegisterEvents()
    self:RegisterEvent("UNIT_AURA", "player")
    self:RegisterEvent("SPELL_UPDATE_CHARGES")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:SetScript("OnEvent", self.OnEvent)

    C_Timer.NewTicker(0.2, function()
        self:CheckDragonflying()
    end)
end

function VB:Initialize()
    self:CreateBar()
    self:UpdateVigor()
    self:UpdateVigorColor()
    self:UpdateCooldowns()
    self:RegisterEvents()
end