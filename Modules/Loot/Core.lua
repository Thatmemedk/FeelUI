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

local function UTF8Sub(self, i, dots)
	if not (self) then 
		return 
	end
	
	local Bytes = self:len()

	if (Bytes <= i) then
		return self
	else
		local Len, Pos = 0, 1
		
		while(Pos <= Bytes) do
			Len = Len + 1
			local c = self:byte(Pos)
			if (c > 0 and c <= 127) then
				Pos = Pos + 1
			elseif (c >= 192 and c <= 223) then
				Pos = Pos + 2
			elseif (c >= 224 and c <= 239) then
				Pos = Pos + 3
			elseif (c >= 240 and c <= 247) then
				Pos = Pos + 4
			end
			if (Len == i) then break end
		end

		if (Len == i and Pos <= Bytes) then
			return self:sub(1, Pos - 1)..(dots and "..." or "")
		else
			return self
		end
	end
end

function Loot:OnEnter()
	if not (self.Highlight) then 
		return 
	end

	self.Highlight:SetStatusBarColor(1, 1, 1, 0.10)
	self.Highlight:Show()

	local SlotID = self:GetID()

	if LootSlotHasItem(SlotID) then
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		_G.GameTooltip:SetLootItem(SlotID)
		CursorUpdate(self)
	end
end

function Loot:OnLeave()
	if (self.Highlight) then
		self.Highlight:SetStatusBarColor(0, 0, 0, 0)
		self.Highlight:Hide()
	end

	_G.GameTooltip:Hide()
	ResetCursor()
end

function Loot:OnClick()
	local ID = self:GetID()
	LootFrame.selectedQuality = self.quality
	LootFrame.selectedItemName = self.name:GetText()
	LootFrame.selectedSlot = ID
	LootFrame.selectedLootButton = self:GetName()
	LootFrame.selectedTexture = self.icon and self.icon:GetTexture()

	if IsModifiedClick() then
		HandleModifiedItemClick(GetLootSlotLink(id))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(ID)
	end
end

function Loot:OnShow()
	if GameTooltip and GameTooltip:IsOwned(self) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

function Loot:AnchorSlots()
	local ShownLootSlots = 0

	for i = 1, #self.Slots do
		local Frames = self.Slots[i]

		if Frames:IsShown() then
			ShownLootSlots = ShownLootSlots + 1

			Frames:Point("TOP", FeelUILootFrame, 0, (-20 + self.IconWidth) - (ShownLootSlots * (self.IconHeight + 2)))
		end
	end

	FeelUILootFrame:Height(max(self.IconWidth, ShownLootSlots * self.IconHeight))
end

function Loot:CreateSlot(ID)
	local Frame = CreateFrame("Button", "FeelUILootSlot"..ID, FeelUILootFrame)
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

	local IconFrame = CreateFrame("Frame", nil, Frame)
	IconFrame:Size(self.IconWidth, self.IconHeight)
	IconFrame:Point("RIGHT", Frame, "LEFT", -2, 0)
	IconFrame:SetTemplate()
	IconFrame:CreateShadow()
	IconFrame:SetShadowOverlay()
	Frame.IconFrame = IconFrame

	local Icon = IconFrame:CreateTexture(nil, "ARTWORK")
	Icon:SetInside()
	UI:KeepAspectRatio(IconFrame, Icon)
	Frame.icon = Icon

	local InvisFrame = CreateFrame("Frame", nil, Frame)
	InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	local Count = IconFrame:CreateFontString(nil, "OVERLAY", nil, 7)
	Count:SetJustifyH("RIGHT")
	Count:Point("BOTTOMRIGHT", IconFrame, -2, 4)
	Count:SetFontTemplate("Default")
	Count:SetText("1")
	Frame.count = Count

	local Name = InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
	Name:SetJustifyH("LEFT")
	Name:Point("LEFT", Frame, 4, 0)
	Name:SetNonSpaceWrap(true)
	Name:SetFontTemplate("Default")
	Frame.name = Name

	local Highlight = CreateFrame("StatusBar", nil, Frame)
	Highlight:SetFrameLevel(Frame:GetFrameLevel() + 2)
	Highlight:SetInside(Frame, 1, 1)
	Highlight:SetStatusBarTexture(Media.Global.Blank)
	Highlight:SetStatusBarColor(0, 0, 0, 0)
	Frame.Highlight = Highlight

	self.Slots[ID] = Frame
	return Frame
end

function Loot:LOOT_SLOT_CLEARED(_, slot)
	if not CustomLootFrame or not CustomLootFrame:IsShown() then 
		return 
	end

	if self.Slots[slot] then
		self.Slots[slot]:Hide()
	end

	self:AnchorSlots()
end

function Loot:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")

	if (FeelUILootFrame) then 
		FeelUILootFrame:Hide() 
	end

	for _, Frames in pairs(self.Slots) do
		if (Frames and Frames.Hide) then 
			Frames:Hide() 
		end
	end
end

function Loot:LOOT_OPENED(_, AutoLootFlag)
	if not (FeelUILootFrame) then 
		return 
	end

	FeelUILootFrame:Show()

	if not FeelUILootFrame:IsShown() then
		CloseLoot(not AutoLootFlag)
	end

	if IsFishingLoot() then
		FeelUILootFrame.Title:SetText("Fishing Loot")
	elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
		FeelUILootFrame.Title:SetText(UnitName("target"))
	else
		FeelUILootFrame.Title:SetText(LOOT)
	end

	if GetCVarBool("lootUnderMouse") then
		local OffsetX, OffsetY = GetCursorPosition()
		local Scale = FeelUILootFrame:GetEffectiveScale() or 1
		OffsetX = (OffsetX / Scale) - 40
		OffsetY = (OffsetY / Scale) + 20

		FeelUILootFrame:ClearAllPoints()
		FeelUILootFrame:Point("TOPLEFT", _G.UIParent, "BOTTOMLEFT", OffsetX, OffsetY)
		FeelUILootFrame:Raise()
	else
		FeelUILootFrame:ClearAllPoints()
		FeelUILootFrame:Point("LEFT", _G.UIParent, 102, 0)
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
				SlotFrame.count:SetText(Quantity)
				SlotFrame.count:Show()
			else
				SlotFrame.count:Hide()
			end

			if (QuestID and not IsActive) then
				SlotFrame.name:SetTextColor(1, 0.82, 0)
				SlotFrame:SetBackdropColorTemplate(0.5, 0.82 * 0.50, 0, 0.7)
			elseif (QuestID or IsQuestItem) then
				SlotFrame.name:SetTextColor(1, 0.82, 0)
				SlotFrame:SetBackdropColorTemplate(0.5, 0.82 * 0.50, 0, 0.7)
			else
				if (Color) then
					SlotFrame.name:SetTextColor(Color.r, Color.g, Color.b)
					SlotFrame:SetBackdropColorTemplate(Color.r * 0.25, Color.g * 0.25, Color.b * 0.25, 0.7)
				else
					SlotFrame.name:SetTextColor(1, 1, 1)
					SlotFrame:SetBackdropColorTemplate(0.08, 0.08, 0.08, 0.7)
				end
			end

			SlotFrame.quality = Quality
			SlotFrame.name:SetText(UTF8Sub(Item or LOOT, 24, true))
			SlotFrame.icon:SetTexture(Texture)

			SlotFrame:Enable()
			SlotFrame:Show()
		end
	else
		local SlotFrame = self.Slots[1] or self:CreateSlot(1)
		local Color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[0]

		SlotFrame.name:SetText("Empty Slot")

		if (Color) then
			SlotFrame.name:SetTextColor(Color.r, Color.g, Color.b)
		end

		SlotFrame.icon:SetTexture([[Interface\Icons\INV_Misc_Herb_AncientLichen]])
		SlotFrame.count:Hide()

		SlotFrame:Disable()
		SlotFrame:Show()
	end

	self:AnchorSlots()
end

function Loot:CreateFrames()
	FeelUILootFrame = CreateFrame("Button", "FeelUILootFrame", _G.UIParent)
	FeelUILootFrame:Size(198, 58)
	FeelUILootFrame:SetClampedToScreen(true)
	FeelUILootFrame:SetToplevel(true)
	FeelUILootFrame:Hide()

	FeelUILootFrame:SetScript("OnHide", function()
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		CloseLoot()
	end)

	FeelUILootFrame.Overlay = CreateFrame("Frame", nil, FeelUILootFrame)
	FeelUILootFrame.Overlay:Size(214, 28)
	FeelUILootFrame.Overlay:Point("TOP", FeelUILootFrame, -16, 22)
	FeelUILootFrame.Overlay:CreateBackdrop()
	FeelUILootFrame.Overlay:CreateShadow()

	FeelUILootFrame.InvisFrame = CreateFrame("Frame", nil, FeelUILootFrame)
	FeelUILootFrame.InvisFrame:SetFrameLevel(FeelUILootFrame:GetFrameLevel() + 10)
	FeelUILootFrame.InvisFrame:SetInside()

	FeelUILootFrame.Title = FeelUILootFrame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
	FeelUILootFrame.Title:Point("CENTER", FeelUILootFrame.Overlay, 0, 0)
	FeelUILootFrame.Title:SetFontTemplate("Default")
	FeelUILootFrame.Title:SetTextColor(1, 0.82, 0)

	tinsert(_G.UISpecialFrames, "FeelUILootFrame")
end

function Loot:DisableBlizzard()
	if (_G.LootFrame and _G.LootFrame.UnregisterAllEvents) then
		_G.LootFrame:UnregisterAllEvents()
	end
end

function Loot:RegisterEvents()
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")
	self:SetScript("OnEvent", function(self, event, ...)
		if self[event] then
			return self[event](self, event, ...)
		end
	end)
end

function Loot:Initialize()
	if (not DB.Global.Loot.Enable) then 
		return 
	end

	self:DisableBlizzard()
	self:CreateFrames()
	self:RegisterEvents()
end