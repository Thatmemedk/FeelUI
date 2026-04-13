local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Memory = UI:RegisterModule("DataTextMemory")
local Panels = UI:CallModule("Panels")

-- Lib Globals
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
local GameTooltip = _G.GameTooltip
local InCombatLockdown = InCombatLockdown

-- Locals
local GradientColorPalet = {
    0, 1, 0,     -- Green
    1, 0.82, 0,  -- Yellow
    1, 0.42, 0,  -- Orange
    1, 0, 0      -- Red
}

local function SortMemory(a, b)
    return a.Memory > b.Memory
end

function Memory:GetAddOnMemoryList()
    local Total = 0

    if (not self.AddOns) then
        self.AddOns = {}
    end

    wipe(self.AddOns)

    for i = 1, GetNumAddOns() do
        if IsAddOnLoaded(i) then
            local MemoryUsage = GetAddOnMemoryUsage(i)
            Total = Total + MemoryUsage

            self.AddOns[#self.AddOns + 1] = {
                    Name = self.AddOnNames[i],
                Memory = MemoryUsage
            }
        end
    end

    return self.AddOns, Total
end

function Memory:Update(Elapsed)
    self.Init = (self.Init or 0) - Elapsed

    if (self.Init > 0) then
        return
    end

    self.Init = 10

    UpdateAddOnMemoryUsage()

    local _, Total = self:GetAddOnMemoryList()

    if (self.Text) then
        self.Text:SetText(UI:FormVal(Total))
    end
end

function Memory:OnEnter()
    if (InCombatLockdown()) then 
        return 
    end

    UpdateAddOnMemoryUsage()
    collectgarbage()
    ResetCPUUsage()

    local AddOns, Total = Memory:GetAddOnMemoryList()
    sort(AddOns, SortMemory)

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

    for i = 1, #AddOns do
        local Data = AddOns[i]

        local R, G, B = UI:ColorGradientText(Data.Memory / 25000, unpack(GradientColorPalet))
        GameTooltip:AddDoubleLine(Data.Name, UI:FormVal(Data.Memory), 1, 0.82, 0, R, G, B)
    end

    local R, G, B = UI:ColorGradientText(Total / 25000, unpack(GradientColorPalet))

    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Total AddOn Memory Usage:", UI:FormVal(Total), 1, 0.82, 0, R, G, B)
    GameTooltip:Show()
end

function Memory:OnLeave()
    _G.GameTooltip_Hide()
end

function Memory:Create()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(160, 50)
    Frame:Point("CENTER", Panels.DataTextHolder, 0, -2)
    Frame:SetScript("OnEnter", function() Memory:OnEnter() end)
    Frame:SetScript("OnLeave", function() Memory:OnLeave() end)

    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetFontTemplate("Default")
    Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

    self.Frame = Frame
    self.Text = Text
end

function Memory:OnUpdate()
    self.Frame:SetScript("OnUpdate", function(_, elapsed)
        Memory:Update(elapsed)
    end)
end

function Memory:Initialize()
    if (not DB.Global.DataTexts.Memory) then
        return
    end

    self.AddOnNames = {}

    for i = 1, GetNumAddOns() do
        self.AddOnNames[i] = GetAddOnInfo(i)
    end

    self:Create()
    self:OnUpdate()
end