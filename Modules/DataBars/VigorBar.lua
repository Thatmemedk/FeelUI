local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local VB = UI:RegisterModule("VigorBar")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

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
    local VigorBars = CreateFrame("Frame", nil, _G.UIParent)
    VigorBars:Size(242, 8)
    VigorBars:Point("CENTER", _G.UIParent, 0, -204)
    VigorBars:SetAlpha(0)

    local CooldownsBars = CreateFrame("Frame", nil, VigorBars)
    CooldownsBars:Size(242, 8)
    CooldownsBars:Point("BOTTOM", VigorBars, 0, -14)

    local InvisFrame = CreateFrame("Frame", nil, VigorBars)
    InvisFrame:SetFrameLevel(VigorBars:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local SpeedText = InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    SpeedText:Point("CENTER", VigorBars, 0, 8)
    SpeedText:SetFontTemplate("Default", 16)

    -- ANIMATION
    VigorBars.Fade = UI:CreateAnimationGroup(VigorBars)

    VigorBars.FadeIn = UI:CreateAnimation(VigorBars.Fade, "Fade")
    VigorBars.FadeIn:SetDuration(0.25)
    VigorBars.FadeIn:SetChange(1)
    VigorBars.FadeIn:SetEasing("In-SineEase")

    VigorBars.FadeOut = UI:CreateAnimation(VigorBars.Fade, "Fade")
    VigorBars.FadeOut:SetDuration(0.25)
    VigorBars.FadeOut:SetChange(0)
    VigorBars.FadeOut:SetEasing("Out-SineEase")

    -- Cache
    self.VigorBars = VigorBars
    self.CooldownsBars = CooldownsBars
    self.InvisFrame = InvisFrame
    self.SpeedText = SpeedText
end

function VB:CreateSegmentBars(Frame, Index)
    local SegmentBar = CreateFrame("StatusBar", nil, Frame)
    SegmentBar:Height(Frame:GetHeight())
    SegmentBar:SetStatusBarTexture(Media.Global.Texture)

    SegmentBar.Text = self.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    SegmentBar.Text:Point("CENTER", SegmentBar, 0, 6)
    SegmentBar.Text:SetFontTemplate("Default", 16)

    if (Index == 1) then
        SegmentBar:Point("LEFT", Frame, "LEFT", 0, 0)
    else
        SegmentBar:Point("LEFT", Frame[Index - 1], "RIGHT", self.Spacing, 0)
    end

    if (not Frame.Backdrop) then
        Frame.Backdrop = {}
    end

    local Backdrop = CreateFrame("StatusBar", nil, Frame)
    Backdrop:Height(Frame:GetHeight())
    Backdrop:SetStatusBarTexture(Media.Global.Texture)
    Backdrop:CreateBackdrop()
    Backdrop:CreateShadow()

    if (Index == 1) then
        Backdrop:Point("LEFT", Frame, "LEFT", 0, 0)
    else
        Backdrop:Point("LEFT", Frame.Backdrop[Index - 1], "RIGHT", self.Spacing, 0)
    end

    Frame[Index] = SegmentBar
    Frame.Backdrop[Index] = Backdrop

    return SegmentBar
end

function VB:CreateCooldownIcon(Frame, Index, SpellID)
    local Icon = CreateFrame("Frame", nil, Frame)
    Icon:Size(38, 18)
    Icon:SetTemplate()
    Icon:CreateShadow()
    Icon:StyleButton()
    Icon:SetShadowOverlay()

    local IconSize = 38
    local TotalWidth = (IconSize * #self.CooldownSpells) + (self.Spacing * (#self.CooldownSpells - 1))
    local StartX = -(TotalWidth / 2) + (IconSize / 2)

    Icon:ClearAllPoints()
    Icon:Point("CENTER", Frame, "CENTER", StartX + ((Index - 1) * (IconSize + self.Spacing)), 44)

    -- ICON
    Icon.Texture = Icon:CreateTexture(nil, "ARTWORK")
    Icon.Texture:SetInside()
    UI:KeepAspectRatio(Icon, Icon.Texture)

    -- COOLDOWN
    Icon.Cooldown = CreateFrame("Cooldown", nil, Icon, "CooldownFrameTemplate")
    Icon.Cooldown:SetInside()
    Icon.Cooldown:SetDrawEdge(false)
    Icon.Cooldown:SetDrawBling(false)
    Icon.Cooldown:SetReverse(true)
    Icon.Cooldown:Hide()

    local InvisFrame = CreateFrame("Frame", nil, Icon)
    InvisFrame:SetFrameLevel(Icon:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    -- COUNT
    Icon.Text = InvisFrame:CreateFontString(nil, "OVERLAY")
    Icon.Text:Point("CENTER", Icon, 0, 8)
    Icon.Text:SetFontTemplate("Default")

    Frame[Index] = Icon

    return Icon
end

function VB:ResizeBars(Frame, Num)
    local MaxWidth = math.floor(Frame:GetWidth())
    local BarWidth = math.floor((MaxWidth / Num) - self.Spacing + (self.Spacing / Num))
    local NewWidth = MaxWidth - ((BarWidth * Num) + (self.Spacing * (Num - 1)))

    for i = 1, Num do
        if (NewWidth > Num - i) then
            Frame[i]:Width(BarWidth + 1)

            if (Frame.Backdrop and Frame.Backdrop[i]) then
                Frame.Backdrop[i]:Width(BarWidth + 1)
            end
        else
            Frame[i]:Width(BarWidth)

            if (Frame.Backdrop and Frame.Backdrop[i]) then
                Frame.Backdrop[i]:Width(BarWidth)
            end
        end
    end
end

function VB:UpdateCooldowns()
    for i, SpellID in ipairs(self.CooldownSpells) do
        local Icon = self.CooldownsBars[i]

        if (not Icon) then
            Icon = self:CreateCooldownIcon(self.CooldownsBars, i, SpellID)
        end

        local Texture = C_Spell.GetSpellTexture(SpellID)

        if (Texture) then
            Icon.Texture:SetTexture(Texture)
        end

        local Charges = GetSpellCharges(SpellID)

        if (Charges) then
            local CurCharges = Charges.currentCharges or 0
            local MaxCharges = Charges.maxCharges or 0

            if (MaxCharges > 1) then
                Icon.Text:SetText(CurCharges)
            else
                Icon.Text:SetText("")
            end

            if (CurCharges < MaxCharges) then
                local Start = Charges.cooldownStartTime
                local Duration = Charges.cooldownDuration

                if (Start and Duration and Duration > 0) then
                    Icon.Cooldown:SetCooldown(Start, Duration)
                    UI:UpdateCooldownText(Icon.Cooldown, Icon, 0, -6, true)
                    Icon.Cooldown:Show()
                else
                    Icon.Cooldown:Hide()
                end
            else
                Icon.Cooldown:Hide()
            end

        else
            local CooldownInfo = C_Spell.GetSpellCooldown(SpellID)

            if (CooldownInfo and CooldownInfo.duration and CooldownInfo.duration > 0) then
                Icon.Cooldown:SetCooldown(CooldownInfo.startTime, CooldownInfo.duration)
                UI:UpdateCooldownText(Icon.Cooldown, Icon, 0, -6, true)
                Icon.Cooldown:Show()
            else
                Icon.Cooldown:Hide()
            end
        end
    end
end

function VB:UpdateVigor()
    local Charges = GetSpellCharges(self.VigorSpell)

    if (not Charges) then 
        return 
    end

    local MaxCharges = Charges.maxCharges
    local CurCharges = Charges.currentCharges

    for i = 1, MaxCharges do
        local SegmentBar = self.VigorBars[i]

        if (not SegmentBar) then
            SegmentBar = self:CreateSegmentBars(self.VigorBars, i)

            self.NeedsResize = true
        end

        SegmentBar:SetStatusBarColor(0, 0.82, 1)
        self.VigorBars.Backdrop[i]:SetStatusBarColor(0, 0.82 * 0.5, 1 * 0.5, 0.5)

        if (CurCharges >= i) then
            SegmentBar:SetMinMaxValues(0, 1)
            SegmentBar:SetValue(1, UI.SmoothBars)

            UI:UIFrameFadeIn(SegmentBar, 0.25, SegmentBar:GetAlpha(), 1)
        elseif (CurCharges + 1 == i) then
            local Duration = GetSpellChargeDuration(self.VigorSpell)

            if (Duration) then
                SegmentBar:SetTimerDuration(Duration)
            end

            UI:UIFrameFadeOut(SegmentBar, 1, SegmentBar:GetAlpha(), 0.5)
        else
            SegmentBar:SetMinMaxValues(0, 1)
            SegmentBar:SetValue(0, UI.SmoothBars)

            UI:UIFrameFadeOut(SegmentBar, 1, SegmentBar:GetAlpha(), 0.5)
        end
    end

    if (self.Count ~= MaxCharges) then
        self.Count = MaxCharges

        self:ResizeBars(self.VigorBars, self.Count)
    end
end

function VB:UpdateSpeed()
    local _, _, Speed = C_PlayerInfo.GetGlidingInfo()
    self.SpeedText:SetFormattedText("%d%%", Speed / BASE_MOVEMENT_SPEED * 100 + 0.5)
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

function VB:GlidingState()
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

function VB:CheckDragonflying()
    C_Timer.NewTicker(0.2, function()
        self:GlidingState()
    end)
end

function VB:OnEvent(event)
    if (event == "SPELL_UPDATE_COOLDOWN") then
        self:UpdateCooldowns()
    elseif (event == "SPELL_UPDATE_CHARGES") then
        self:UpdateVigor()
    end
end

function VB:RegisterEvents()
    self:RegisterEvent("SPELL_UPDATE_CHARGES")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:SetScript("OnEvent", self.OnEvent)
end

function VB:Initialize()
    self:CreateBar()
    self:UpdateVigor()
    self:UpdateCooldowns()
    self:RegisterEvents()
    self:CheckDragonflying()
end