local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local B = UI:RegisterModule("Bags")

-- Libs Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local C_Item = _G.C_Item
local C_Container = _G.C_Container
local GetContainerNumSlots = GetContainerNumSlots or (C_Container and C_Container.GetContainerNumSlots)
local GetContainerItemInfo = GetContainerItemInfo or (C_Container and C_Container.GetContainerItemInfo)
local GetContainerItemQuestInfo = GetContainerItemQuestInfo or (C_Container and C_Container.GetContainerItemQuestInfo)
local SetSortBagsRightToLeft = C_Container and C_Container.SetSortBagsRightToLeft or SetSortBagsRightToLeft
local SetInsertItemsLeftToRight = C_Container and C_Container.SetInsertItemsLeftToRight or SetSortBagsRightToLeft
local PickupContainerItem = C_Container.PickupContainerItem
local UseContainerItem = C_Container.UseContainerItem
local SetItemSearch = C_Container.SetItemSearch

-- Locals
B.ButtonWidth = 32
B.ButtonHeight = 22
B.ButtonSpacing = 4
B.ButtonsPerRow = 12

-- Locals
B.ItemNameCache = {}
B.BagSlots = {}
B.ReagentSlots = {}

-- Locals
local SlotTables = {
    B.BagSlots,
    B.ReagentSlots,
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
end

function B:GetCachedItemName(ItemID)
    if (not ItemID) then 
        return "" 
    end

    if not B.ItemNameCache[ItemID] then
        B.ItemNameCache[ItemID] = C_Item.GetItemNameByID(ItemID) or ""
    end

    return B.ItemNameCache[ItemID]
end

function B:GetContainerItemInfo(bag, slot)
    if (_G.GetContainerItemInfo) then
        local info = {}
        info.iconFileID, info.stackCount, info.isLocked, info.quality, info.isReadable, info.hasLoot, info.hyperlink, info.isFiltered, info.hasNoValue, info.itemID, info.isBound = GetContainerItemInfo(bag, slot)
        return info
    else
        return GetContainerItemInfo(bag, slot) or {}
    end
end

function B:GetContainerItemQuestInfo(bag, slot)
    if (_G.GetContainerItemQuestInfo) then
        local info = {}
        info.isQuestItem, info.questID, info.isActive = GetContainerItemQuestInfo(bag, slot)
        return info
    else
        return GetContainerItemQuestInfo(bag, slot)
    end
end

function B:UpdateBorderColors(Button)
    if (Button.ButtonPanel) then
        if (Button.type and Button.type == QUESTS_LABEL) then
            Button.ButtonPanel:SetColorTemplate(1, 0.82, 0)
        elseif (Button.quality) then
            local R, G, B = GetItemQualityColor(Button.quality)

            Button.ButtonPanel:SetColorTemplate(R, G, B)
        else
            Button.ButtonPanel:SetColorTemplate(unpack(DB.Global.General.BorderColor))
        end
    end
end

function B:CreateContainer()
    local Container = CreateFrame("Frame", "FeelUI_Bag", _G.UIParent)
    Container:SetFrameStrata("LOW")
    Container:SetFrameLevel(50)
    Container:Size(448, 418)
    Container:Point("BOTTOMRIGHT", _G.UIParent, -6, 224)
    Container:CreateBackdrop()
    Container:CreateShadow()
    Container:Hide()

    -- CLOSE BUTTON
    local CloseButton = CreateFrame("Button", nil, Container)
    CloseButton:Size(22, 22)
    CloseButton:Point("TOPRIGHT", Container)
    CloseButton:HandleCloseButton(-6, -8, 16)
    CloseButton:SetScript("OnMouseUp", function()
        B:CloseAllBags()
        PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    end)

    -- SEARCH BOX
    local SearchBox = CreateFrame("EditBox", nil, Container)
    SearchBox:SetFrameLevel(Container:GetFrameLevel() + 10)
    SearchBox:Size(Container:GetWidth()-28, 22)
    SearchBox:Point("BOTTOM", Container, 0, 10)
    SearchBox:SetFontTemplate("Default")
    SearchBox:SetMultiLine(false)
    SearchBox:EnableMouse(true)
    SearchBox:SetAutoFocus(false)

    SearchBox.Title = SearchBox:CreateFontString(nil, "OVERLAY")
    SearchBox.Title:Point("LEFT", SearchBox, 0, 0)
    SearchBox.Title:SetFontTemplate("Default")
    SearchBox.Title:SetText("Search")
    SearchBox.Title:SetTextColor(0.5, 0.5, 0.5)

    SearchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); self:SetText(""); if SetItemSearch then SetItemSearch("") end end)
    SearchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus(); self:SetText("") end)
    SearchBox:SetScript("OnEditFocusLost", function(self) self.Title:Show(); if SetItemSearch then SetItemSearch("") end end)
    SearchBox:SetScript("OnEditFocusGained", function(self) self:SetText(""); self.Title:Hide() end)

    SearchBox:SetScript("OnTextChanged", function(self)
        local Text = (self:GetText() or ""):lower()

        if (SetItemSearch) then
            SetItemSearch(Text)
        end

        for _, Frames in ipairs(SlotTables) do
            for _, Button in ipairs(Frames) do
                local Info = (C_Container and C_Container.GetContainerItemInfo) and C_Container.GetContainerItemInfo(Button.bag, Button.slot)
                local Name = B:GetCachedItemName(Info and Info.itemID)

                Button:SetAlpha((Text == "" or Name:find(Text)) and 1 or 0.5)
            end
        end
    end)

    SearchBox.CloseButton = CreateFrame("Button", nil, SearchBox)
    SearchBox.CloseButton:Size(12, 12)
    SearchBox.CloseButton:Point("RIGHT", SearchBox)
    SearchBox.CloseButton:EnableMouse(true)
    SearchBox.CloseButton:HandleCloseButton()
    SearchBox.CloseButton:SetScript("OnMouseUp", function()
        if SetItemSearch then SetItemSearch("") end
        SearchBox:ClearFocus()
        SearchBox:SetText("")
    end)

    SearchBox.Overlay = CreateFrame("Frame", nil, SearchBox)
    SearchBox.Overlay:SetFrameLevel(SearchBox:GetFrameLevel() + 1)
    SearchBox.Overlay:Size(SearchBox:GetWidth()+10, SearchBox:GetHeight())
    SearchBox.Overlay:Point("CENTER", SearchBox, 0, 0)
    SearchBox.Overlay:SetTemplate()
    SearchBox.Overlay:CreateShadow()

    SearchBox.Backdrop = CreateFrame("Frame", nil, SearchBox, "BackdropTemplate")
    SearchBox.Backdrop:SetFrameLevel(SearchBox:GetFrameLevel() - 1)
    SearchBox.Backdrop:Size(SearchBox:GetWidth()+10, SearchBox:GetHeight())
    SearchBox.Backdrop:Point("CENTER", SearchBox, 0, 0)
    SearchBox.Backdrop:SetBackdrop({ bgFile = Media.Global.Texture })
    SearchBox.Backdrop:SetBackdropColor(unpack(DB.Global.General.PanelColor))

    -- GOLD TEXT
    local MoneyText = Container:CreateFontString(nil, "OVERLAY")
    MoneyText:Point("TOPLEFT", Container, "TOPLEFT", 10, -12)
    MoneyText:SetFontTemplate("Default", 12)

    self.Container = Container
    self.Container.CloseButton = CloseButton
    self.Container.SearchBox = SearchBox
    self.Container.MoneyText = MoneyText
end

function B:CreateReagentContainer()
    local ReagentContainer = CreateFrame("Frame", "FeelUI_ReagentBag", _G.UIParent)
    ReagentContainer:Size(158, 258)
    ReagentContainer:Point("LEFT", B.Container, -166, 67)
    ReagentContainer:SetFrameStrata("LOW")
    ReagentContainer:SetFrameLevel(50)
    ReagentContainer:CreateBackdrop()
    ReagentContainer:CreateShadow()
    ReagentContainer:Hide()

    local InvisFrame = CreateFrame("Frame", nil, ReagentContainer)
    InvisFrame:SetFrameLevel(ReagentContainer:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    self.ReagentContainer = ReagentContainer
end

function B:CreateItemSlot(Frame)
    local Button = CreateFrame("Button", nil, Frame, "SecureActionButtonTemplate")
    Button:SetFrameLevel(Frame:GetFrameLevel() + 10)
    Button:Size(B.ButtonWidth, B.ButtonHeight)
    Button:CreateButtonPanel()
    Button:CreateButtonBackdrop()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    Button.Icon = Button:CreateTexture(nil, "ARTWORK")
    Button.Icon:SetInside(Button, 1, 1)
    UI:KeepAspectRatio(Button, Button.Icon)

    Button.Count = Button:CreateFontString(nil, "OVERLAY")
    Button.Count:Point("BOTTOMRIGHT", Button, -1, 3)
    Button.Count:SetFontTemplate("Default")

    Button.Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Button.Cooldown:SetInside()
    Button.Cooldown:SetReverse(false)
    Button.Cooldown:SetDrawBling(false)
    Button.Cooldown:SetDrawEdge(false)

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

    Button:EnableMouse(true)
    Button:RegisterForClicks("AnyUp")
    Button:RegisterForDrag("LeftButton")

    Button:HookScript("PreClick", function(self, mouseButton)
        if IsShiftKeyDown() and mouseButton == "LeftButton" and self.ItemLink then
            ChatEdit_InsertLink(self.ItemLink)
        end
    end)

    Button:HookScript("OnEnter", function(self)
        if (self.ItemLink) then
            _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            _G.GameTooltip:SetBagItem(self.bag, self.slot)
            _G.GameTooltip:Show()
        end
    end)

    Button:HookScript("OnLeave", function() 
        _G.GameTooltip_Hide() 
    end)

    return Button
end

function B:UpdateItemSlots(BagID, StartIndex, SlotTable, ParentFrame, isReagent)
    local NumSlots = C_Container.GetContainerNumSlots(BagID)
    local Index = StartIndex

    for Slot = 1, NumSlots do
        local Button = SlotTable[Index]

        if (not Button) then
            Button = B:CreateItemSlot(ParentFrame)

            SlotTable[Index] = Button
        end

        -- Assign bag and slot
        Button.bag, Button.slot = BagID, Slot

        -- set attributes for the secure template
        Button:SetAttribute("type", "item")
        Button:SetAttribute("bag", BagID)
        Button:SetAttribute("slot", Slot)

        -- Get item info
        local Info = B:GetContainerItemInfo(BagID, Slot)
        local Quest = B:GetContainerItemQuestInfo(BagID, Slot)
        Button.ItemID, Button.ItemLink = Info.itemID, Info.hyperlink

        -- Handle tooltip & new item glow
        Button:HookScript("OnEnter", function(self)
            if C_NewItems.IsNewItem(self.bag, self.slot) then
                C_NewItems.RemoveNewItem(self.bag, self.slot)

                if (self.NewItemTexture) then 
                    self.NewItemTexture:Hide() 
                end

                if self.NewItemAnimation and self.NewItemAnimation:IsPlaying() then
                    self.NewItemAnimation:Stop()
                end
            end
        end)

        -- Update visuals
        if (Button.ItemLink) then
            Button.Icon:SetTexture(Info.iconFileID)

            if (Info.stackCount and Info.stackCount > 1) then
                Button.Count:Show()
                Button.Count:SetText(Info.stackCount)
            else
                Button.Count:Hide()
            end

            Button.name, _, Button.quality, _, _, Button.type = GetItemInfo(Button.ItemLink)

            if not (Button.quality) then 
                Button.quality = Info.quality 
            end
        else
            Button.name, Button.quality, Button.type = nil, nil, nil
            Button.Icon:SetTexture(nil)
            Button.Count:Hide()
        end

        if (Quest and Quest.questID or Quest.isQuestItem) then
            Button.type = QUESTS_LABEL
        end

        B:UpdateBorderColors(Button)

        -- New item glow
        if (C_NewItems.IsNewItem(BagID, Slot)) then
            local quality = Button.quality or Info.quality or 0
            local atlas

            if (quality >= Enum.ItemQuality.Epic) then
                atlas = "bags-glow-purple"
            elseif (quality >= Enum.ItemQuality.Rare) then
                atlas = "bags-glow-blue"
            elseif (quality >= Enum.ItemQuality.Uncommon) then
                atlas = "bags-glow-green"
            else
                atlas = "bags-glow-white"
            end

            Button.NewItemTexture:SetAtlas(atlas)
            Button.NewItemTexture:Show()

            if Button.NewItemAnimation and not Button.NewItemAnimation:IsPlaying() then
                Button.NewItemAnimation:Play()
            end
        else
            Button.NewItemTexture:Hide()

            if Button.NewItemAnimation and Button.NewItemAnimation:IsPlaying() then
                Button.NewItemAnimation:Stop()
            end
        end

        --[[
        if Info.itemID then  -- Reagent bank
            if C_TradeSkillUI and C_TradeSkillUI.GetReagentQuality then
                local qualityTier = C_TradeSkillUI.GetReagentQuality(itemInfo)

                local atlas
                if qualityTier == 1 then
                    atlas = "bags-glow-bronze"
                elseif qualityTier == 2 then
                    atlas = "bags-glow-silver"
                elseif qualityTier == 3 then
                    atlas = "bags-glow-gold"
                end

                if atlas then
                    Button.ReagentQualityTexture:SetAtlas(atlas, true)
                    Button.ReagentQualityTexture:Show()
                else
                    Button.ReagentQualityTexture:Hide()
                end
            else
                -- Handle the case where the function is not available
                Button.ReagentQualityTexture:Hide()
            end
        else
            Button.ReagentQualityTexture:Hide()
        end
        --]]

        -- Position
        Button:Show()
        Button:ClearAllPoints()

        if isReagent then
            local rows = math.floor((Slot - 1) / 4)
            local cols = (Slot - 1) % 4
            Button:Point("TOPLEFT", ParentFrame, "TOPLEFT", 10 + cols * (B.ButtonWidth + B.ButtonSpacing), -42 - rows * (B.ButtonHeight + B.ButtonSpacing))
        else
            local rows = math.floor((Index - 1) / B.ButtonsPerRow)
            local cols = (Index - 1) % B.ButtonsPerRow
            Button:Point("TOPLEFT", ParentFrame, "TOPLEFT", 10 + cols * (B.ButtonWidth + B.ButtonSpacing), -42 - rows * (B.ButtonHeight + B.ButtonSpacing))
        end

        Index = Index + 1
    end

    return Index
end

function B:UpdateBags()
    local Index = 1
    local ReagentIndex = 1

    for Bag = 0, 4 do
        Index = B:UpdateItemSlots(Bag, Index, B.BagSlots, B.Container, false)
    end

    for i = Index, #B.BagSlots do
        B.BagSlots[i]:Hide()
    end

    ReagentIndex = B:UpdateItemSlots(5, ReagentIndex, B.ReagentSlots, B.ReagentContainer, true)

    for i = ReagentIndex, #B.ReagentSlots do
        B.ReagentSlots[i]:Hide()
    end
end

function B:ToggleStandaloneBag()
    if B.Container:IsShown() then
        B.Container:Hide()
        B.ReagentContainer:Hide()
    else
        B.Container:Show()
        B.ReagentContainer:Show()
        B:UpdateBags()
    end
end

function B:CloseAllBags()
    B.Container:Hide()
    B.ReagentContainer:Hide()
end

function B:UpdateMoneyText()
    B.Container.MoneyText:SetText(UI:FormatMoney(GetMoney(), true))
end

function B:OnEvent(event, ...)
    if (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_MONEY" or event == "PLAYER_TRADE_MONEY" or event == "TRADE_MONEY_CHANGED") then
        self:UpdateMoneyText()
    end

    if (event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" or event == "PLAYERBANKSLOTS_CHANGED" or event == "BANKFRAME_OPENED" or event == "BANKFRAME_CLOSED") then
        self:UpdateBags()
    end
end

function B:OpenBags()
    hooksecurefunc("OpenBackpack", function() B:ToggleStandaloneBag() end)
    hooksecurefunc("CloseBackpack", function() B:CloseAllBags() end)
    hooksecurefunc("ToggleBackpack", function() B:ToggleStandaloneBag() end)
    hooksecurefunc("OpenAllBags", function() B:ToggleStandaloneBag() end)
    hooksecurefunc("CloseAllBags", function() B:CloseAllBags() end)
    hooksecurefunc("ToggleAllBags", function() B:ToggleStandaloneBag() end)
end

function B:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("BAG_CLOSED")
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("MERCHANT_CLOSED")
    self:RegisterEvent("MAIL_CLOSED")
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

function B:Initialize()
    if (not DB.Global.Bags.Enable) then 
        return 
    end

    --[[
    self:DisableBlizzard()
    self:CreateContainer()
    self:CreateReagentContainer()
    self:RegisterEvents()
    self:OpenBags()
    self:SortBags()
    --]]
end
