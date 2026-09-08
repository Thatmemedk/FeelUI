local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:CallModule("CooldownManager")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer
local GetAuraDispelTypeColor = _G.C_UnitAuras.GetAuraDispelTypeColor

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function CDM:StripTextureMasks(Frame)
	if (not Frame or not Frame.GetMaskTexture) then 
		return 
	end

	local Index = 1
	local Mask = Frame:GetMaskTexture(Index)

	while Mask do
		Frame:RemoveMaskTexture(Mask)
		Index = Index + 1
		Mask = Frame:GetMaskTexture(Index)
	end
end

function CDM:SkinIcons(Button, ButtonSize)
	if (not Button or Button.CDMIsSkinned or Button:IsForbidden() or UI:IsSecretValue(Button)) then
		return
	end

	local Icon = Button.Icon
	local Count = Button.Applications and Button.Applications.Applications
	local Charges = Button.ChargeCount and Button.ChargeCount.Current
	local Cooldown = Button.Cooldown
	local OutOfRange = Button.OutOfRange
	local CooldownFlash = Button.CooldownFlash
	local Border = Button.DebuffBorder
	local BorderTex = select(3, Button:GetRegions())

	if (not Icon) then
		return
	end

	Button:Size(unpack(ButtonSize))
	Button:SetTemplate()
	Button:CreateShadow()
	Button:SetShadowOverlay()

	-- Disable Tooltip
	Button:HookScript("OnEnter", function()
		_G.GameTooltip_Hide()
	end)

	Button:HookScript("OnLeave", function()
		_G.GameTooltip_Hide()
	end)

	local InvisFrame = CreateFrame("Frame", nil, Button)
	InvisFrame:SetFrameLevel(Button:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	if (BorderTex) then
		BorderTex:SetAlpha(0)
	end

	if (Border) then
		Border:SetAlpha(0)
	end

	-- Icon
	if (Icon) then
		Icon:ClearAllPoints()
		Icon:SetInside(Button, 0, 0)

		-- Keep Aspect Ratio
		UI:KeepAspectRatio(Button, Icon)

		-- Remove Masks
		self:StripTextureMasks(Icon)
	end

	if (Cooldown) then
		Cooldown:SetSwipeTexture(Media.Global.Blank)
		Cooldown:ClearAllPoints()
		Cooldown:SetInside(Button, 0, 0)
		Cooldown:SetReverse(true)

		UI:UpdateCooldownText(Cooldown, Button, 0, -8, true)
	end

	if (CooldownFlash) then
		CooldownFlash:ClearAllPoints()
		CooldownFlash:SetInside(Button, 0, 0)
	end

	if (OutOfRange) then
		OutOfRange:ClearAllPoints()
		OutOfRange:SetInside(Button, 0, 0)
	end

	if (Charges) then
		Charges:ClearAllPoints()
		Charges:Point("TOP", Button, 0, 6)
		Charges:SetFontTemplate("Default", 12)
	end

	if (Count) then
		Count:SetParent(InvisFrame)
		Count:ClearAllPoints()
		Count:Point("TOP", Button, 0, 6)
		Count:SetFontTemplate("Default", 14)
	end

	-- Pandemic
	if (not Button.CDMPandemic) then
		local NewPandemic = CreateFrame("Frame", nil, Button)
		NewPandemic:SetFrameLevel(Button:GetFrameLevel() -1)
		NewPandemic:SetInside()
		NewPandemic:CreateGlow(2, 3, 1, 0, 0, 1)
		NewPandemic:Hide()

		local Animation = NewPandemic:CreateAnimationGroup()
		Animation:SetLooping("BOUNCE")

		Animation.FadeOut = Animation:CreateAnimation("Alpha")
		Animation.FadeOut:SetFromAlpha(1)
		Animation.FadeOut:SetToAlpha(0)
		Animation.FadeOut:SetDuration(0.5)
		Animation.FadeOut:SetSmoothing("IN_OUT")

		Button.CDMPandemic = NewPandemic
		Button.CDMPandemicAnimation = Animation

		if (Button.ShowPandemicStateFrame) then
			hooksecurefunc(Button, "ShowPandemicStateFrame", function()
				if (Button.PandemicIcon) then
					Button.PandemicIcon:Hide()
					Button.PandemicIcon:SetAlpha(0)
				end

				if (not Button.CDMPandemicAnimation:IsPlaying()) then
			        Button.CDMPandemic:Show()
			        Button.CDMPandemicAnimation:Play()
			    end
			end)
		end

		if (Button.HidePandemicStateFrame) then
			hooksecurefunc(Button, "HidePandemicStateFrame", function()
				if (Button.PandemicIcon) then
					Button.PandemicIcon:Hide()
					Button.PandemicIcon:SetAlpha(0)
				end

			    if (Button.CDMPandemicAnimation and Button.CDMPandemicAnimation:IsPlaying()) then
			    	Button.CDMPandemic:Hide()
			        Button.CDMPandemicAnimation:Stop()
			    end
			end)
		end
	end

	Button.CDMIsSkinned = true
end

function CDM:UpdateIconPool(Elements, ButtonSize)
    hooksecurefunc(Elements, "OnAcquireItemFrame", function(self, Frame)
        CDM:SkinIcons(Frame, ButtonSize)
    end)

    for Frame in Elements.itemFramePool:EnumerateActive() do
        CDM:SkinIcons(Frame, ButtonSize)
    end
end

function CDM:UpdateIcons()
	self:UpdateIconPool(BuffIconCooldownViewer, DB.Global.CooldownManager.BuffViewerButtonSize)
	self:UpdateIconPool(EssentialCooldownViewer, DB.Global.CooldownManager.EssentialViewerButtonSize)
	self:UpdateIconPool(UtilityCooldownViewer, DB.Global.CooldownManager.UtilityViewerButtonSize)
end