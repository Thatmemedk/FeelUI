local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local LossControl = UI:RegisterModule("LossControl")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local LossOfControlFrame = _G.LossOfControlFrame

function LossControl:UpdateSetUpDisplay()
	if (self.AbilityName) then
		self.AbilityName:SetShadowOffset(UI:Scale(2), -UI:Scale(2))
		self.AbilityName:SetShadowColor(0, 0, 0, 0.5)
	end

	if (self.TimeLeft.NumberText) then
		self.TimeLeft.NumberText:SetTextColor(unpack(DB.Global.CooldownFrame.SecondsColor))
		self.TimeLeft.NumberText:SetShadowOffset(UI:Scale(2), -UI:Scale(2))
		self.TimeLeft.NumberText:SetShadowColor(0, 0, 0, 0.5)
	end

	if (self.TimeLeft.SecondsText) then
		self.TimeLeft.SecondsText:SetShadowOffset(UI:Scale(2), -UI:Scale(2))
		self.TimeLeft.SecondsText:SetShadowColor(0, 0, 0, 0.5)
	end

	if (self.Cooldown) then
		self.Cooldown:SetAlpha(0)
	end
end

function LossControl:Update()
	LossOfControlFrame:StripTexture()
	
	LossOfControlFrame.IconOverlay = CreateFrame("Frame", nil, LossOfControlFrame)
	LossOfControlFrame.IconOverlay:SetInside(LossOfControlFrame.Icon)
	LossOfControlFrame.IconOverlay:SetTemplate()
	LossOfControlFrame.IconOverlay:CreateShadow()
	LossOfControlFrame.IconOverlay:SetShadowOverlay()
	LossOfControlFrame.IconOverlay:CreateGlow(4, 3, 1 * 0.55, 0, 0, 0.80)

	LossOfControlFrame.Icon:Size(48, 28)
	UI:KeepAspectRatio(LossOfControlFrame.Icon, LossOfControlFrame.Icon)

	-- Hook Secure
	hooksecurefunc(LossOfControlFrame, "SetUpDisplay", self.UpdateSetUpDisplay)
end

function LossControl:Initialize()
	self:Update()
end