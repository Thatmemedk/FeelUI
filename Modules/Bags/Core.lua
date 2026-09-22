local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local B = UI:RegisterModule("Bags")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local C_Container = _G.C_Container
local C_Currency = _G.C_CurrencyInfo
local C_Item = _G.C_Item
local C_NewItems = _G.C_NewItems
local C_TradeSkillUI = _G.C_TradeSkillUI
local ColorManager = _G.ColorManager
local GameTooltip = _G.GameTooltip

-- WoW Globals
local GetBackpackCurrencyInfo = C_Currency.GetBackpackCurrencyInfo
local GetItemInfo = C_Item.GetItemInfo
local GetItemNameByID = C_Item.GetItemNameByID
local GetItemSpell = C_Item.GetItemSpell
local IsNewItem = C_NewItems.IsNewItem

-- WoW Globals
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local PickupBagFromSlot = _G.PickupBagFromSlot
local PutItemInBackpack = _G.PutItemInBackpack
local PutItemInBag = _G.PutItemInBag
local ToggleBackpack = _G.ToggleBackpack

-- WoW Globals
local CalculateTotalNumberOfFreeBagSlots = C_Container.CalculateTotalNumberOfFreeBagSlots
local ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID
local GetColorDataForItemQuality = ColorManager.GetColorDataForItemQuality
local GetContainerItemCooldown = C_Container.GetContainerItemCooldown
local GetContainerItemInfo = C_Container.GetContainerItemInfo
local GetContainerItemQuestInfo = C_Container.GetContainerItemQuestInfo
local GetContainerNumSlots = C_Container.GetContainerNumSlots
local PickupContainerItem = C_Container.PickupContainerItem
local SetInsertItemsLeftToRight = C_Container.SetInsertItemsLeftToRight
local SetItemSearch = C_Container.SetItemSearch
local SetSortBagsRightToLeft = C_Container.SetSortBagsRightToLeft
local UseContainerItem = C_Container.UseContainerItem

-- WoW Globals
local GetItemReagentQualityInfo = C_TradeSkillUI.GetItemReagentQualityInfo

-- Locals
B.ButtonWidth = 36
B.ButtonHeight = 22
B.ButtonSpacing = 4
B.ButtonsPerRow = 12
B.SideMargin = 12
B.TopMargin = 42
B.SeparatorHeight = 22
B.SearchBoxHeight = 22
B.SearchBoxPadding = 12

-- Locals
B.BagButtonWidth = 36
B.BagButtonHeight = 22
B.BagButtonSpacing = 4
B.BagBarPadding = 6

-- Tables
B.BagHolders = {}
B.BagButtons = {}
B.BagSlots = {}
B.ReagentSlots = {}

-- Tables
B.ItemNameCache = {}
B.CurrencyButtons = {}

-- Locals
B.ReplaceBags = 0
B.PendingBagUpdate = false

-- Locals
local SlotTables = {
    B.BagSlots,
    B.ReagentSlots,
}

local BagIDs = {
    Enum.BagIndex.Backpack,
    Enum.BagIndex.Bag_1,
    Enum.BagIndex.Bag_2,
    Enum.BagIndex.Bag_3,
    Enum.BagIndex.Bag_4,
    Enum.BagIndex.ReagentBag,
}

function B:DisableBlizzard()
    for i = 1, _G.NUM_CONTAINER_FRAMES or 13 do
        local Frame = _G["ContainerFrame"..i]

        if (Frame) then
            Frame:UnregisterAllEvents()
            Frame:Hide()
            Frame:HookScript("OnShow", Frame.Hide)
        end
    end

    if (_G.BankFrame) then
        _G.BankFrame:UnregisterAllEvents()
        _G.BankFrame:Hide()
    end

    if (_G.ReagentBankFrame) then
        _G.ReagentBankFrame:UnregisterAllEvents()
        _G.ReagentBankFrame:Hide()
    end

    hooksecurefunc(_G.ContainerFrameCombinedBags, "Show", function()
        _G.ContainerFrameCombinedBags:UnregisterAllEvents()
        _G.ContainerFrameCombinedBags:Hide()
    end)
end

function B:GetRowHeight()
    return self.ButtonHeight + self.ButtonSpacing
end

function B:GetContainerWidth()
    return (self.SideMargin * 2) + (self.ButtonsPerRow * self.ButtonWidth) + ((self.ButtonsPerRow - 1) * self.ButtonSpacing)
end

function B:GetRowY(Row, ExtraOffset)
    return -self.TopMargin - (Row * self:GetRowHeight()) - (ExtraOffset or 0)
end

function B:NumRows(SlotCount)
    if (SlotCount <= 0) then
        return 0
    end

    return math.ceil(SlotCount / self.ButtonsPerRow)
end

function B:GetCachedItemName(ItemID)
    if (not ItemID) then
        return ""
    end

    if (not self.ItemNameCache[ItemID]) then
        self.ItemNameCache[ItemID] = GetItemNameByID(ItemID) or ""
    end

    return self.ItemNameCache[ItemID]
end

function B:GetBagHolder(BagID)
    local Holder = self.BagHolders[BagID]

    if (not Holder) then
        Holder = CreateFrame("Frame", nil, self.Container)
        Holder:SetID(BagID)

        self.BagHolders[BagID] = Holder
    end

    return Holder
end

function B:GetNumSlots(BagID)
    return GetContainerNumSlots and GetContainerNumSlots(BagID) or 0
end

function B:GetContainerItemInfo(BagID, SlotID)
    return GetContainerItemInfo and GetContainerItemInfo(BagID, SlotID)
end

function B:GetContainerItemQuestInfo(BagID, SlotID)
    return GetContainerItemQuestInfo and GetContainerItemQuestInfo(BagID, SlotID)
end

function B:GetBackpackCurrencies()
    local Currencies = {}
    local Index = 1

    while true do
        local Info = GetBackpackCurrencyInfo(Index)

        if (not Info) then
            break
        end

        Currencies[Index] = Info

        Index = Index + 1
    end

    return Currencies
end

function B:TryEquipBag(self)
    if (self.BagID == Enum.BagIndex.Backpack) then
        return false
    end

    local InventoryID = C_Container.ContainerIDToInventoryID(self.BagID)

    if (InventoryID) then
        return PutItemInBag(InventoryID)
    end

    return false
end

function B:GetQualityColor(Quality)
    if (not Quality) then
        return
    end

    if (GetColorDataForItemQuality) then
        return GetColorDataForItemQuality(Quality)
    end

    return _G.ITEM_QUALITY_COLORS and _G.ITEM_QUALITY_COLORS[Quality]
end

function B:UpdateBorderColors(Button)
    if (not Button.ButtonPanel) then
        return
    end

    if (Button.Type == QUESTS_LABEL) then
        Button.ButtonPanel:SetColorTemplate(1, 0.82, 0)
        Button.ButtonPanel:Show()
        return
    end

    local Color = self:GetQualityColor(Button.Quality)

    if (Color) then
        Button.ButtonPanel:SetColorTemplate(Color.r, Color.g, Color.b)
        Button.ButtonPanel:Show()
    else
        Button.ButtonPanel:SetColorTemplate(0, 0, 0)
        Button.ButtonPanel:Hide()
    end
end

function B:UpdateCooldown(Button)
    local Start, Duration, Enabled = GetContainerItemCooldown(Button.BagID, Button.SlotID)
    local CD = Button.Cooldown

    if (not CD) then
        return
    end

    if (Duration and Duration > 0 and Enabled == 1) then
        local NewStart = not CD.Start or CD.Start ~= Start
        local NewDuration = not CD.Duration or CD.Duration ~= Duration

        if (NewStart or NewDuration) then
            CD:SetCooldown(Start, Duration)
            CD:Show()

            CD.Start = Start
            CD.Duration = Duration
        end
    else
        CD:Hide()
        CD.Start = nil
        CD.Duration = nil
    end
end

function B:CreateContainer()
    local Container = CreateFrame("Frame", "FeelUI_Bag", _G.UIParent)
    Container:SetFrameStrata("HIGH")
    Container:SetFrameLevel(50)
    Container:Size(self:GetContainerWidth(), 418)
    Container:Point("BOTTOMRIGHT", _G.UIParent, -6, 6)
    Container:CreateBackdrop()
    Container:SetBackdropColorTemplate(0.1, 0.1, 0.1, 0.9)
    Container:CreateShadow()
    Container:SetAlpha(0)
    Container:Hide()

    -- CLOSE BUTTON
    --[[
    local CloseButton = CreateFrame("Button", nil, Container)
    CloseButton:Size(22, 22)
    CloseButton:Point("TOPRIGHT", Container)
    CloseButton:HandleCloseButton(-12, -8, 16)
    CloseButton:SetScript("OnMouseUp", function()
        B:CloseAllBags()
        PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    end)
    --]]

    -- SEARCH BOX
    local SearchBox = CreateFrame("EditBox", nil, Container)
    SearchBox:SetFrameLevel(Container:GetFrameLevel() + 10)
    SearchBox:Size(Container:GetWidth() - 28, self.SearchBoxHeight)
    SearchBox:Point("TOP", Container, 0, -self.TopMargin)
    SearchBox:SetFontTemplate("Default")
    SearchBox:SetMultiLine(false)
    SearchBox:EnableMouse(true)
    SearchBox:SetAutoFocus(false)

    SearchBox.Title = SearchBox:CreateFontString(nil, "OVERLAY")
    SearchBox.Title:Point("LEFT", SearchBox, 0, 0)
    SearchBox.Title:SetFontTemplate("Default")
    SearchBox.Title:SetText("Search")
    SearchBox.Title:SetTextColor(0.5, 0.5, 0.5)

    SearchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:SetText("")

        if (SetItemSearch) then
            SetItemSearch("")
        end
    end)

    SearchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    SearchBox:SetScript("OnEditFocusLost", function(self)
        self.Title:Show()

        if (SetItemSearch) then
            SetItemSearch("")
        end
    end)

    SearchBox:SetScript("OnEditFocusGained", function(self)
        self:SetText("")
        self.Title:Hide()
    end)

    SearchBox:SetScript("OnTextChanged", function(self)
        local Text = (self:GetText() or ""):lower()

        if (SetItemSearch) then
            SetItemSearch(Text)
        end

        for _, Frames in ipairs(SlotTables) do
            for _, Button in ipairs(Frames) do
                local Name = (Button.Name or ""):lower()
                Button:SetAlpha((Text == "" or Name:find(Text, 1, true)) and 1 or 0.25)
            end
        end
    end)

    SearchBox.CloseButton = CreateFrame("Button", nil, SearchBox)
    SearchBox.CloseButton:Size(12, 12)
    SearchBox.CloseButton:Point("RIGHT", SearchBox)
    SearchBox.CloseButton:EnableMouse(true)
    SearchBox.CloseButton:HandleCloseButton()
    SearchBox.CloseButton:SetScript("OnMouseUp", function()
        if (SetItemSearch) then
            SetItemSearch("")
        end

        SearchBox:ClearFocus()
        SearchBox:SetText("")
    end)

    SearchBox.Overlay = CreateFrame("Frame", nil, SearchBox)
    SearchBox.Overlay:SetFrameLevel(SearchBox:GetFrameLevel() + 1)
    SearchBox.Overlay:Size(SearchBox:GetWidth() + 10, SearchBox:GetHeight())
    SearchBox.Overlay:Point("CENTER", SearchBox, 0, 0)
    SearchBox.Overlay:SetTemplate()
    SearchBox.Overlay:CreateShadow()

    SearchBox.Backdrop = CreateFrame("Frame", nil, SearchBox, "BackdropTemplate")
    SearchBox.Backdrop:SetFrameLevel(SearchBox:GetFrameLevel() - 1)
    SearchBox.Backdrop:Size(SearchBox:GetWidth() + 10, SearchBox:GetHeight())
    SearchBox.Backdrop:Point("CENTER", SearchBox, 0, 0)
    SearchBox.Backdrop:SetBackdrop({ bgFile = Media.Global.Texture })
    SearchBox.Backdrop:SetBackdropColor(unpack(DB.Global.General.PanelColor))

    -- GOLD TEXT
    local MoneyText = Container:CreateFontString(nil, "OVERLAY")
    MoneyText:Point("TOPLEFT", Container, "TOPLEFT", 12, -12)
    MoneyText:SetFontTemplate("Default")

    -- SEPARATOR
    local Separator = Container:CreateFontString(nil, "OVERLAY")
    Separator:SetFontTemplate("Default")
    Separator:SetText(REAGENT_CONTAINER or "Reagents")
    Separator:SetTextColor(1, 0.82, 0)
    Separator:Hide()

    -- TOGGLE BAGS CONTAINER
    local ToggleBagsContainer = CreateFrame("Button", nil, Container)
    ToggleBagsContainer:Size(30, 16)
    ToggleBagsContainer:Point("TOPRIGHT", Container, "TOPRIGHT", -12, -12)
    ToggleBagsContainer:StyleButton()
    ToggleBagsContainer:SetScript("OnClick", function()
        if (self.ReplaceBags == 0) then
            self.ReplaceBags = 1

            UI:UIFrameFadeIn(self.BagBar, 0.5, self.BagBar:GetAlpha(), 1)
            UI:Delay("ShowBagsContainer", 0.5, function()
                self.BagBar:Show()
            end)
        else
            self.ReplaceBags = 0

            UI:UIFrameFadeOut(self.BagBar, 0.5, self.BagBar:GetAlpha(), 0)
            UI:Delay("HideBagsContainer", 0.5, function()
                self.BagBar:Hide()
            end)
        end
    end)
    
    ToggleBagsContainer.IconTexture = ToggleBagsContainer:CreateTexture(nil, "OVERLAY")
    ToggleBagsContainer.IconTexture:SetTexture("Interface/ICONS/INV_Misc_Bag_08")
    ToggleBagsContainer.IconTexture:SetInside()     
    UI:KeepAspectRatio(ToggleBagsContainer, ToggleBagsContainer.IconTexture)
    
    ToggleBagsContainer.IconOverlay = CreateFrame("Frame", nil, ToggleBagsContainer)
    ToggleBagsContainer.IconOverlay:SetInside(ToggleBagsContainer.IconTexture)
    ToggleBagsContainer.IconOverlay:SetTemplate()
    ToggleBagsContainer.IconOverlay:CreateShadow()
    ToggleBagsContainer.IconOverlay:SetShadowOverlay()

    -- Cache
    self.Container = Container
    --self.Container.CloseButton = CloseButton
    self.Container.SearchBox = SearchBox
    self.Container.MoneyText = MoneyText
    self.Container.Separator = Separator
    self.Container.ToggleBagsContainer = ToggleBagsContainer
end

function B:CreateCurrencyButton(Index)
    local Button = CreateFrame("Button", nil, self.Container)
    Button:Size(30, 16)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    local InvisFrame = CreateFrame("Frame", nil, Button)
    InvisFrame:SetFrameLevel(Button:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    -- Icon
    Button.Icon = Button:CreateTexture(nil, "ARTWORK")
    Button.Icon:SetInside()
    UI:KeepAspectRatio(Button, Button.Icon)

    -- Count
    Button.Count = InvisFrame:CreateFontString(nil, "OVERLAY")
    Button.Count:Point("CENTER", Button, 2, -6)
    Button.Count:SetFontTemplate("Default")

    -- OnEnter
    Button:SetScript("OnEnter", function(self)
        if (GameTooltip:IsForbidden()) then
            return
        end
 
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
 
        if (self.CurrencyID) then
            GameTooltip:SetCurrencyByID(self.CurrencyID)
        end
 
        GameTooltip:Show()
    end)
 
    -- OnLeave
    Button:SetScript("OnLeave", function()
        if (GameTooltip:IsForbidden()) then
            return
        end
 
        GameTooltip:Hide()
    end)

    -- Cache
    self.CurrencyButtons[Index] = Button

    return Button
end

function B:UpdateCurrencies()
    if (not self.Container) then
        return
    end

    local Currencies = self:GetBackpackCurrencies()

    if (not Currencies) then
        return
    end

    for Index, Info in ipairs(Currencies) do
        local Button = self.CurrencyButtons[Index]

        if (not Button) then
            Button = self:CreateCurrencyButton(Index)
        end

        Button.CurrencyID = Info.currencyTypesID
        Button.Icon:SetTexture(Info.iconFileID)
        Button.Count:SetText(AbbreviateNumbers(Info.quantity or 0))

        Button:ClearAllPoints()
        Button:Point("RIGHT", self.Container.ToggleBagsContainer, "LEFT", -4 - ((Index - 1) * (Button:GetWidth() + self.ButtonSpacing)), 0)
        Button:Show()
    end

    for Index = #Currencies + 1, #self.CurrencyButtons do
        self.CurrencyButtons[Index]:Hide()
    end
end

function B:CreateBagBar()
    local BagBar = CreateFrame("Frame", "FeelUI_BagBar", self.Container)
    BagBar:Size((self.BagButtonWidth * #BagIDs) + (self.BagButtonSpacing * (#BagIDs)) + (self.BagBarPadding * 2), self.BagButtonHeight + (self.BagBarPadding * 2))
    BagBar:Point("TOPRIGHT", self.Container, "TOPRIGHT", 0, 38)
    BagBar:CreateBackdrop()
    BagBar:CreateShadow()
    BagBar:SetAlpha(0)
    BagBar:Hide()

    -- Cache
    self.BagBar = BagBar
end

function B:CreateBagButton(BagID, Index)
    local Button = CreateFrame("Button", nil, self.BagBar)
    Button:Size(self.BagButtonWidth, self.BagButtonHeight)
    Button:RegisterForClicks("AnyUp")
    Button:RegisterForDrag("LeftButton")
    Button:StripTexture()
    Button:CreateButtonBackdrop()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    Button.BagID = BagID

    -- Backpack Icon
    Button.BackpackIcon = Button:CreateTexture(nil, "ARTWORK")
    Button.BackpackIcon:SetInside()
    Button.BackpackIcon:SetTexture("Interface/ICONS/INV_Misc_Bag_08")
    Button.BackpackIcon:Hide()
    UI:KeepAspectRatio(Button, Button.BackpackIcon)

    -- Icons
    Button.Icon = Button:CreateTexture(nil, "ARTWORK")
    Button.Icon:SetInside()
    UI:KeepAspectRatio(Button, Button.Icon)

    -- Count
    if (Index == 1) then
        Button.Count = Button:CreateFontString(nil, "OVERLAY")
        Button.Count:Point("BOTTOMRIGHT", Button, -1, 3)
        Button.Count:SetFontTemplate("Default")
    end

    -- OnClick
    Button:SetScript("OnClick", function(self)
        if (B:TryEquipBag(self)) then
            return
        end

        --[[
        if (self.BagID == Enum.BagIndex.Backpack) then
            B:ToggleStandaloneBag()
        elseif (C_Container.OpenBag) then
            C_Container.OpenBag(self.BagID)
        end
        --]]
    end)

    -- OnDragStart
    Button:SetScript("OnDragStart", function(self)
        if (self.BagID == Enum.BagIndex.Backpack) then
            return
        end

        local InventoryID = C_Container.ContainerIDToInventoryID(self.BagID)

        if (InventoryID) then
            PickupBagFromSlot(InventoryID)
        end
    end)

    -- OnReceiveDrag
    Button:SetScript("OnReceiveDrag", function(self)
        B:TryEquipBag(self)
    end)

    -- OnEnter
    Button:SetScript("OnEnter", function(self)
        if (GameTooltip:IsForbidden()) then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        if (self.BagID == Enum.BagIndex.Backpack) then
            GameTooltip:AddLine(BACKPACK_TOOLTIP or "Backpack")
        else
            local InventoryID = C_Container.ContainerIDToInventoryID(self.BagID)

            if (InventoryID) then
                GameTooltip:SetInventoryItem("player", InventoryID)
            end
        end

        GameTooltip:Show()
    end)

    -- OnLeave
    Button:SetScript("OnLeave", function()
        if (GameTooltip:IsForbidden()) then
            return
        end

        GameTooltip:Hide()
    end)

    -- Cache
    self.BagButtons[BagID] = Button

    return Button
end

function B:UpdateBagButton(Button)
    local InventoryID = C_Container.ContainerIDToInventoryID(Button.BagID)
    local Texture = InventoryID and GetInventoryItemTexture("player", InventoryID)

    if (Button.BagID == Enum.BagIndex.Backpack) then
        Button.Icon:Hide()
        Button.BackpackIcon:Show()
    else
        -- Normal bag slots
        Button.BackpackIcon:Hide()
        Button.Icon:SetTexture(Texture)
        Button.Icon:SetShown(Texture ~= nil)
    end
    
    Button.Quality = nil

    if (Button.Count) then
        Button.Count:SetText(C_Container.CalculateTotalNumberOfFreeBagSlots())
    end

    if (InventoryID and Texture) then
        local ItemLink = GetInventoryItemLink("player", InventoryID)

        if (ItemLink) then
            local _, _, Quality = GetItemInfo(ItemLink)
            Button.Quality = Quality
        end
    end

    if (Button.Quality) then
        if (not Button.IsPanelCreated) then
            Button:CreateButtonPanel(true)
            Button.IsPanelCreated = true
        end
    else
        if (not Button.IsSkinned) then
            Button:SetTemplate()
            Button.IsSkinned = true
        end
    end

    self:UpdateBorderColors(Button)
end

function B:UpdateBagBar()
    if (not self.BagBar) then
        return
    end

    for Index, BagID in ipairs(BagIDs) do
        local Button = self.BagButtons[BagID]

        if (not Button) then
            Button = self:CreateBagButton(BagID, Index)
        end

        Button:ClearAllPoints()

        if (Index == 1) then
            Button:Point("LEFT", self.BagBar, "LEFT", self.BagBarPadding, 0)
        else
            Button:Point("LEFT", self.BagButtons[BagIDs[Index - 1]], "RIGHT", self.BagButtonSpacing, 0)
        end

        self:UpdateBagButton(Button)
    end
end

function B:CreateItemSlot(Frame, BagID, SlotID)
    local Holder = self:GetBagHolder(BagID)

    local Button = CreateFrame("Button", nil, Holder, "ContainerFrameItemButtonTemplate")
    Button:SetFrameLevel(Frame:GetFrameLevel() + 10)
    Button:Size(self.ButtonWidth, self.ButtonHeight)
    Button:StripTexture()
    Button:CreateButtonBackdrop()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()
    Button:SetID(SlotID)

    Button.BagID = BagID
    Button.SlotID = SlotID

    -- Icon
    Button.Icon = Button:CreateTexture(nil, "ARTWORK")
    Button.Icon:SetInside(Button, 1, 1)
    UI:KeepAspectRatio(Button, Button.Icon)

    -- Count
    Button.Count = Button:CreateFontString(nil, "OVERLAY")
    Button.Count:Point("BOTTOMRIGHT", Button, -1, 3)
    Button.Count:SetFontTemplate("Default")

    -- Cooldown
    Button.Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Button.Cooldown:SetInside()
    Button.Cooldown:SetReverse(false)
    Button.Cooldown:SetDrawBling(false)
    Button.Cooldown:SetDrawEdge(false)

    UI:UpdateCooldownText(Button.Cooldown, Button.Icon, 0, 0, true)

    Button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    Button:SetScript("OnEvent", function(self, Event)
        if (Event == "SPELL_UPDATE_COOLDOWN") then
            B:UpdateCooldown(self)
        end
    end)

    -- New Item Glow
    Button.NewItemTexture = Button:CreateTexture(nil, "OVERLAY", nil, 1)
    Button.NewItemTexture:SetAtlas("bags-glow-white", true)
    Button.NewItemTexture:SetBlendMode("ADD")
    Button.NewItemTexture:SetInside(Button, 1, 1)
    Button.NewItemTexture:Hide()

    Button.NewItemAnimation = Button.NewItemTexture:CreateAnimationGroup()
    Button.NewItemAnimation:SetLooping("BOUNCE")
    Button.NewItemAnimation.FadeOut = Button.NewItemAnimation:CreateAnimation("Alpha")
    Button.NewItemAnimation.FadeOut:SetFromAlpha(1)
    Button.NewItemAnimation.FadeOut:SetToAlpha(0.5)
    Button.NewItemAnimation.FadeOut:SetDuration(0.5)
    Button.NewItemAnimation.FadeOut:SetSmoothing("IN_OUT")

    -- Trade Skill Quality Overlay
    Button.ReagentQualityTexture = Button:CreateTexture(nil, "OVERLAY", nil, 2)
    Button.ReagentQualityTexture:Point("TOPLEFT", Button, "TOPLEFT", 2, -2)
    Button.ReagentQualityTexture:Size(14, 14)
    Button.ReagentQualityTexture:Hide()

    -- Item Level
    Button.ItemLevel = Button:CreateFontString(nil, "OVERLAY")
    Button.ItemLevel:Point("TOPLEFT", Button, "TOPLEFT", 2, -2)
    Button.ItemLevel:SetFontTemplate("Default")
    Button.ItemLevel:Hide()

    return Button
end

function B:UpdateItemSlots(BagID, TableIndex, PositionIndex, SlotTable, ParentFrame, ExtraYOffset)
    local NumSlots = B:GetNumSlots(BagID)
    ExtraYOffset = ExtraYOffset or 0

    for SlotID = 1, NumSlots do
        local Button = SlotTable[TableIndex]

        if (not Button) then
            Button = self:CreateItemSlot(ParentFrame, BagID, SlotID)
            SlotTable[TableIndex] = Button
        end

        -- SetID
        Button:SetID(SlotID)

        -- GetItemInfo
        local Info = self:GetContainerItemInfo(BagID, SlotID)
        local Quest = self:GetContainerItemQuestInfo(BagID, SlotID)
        local InfoNewItem = IsNewItem(BagID, SlotID)

        -- Cache
        Button.ItemID = nil
        Button.ItemLink = nil
        Button.Name = nil
        Button.Quality = nil
        Button.Type = nil
        Button.SpellID = nil
        Button.BagID = BagID
        Button.SlotID = SlotID

        if (Info) then
            if (not Button.IsCreated) then
                Button:CreateButtonPanel(true)
                Button.IsCreated = true
            end

            Button.ItemID = Info.itemID
            Button.ItemLink = Info.hyperlink
            Button.Icon:SetTexture(Info.iconFileID)

            if (Info.stackCount and Info.stackCount > 1) then
                Button.Count:Show()
                Button.Count:SetText(Info.stackCount)
            else
                Button.Count:Hide()
            end

            if (Button.ItemLink) then
                local ItemName, _, ItemQuality, ItemLevel, _, ItemType = GetItemInfo(Button.ItemLink)
                local ReagentInfo = GetItemReagentQualityInfo(Button.ItemLink)
                local _, SpellID = GetItemSpell(Button.ItemLink)

                Button.Name = ItemName
                Button.Quality = Info.quality or ItemQuality
                Button.ItemLevelValue = ItemLevel
                Button.Type = ItemType
                Button.SpellID = SpellID

                if (ItemLevel and (ItemType == ARMOR or ItemType == WEAPON)) then
                    Button.ItemLevel:SetText(ItemLevel)
                    Button.ItemLevel:Show()

                    local Color = self:GetQualityColor(Button.Quality)

                    if (Color) then
                        Button.ItemLevel:SetTextColor(Color.r, Color.g, Color.b)
                    else
                        Button.ItemLevel:SetTextColor(1, 1, 1)
                    end
                else
                    Button.ItemLevel:Hide()
                end

                if (ReagentInfo and ReagentInfo.iconInventory) then
                    Button.ReagentQualityTexture:SetAtlas(ReagentInfo.iconInventory, true)
                    Button.ReagentQualityTexture:Show()
                else
                    Button.ReagentQualityTexture:Hide()
                end
            else
                Button.Quality = Info.quality
                Button.ItemLevelValue = nil
            end
        else
            if (not Button.IsSkinned) then
                Button:SetTemplate()
                Button.IsSkinned = true
            end

            Button.Icon:SetTexture(nil)
            Button.Count:Hide()
            Button.ItemLevel:Hide()
            Button.ReagentQualityTexture:Hide()
        end

        if (InfoNewItem) then
            local Quality = Button.Quality
            local Atlas = "bags-glow-white"

            if (Enum and Enum.ItemQuality) then
                if (Quality and Quality >= Enum.ItemQuality.Epic) then
                    Atlas = "bags-glow-purple"
                elseif (Quality and Quality >= Enum.ItemQuality.Rare) then
                    Atlas = "bags-glow-blue"
                elseif (Quality and Quality >= Enum.ItemQuality.Uncommon) then
                    Atlas = "bags-glow-green"
                end
            end

            Button.NewItemTexture:SetAtlas(Atlas)
            Button.NewItemTexture:Show()

            if (not Button.NewItemAnimation:IsPlaying()) then
                Button.NewItemAnimation:Play()
            end
        else
            Button.NewItemTexture:Hide()

            if (Button.NewItemAnimation:IsPlaying()) then
                Button.NewItemAnimation:Stop()
            end
        end

        if (Quest and (Quest.questID or Quest.isQuestItem)) then
            Button.Type = QUESTS_LABEL
        end

        -- Update Border Color
        self:UpdateBorderColors(Button)

        -- Update Cooldown
        self:UpdateCooldown(Button)

        -- Update Positions
        local Row = math.floor((PositionIndex - 1) / self.ButtonsPerRow)
        local Col = (PositionIndex - 1) % self.ButtonsPerRow

        Button:ClearAllPoints()
        Button:Point("TOPLEFT", ParentFrame, "TOPLEFT", self.SideMargin + Col * (self.ButtonWidth + self.ButtonSpacing), self:GetRowY(Row, ExtraYOffset))
        Button:Show()

        -- Cache
        TableIndex = TableIndex + 1
        PositionIndex = PositionIndex + 1
    end

    return TableIndex, PositionIndex
end

function B:PositionSeparator(Row)
    local Separator = self.Container.Separator

    if (not Separator) then
        return
    end

    local Y = self:GetRowY(Row) + (self.ButtonSpacing / 2) - (self.SeparatorHeight / 2)

    Separator:ClearAllPoints()
    Separator:Point("LEFT", self.Container, "TOPLEFT", self.SideMargin, Y)
    Separator:Show()
end

function B:PositionSearchBox(BottomY)
    local SearchBox = self.Container.SearchBox

    if (not SearchBox) then
        return
    end

    local Y = BottomY - self.SearchBoxPadding

    SearchBox:ClearAllPoints()
    SearchBox:Point("TOP", self.Container, "TOP", 0, Y)
end

function B:UpdateBags()
    local TableIndex, PositionIndex = 1, 1
    local NormalSlotCount = 0

    for Bag = 0, 4 do
        NormalSlotCount = NormalSlotCount + GetContainerNumSlots(Bag)
        TableIndex, PositionIndex = self:UpdateItemSlots(Bag, TableIndex, PositionIndex, B.BagSlots, B.Container, 0)
    end

    for i = TableIndex, #self.BagSlots do
        self.BagSlots[i]:Hide()
    end

    local NormalRows = self:NumRows(NormalSlotCount)
    local ReagentSlotCount = GetContainerNumSlots(Enum.BagIndex.ReagentBag)
    local ReagentRows = self:NumRows(ReagentSlotCount)
    local BottomY

    if (ReagentSlotCount > 0) then
        PositionIndex = (NormalRows * B.ButtonsPerRow) + 1

        self:PositionSeparator(NormalRows)
        self.Container.Separator:Show()

        local ReagentExtraOffset = self.SeparatorHeight
        local ReagentTableIndex = self:UpdateItemSlots(Enum.BagIndex.ReagentBag, 1, PositionIndex, self.ReagentSlots, self.Container, ReagentExtraOffset)

        for i = ReagentTableIndex, #B.ReagentSlots do
            self.ReagentSlots[i]:Hide()
        end

        BottomY = self:GetRowY(NormalRows + ReagentRows, ReagentExtraOffset)
    else
        self.Container.Separator:Hide()

        for i = 1, #self.ReagentSlots do
            self.ReagentSlots[i]:Hide()
        end

        BottomY = self:GetRowY(NormalRows, 0)
    end

    -- Set SearchBox Position
    self:PositionSearchBox(BottomY)

    -- Set Container Size
    self.Container:Size(self:GetContainerWidth(), (-BottomY) + self.SearchBoxPadding + self.SearchBoxHeight + self.SearchBoxPadding)

    -- Update BagBar
    self:UpdateBagBar()
end

function B:ToggleStandaloneBag()
    if (self.Container:IsShown()) then
        UI:UIFrameFadeOut(self.Container, 0.5, self.Container:GetAlpha(), 0)
        UI:Delay("CloseBackPack", 0.5, function()
            self.Container:Hide()
        end)
    else
        self:UpdateBagBar()
        self:UpdateBags()

        UI:UIFrameFadeIn(self.Container, 0.5, self.Container:GetAlpha(), 1)
        UI:Delay("ShowBackPack", 0.5, function()
            self.Container:Show()
        end)
    end
end

function B:CloseAllBags()
    UI:UIFrameFadeOut(self.Container, 0.5, self.Container:GetAlpha(), 0)
    UI:Delay("CloseAllBags", 0.5, function()
        self.Container:Hide()
    end)
end

function B:UpdateMoneyText()
    self.Container.MoneyText:SetText(UI:FormatMoney(GetMoney(), true))
end

function B:OnEvent(event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        self:UpdateMoneyText()
        self:UpdateCurrencies()
        self:UpdateBagBar()
        self:UpdateBags()
    elseif (event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED") then
        self:UpdateBagBar()
        self:UpdateBags()
    elseif (event == "BAG_CONTAINER_UPDATE") then
        self:UpdateBagBar()
        self:UpdateBags() 
    elseif (event == "PLAYER_MONEY" or event == "PLAYER_TRADE_MONEY" or event == "TRADE_MONEY_CHANGED") then
        self:UpdateMoneyText()
    elseif (event == "CURRENCY_DISPLAY_UPDATE") then
        self:UpdateCurrencies()
    end
end

function B:OpenCloseBags()
    _G.OpenAllBags = function() B:ToggleStandaloneBag() end
    _G.OpenBackpack = function() B:ToggleStandaloneBag() end
    _G.ToggleBackpack = function() B:ToggleStandaloneBag() end
    _G.ToggleAllBags = function() B:ToggleStandaloneBag() end
    _G.CloseBackpack = function() B:CloseAllBags() end
    _G.CloseAllBags = function() B:CloseAllBags() end
end

function B:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("BAG_CONTAINER_UPDATE")
    self:RegisterEvent("PLAYER_MONEY")
    self:RegisterEvent("PLAYER_TRADE_MONEY")
    self:RegisterEvent("TRADE_MONEY_CHANGED")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end)
end

function B:SortBags()
    SetSortBagsRightToLeft(false)
    SetInsertItemsLeftToRight(false)
end

function B:CurrencyTracking()
    hooksecurefunc(C_Currency, "SetCurrencyBackpack", function()
        B:UpdateCurrencies()
    end)
end

function B:Initialize()
    if (not DB.Global.Bags.Enable) then
        return
    end

    self:DisableBlizzard()
    self:CreateContainer()
    self:CreateBagBar()
    self:RegisterEvents()
    self:OpenCloseBags()
    self:SortBags()
    self:CurrencyTracking()
end