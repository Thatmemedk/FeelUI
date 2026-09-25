local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local MultiCastActionBarFrame = _G.MultiCastActionBarFrame
local SummonButton = _G.MultiCastSummonSpellButton
local SummonButtonNormalTexture = _G.MultiCastSummonSpellButtonNormalTexture
local SummonButtonIcon = _G.MultiCastSummonSpellButtonIcon
local SummonButtonCooldown = _G.MultiCastSummonSpellButtonCooldown
local RecallButton = _G.MultiCastRecallSpellButton
local RecallButtonNormalTexture = _G.MultiCastRecallSpellButtonNormalTexture
local RecallButtonIcon = _G.MultiCastRecallSpellButtonIcon
local RecallButtonCooldown = _G.MultiCastRecallSpellButtonCooldown
local OpenButton = _G.MultiCastFlyoutFrameOpenButton
local CloseButton = _G.MultiCastFlyoutFrameCloseButton

-- Locals
local TotemButtonSize = DB.Global.ActionBars.TotemButtonSize
local TotemButtonSpacing = DB.Global.ActionBars.TotemButtonSpacing

-- Locals
local Class = select(2, UnitClass("player"))

-- Tables
local SLOT_BORDER_COLORS = {
	summon = { r = 1, g = 0.82, b = 0, a = 1 },
	[_G.EARTH_TOTEM_SLOT]= { r = 0.23, g = 0.45, b = 0.13, a = 1 },
	[_G.FIRE_TOTEM_SLOT] = { r = 0.58, g = 0.23, b = 0.10, a = 1 },
	[_G.WATER_TOTEM_SLOT]= { r = 0.19, g = 0.48, b = 0.60, a = 1 },
	[_G.AIR_TOTEM_SLOT]	= { r = 0.42, g = 0.18, b = 0.74, a = 1 }
}

local SLOT_EMPTY_TCOORDS = {
	[_G.EARTH_TOTEM_SLOT] = { left = 0.52, right = 0.75, top = 0.01, bottom = 0.13 },
	[_G.FIRE_TOTEM_SLOT] = { left = 0.52, right = 0.76, top = 0.39, bottom = 0.51 },
	[_G.WATER_TOTEM_SLOT] = { left = 0.30, right = 0.54, top = 0.82, bottom = 0.93 },
	[_G.AIR_TOTEM_SLOT] = { left = 0.52, right = 0.75, top = 0.14, bottom = 0.26 }
}

function AB:SkinMultiCastSpellButton(Button, Icon, Cooldown, NormalTexture)
	if (not Button or Button.IsSkinned) then
		return
	end

	local Highlight = _G[Button:GetName().."Highlight"]

	Button:SetParent(self.TotemHolder)
	Button:Size(unpack(TotemButtonSize))
	Button:SetNormalTexture(UI.ClearTexture)
	Button:CreateButtonPanel()
	Button:CreateShadow()
	Button:StyleButton()
	Button:SetShadowOverlay()

	if (NormalTexture) then
		NormalTexture:SetAlpha(0)
	end

	if (Icon) then
		Icon:SetInside(Button, 1, 1)
		UI:KeepAspectRatio(Button, Icon)
	end

	if (Cooldown) then
		Cooldown:ClearAllPoints()
		Cooldown:SetInside(Button, 1, 1)
		UI:UpdateCooldownText(Cooldown, 0, 0, true)
	end

	if (Highlight) then
		Highlight:SetAlpha(0)
	end

	Button.IsSkinned = true
end

function AB:SkinMultiCastArrowButton(Button, Texture, PointY)
	if (not Button or Button.IsSkinned) then
		return
	end

	local NormalTexture = Button:GetNormalTexture()
	local Highlight = _G[Button:GetName().."Highlight"]

	Button:Size(36, 12)
	Button:SetNormalTexture(UI.ClearTexture)
	Button:SetPushedTexture(UI.ClearTexture)
	Button:SetHighlightTexture(UI.ClearTexture)

	if (NormalTexture) then
		NormalTexture:SetAlpha(0)
	end

	if (Highlight) then
		Highlight:SetAlpha(0)
	end

	Button.NewTexture = Button:CreateTexture(nil, "ARTWORK")
	Button.NewTexture:Size(16)
	Button.NewTexture:Point("CENTER", Button, 0, PointY)
	Button.NewTexture:SetTexture(Texture)
	Button.NewTexture:SetVertexColor(1, 0.82, 0)
	Button.NewTexture:SetAlpha(0)

	Button:HookScript("OnEnter", function()
		UI:UIFrameFadeIn(Button.NewTexture, 0.5, Button.NewTexture:GetAlpha(), 1)
	end)
	
	Button:HookScript("OnLeave", function()
		UI:UIFrameFadeOut(Button.NewTexture, 0.5, Button.NewTexture:GetAlpha(), 0)
	end)

	Button.IsSkinned = true
end

function AB:UpdateTotemFlyout(Frame, Type, Parent)
	Frame.top:SetTexture(nil)
	Frame.middle:SetTexture(nil)

	local Color = Type == "page" and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[Parent:GetID()]
	local NumButtons = 0
	local TotalHeight = 0
	local PreviousButton

	for _, Button in ipairs(Frame.buttons) do
		if (not Button.IsSkinned) then
			Button:CreateBackdrop()
			Button:CreateShadow()
			Button:StyleButton()
			Button:SetShadowOverlay()

			Button.IsSkinned = true
		end

		if (Button:IsShown()) then
			NumButtons = NumButtons + 1

			Button:ClearAllPoints()
			Button:Size(unpack(TotemButtonSize))
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

	if (Type == "slot") then
		local IconCoords = SLOT_EMPTY_TCOORDS[Parent:GetID()]
		UI:KeepAspectRatio(Frame.buttons[1], Frame.buttons[1].icon, IconCoords)
	end

	Frame:ClearAllPoints()
	CloseButton:ClearAllPoints()

	if (PreviousButton) then
		Frame:Point("BOTTOM", Parent, "TOP", 0, TotemButtonSpacing)
		CloseButton:Point("BOTTOM", PreviousButton, "TOP", 0, TotemButtonSpacing)
	else
		Frame:Point("TOP", Parent, "BOTTOM", 0, TotemButtonSpacing)
		CloseButton:Point("BOTTOM", Parent, "TOP", 0, TotemButtonSpacing)
	end

	TotalHeight = TotalHeight + TotemButtonSpacing + CloseButton:GetHeight()

	if (OpenButton) then
		OpenButton.NewTexture:SetVertexColor(Color.r, Color.g, Color.b)
	end

	if (CloseButton) then
		CloseButton.NewTexture:SetVertexColor(Color.r, Color.g, Color.b)
	end

	Frame:Height(TotalHeight)
end

function AB:UpdateTotemFlyoutOpen(Button, Type, Parent)
	local Color = Type == "page" and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[Parent:GetID()]

	if (OpenButton) then
		OpenButton.NewTexture:SetVertexColor(Color.r, Color.g, Color.b)
	end
end

function AB:CreateAnchor()
	local TotemHolder = CreateFrame("Frame", "FeelUI_Totems", _G.UIParent)
	TotemHolder:Size(100, 100)
	TotemHolder:Point("CENTER", _G.UIParent, -322, -178)

	if (not DB.Global.ActionBars.TotemBar) then
		TotemHolder:Hide()
	end

	if (MultiCastActionBarFrame) then
		MultiCastActionBarFrame:SetParent(TotemHolder)
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetAllPoints(TotemHolder)
		MultiCastActionBarFrame:SetMovable(false)
	end

	-- Cache
	self.TotemHolder = TotemHolder
end

function AB:PositionTotemActionButton(Button)
	if (InCombatLockdown()) then
		return
	end

	if (Button and Button.slotButton) then
		Button:ClearAllPoints()
		Button:Size(unpack(TotemButtonSize))
		Button:SetInside(Button.slotButton)
	end
end

function AB:PositionTotemBar()
	if (InCombatLockdown()) then
		self.NeedsTotemBarPosition = true

		return
	end

	local NumActiveSlots = MultiCastActionBarFrame.numActiveSlots or 0
	local ButtonWidth, ButtonHeight = unpack(TotemButtonSize)
	local Width = (ButtonWidth * (NumActiveSlots + 2)) + (TotemButtonSpacing * (NumActiveSlots + 1))

	SummonButton:ClearAllPoints()
	SummonButton:Point("LEFT", self.TotemHolder, "LEFT", 0, 0)

	for i = 1, NumActiveSlots do
		local SlotButton = _G["MultiCastSlotButton"..i]

		if (SlotButton) then
			SlotButton:ClearAllPoints()

			if (i == 1) then
				SlotButton:Point("LEFT", SummonButton, "RIGHT", TotemButtonSpacing, 0)
			else
				local PreviousButton = _G["MultiCastSlotButton"..(i - 1)]
				SlotButton:Point("LEFT", PreviousButton, "RIGHT", TotemButtonSpacing, 0)
			end
		end
	end

	for i = 1, 6 do
		local ActionButton = _G["MultiCastActionButton"..i]

		if (ActionButton and ActionButton.slotButton) then
			AB:PositionTotemActionButton(ActionButton)
		end
	end

	RecallButton:ClearAllPoints()

	if (NumActiveSlots > 0) then
		local LastSlot = _G["MultiCastSlotButton"..NumActiveSlots]
		RecallButton:Point("LEFT", LastSlot, "RIGHT", TotemButtonSpacing, 0)
	else
		RecallButton:Point("LEFT", SummonButton, "RIGHT", TotemButtonSpacing, 0)
	end
end

function AB:SkinTotemButtons()
	for i = 1, 6 do
		local Button = _G["MultiCastActionButton"..i]
		local ButtonSlot = _G["MultiCastSlotButton"..i]
		local OverlayTex = Button.overlayTex
		local Art = Button.SlotArt
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
			UI:KeepAspectRatio(Button, Icon)
		end

		if (ButtonSlot) then
			ButtonSlot:StripTexture()
			ButtonSlot:Size(unpack(TotemButtonSize))
		end

		if (Art) then
			Art:Size(unpack(TotemButtonSize))
			Art:SetInside(Button, 1, 1)
			UI:KeepAspectRatio(Button, Art)
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

	AB:SkinMultiCastSpellButton(SummonButton, SummonButtonIcon, SummonButtonCooldown, SummonButtonNormalTexture)
	AB:SkinMultiCastSpellButton(RecallButton, RecallButtonIcon, RecallButtonCooldown, RecallButtonNormalTexture)
	AB:SkinMultiCastArrowButton(OpenButton, Media.Global.ArrowTop, 0)
	AB:SkinMultiCastArrowButton(CloseButton, Media.Global.ArrowBottom, 2)
end

function AB:UpdateTotemBar()
	hooksecurefunc("MultiCastFlyoutFrame_ToggleFlyout", function(Frame, Type, Parent)
		AB:UpdateTotemFlyout(Frame, Type, Parent)
	end)

	hooksecurefunc("MultiCastFlyoutFrameOpenButton_Show", function(Button, Type, Parent)
		AB:UpdateTotemFlyoutOpen(Button, Type, Parent)
	end)

	hooksecurefunc("MultiCastSummonSpellButton_Update", function()
		AB:PositionTotemBar()
	end)

	hooksecurefunc("MultiCastRecallSpellButton_Update", function()
		AB:PositionTotemBar()
	end)

	hooksecurefunc("MultiCastActionButton_Update", function(Button)
		AB:PositionTotemActionButton(Button)
		AB:PositionTotemBar()
	end)
end

function AB:CreateTotemBar()
	if (not DB.Global.ActionBars.TotemBar or Class ~= "SHAMAN") then
		return
	end

	self:CreateAnchor()
	self:SkinTotemButtons()
	self:UpdateTotemBar()
end