local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local ActionButtonSpellAlertManager = _G.ActionButtonSpellAlertManager

function AB:StartButtonHighlight()
    if self.SpellActivationAlert and self.SpellActivationAlert:GetParent() ~= UI.HiddenParent then
        self.SpellActivationAlert:SetParent(UI.HiddenParent)
    end

    if not self.Animation then
        self.NewProc = CreateFrame("Frame", nil, self)
        self.NewProc:SetFrameLevel(self:GetFrameLevel() + 5)
        self.NewProc:SetInside()
        self.NewProc:CreateBackdrop()
        self.NewProc:SetBackdropColorTemplate(unpack(DB.Global.ActionBars.OverlayGlowColor))
        self.NewProc:Hide()

        self.Animation = self.NewProc:CreateAnimationGroup()
        self.Animation:SetLooping("BOUNCE")

        self.Animation.FadeOut = self.Animation:CreateAnimation("Alpha")
        self.Animation.FadeOut:SetFromAlpha(0.80)
        self.Animation.FadeOut:SetToAlpha(0)
        self.Animation.FadeOut:SetDuration(0.8)
        self.Animation.FadeOut:SetSmoothing("IN_OUT")
    end

    if not self.Animation:IsPlaying() then
        self.NewProc:Show()
        self.Animation:Play()
    end
end

function AB:StopButtonHighlight()
    if self.Animation and self.Animation:IsPlaying() then
        self.Animation:Stop()
        self.NewProc:Hide()
    end
end

function AB:CreateGlow()
    hooksecurefunc(ActionButtonSpellAlertManager, "ShowAlert", function(self, Button)
        if not (Button) then 
        	return 
        end

        if not (Button.StartButtonHighlight) then
            Button.StartButtonHighlight = AB.StartButtonHighlight
            Button.StopButtonHighlight  = AB.StopButtonHighlight
        end

        Button:StartButtonHighlight()
    end)

    hooksecurefunc(ActionButtonSpellAlertManager, "HideAlert", function(self, Button)
        if (Button and Button.StopButtonHighlight) then
            Button:StopButtonHighlight()
        end
    end)
end