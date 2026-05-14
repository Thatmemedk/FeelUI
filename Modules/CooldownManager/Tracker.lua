local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:CallModule("CooldownManager")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Locals
CDM.SpellID = 188290 -- Death and Decay

-- Locals
local Class = select(2, UnitClass("player"))

function CDM:CreateTracker()
    local Button = CreateFrame("Button", "FeelUI_CDMTracker", _G.UIParent)
    Button:Size(44, 12)
    Button:Point("CENTER", _G.UIParent, 0, -140)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:SetShadowOverlay()
    Button:SetAlpha(0)

    local InvisFrame = CreateFrame("Frame", nil, Button)
    InvisFrame:SetFrameLevel(Button:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    -- ICON
    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetInside()
    Icon:SetTexture(C_Spell.GetSpellTexture(self.SpellID))
    UI:KeepAspectRatio(Button, Icon)

    -- COOLDOWN
    local Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Cooldown:SetInside()
    Cooldown:SetReverse(true)
    Cooldown:SetDrawEdge(false)
    Cooldown:Hide()

    UI:UpdateCooldownText(Cooldown, Button, 0, -6, true)

    -- ANIMATION
    Button.Fade = UI:CreateAnimationGroup(Button)

    Button.FadeIn = UI:CreateAnimation(Button.Fade, "Fade")
    Button.FadeIn:SetDuration(0.5)
    Button.FadeIn:SetChange(1)
    Button.FadeIn:SetEasing("In-SineEase")

    Button.FadeOut = UI:CreateAnimation(Button.Fade, "Fade")
    Button.FadeOut:SetDuration(0.5)
    Button.FadeOut:SetChange(0)
    Button.FadeOut:SetEasing("Out-SineEase")

    -- CACHE
    self.Button = Button
    self.Icon = Icon
    self.Cooldown = Cooldown
end

function CDM:StartTracker(Unit)
    if (not self.Button) then 
        return 
    end

    local Aura = C_UnitAuras.GetPlayerAuraBySpellID(self.SpellID)

    if (Aura) then
        if (self.Button.FadeOut:IsPlaying()) then
            self.Button.FadeOut:Stop()
        end

        self.Button.FadeIn:Play()
    else
        if (self.Button.FadeIn:IsPlaying()) then
            self.Button.FadeIn:Stop()
        end

        self.Button.FadeOut:Play()
    end

    if (self.Cooldown) then
        if (Aura and Aura.duration and Aura.expirationTime) then
            local StartTime = Aura.expirationTime - Aura.duration

            local DurationObject = C_DurationUtil.CreateDuration()
            DurationObject:SetTimeFromStart(StartTime, Aura.duration)

            self.Cooldown:SetCooldownFromDurationObject(DurationObject)
            self.Cooldown:Show()
        else
            self.Cooldown:Hide()
        end
    end
end

function CDM:TrackerOnEvent(Event, Unit)
    if (Unit ~= "player") then 
        return 
    end

    self:StartTracker()
end

function CDM:RegisterEvents()
    self.Button:RegisterEvent("UNIT_AURA")
    self.Button:SetScript("OnEvent", function(_, Event, ...)
        self:TrackerOnEvent(Event, ...)
    end)
end

function CDM:UpdateTracker()
    if (Class ~= "DEATHKNIGHT") then
        return
    end

    self:CreateTracker()
    self:RegisterEvents()
end