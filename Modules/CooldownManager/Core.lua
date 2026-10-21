local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:RegisterModule("CooldownManager")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local type = type
local pairs = pairs
local ipairs = ipairs
local table = table

-- WoW Globals
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local GameTooltip_Hide = _G.GameTooltip_Hide
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer
local BuffBarCooldownViewer = _G.BuffBarCooldownViewer
local SetCVar = _G.C_CVar.SetCVar
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local LoadAddOn = _G.C_AddOns.LoadAddOn

-- Tables
CDM.Anchors = {}
CDM.Items = {}
CDM.Shown = {}
CDM.ItemSize = {}
CDM.ItemScale = {}

CDM.DynamicViewers = {
	EssentialCooldownViewer = "CENTER",
	BuffIconCooldownViewer = "CENTER",
	UtilityCooldownViewer = "CENTER",
}

-- ICON SKINNING

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

	if (type(ButtonSize) == "table") then
		Button:Size(unpack(ButtonSize))
	end

	Button:SetTemplate()
	Button:CreateShadow()
	Button:SetShadowOverlay()

	-- Disable Tooltip
	Button:HookScript("OnEnter", GameTooltip_Hide)
	Button:HookScript("OnLeave", GameTooltip_Hide)

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
	Icon:ClearAllPoints()
	Icon:SetInside(Button, 0, 0)

	-- Keep Aspect Ratio
	UI:KeepAspectRatio(Button, Icon)

	-- Remove Masks
	self:StripTextureMasks(Icon)

	-- Cooldown
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
		NewPandemic:SetFrameLevel(Button:GetFrameLevel() - 1)
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
	if (not Elements or not Elements.itemFramePool) then
		return
	end

	for Frame in Elements.itemFramePool:EnumerateActive() do
		self:SkinIcons(Frame, ButtonSize)
	end
end

function CDM:UpdateIcons()
	self:UpdateIconPool(BuffIconCooldownViewer, DB.Global.CooldownManager.BuffViewerButtonSize)
	self:UpdateIconPool(EssentialCooldownViewer, DB.Global.CooldownManager.EssentialViewerButtonSize)
	self:UpdateIconPool(UtilityCooldownViewer, DB.Global.CooldownManager.UtilityViewerButtonSize)
end

-- ANCHORS

function CDM:CreateAnchors(Frame, Point, Anchor, X, Y, IconSpacing)
	if (not Frame) then
		return
	end

	local Existing = self.Anchors[Frame]

	if (Existing and Existing.Frame) then
		Existing.IconSpacing = IconSpacing

		return Existing.Frame
	end

	local AnchorFrame = CreateFrame("Frame", nil, _G.UIParent)
	AnchorFrame:Size(36, 18)
	AnchorFrame:Point(Point, Anchor, X or 0, Y or 0)

	self.Anchors[Frame] = {
		Frame = AnchorFrame,
		IconSpacing = IconSpacing,
	}

	return AnchorFrame
end

function CDM:CreateContainers()
	local Point, Parent, X, Y
	local Spacing = DB.Global.CooldownManager.ButtonSpacing

	Point, Parent, X, Y = unpack(DB.Global.CooldownManager.BuffViewerPoint)
	self:CreateAnchors(BuffIconCooldownViewer, Point, Parent, X, Y, Spacing)

	Point, Parent, X, Y = unpack(DB.Global.CooldownManager.EssentialViewerPoint)
	self:CreateAnchors(EssentialCooldownViewer, Point, Parent, X, Y, Spacing)

	Point, Parent, X, Y = unpack(DB.Global.CooldownManager.UtilityViewerPoint)
	self:CreateAnchors(UtilityCooldownViewer, Point, Parent, X, Y, Spacing)
end

function CDM:UpdateAnchors(OnlyViewer)
	for Viewer, Data in pairs(self.Anchors) do
		local AnchorFrame = Data.Frame

		if (AnchorFrame and (not OnlyViewer or Viewer == OnlyViewer)) then
			if (Viewer:GetParent() ~= AnchorFrame) then
				Viewer:SetParent(AnchorFrame)
			end

			local Point, Relative = Viewer:GetPoint(1)

			if (Point ~= "CENTER" or Relative ~= AnchorFrame or Viewer:GetNumPoints() ~= 1) then
				Viewer:ClearAllPoints()
				Viewer:Point("CENTER", AnchorFrame, "CENTER", 0, 0)
			end
		end
	end
end

-- LAYOUT

function CDM.ByLayoutIndex(A, B)
	return (A.layoutIndex or 0) < (B.layoutIndex or 0)
end

function CDM:RepositionButtons(Viewer, Anchor, Measure)
	local Items = self.Items[Viewer]

	if (not Items) then
		return
	end

	local ShownItems = self.Shown[Viewer]

	if (not ShownItems) then
		ShownItems = {}
		self.Shown[Viewer] = ShownItems
	end

	local ItemCount = 0

	for _, Item in ipairs(Items) do
		if (Item:IsShown()) then
			ItemCount = ItemCount + 1
			ShownItems[ItemCount] = Item
		end
	end

	for Index = #ShownItems, ItemCount + 1, -1 do
		ShownItems[Index] = nil
	end

	if (ItemCount == 0) then
		return
	end

	if (ItemCount > 1) then
		table.sort(ShownItems, self.ByLayoutIndex)
	end

	local IsVertical = (Anchor == "BOTTOM" or Viewer.isHorizontal == false)

	if (Measure or not self.ItemSize[Viewer]) then
		local FirstItem = ShownItems[1]
		local ItemDimension = IsVertical and FirstItem:GetHeight() or FirstItem:GetWidth()
		local ItemScale = FirstItem:GetScale()

		if (not UI:IsSecretValue(ItemDimension) and ItemDimension ~= nil) then
			self.ItemSize[Viewer] = ItemDimension
		end

		if (not UI:IsSecretValue(ItemScale) and ItemScale ~= nil) then
			self.ItemScale[Viewer] = ItemScale
		end
	end

	local ItemScale = self.ItemScale[Viewer] or 1
	local ButtonSpacing = DB.Global.CooldownManager.ButtonSpacing or 0
	local ScaledSpacing = ButtonSpacing / ItemScale
	local ItemSize = self.ItemSize[Viewer] or 40
	local ItemStep = ItemSize + ScaledSpacing
	local StartOffset = (Anchor == "BOTTOM") and 0 or -(ItemCount - 1) * ItemStep / 2

	for Index = 1, ItemCount do
		local Item = ShownItems[Index]
		local Offset = StartOffset + (Index - 1) * ItemStep

		Item:ClearAllPoints()

		if (IsVertical) then
			Item:Point(Anchor, Viewer, Anchor, 0, Offset)
		else
			Item:Point(Anchor, Viewer, Anchor, Offset, 0)
		end
	end
end

function CDM:UpdateItems(Viewer, Item, Anchor, ButtonSize)
	if (Item.CDMKnown) then
		return
	end

	local Items = self.Items[Viewer]
	Items[#Items + 1] = Item

	Item:HookScript("OnShow", function() self:RepositionButtons(Viewer, Anchor) end)
	Item:HookScript("OnHide", function() self:RepositionButtons(Viewer, Anchor) end)

	self:SkinIcons(Item, ButtonSize)

	Item.CDMKnown = true
end

function CDM:UpdateViewers(Name, Anchor, ButtonSize)
	local Viewer = _G[Name]

	if (not Viewer or self.Items[Viewer]) then
		return
	end

	self.Items[Viewer] = {}

	local Container = Viewer.GetItemContainerFrame and Viewer:GetItemContainerFrame()

	if (Container) then
		for _, Child in ipairs({ Container:GetChildren() }) do
			if (Child.SetHideWhenInactive) then
				self:UpdateItems(Viewer, Child, Anchor, ButtonSize)
			end
		end

		self:UpdateIconPool(Container, ButtonSize)
	end

	hooksecurefunc(Viewer, "OnAcquireItemFrame", function(_, Item)
		self:UpdateItems(Viewer, Item, Anchor, ButtonSize)
		self:RepositionButtons(Viewer, Anchor)
		self:UpdateAnchors(Viewer)
	end)

	if (Viewer.Layout) then
		hooksecurefunc(Viewer, "Layout", function()
			self:RepositionButtons(Viewer, Anchor, true)
			self:UpdateAnchors(Viewer)
		end)
	elseif (Viewer.RefreshLayout) then
		hooksecurefunc(Viewer, "RefreshLayout", function()
			self:RepositionButtons(Viewer, Anchor, true)
			self:UpdateAnchors(Viewer)
		end)
	end

	self:RepositionButtons(Viewer, Anchor)
end

function CDM:UpdateLayout()
	self:UpdateViewers("EssentialCooldownViewer", self.DynamicViewers.EssentialCooldownViewer, DB.Global.CooldownManager.EssentialViewerButtonSize)
	self:UpdateViewers("BuffIconCooldownViewer", self.DynamicViewers.BuffIconCooldownViewer, DB.Global.CooldownManager.BuffViewerButtonSize)
	self:UpdateViewers("UtilityCooldownViewer", self.DynamicViewers.UtilityCooldownViewer, DB.Global.CooldownManager.UtilityViewerButtonSize)
end

function CDM:SetCVarOnLogin()
	SetCVar("cooldownViewerEnabled", 1)
end

-- INITIALIZATION

function CDM:Initialize()
	if (not DB.Global.CooldownManager.Enable) then
		return
	end

	if (not IsAddOnLoaded("Blizzard_CooldownViewer")) then
		LoadAddOn("Blizzard_CooldownViewer")
	end

	self:SetCVarOnLogin()
	self:CreateContainers()
	self:UpdateAnchors()
	self:UpdateIcons()
	self:UpdateLayout()
end