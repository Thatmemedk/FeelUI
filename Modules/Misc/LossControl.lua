local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local LossControl = UI:RegisterModule("LossControl")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local LossOfControlFrame = _G.LossOfControlFrame

function LossControl:UpdateSkin()
	self.AbilityName.scrollTime = nil
	self.AbilityName:SetFontTemplate("Default", 24, 2, 2)

	self.TimeLeft.NumberText.scrollTime = nil
	self.TimeLeft.NumberText:SetFontTemplate("Default", 20, 2, 2)
	self.TimeLeft.NumberText:SetTextColor(unpack(DB.Global.Cooldowns.SecondsColor))

	self.TimeLeft.SecondsText.scrollTime = nil
	self.TimeLeft.SecondsText:SetFontTemplate("Default", 20, 2, 2)

	self.Cooldown:SetAlpha(0)
end

function LossControl:Skin()
	LossOfControlFrame:StripTexture()
	
	LossOfControlFrame.IconOverlay = CreateFrame("Frame", nil, LossOfControlFrame)
	LossOfControlFrame.IconOverlay:SetInside(LossOfControlFrame.Icon)
	LossOfControlFrame.IconOverlay:SetTemplate()
	LossOfControlFrame.IconOverlay:CreateShadow()
	LossOfControlFrame.IconOverlay:SetShadowOverlay()
	LossOfControlFrame.IconOverlay:CreateGlow(6, 3, 1 * 0.55, 0, 0, 0.80)
	
	LossOfControlFrame.Icon:Size(48, 28)
	UI:KeepAspectRatio(LossOfControlFrame.Icon, LossOfControlFrame.Icon)
end

function LossControl:AddHooks()
	hooksecurefunc(LossOfControlFrame, "SetUpDisplay", self.UpdateSkin)
end

function LossControl:Initialize()
	self:Skin()
	self:AddHooks()
end