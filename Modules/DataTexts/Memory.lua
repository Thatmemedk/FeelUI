local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AM = UI:RegisterModule("DataTextMemory")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local format = string.format
local sort = table.sort
local wipe = table.wipe
local collectgarbage = collectgarbage

-- WoW Globals
local GameTooltip = _G.GameTooltip
local GetAddOnInfo = _G.C_AddOns.GetAddOnInfo
local GetNumAddOns = _G.C_AddOns.GetNumAddOns
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage

-- Tables
AM.AddOns = {}
AM.Memory = {}

-- Locals
AM.UpdateInterval = 5

-- Colors
local GradientColorPalette = {
    0, 1, 0,     -- Green
    1, 0.82, 0,  -- Yellow
    1, 0.42, 0,  -- Orange
    1, 0, 0      -- Red
}

local function SortMemoryComparator(A, B)
    if (A.Memory == B.Memory) then
        return A.Name < B.Name
    end

    return A.Memory > B.Memory
end

function AM:GetMemoryColor(Value)
    local R, G, B = UI:ColorGradientText(Value / 25000, unpack(GradientColorPalette))
    return R, G, B
end

function AM:ColorText(Text, R, G, B)
    return format("|cff%02x%02x%02x%s|r", R * 255, G * 255, B * 255, Text)
end

function AM:FormatMemoryParts(Value)
    if (Value >= 1024) then
        return format("%.2f", Value / 1024), "MB"
    end

    return format("%d", Value), "KB"
end

function AM:BuildAddOnCache()
    if (self.AddOnsNeedsRefresh == false) then
        return
    end

    wipe(self.AddOns)
    self.AddOnCount = GetNumAddOns()

    for Index = 1, self.AddOnCount do
        local Name = GetAddOnInfo(Index)

        if (Name) then
            self.AddOns[#self.AddOns + 1] = {
                Index = Index,
                Name = Name
            }
        end
    end

    self.AddOnsNeedsRefresh = false
    self.MemoryNeedsRefresh = true
end

function AM:UpdateMemory()
    self:BuildAddOnCache()

    if (self.MemoryNeedsRefresh == false) then
        return
    end

    wipe(self.Memory)
    self.MemoryTotal = 0

    for Index = 1, #self.AddOns do
        local AddOn = self.AddOns[Index]

        if (IsAddOnLoaded(AddOn.Index)) then
            local Value = GetAddOnMemoryUsage(AddOn.Index)
            self.MemoryTotal = self.MemoryTotal + Value

            self.Memory[#self.Memory + 1] = {
                Index = AddOn.Index,
                Name = AddOn.Name,
                Memory = Value
            }
        end
    end

    sort(self.Memory, SortMemoryComparator)

    self.MemoryNeedsRefresh = false
end

function AM:AddMemoryLine(Data)
    local MemoryValue = Data.Memory
    local R, G, B = self:GetMemoryColor(MemoryValue)
    local Percentage = 0

    if (self.MemoryTotal > 0) then
        Percentage = MemoryValue / self.MemoryTotal * 100
    end

    local Amount, Unit = self:FormatMemoryParts(MemoryValue)
    local MemoryText = format("%s %s |cffffffff-|r %.1f%%", self:ColorText(Amount, R, G, B), self:ColorText(Unit, 0.7, 0.7, 0.7), Percentage)
    GameTooltip:AddDoubleLine(Data.Name, MemoryText, 1, 0.82, 0, R, G, B)
end

function AM:UpdateTooltip()
    if (not self.TooltipVisible) then
        return
    end

    self:RenderTooltip()
end

function AM:RenderTooltip()
    UpdateAddOnMemoryUsage()
    self:UpdateMemory()

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self.Frame, "ANCHOR_CURSOR", 0, -4)

    for Index = 1, #self.Memory do
        self:AddMemoryLine(self.Memory[Index])
    end

    local R, G, B = self:GetMemoryColor(self.MemoryTotal)
    local Amount, Unit = self:FormatMemoryParts(self.MemoryTotal)
    local TotalText = format("%s %s", self:ColorText(Amount, R, G, B), self:ColorText(Unit, 0.7, 0.7, 0.7))
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Total AddOn Memory:", TotalText, 1, 0.82, 0, R, G, B)
    GameTooltip:Show()
end

function AM:OnEnter()
    if (InCombatLockdown()) then
        return
    end

    AM.TooltipVisible = true
    AM:RenderTooltip()
end

function AM:OnLeave()
    AM.TooltipVisible = false
    GameTooltip:Hide()
end

function AM:OnMouseDown(Button)
    if (Button ~= "LeftButton") then
        return
    end

    if (InCombatLockdown()) then
        return
    end

    collectgarbage("collect")
    AM.MemoryNeedsRefresh = true
    AM:UpdateText()
end

function AM:Create()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(160, 50)
    Frame:Point("CENTER", Panels.DataTextHolder, 0, -2)
    Frame:EnableMouse(true)
    Frame:SetScript("OnEnter", AM.OnEnter)
    Frame:SetScript("OnLeave", AM.OnLeave)
    Frame:SetScript("OnMouseDown", AM.OnMouseDown)

    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame)
    Text:SetFontTemplate("Default")
    Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

    self.Frame = Frame
    self.Text = Text
end

function AM:OnEvent(event)
    if (event == "ADDON_LOADED") then
        self.AddOnsNeedsRefresh = true
        self.MemoryNeedsRefresh = true
        self:UpdateText()
    elseif (event == "PLAYER_ENTERING_WORLD") then
        self.AddOnsNeedsRefresh = true
        self.MemoryNeedsRefresh = true
        self:UpdateText()
    elseif (event == "PLAYER_LOGOUT") then
        self.TooltipVisible = false
    end
end

function AM:RegisterEvents()
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")
    self:SetScript("OnEvent", self.OnEvent)
end

function AM:OnUpdate(Elapsed)
    self.UpdateElapsed = (self.UpdateElapsed or 0) + Elapsed

    if (self.UpdateElapsed < self.UpdateInterval) then
        return
    end

    self.UpdateElapsed = 0
    self:UpdateText()

    if (self.TooltipVisible) then
        self:UpdateTooltip()
    end
end

function AM:RegisterOnUpdate()
    self:SetScript("OnUpdate", self.OnUpdate)
end

function AM:UpdateText()
    UpdateAddOnMemoryUsage()
    self.MemoryNeedsRefresh = true
    self:UpdateMemory()

    local Amount, Unit = self:FormatMemoryParts(self.MemoryTotal)
    local R, G, B = self:GetMemoryColor(self.MemoryTotal)
    self.Text:SetText(self:ColorText(Amount, R, G, B) .. " " .. Unit)
end

function AM:Initialize()
    if (not DB.Global.DataTexts.Memory) then
        return
    end

    self:Create()
    self:RegisterEvents()
    self:RegisterOnUpdate()
    self:UpdateText()
end