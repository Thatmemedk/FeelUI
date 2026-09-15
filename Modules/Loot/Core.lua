local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Loot = UI:RegisterModule("Loot")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local pairs = pairs
local tinsert = table.insert
local max = math.max
local floor = math.floor

-- WoW Globals
local CreateFrame = CreateFrame
local GetNumLootItems = GetNumLootItems
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetLootSlotType = GetLootSlotType
local LootSlotHasItem = LootSlotHasItem
local HandleModifiedItemClick = HandleModifiedItemClick
local StaticPopup_Hide = StaticPopup_Hide
local CloseLoot = CloseLoot
local IsFishingLoot = IsFishingLoot
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local GetCVarBool = GetCVarBool
local GetCursorPosition = GetCursorPosition
local ResetCursor = ResetCursor
local CursorUpdate = CursorUpdate
local CursorOnUpdate = CursorOnUpdate
local IsModifiedClick = IsModifiedClick
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS
local LOOT = _G.LOOT
local LOOT_SLOT_MONEY = _G.LOOT_SLOT_MONEY

-- Locals
Loot.IconWidth = 36
Loot.IconHeight = 22
Loot.Slots = {}

-- DISABLE

function Loot:DisableBlizzard()
	if (_G.LootFrame and _G.LootFrame.UnregisterAllEvents) then
		_G.LootFrame:UnregisterAllEvents()
	end
end

-- CREATE FRAME

function Loot:CreateFrames()
	-- Frame
	Frame = CreateFrame("Button", "FeelUI_LootFrame", _G.UIParent)
	Frame:Size(198, 58)
	Frame:SetClampedToScreen(true)
	Frame:SetToplevel(true)
	Frame:SetAlpha(0)
	Frame:Hide()
	Frame:SetScript("OnHide", function()
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		CloseLoot()
	end)

	-- Invs Frame
	Frame.InvisFrame = CreateFrame("Frame", nil, Frame)
	Frame.InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
	Frame.InvisFrame:SetInside()

	-- Overlay
	Frame.Overlay = CreateFrame("Frame", nil, Frame)
	Frame.Overlay:Size(214, 28)
	Frame.Overlay:Point("TOP", Frame, -16, 22)
	Frame.Overlay:CreateBackdrop()
	Frame.Overlay:CreateShadow()

	-- Title
	Frame.Title = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
	Frame.Title:Point("CENTER", Frame.Overlay, 0, 0)
	Frame.Title:SetFontTemplate("Default")
	Frame.Title:SetTextColor(1, 0.82, 0)

	-- Insert
	tinsert(_G.UISpecialFrames, "FeelUI_LootFrame")

	-- Cache
	self.Frame = Frame
end

-- SLOT FUNCTIONS

function Loot:OnEnter()
	if (not self.Highlight) then 
		return 
	end

	self.Highlight:SetStatusBarColor(1, 1, 1, 0.10)
	self.Highlight:Show()

	local SlotID = self:GetID()

	if (LootSlotHasItem(SlotID)) then
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		_G.GameTooltip:SetLootItem(SlotID)

		if (CursorUpdate) then
			CursorUpdate(self)
		end
	end
end

function Loot:OnLeave()
	if (self.Highlight) then
		self.Highlight:SetStatusBarColor(0, 0, 0, 0)
		self.Highlight:Hide()
	end

	if (_G.GameTooltip and _G.GameTooltip:IsOwned(self)) then
		_G.GameTooltip:Hide()
	end

	if (ResetCursor) then
		ResetCursor()
	end
end

function Loot:OnClick()
	local ID = self:GetID()

	if (not LootSlotHasItem(ID)) then
		return
	end

	if (_G.LootFrame) then
		_G.LootFrame.selectedSlot = ID
		_G.LootFrame.selectedQuality = self.Quality
		_G.LootFrame.selectedItemName = self.Name:GetText()
		_G.LootFrame.selectedLootButton = self:GetName()
		_G.LootFrame.selectedTexture = self.Icon and self.Icon:GetTexture()
	end

	if (IsModifiedClick()) then
		local Link = GetLootSlotLink(ID)

		if (Link) then
			HandleModifiedItemClick(Link)
		end
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(ID)
	end
end

function Loot:OnShow()
	if (_G.GameTooltip and _G.GameTooltip:IsOwned(self)) then
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		_G.GameTooltip:SetLootItem(self:GetID())

		if (CursorOnUpdate) then
			CursorOnUpdate(self)
		end
	end
end

function Loot:OnShow()
	if (GameTooltip and GameTooltip:IsOwned(self)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

function Loot:CreateSlot(ID)
	local Frame = CreateFrame("Button", "FeelUI_LootSlot"..ID, self.Frame)
	Frame:Height(self.IconHeight)
	Frame:Point("LEFT", 14, 0)
	Frame:Point("RIGHT", -8, 0)
	Frame:CreateBackdrop()
	Frame:CreateShadow()
	Frame:SetID(ID)

	Frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	Frame:SetScript("OnEnter", self.OnEnter)
	Frame:SetScript("OnLeave", self.OnLeave)
	Frame:SetScript("OnClick", self.OnClick)
	Frame:SetScript("OnShow", self.OnShow)

	local InvisFrame = CreateFrame("Frame", nil, Frame)
	InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	-- Icon
	local IconFrame = CreateFrame("Frame", nil, Frame)
	IconFrame:Size(self.IconWidth, self.IconHeight)
	IconFrame:Point("RIGHT", Frame, "LEFT", -2, 0)
	IconFrame:SetTemplate()
	IconFrame:CreateShadow()
	IconFrame:SetShadowOverlay()

	local Icon = IconFrame:CreateTexture(nil, "ARTWORK")
	Icon:SetInside()
	UI:KeepAspectRatio(IconFrame, Icon)

	-- Count
	local Count = IconFrame:CreateFontString(nil, "OVERLAY", nil, 7)
	Count:SetJustifyH("RIGHT")
	Count:Point("BOTTOMRIGHT", IconFrame, -2, 4)
	Count:SetFontTemplate("Default")
	Count:SetText("1")

	-- Name
	local Name = InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
	Name:SetJustifyH("LEFT")
	Name:Point("LEFT", Frame, 4, 0)
	Name:SetNonSpaceWrap(true)
	Name:SetFontTemplate("Default")

	-- Highlight
	local Highlight = CreateFrame("StatusBar", nil, Frame)
	Highlight:SetFrameLevel(Frame:GetFrameLevel() + 2)
	Highlight:SetInside(Frame, 1, 1)
	Highlight:SetStatusBarTexture(Media.Global.Blank)
	Highlight:SetStatusBarColor(0, 0, 0, 0)

	-- Cache
	Frame.IconFrame = IconFrame
	Frame.Icon = Icon
	Frame.Count = Count
	Frame.Name = Name
	Frame.Highlight = Highlight

	self.Slots[ID] = Frame

	return Frame
end

function Loot:AnchorSlots()
	if (not self.Frame) then
		return
	end

	local ShownLootSlots = 0

	for i = 1, #self.Slots do
		local Frames = self.Slots[i]

		if (Frames:IsShown()) then
			ShownLootSlots = ShownLootSlots + 1

			Frames:Point("TOP", self.Frame, 0, (-20 + self.IconWidth) - (ShownLootSlots * (self.IconHeight + 2)))
		end
	end

	self.Frame:Height(max(self.IconWidth, ShownLootSlots * self.IconHeight))
end

-- EVENTS

function Loot:LOOT_SLOT_CLEARED(_, Slot)
	if (not self.Frame or not self.Frame:IsShown()) then
		return
	end

	if (self.Slots[Slot]) then
		self.Slots[Slot]:Hide()
	end

	self:AnchorSlots()
end

function Loot:LOOT_CLOSED()
	if (not self.Frame) then
		return
	end

	StaticPopup_Hide("LOOT_BIND")

	UI:UIFrameFadeOut(self.Frame, 1, self.Frame:GetAlpha(), 0)
	UI:Delay("LootClosed", 1, function()
		self.Frame:Hide()
	end)

	for i = 1, #self.Slots do
		local Frames = self.Slots[i]

		if (Frames:IsShown()) then
			Frames:Hide()
		end
	end
end

function Loot:LOOT_OPENED(_, AutoLootFlag)
	if (not self.Frame) then
		return
	end

	UI:UIFrameFadeIn(self.Frame, 0.25, self.Frame:GetAlpha(), 1)
	self.Frame:Show()

	if (not self.Frame:IsShown()) then
		CloseLoot(not AutoLootFlag)
	end

	if (IsFishingLoot()) then
		self.Frame.Title:SetText("Fishing Loot")
	elseif (not UnitIsFriend("player", "target") and UnitIsDead("target")) then
		self.Frame.Title:SetText(UnitName("target"))
	else
		self.Frame.Title:SetText(LOOT)
	end

	if (GetCVarBool("lootUnderMouse")) then
		local OffsetX, OffsetY = GetCursorPosition()
		local Scale = self.Frame:GetEffectiveScale() or 1

		OffsetX = (OffsetX / Scale) - 40
		OffsetY = (OffsetY / Scale) + 20

		self.Frame:ClearAllPoints()
		self.Frame:Point("TOPLEFT", _G.UIParent, "BOTTOMLEFT", OffsetX, OffsetY)
		self.Frame:Raise()
	else
		self.Frame:ClearAllPoints()
		self.Frame:Point("LEFT", _G.UIParent, 102, 0)
	end

	local Items = GetNumLootItems()

	if (Items and Items > 0) then
		for Index = 1, Items do
			local Texture, Item, Quantity, _, Quality, _, IsQuestItem, QuestID, IsActive = GetLootSlotInfo(Index)

			if (GetLootSlotType(Index) == LOOT_SLOT_MONEY and Item and type(Item) == "string") then
				Item = Item:gsub("\n", ", ")
			end

			local SlotFrame = self.Slots[Index] or self:CreateSlot(Index)
			local Color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[Quality]

			if (Quantity and Quantity > 1) then
				SlotFrame.Count:SetText(Quantity)
				SlotFrame.Count:Show()
			else
				SlotFrame.Count:Hide()
			end

			if (QuestID and not IsActive) then
				SlotFrame.Name:SetTextColor(1, 0.82, 0)
				SlotFrame:SetBackdropColorTemplate(0.5, 0.82 * 0.50, 0, 0.7)
			elseif (QuestID or IsQuestItem) then
				SlotFrame.Name:SetTextColor(1, 0.82, 0)
				SlotFrame:SetBackdropColorTemplate(0.5, 0.82 * 0.50, 0, 0.7)
			else
				if (Color) then
					SlotFrame.Name:SetTextColor(Color.r, Color.g, Color.b)
					SlotFrame:SetBackdropColorTemplate(Color.r * 0.25, Color.g * 0.25, Color.b * 0.25, 0.7)
				else
					SlotFrame.Name:SetTextColor(1, 1, 1)
					SlotFrame:SetBackdropColorTemplate(0.08, 0.08, 0.08, 0.7)
				end
			end

			SlotFrame.Quality = Quality
			SlotFrame.Name:SetText(UI:UTF8Sub(Item or LOOT, 24, true))
			SlotFrame.Icon:SetTexture(Texture)
			SlotFrame:Enable()
			SlotFrame:Show()
		end
	else
		local SlotFrame = self.Slots[1] or self:CreateSlot(1)
		local Color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[0]

		SlotFrame.Name:SetText("Empty Slot")

		if (Color) then
			SlotFrame.Name:SetTextColor(Color.r, Color.g, Color.b)
		end

		SlotFrame.Icon:SetTexture([[Interface\Icons\INV_Misc_Herb_AncientLichen]])
		SlotFrame.Count:Hide()
		SlotFrame:Disable()
		SlotFrame:Show()
	end

	self:AnchorSlots()
end

-- REGISTER EVENTS

function Loot:RegisterEvents()
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")
	self:SetScript("OnEvent", function(self, event, ...)
		if (self[event]) then
			return self[event](self, event, ...)
		end
	end)
end

-- INITIALIZE

function Loot:Initialize()
	if (not DB.Global.Loot.Enable) then 
		return 
	end

	self:DisableBlizzard()
	self:CreateFrames()
	self:RegisterEvents()
end