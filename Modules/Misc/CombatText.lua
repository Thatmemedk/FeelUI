local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local SCT = UI:RegisterModule("SCT")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local ENTERING_COMBAT = _G.ENTERING_COMBAT
local LEAVING_COMBAT = _G.LEAVING_COMBAT

function SCT:Create()
    local Frame = CreateFrame("Frame", "FeelUI_SCT", _G.UIParent)
    Frame:Size(200, 30)
    Frame:Point("CENTER", _G.UIParent, 0, 102)
    Frame:SetFrameStrata("HIGH")
    Frame:SetFrameLevel(60)
    Frame:EnableMouse(false)
    Frame:Hide()

    -- TEXT
    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, "CENTER", 0, 0)
    Text:SetFontTemplate("Default", 22, 2, 2)

    -- ANIMATION
    local Animation = Frame:CreateAnimationGroup()

    local FadeIn = Animation:CreateAnimation("Alpha")
    FadeIn:SetFromAlpha(0)
    FadeIn:SetToAlpha(1)
    FadeIn:SetDuration(0.20)
    FadeIn:SetOrder(1)

    local Hold = Animation:CreateAnimation("Alpha")
    Hold:SetFromAlpha(1)
    Hold:SetToAlpha(1)
    Hold:SetDuration(1.5)
    Hold:SetOrder(2)

    local FadeOut = Animation:CreateAnimation("Alpha")
    FadeOut:SetFromAlpha(1)
    FadeOut:SetToAlpha(0)
    FadeOut:SetDuration(0.5)
    FadeOut:SetOrder(3)

    Animation:SetScript("OnFinished", function()
        Frame:Hide()
    end)

    Frame:SetScript("OnHide", function()
        Animation:Stop()
    end)

    -- CACHE
    self.Frame = Frame
    self.Text = Text
    self.Animation = Animation
end

function SCT:Play(Message, R, G, B)
    self.Animation:Stop()
    self.Text:SetText(Message)
    self.Text:SetTextColor(R, G, B)
    self.Frame:SetAlpha(1)
    self.Frame:Show()
    self.Animation:Play()
end

function SCT:EnteringCombat()
    self:Play("+"..ENTERING_COMBAT, 1, 0.25, 0.25)
end

function SCT:LeavingCombat()
    self:Play("-"..LEAVING_COMBAT, 0.25, 1, 0.25)
end

function SCT:OnEvent(event)
    if (event == "PLAYER_REGEN_DISABLED") then
        self:EnteringCombat()
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self:LeavingCombat()
    end
end

function SCT:RegisterEvents()
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:SetScript("OnEvent", function(_, event)
        self:OnEvent(event)
    end)
end

function SCT:Initialize()
    if (not DB.Global.ScrollingCombatText.Enable) then
        return
    end

    self:Create()
    self:RegisterEvents()
end