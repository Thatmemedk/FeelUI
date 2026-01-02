local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local TalkingHead = UI:RegisterModule("TalkingHead")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- Locals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

function TalkingHead:Skin()
	if (self.IsSkinned) then
		return
	end

	local TalkingHeadFrame = _G.TalkingHeadFrame
	TalkingHeadFrame.BackgroundFrame:Hide()
	TalkingHeadFrame.PortraitFrame:Hide()
	TalkingHeadFrame.MainFrame.Model.PortraitBg:Hide()
	TalkingHeadFrame.MainFrame.CloseButton:HandleCloseButton()

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
	Name.SetTextColor = UI.Noop
	Name.SetShadowOffset = UI.Noop
	
	local Text = TalkingHeadFrame.TextFrame.Text
	Text:SetFontTemplate("Default", 14)
	Text:SetTextColor(1, 1, 1)
	Text.SetTextColor = UI.Noop
	Text.SetShadowOffset = UI.Noop
		
	self.IsSkinned = true
end

function TalkingHead:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end

	if not IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		LoadAddOn("Blizzard_TalkingHeadUI")
	end
	
	self:Skin()
end