local UI, DB, Media = select(2, ...):Call()

-- Call Modules
local NPA = UI:RegisterModule("NoPetAlert")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function NPA:Create()
    -- Frame
    local Frame = CreateFrame("Frame", "FeelUI_NoPetAlert", _G.UIParent)
    Frame:Size(200, 60)
    Frame:Point("CENTER", _G.UIParent, "CENTER", 0, 200)
    Frame:Hide()

    -- Icon
    local Icon = Frame:CreateTexture(nil, "ARTWORK")
    Icon:Size(52, 22)
    Icon:Point("TOP", Frame, "TOP", 0, 12)
    Icon:SetTexture(4667414)

    UI:KeepAspectRatio(Icon, Icon)

    local IconOverlay = CreateFrame("Frame", nil, Frame)
    IconOverlay:SetInside(Icon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()

    -- Text
    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:SetFontTemplate("CombatText", 32, 2, 2)
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetText("NO PET")
    Text:SetTextColor(1, 1, 1)

    -- Animation
    local Anim = Frame:CreateAnimationGroup()
    Anim:SetLooping("REPEAT")

    local FadeOut = Anim:CreateAnimation("Alpha")
    FadeOut:SetFromAlpha(1)
    FadeOut:SetToAlpha(0.25)
    FadeOut:SetDuration(0.4)
    FadeOut:SetOrder(1)

    local FadeIn = Anim:CreateAnimation("Alpha")
    FadeIn:SetFromAlpha(0.25)
    FadeIn:SetToAlpha(1)
    FadeIn:SetDuration(0.4)
    FadeIn:SetOrder(2)

    self.Frame = Frame
    self.Text = Text
    self.Anim = Anim
end

function NPA:UpdatePetStatus()
    local _, Class = UnitClass("player")
    local Spec = GetSpecialization()
    local ValidClassSpec = false

    if (Class == "DEATHKNIGHT") then
        if (Spec == 3) then
            ValidClassSpec = true
        end
    elseif (Class == "WARLOCK") then
        ValidClassSpec = true
    elseif (Class == "HUNTER") then
        if (Spec == 1 or Spec == 3) then
            ValidClassSpec = true
        end
    end

    if (not ValidClassSpec) then
        self.Frame:Hide()
        self.Anim:Stop()
        
        return
    end

    if (IsMounted()) then
        self.Frame:Hide()
        self.Anim:Stop()

        return
    end

    if (UnitExists("pet")) then
        self.Frame:Hide()
        self.Anim:Stop()
    elseif (UnitAffectingCombat("player")) then
        self.Frame:Show()

        if (not self.Anim:IsPlaying()) then
            self.Anim:Play()
        end
    else
        self.Frame:Hide()
        self.Anim:Stop()
    end
end

function NPA:OnEvent(event, unit)
    if (event == "UNIT_PET" or event == "UNIT_AURA" and unit ~= "player") then 
        return 
    end

    self:UpdatePetStatus()
end

function NPA:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:SetScript("OnEvent", self.OnEvent)
end

function NPA:Initialize()
    self:Create()
    self:RegisterEvents()
end