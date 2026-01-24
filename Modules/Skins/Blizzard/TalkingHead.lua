local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local TalkingHead = UI:RegisterModule("TalkingHead")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local TalkingHeadFrame = _G.TalkingHeadFrame
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

function TalkingHead:Skin()
	if (self.IsSkinned) then
		return
	end

	if (TalkingHeadFrame.BackgroundFrame) then
		TalkingHeadFrame.BackgroundFrame:Hide()
	end

	if (TalkingHeadFrame.PortraitFrame) then
		TalkingHeadFrame.PortraitFrame:Hide()
	end

	if (TalkingHeadFrame.MainFrame.Model.PortraitBg) then
		TalkingHeadFrame.MainFrame.Model.PortraitBg:Hide()
	end

	local TalkingHeadFramePanel = CreateFrame("Frame", nil, TalkingHeadFrame)
	TalkingHeadFramePanel:SetFrameLevel(TalkingHeadFrame:GetFrameLevel() - 1)
	TalkingHeadFramePanel:Size(542, 129)
	TalkingHeadFramePanel:Point("CENTER", TalkingHeadFrame, 0, 0)
	TalkingHeadFramePanel:CreateBackdrop()
	TalkingHeadFramePanel:CreateShadow()
	
	local TalkingHeadFrameModelPanel = CreateFrame("Frame", nil, TalkingHeadFrame.MainFrame.Model)
	TalkingHeadFrameModelPanel:SetOutside(TalkingHeadFrame.MainFrame.Model, 1, 1)
	TalkingHeadFrameModelPanel:SetTemplate()
	TalkingHeadFrameModelPanel:CreateShadow()

	local Name = TalkingHeadFrame.NameFrame.Name
	Name:SetFontTemplate("Default", 18)
	Name:SetTextColor(1, 0.82, 0)

	local Text = TalkingHeadFrame.TextFrame.Text
	Text:SetFontTemplate("Default", 14)
	Text:SetTextColor(1, 1, 1)

	local CloseButton = TalkingHeadFrame.MainFrame.CloseButton
	CloseButton:HandleCloseButton()
	
	self.IsSkinned = true
end

function TalkingHead:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end

	if (not IsAddOnLoaded("Blizzard_TalkingHeadUI")) then
		LoadAddOn("Blizzard_TalkingHeadUI")
	end
	
	self:Skin()
end