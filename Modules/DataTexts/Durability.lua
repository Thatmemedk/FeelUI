local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Durability = UI:RegisterModule("DataTextDurability")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local format = string.format
local wipe = wipe
local floor = math.floor
local ipairs = ipairs

-- WoW Globals
local GameTooltip = _G.GameTooltip
local GetInventoryItemDurability = GetInventoryItemDurability

-- Locals
Durability.SlotDurability = {}
Durability.TotalDurability = 100
Durability.TooltipVisible = false

-- Locals
local SlotOrder = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }

-- Locals
local SlotNames = {
    [1] = _G.INVTYPE_HEAD,
    [3] = _G.INVTYPE_SHOULDER,
    [5] = _G.INVTYPE_CHEST,
    [6] = _G.INVTYPE_WAIST,
    [7] = _G.INVTYPE_LEGS,
    [8] = _G.INVTYPE_FEET,
    [9] = _G.INVTYPE_WRIST,
    [10] = _G.INVTYPE_HAND,
    [16] = _G.INVTYPE_WEAPONMAINHAND,
    [17] = _G.INVTYPE_WEAPONOFFHAND,
    [18] = _G.INVTYPE_RANGED,
}

-- Colors
local GradientColorPalette = {
    1, 0, 0,       -- Red
    1, 0.42, 0,    -- Orange
    1, 0.82, 0,    -- Yellow
    0, 1, 0        -- Green
}

function Durability:GetDurabilityColor(Value)
    return UI:ColorGradient(Value, 100, unpack(GradientColorPalette))
end

function Durability:ColorText(Text, R, G, B)
    return format("%s%s|r", UI:RGBToHex(R, G, B), Text)
end

function Durability:UpdateDurability()
    wipe(self.SlotDurability)
    self.TotalDurability = 100

    for _, Index in ipairs(SlotOrder) do
        local CurrentDurability, MaxDurability = GetInventoryItemDurability(Index)

        if (CurrentDurability and MaxDurability and MaxDurability > 0) then
            local Perc = floor((CurrentDurability / MaxDurability) * 100)
            self.SlotDurability[Index] = Perc

            if (Perc < self.TotalDurability) then
                self.TotalDurability = Perc
            end
        end
    end
end

function Durability:UpdateText()
    self:UpdateDurability()

    local R, G, B = self:GetDurabilityColor(self.TotalDurability)
    self.Text:SetFormattedText("|cffffffffDurability|r: %s", self:ColorText(self.TotalDurability .. "%", R, G, B))
end

function Durability:RenderTooltip()
    self:UpdateDurability()

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self.Frame, "ANCHOR_CURSOR", 0, -4)
    GameTooltip:AddLine("Durability", 1, .82, 0)

    local HasItems = false

    for _, Index in ipairs(SlotOrder) do
        local Perc = self.SlotDurability[Index]

        if (Perc) then
            HasItems = true
            local R, G, B = self:GetDurabilityColor(Perc)
            GameTooltip:AddDoubleLine(SlotNames[Index], format("%d%%", Perc), 1, 1, 1, R, G, B)
        end
    end

    if (not HasItems) then
        GameTooltip:AddLine("No items equipped", 0.7, 0.7, 0.7)
    end

    GameTooltip:AddLine(" ")

    local R, G, B = self:GetDurabilityColor(self.TotalDurability)
    GameTooltip:AddDoubleLine("Overall Durability:", format("%d%%", self.TotalDurability), 1, 0.82, 0, R, G, B)
    GameTooltip:Show()
end

function Durability:Create()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(160, 50)
    Frame:Point("RIGHT", Panels.DataTextHolder, 32, -2)
    Frame:SetScript("OnEnter", Durability.OnEnter)
    Frame:SetScript("OnLeave", Durability.OnLeave)

    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetFontTemplate("Default", 12)
    Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

    self.Frame = Frame
    self.Text = Text
end

function Durability:OnEnter()
    if (InCombatLockdown()) then
        return
    end

    Durability.TooltipVisible = true
    Durability:RenderTooltip()
end

function Durability:OnLeave()
    Durability.TooltipVisible = false
    GameTooltip:Hide()
end

function Durability:OnEvent()
    self:UpdateText()

    if (self.TooltipVisible) then
        self:RenderTooltip()
    end
end

function Durability:RegisterEvents()
    self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    self:RegisterEvent("MERCHANT_SHOW")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", self.OnEvent)
end

function Durability:Initialize()
    if (not DB.Global.DataTexts.Durability) then
        return
    end

    self:Create()
    self:RegisterEvents()
    self:UpdateText()
end