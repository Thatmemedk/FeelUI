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
    Frame:Size(38, 18)
    Frame:EnableMouse(true)
    Frame:RegisterForClicks("AnyUp")
    Frame:StyleButton()

    local Index = #self.Buttons + 1

    if (Index == 1) then
        Frame:Point("LEFT", self.Holder, "LEFT", 0, 0)
    else
        Frame:Point("LEFT", self.Buttons[Index -1], "RIGHT", 2, 0)
    end

    Frame.InvisFrame = CreateFrame("Frame", nil, Frame)
    Frame.InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
    Frame.InvisFrame:SetInside()
    Frame.InvisFrame:EnableMouse(false)

    Frame.Icon = Frame:CreateTexture(nil, "ARTWORK")
    Frame.Icon:SetInside()
    UI:KeepAspectRatio(Frame, Frame.Icon)

    Frame.IconOverlay = CreateFrame("Frame", nil, Frame)
    Frame.IconOverlay:SetInside(Frame.Icon)
    Frame.IconOverlay:SetTemplate()
    Frame.IconOverlay:CreateShadow()
    Frame.IconOverlay:SetShadowOverlay()
    Frame.IconOverlay:EnableMouse(false)

    Frame.Count = Frame.InvisFrame:CreateFontString(nil, "OVERLAY")
    Frame.Count:Point("TOPRIGHT", Frame, 2, 2)
    Frame.Count:SetFontTemplate("Default")

    Frame.Cooldown = CreateFrame("Cooldown", nil, Frame, "CooldownFrameTemplate")
    Frame.Cooldown:SetInside()
    Frame.Cooldown:SetReverse(false)
    Frame.Cooldown:SetDrawBling(false)
    Frame.Cooldown:SetDrawEdge(false)
    Frame.Cooldown:Hide()

    -- Cache
    Frame.ButtonType = Type
    Frame.ButtonName = Name
    Frame.ButtonID = ID

    -- Insert Table
    table.insert(self.Buttons, Frame)

    return Frame
end

function PBM:GetItemList(Name)
    return self.ItemID[Name]
end

function PBM:UpdateButton(Button)
    local List = self:GetItemList(Button.ButtonName)

    if (not List or #List == 0) then
        return
    end

    local ItemID = List[1]
    local Count = C_Item.GetItemCount(ItemID)

    if (ItemID == 224464 or ItemID == 5512) then
        Count = C_Item.GetItemCount(ItemID, false, true)
    end

    local _, ItemLink = C_Item.GetItemInfo(ID)

    if (ItemLink) then
        Button:SetAttribute("type", "item")
        Button:SetAttribute("item", ItemLink)
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

        if (Start and Duration) then
            local DurationObject = C_DurationUtil.CreateDuration()

            if (DurationObject) then
                DurationObject:SetTimeFromStart(Start, Duration)
                Button.Cooldown:SetCooldownFromDurationObject(DurationObject)

                for i = 1, Button.Cooldown:GetNumRegions() do
                    local Region = select(i, Button.Cooldown:GetRegions())

                    if (Region.GetText) then
                        if (Region and Region.GetText) then
                            local FontSize = UI:GetCooldownFontScale(Button.Cooldown)

                            Region:ClearAllPoints()
                            Region:Point("CENTER", Button, 0, 0)
                            Region:SetFontTemplate("Default", FontSize)
                            Region:SetTextColor(1, 0.82, 0)
                        end
                    end
                end

                Button.Cooldown:Show()
            end
        else
            Button.Cooldown:Hide()
        end
    end

    Button.ItemID = ItemID
end

function PBM:UpdateAll()
    for _, Button in pairs(self.Buttons) do
        self:UpdateButton(Button)
    end
end

function PBM:OnEvent(event)
    self:UpdateAll()
end

function PBM:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ITEM_PUSH")
    self:RegisterEvent("ITEM_COUNT_CHANGED")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:RegisterEvent("SPELL_UPDATE_CHARGES")
    self:SetScript("OnEvent", self.OnEvent)
end

function PBM:Initialize()
    self:CreateHolder()
    self:CreateExtraButtons()
    self:RegisterEvents()
end