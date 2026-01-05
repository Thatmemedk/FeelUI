local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:CallModule("CooldownManager")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer

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
	if (Button.CDMIsSkinned) then
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

	if (not Button and not Icon) then
		return
	end

	Button:Size(unpack(ButtonSize))
	Button:SetTemplate()
	Button:CreateShadow()
	Button:SetShadowOverlay()

	-- Diable Tooltip
	Button:HookScript("OnEnter", function()
		GameTooltip:Hide()
	end)

	Button:HookScript("OnLeave", function()
		GameTooltip:Hide()
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

	if (Icon) then
		Icon:ClearAllPoints()
		Icon:SetInside()

		-- Keep Aspect Ratio
		UI:KeepAspectRatio(Button, Icon)

		-- Remove Masks
		self:StripTextureMasks(Icon)
	end

	if (Cooldown) then
		Cooldown:SetSwipeTexture(Media.Global.Blank)
		Cooldown:ClearAllPoints()
		Cooldown:SetInside()
		Cooldown:SetReverse(true)
	end

	if (CooldownFlash) then
		CooldownFlash:ClearAllPoints()
		CooldownFlash:SetInside()
	end

	if (OutOfRange) then
		OutOfRange:ClearAllPoints()
		OutOfRange:SetInside()
	end
 
	if (Charges) then
    	Charges:ClearAllPoints()
    	Charges:Point("TOPRIGHT", Button, -2, 6)
    	Charges:SetFontTemplate("Default", 12)
	end

	if (Count) then
		Count:SetParent(InvisFrame)
    	Count:ClearAllPoints()
    	Count:Point("TOP", Button, 0, 8)
    	Count:SetFontTemplate("Default", 14)
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