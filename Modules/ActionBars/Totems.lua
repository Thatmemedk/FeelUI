local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

-- WoW Globals
local MultiCastActionBarFrame = _G.MultiCastActionBarFrame
local MultiCastSummonSpellButton = _G.MultiCastSummonSpellButton
local MultiCastRecallSpellButton = _G.MultiCastRecallSpellButton
local MultiCastSummonSpellButtonNormalTexture = _G.MultiCastSummonSpellButtonNormalTexture
local MultiCastSummonSpellButtonIcon = _G.MultiCastSummonSpellButtonIcon
local MultiCastSummonSpellButtonCooldown = _G.MultiCastSummonSpellButtonCooldown
local MultiCastRecallSpellButtonNormalTexture = _G.MultiCastRecallSpellButtonNormalTexture
local MultiCastRecallSpellButtonIcon = _G.MultiCastRecallSpellButtonIcon
local MultiCastRecallSpellButtonCooldown = _G.MultiCastRecallSpellButtonCooldown
local OpenButton = _G.MultiCastFlyoutFrameOpenButton
local CloseButton = _G.MultiCastFlyoutFrameCloseButton

-- Locals
local TotemButtonSize = DB.Global.ActionBars.TotemButtonSize
local TotemButtonSpacing = DB.Global.ActionBars.TotemButtonSpacing
local TotemBarPositioning = false
local TotemBarPositionPending = false

-- Tables
local SLOT_BORDER_COLORS = {
	["summon"]			= { r = 0.45, g = 0.45, b = 0.45 },
	[EARTH_TOTEM_SLOT]	= { r = 0.23, g = 0.45, b = 0.13 },
	[FIRE_TOTEM_SLOT]	= { r = 0.58, g = 0.23, b = 0.10 },
	[WATER_TOTEM_SLOT]	= { r = 0.19, g = 0.48, b = 0.60 },
	[AIR_TOTEM_SLOT]	= { r = 0.42, g = 0.18, b = 0.74 }
}

-- POSITIONING

function AB:PositionTotemButtons()
	if (TotemBarPositioning) then
		return
	end

	if (InCombatLockdown()) then
		TotemBarPositionPending = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local Holder = self.TotemHolder

	if (not Holder) then
		return
	end

	TotemBarPositioning = true

	local NumActiveSlots = MultiCastActionBarFrame and MultiCastActionBarFrame.numActiveSlots or 0
	local Width = (TotemButtonSize[1] * (NumActiveSlots + 2)) + (TotemButtonSpacing * (NumActiveSlots + 1))

	Holder:Width(Width)
	Holder:Height(TotemButtonSize[2])

	if (MultiCastActionBarFrame) then
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetAllPoints(Holder)
	end

	if (MultiCastSummonSpellButton) then
		MultiCastSummonSpellButton:ClearAllPoints()
		MultiCastSummonSpellButton:Point("LEFT", Holder, "LEFT", 0, 0)
	end

	local PreviousSlot

	for i = 1, NumActiveSlots do
		local ActionButton = _G["MultiCastActionButton"..i]
		local SlotButton = _G["MultiCastSlotButton"..i]

		if (SlotButton) then
			SlotButton:ClearAllPoints()

			if (i == 1) then
				SlotButton:Point("LEFT", MultiCastSummonSpellButton, "RIGHT", TotemButtonSpacing, 0)
			else
				SlotButton:Point("LEFT", PreviousSlot, "RIGHT", TotemButtonSpacing, 0)
			end

			if (ActionButton) then
				ActionButton:ClearAllPoints()
				ActionButton:SetAllPoints(SlotButton)
			end

			-- Color this slot by totem element so the bar reads at a glance
			local Color = SLOT_BORDER_COLORS[SlotButton:GetID()]

			if (ActionButton and Color and ActionButton.SetBackdropColorTemplate) then
				ActionButton:SetBackdropColorTemplate(Color.r, Color.g, Color.b)
			end

			PreviousSlot = SlotButton
		end
	end

	if (MultiCastRecallSpellButton) then
		MultiCastRecallSpellButton:ClearAllPoints()

		if (PreviousSlot) then
			MultiCastRecallSpellButton:Point("LEFT", PreviousSlot, "RIGHT", TotemButtonSpacing, 0)
		elseif (MultiCastSummonSpellButton) then
			MultiCastRecallSpellButton:Point("LEFT", MultiCastSummonSpellButton, "RIGHT", TotemButtonSpacing, 0)
		end
	end

	TotemBarPositioning = false
end

-- UPDATE

function AB:UpdateTotemFlyout(Type, Parent)
	self.top:SetTexture(nil)
	self.middle:SetTexture(nil)

	local Color = Type == "page" and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[Parent:GetID()]
	local NumButtons = 0
	local TotalHeight = 0
	local PreviousButton

	for _, Button in ipairs(self.buttons) do
		if (not Button.TotemFlyOutIsSkinned) then
			Button:CreateBackdrop()
			Button:CreateShadow()
			Button:StyleButton()
			Button:SetShadowOverlay()

			Button.TotemFlyOutIsSkinned = true
		end

		if (Button:IsShown()) then
			NumButtons = NumButtons + 1

			Button:ClearAllPoints()
			Button:Size(unpack(TotemButtonSize))
			Button:SetBackdropColorTemplate(Color.r, Color.g, Color.b)
			UI:KeepAspectRatio(Button, Button.icon)

			if (PreviousButton) then
				Button:Point("BOTTOM", PreviousButton, "TOP", 0, TotemButtonSpacing)
			else
				Button:Point("BOTTOM", Parent, "TOP", 0, TotemButtonSpacing)
			end

			PreviousButton = Button
			TotalHeight = TotalHeight + Button:GetHeight()

			if (NumButtons > 1) then
				TotalHeight = TotalHeight + TotemButtonSpacing
			end
		end
	end

	CloseButton:ClearAllPoints()

	if (PreviousButton) then
		CloseButton:Point("BOTTOM", PreviousButton, "TOP", 0, TotemButtonSpacing)
	else
		CloseButton:Point("BOTTOM", Parent, "TOP", 0, TotemButtonSpacing)
	end

	TotalHeight = TotalHeight + TotemButtonSpacing + CloseButton:GetHeight()

	if (Type == "slot") then
		self.buttons[1].icon:SetAlpha(0)
	end

	OpenButton.NewTexture:SetVertexColor(Color.r, Color.g, Color.b)
	CloseButton.NewTexture:SetVertexColor(Color.r, Color.g, Color.b)

	self:ClearAllPoints()
	self:Point("BOTTOM", Parent, "TOP", 0, TotemButtonSpacing)
	self:Height(TotalHeight)
end

function AB:UpdateTotemFlyoutOpen(Type, Parent)
	local Color = Type == "page" and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[Parent:GetID()]
	OpenButton.NewTexture:SetVertexColor(Color.r, Color.g, Color.b)
	OpenButton:ClearAllPoints()
	OpenButton:Point("BOTTOM", Parent, "TOP", 0, TotemButtonSpacing)
end

function AB:SkinTotemButtons()
	local TotemHolder = CreateFrame("Frame", "FeelUI_Totems", _G.UIParent)
	TotemHolder:Size(TotemButtonSize[1] * 3 + TotemButtonSpacing * 2, TotemButtonSize[2])
	TotemHolder:Point("CENTER", _G.UIParent, -294, -172)

	if (MultiCastActionBarFrame) then
		MultiCastActionBarFrame:SetParent(TotemHolder)
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetAllPoints(TotemHolder)
		MultiCastActionBarFrame:SetMovable(false)
	end

	for i = 1, 12 do
		local Button = _G["MultiCastActionButton"..i]
		local ButtonSlot = _G["MultiCastSlotButton"..i]
		local OverlayTex = Button.overlayTex
		local Border = _G["MultiCastActionButton"..i.."Border"]
		local Icon = _G["MultiCastActionButton"..i.."Icon"]
		local Cooldown = _G["MultiCastActionButton"..i.."Cooldown"]

		Button:Size(unpack(TotemButtonSize))
		Button:SetNormalTexture(UI.ClearTexture)
		Button:CreateButtonPanel()
		Button:CreateShadow()
		Button:StyleButton()
		Button:SetShadowOverlay()

		if (Icon) then
			Icon:Size(unpack(TotemButtonSize))
			Icon:SetInside(Button, 1, 1)
			UI:KeepAspectRatio(Icon, Icon)
		end

		if (ButtonSlot) then
			ButtonSlot:StripTexture()
			ButtonSlot:Size(unpack(TotemButtonSize))
			ButtonSlot:SetInside(Button, 1, 1)
		end

		if (OverlayTex) then
			OverlayTex:Hide()
		end

		if (Border) then
			Border:SetAlpha(0)
		end

		if (Cooldown) then
			Cooldown:ClearAllPoints()
			Cooldown:SetInside(Button, 1, 1)
			UI:UpdateCooldownText(Cooldown, 0, 0, true)
		end
	end

	if (MultiCastSummonSpellButton) then
		MultiCastSummonSpellButton:SetParent(TotemHolder)
		MultiCastSummonSpellButton:Size(unpack(TotemButtonSize))
		MultiCastSummonSpellButton:SetNormalTexture(UI.ClearTexture)
		MultiCastSummonSpellButton:CreateButtonPanel()
		MultiCastSummonSpellButton:CreateShadow()
		MultiCastSummonSpellButton:StyleButton()
		MultiCastSummonSpellButton:SetShadowOverlay()

		if (MultiCastSummonSpellButtonIcon) then
			MultiCastSummonSpellButtonIcon:SetInside(MultiCastSummonSpellButton, 1, 1)
			UI:KeepAspectRatio(MultiCastSummonSpellButton, MultiCastSummonSpellButtonIcon)
		end

		if (MultiCastSummonSpellButtonCooldown) then
			MultiCastSummonSpellButtonCooldown:ClearAllPoints()
			MultiCastSummonSpellButtonCooldown:SetInside(MultiCastSummonSpellButton, 1, 1)

			UI:UpdateCooldownText(MultiCastSummonSpellButtonCooldown, 0, 0, true)
		end

		if (_G.MultiCastSummonSpellButtonHighlight) then
			_G.MultiCastSummonSpellButtonHighlight:Kill()
		end
	end

	if (MultiCastRecallSpellButton) then
		MultiCastRecallSpellButton:SetParent(TotemHolder)
		MultiCastRecallSpellButton:Size(unpack(TotemButtonSize))
		MultiCastRecallSpellButton:SetNormalTexture(UI.ClearTexture)
		MultiCastRecallSpellButton:CreateButtonPanel()
		MultiCastRecallSpellButton:CreateShadow()
		MultiCastRecallSpellButton:StyleButton()
		MultiCastRecallSpellButton:SetShadowOverlay()

		if (MultiCastRecallSpellButtonIcon) then
			MultiCastRecallSpellButtonIcon:SetInside(MultiCastRecallSpellButton, 1, 1)
			UI:KeepAspectRatio(MultiCastRecallSpellButton, MultiCastRecallSpellButtonIcon)
		end

		if (MultiCastRecallSpellButtonCooldown) then
			MultiCastRecallSpellButtonCooldown:ClearAllPoints()
			MultiCastRecallSpellButtonCooldown:SetInside(MultiCastRecallSpellButton, 1, 1)

			UI:UpdateCooldownText(MultiCastRecallSpellButtonCooldown, 0, 0, true)
		end

		if (_G.MultiCastRecallSpellButtonHighlight) then
			_G.MultiCastRecallSpellButtonHighlight:Kill()
		end
	end

	OpenButton:Size(42, 12)
	OpenButton:CreateBackdrop()
	OpenButton:CreateShadow()
	OpenButton.normalTexture:SetTexture("")
	OpenButton:StyleButton()

	OpenButton.NewTexture = OpenButton:CreateTexture(nil, "ARTWORK")
	OpenButton.NewTexture:Size(16)
	OpenButton.NewTexture:Point("CENTER", OpenButton, 0, -2)
	OpenButton.NewTexture:SetTexture(Media.Global.ArrowTop)
	OpenButton.NewTexture:SetVertexColor(1, 0.82, 0)

	CloseButton:Size(42, 12)
	CloseButton:CreateBackdrop()
	CloseButton:CreateShadow()
	CloseButton.normalTexture:SetTexture("")
	CloseButton:StyleButton()

	CloseButton.NewTexture = CloseButton:CreateTexture(nil, "ARTWORK")
	CloseButton.NewTexture:Size(16)
	CloseButton.NewTexture:Point("CENTER", CloseButton, 0, 2)
	CloseButton.NewTexture:SetTexture(Media.Global.ArrowBottom)
	CloseButton.NewTexture:SetVertexColor(1, 0.82, 0)

	-- Cache
	self.TotemHolder = TotemHolder
end

function AB:UpdateTotemBar()
	hooksecurefunc("MultiCastFlyoutFrame_ToggleFlyout", self.UpdateTotemFlyout)
	hooksecurefunc("MultiCastFlyoutFrameOpenButton_Show", self.UpdateTotemFlyoutOpen)

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	self:SetScript("OnEvent", function(self, event)
		if (event == "PLAYER_REGEN_ENABLED") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")

			if (TotemBarPositionPending) then
				TotemBarPositionPending = false
				AB:PositionTotemButtons()
			end
		elseif (event == "PLAYER_ENTERING_WORLD") then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			AB:PositionTotemButtons()
		elseif (event == "UPDATE_MULTI_CAST_ACTIONBAR") then
			AB:PositionTotemButtons()
		end
	end)
end

function AB:CreateTotemBar()
	self:SkinTotemButtons()
	self:UpdateTotemBar()
end