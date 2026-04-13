local UI, DB, Media = select(2, ...):Call()

-- Call Modules
local PBM = UI:RegisterModule("PotionButtonMenu")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- Tables
PBM.ItemID = {
    Healthstone = { 5512, 224464 },
    HealingPotions = { 241304, 241305 }, -- Silvermoon Health Potion
    Potions = { 241308, 241309, 241288, 241289 }, -- Light's Potential & Potion of Recklessness
}

-- Locals
PBM.Buttons = {}

function PBM:CreateHolder()
    local Holder = CreateFrame("Frame", "FeelUI_PotionButtonMenuHolder", _G.UIParent)
    Holder:Size(180, 40)
    Holder:Point(unpack(DB.Global.PotionButtonMenu.Point))

    self.Holder = Holder
end

function PBM:CreateExtraButtons()
    self:CreateIcon("Item", "Healthstone", self.ItemID.Healthstone)
    self:CreateIcon("Item", "HealingPotions", self.ItemID.HealingPotions)
    self:CreateIcon("Item", "Potions", self.ItemID.Potions)
end

function PBM:CreateIcon(Type, Name, ID)
    local Frame = CreateFrame("Button", nil, self.Holder, "SecureActionButtonTemplate")
    Frame:SetFrameStrata("LOW")
    Frame:Size(unpack(DB.Global.PotionButtonMenu.ButtonSize))
    Frame:EnableMouse(true)
    Frame:RegisterForClicks("AnyUp", "AnyDown")
    Frame:StyleButton()

    local Index = #self.Buttons + 1

    if (Index == 1) then
        Frame:Point("LEFT", self.Holder, "LEFT", 0, 0)
    else
        Frame:Point("LEFT", self.Buttons[Index -1], "RIGHT", DB.Global.PotionButtonMenu.ButtonSpacing, 0)
    end

    Frame.Icon = Frame:CreateTexture(nil, "ARTWORK")
    Frame.Icon:SetInside()
    UI:KeepAspectRatio(Frame, Frame.Icon)

    Frame.IconOverlay = CreateFrame("Frame", nil, Frame)
    Frame.IconOverlay:SetInside(Frame.Icon)
    Frame.IconOverlay:SetTemplate()
    Frame.IconOverlay:CreateShadow()
    Frame.IconOverlay:SetShadowOverlay()
    Frame.IconOverlay:EnableMouse(false)

    Frame.Count = Frame:CreateFontString(nil, "OVERLAY")
    Frame.Count:Point("TOPRIGHT", Frame, -2, -2)
    Frame.Count:SetFontTemplate("Default")

    Frame.Cooldown = CreateFrame("Cooldown", nil, Frame, "CooldownFrameTemplate")
    Frame.Cooldown:SetInside()
    Frame.Cooldown:Hide()

    -- Cache
    Frame.ButtonType = Type
    Frame.ButtonName = Name
    Frame.ButtonID = ID

    -- Insert Table
    table.insert(self.Buttons, Frame)

    return Frame
end

function PBM:ShouldRefreshCooldown(Frame, Start, Duration)
    if (not Frame) then
        return false
    end

    local OldStart, OldDuration = Frame:GetCooldownTimes()

    OldStart = tonumber(OldStart) or 0
    OldDuration = tonumber(OldDuration) or 0

    if (Start and Duration and Start > 0 and Duration > 0) then
        if (OldStart <= 0 or OldDuration <= 0) then
            return true
        end

        local OldEnd = (OldStart + OldDuration) / 1000
        local NewEnd = Start + Duration

        return math.abs(OldEnd - NewEnd) > 0.01
    end

    return OldStart > 0 and OldDuration > 0
end

function PBM:GetItemList(Name)
    return self.ItemID[Name]
end

function PBM:UpdateButton(Button)
    local List = self:GetItemList(Button.ButtonName)
    local ItemID
    local Count = 0
    local CurrentItem = Button.ItemID

    if (not List or #List == 0) then
        return
    end

    for _, ID in ipairs(List) do
        local ItemCount

        if (ID == 224464 or ID == 5512) then
            ItemCount = C_Item.GetItemCount(ID, false, true)
        else
            ItemCount = C_Item.GetItemCount(ID)
        end

        if (ItemCount > 0) then
            ItemID = ID
            Count = ItemCount

            break
        end
    end

    if (not ItemID) then
        ItemID = List[1]
    end

    if (CurrentItem and CurrentItem ~= ItemID) then
        local Start, Duration = C_Item.GetItemCooldown(CurrentItem)

        if (Start and Duration and Start > 0 and Duration > 0) then
            ItemID = CurrentItem
        end
    end

    if (Button.ItemID ~= ItemID) then
        Button.ItemID = ItemID
    end

    local _, ItemLink = GetItemInfo(ItemID)

    if (not ItemLink) then
        C_Item.RequestLoadItemDataByID(ItemID)

        return
    end

    if (not InCombatLockdown() and Button.CurrentItem ~= ItemLink) then
        Button:SetAttribute("type", "item")
        Button:SetAttribute("item", ItemLink)

        Button.CurrentItem = ItemLink
    end

    if (Button.Icon) then
        local Texture = C_Item.GetItemIconByID(ItemID)
        Button.Icon:SetTexture(Texture)

        if (Count > 0) then
            Button.Icon:SetDesaturated(false)
        else
            Button.Icon:SetDesaturated(true)
        end
    end

    if (Button.Count) then
        if (Count > 0) then
            Button.Count:SetText(Count)
        else
            Button.Count:SetText("")
        end
    end

    if (Button.Cooldown) then
        local Start, Duration = C_Item.GetItemCooldown(ItemID)

        if (Start and Duration and Start > 0 and Duration > 1) then
            if (PBM:ShouldRefreshCooldown(Button.Cooldown, Start, Duration)) then
                local DurationObject = C_DurationUtil.CreateDuration()
                DurationObject:SetTimeFromStart(Start, Duration)
                Button.Cooldown:SetCooldownFromDurationObject(DurationObject)
            end

            Button.Cooldown:Show()

            -- Update The Text
            UI:UpdateCooldownText(Button.Cooldown, Button, 0, 1, true)
        else
            local OldStart = Button.Cooldown:GetCooldownTimes()

            if (OldStart == 0) then
                Button.Cooldown:Hide()
            end
        end
    end
end

function PBM:UpdateAll()
    for _, Button in pairs(self.Buttons) do
        self:UpdateButton(Button)
    end
end

function PBM:OnEvent(event, ...)
    if (event == "GET_ITEM_INFO_RECEIVED") then
        local ItemID, Success = ...

        if (Success) then
            for _, Button in pairs(self.Buttons) do
                local List = self:GetItemList(Button.ButtonName)

                for _, ID in ipairs(List) do
                    if (ID == ItemID) then
                        self:UpdateButton(Button)
                        break
                    end
                end
            end
        end
    else
        self:UpdateAll()
    end
end

function PBM:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ITEM_PUSH")
    self:RegisterEvent("ITEM_COUNT_CHANGED")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:RegisterEvent("SPELL_UPDATE_CHARGES")
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:SetScript("OnEvent", self.OnEvent)
end

function PBM:Initialize()
    self:CreateHolder()
    self:CreateExtraButtons()
    self:RegisterEvents()
end