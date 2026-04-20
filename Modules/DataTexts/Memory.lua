local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AM = UI:RegisterModule("DataTextMemory")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local sort = table.sort
local wipe = table.wipe

-- WoW Globals
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetNumAddOns = C_AddOns.GetNumAddOns
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local GameTooltip = GameTooltip
local InCombatLockdown = InCombatLockdown

-- Locals
local UpdateTime = 10

-- Locals
local GradientColorPalette = {
    0, 1, 0,
    1, 0.82, 0,
    1, 0.42, 0,
    1, 0, 0
}

function AM:Create()
    local Frame = CreateFrame("Frame", nil, UIParent)
    Frame:Size(160, 50)
    Frame:Point("CENTER", Panels.DataTextHolder, 0, -2)
    Frame:SetScript("OnEnter", function() self:OnEnter() end)
    Frame:SetScript("OnLeave", function() self:OnLeave() end)

    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetFontTemplate("Default")
    Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

    self.Frame = Frame
    self.Text = Text
end

local function SortMemory(A, B)
    return A.Memory > B.Memory
end

function AM:BuildAddonList()
    local Count = GetNumAddOns()

    if (self.AddOnCount == Count) then
        return
    end

    self.AddOnCount = Count
    self.AddOnList = {}

    for i = 1, Count do
        if (IsAddOnLoaded(i)) then
            self.AddOnList[#self.AddOnList + 1] = {
                Index = i,
                Name = GetAddOnInfo(i)
            }
        end
    end
end

function AM:GetAddOnMemoryList()
    local Total = 0

    if (not self.AddOns) then
        self.AddOns = {}
    end

    local List = self.AddOns
    local Addons = self.AddOnList

    for i = 1, #Addons do
        local Addon = Addons[i]
        local Memory = GetAddOnMemoryUsage(Addon.Index)

        Total = Total + Memory

        local Entry = List[i]

        if (not Entry) then
            Entry = {}
            List[i] = Entry
        end

        Entry.Name = Addon.Name
        Entry.Memory = Memory
    end

    for i = #Addons + 1, #List do
        List[i] = nil
    end

    return List, Total
end

function AM:OnEnter()
    if (InCombatLockdown()) then
        return
    end

    UpdateAddOnMemoryUsage()

    local AddOns, Total = self:GetAddOnMemoryList()
    sort(AddOns, SortMemory)

    _G.GameTooltip:ClearLines()
    _G.GameTooltip:SetOwner(self.Frame, "ANCHOR_CURSOR", 0, -4)

    for i = 1, #AddOns do
        local Data = AddOns[i]

        local R, G, B = UI:ColorGradientText(Data.Memory / 25000, unpack(GradientColorPalette))
        _G.GameTooltip:AddDoubleLine(Data.Name, UI:FormVal(Data.Memory), 1, 0.82, 0, R, G, B)
    end

    local R, G, B = UI:ColorGradientText(Total / 25000, unpack(GradientColorPalette))
    _G.GameTooltip:AddLine(" ")
    _G.GameTooltip:AddDoubleLine("Total AddOn Memory Usage:", UI:FormVal(Total),1, 0.82, 0, R, G, B)
    _G.GameTooltip:Show()
end

function AM:OnLeave()
    _G.GameTooltip:Hide()
end

function AM:Update(Elapsed)
    self.TimeElapsed = (self.TimeElapsed or 0) - Elapsed

    if (self.TimeElapsed > 0) then 
        return 
    end

    self.TimeElapsed = UpdateTime

    UpdateAddOnMemoryUsage()

    local _, Total = self:GetAddOnMemoryList()
    self.Text:SetText(UI:FormVal(Total))
end

function AM:OnUpdate()
    self:SetScript("OnUpdate", self.Update)
end

function AM:Initialize()
    if (not DB.Global.DataTexts.Memory) then
        return
    end

    self:Create()
    self:BuildAddonList()
    self:OnUpdate()
end