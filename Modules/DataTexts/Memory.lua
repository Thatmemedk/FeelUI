local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AM = UI:RegisterModule("DataTextMemory")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local sort = table.sort
local wipe = table.wipe
local collectgarbage = collectgarbage

-- WoW Globals
local GetAddOnInfo = _G.C_AddOns.GetAddOnInfo
local GetNumAddOns = _G.C_AddOns.GetNumAddOns
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local ResetCPUUsage = ResetCPUUsage
local GameTooltip = _G.GameTooltip

-- Locals
local UpdateTime = 10

-- Locals
local GradientColorPalette = {
    0, 1, 0,
    1, 0.82, 0,
    1, 0.42, 0,
    1, 0, 0
}

local function SortMemory(a, b)
    return a.Memory > b.Memory
end

function AM:Create()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(160, 50)
    Frame:Point("CENTER", Panels.DataTextHolder, 0, -2)
    Frame:SetScript("OnEnter", function()
        self:OnEnter()
    end)

    Frame:SetScript("OnLeave", function()
        self:OnLeave()
    end)

    Frame:SetScript("OnMouseDown", function()
        collectgarbage("collect")
        ResetCPUUsage()
    end)

    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame)
    Text:SetFontTemplate("Default")
    Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

    self.Frame = Frame
    self.Text = Text
end

function AM:BuildAddonList()
    local Count = GetNumAddOns()

    if (self.AddOnCount == Count) then
        return
    end

    self.AddOnCount = Count

    if (not self.AddOnList) then
        self.AddOnList = {}
    else
        wipe(self.AddOnList)
    end

    for i = 1, Count do
        if (IsAddOnLoaded(i)) then
            local Name = GetAddOnInfo(i)

            self.AddOnList[#self.AddOnList + 1] = {
                Index = i,
                Name = Name
            }
        end
    end
end

function AM:GetMemoryList()
    if (not self.MemoryList) then
        self.MemoryList = {}
    end

    local List = self.MemoryList
    local Total = 0

    wipe(List)

    for i = 1, #self.AddOnList do
        local Addon = self.AddOnList[i]

        local Memory = GetAddOnMemoryUsage(Addon.Index)
        Total = Total + Memory

        List[#List + 1] = {
            Name = Addon.Name,
            Memory = Memory
        }
    end

    return List, Total
end

function AM:OnEnter()
    if (InCombatLockdown()) then
        return
    end

    UpdateAddOnMemoryUsage()

    local List, Total = self:GetMemoryList()
    sort(List, SortMemory)

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self.Frame, "ANCHOR_CURSOR", 0, -4)

    for i = 1, #List do
        local Data = List[i]

        local R, G, B = UI:ColorGradientText(Data.Memory / 25000, unpack(GradientColorPalette))
        GameTooltip:AddDoubleLine(Data.Name, UI:FormVal(Data.Memory), 1, 0.82, 0, R, G, B)
    end

    local R, G, B = UI:ColorGradientText(Total / 25000, unpack(GradientColorPalette))
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Total AddOn Memory Usage:", UI:FormVal(Total), 1, 0.82, 0,R, G, B)
    GameTooltip:Show()
end

function AM:OnLeave()
    GameTooltip:Hide()
end

function AM:Update(Elapsed)
    self.TimeElapsed = (self.TimeElapsed or 0) - Elapsed

    if (self.TimeElapsed > 0) then
        return
    end

    self.TimeElapsed = UpdateTime

    UpdateAddOnMemoryUsage()

    local _, Total = self:GetMemoryList()
    self.Text:SetText(UI:FormVal(Total))
end

function AM:RegisterOnUpdate()
    self.Frame:SetScript("OnUpdate", function(_, elapsed)
        self:Update(elapsed)
    end)
end

function AM:Initialize()
    if (not DB.Global.DataTexts.Memory) then
        return
    end

    self:Create()
    self:BuildAddonList()
    self:RegisterOnUpdate()
end