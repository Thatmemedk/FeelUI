local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Memory = UI:RegisterModule("DataTextMemory")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local unpack = unpack
local select = select

-- WoW Globals
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetNumAddOns = C_AddOns.GetNumAddOns
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local GameTooltip = _G.GameTooltip

-- Locals
local GradientColorPalet = { 
    0, 1, 0,     -- Green
    1, 0.82, 0,  -- Yellow
    1, 0.42, 0,  -- Orange
    1, 0, 0      -- Red
}

local function SortMemory(A, B)
    return A.Memory > B.Memory
end

function Memory:GetAddOnMemoryList()
    local Total = 0
    local AddOns = {}

    for i = 1, GetNumAddOns() do
        if IsAddOnLoaded(i) then
            local MemoryUsage = GetAddOnMemoryUsage(i)
            Total = Total + MemoryUsage
            tinsert(AddOns, { Name = GetAddOnInfo(i), Memory = MemoryUsage })
        end
    end

    sort(AddOns, SortMemory)

    return AddOns, Total
end

function Memory:Update(Elapsed)
    self.Init = (self.Init or 0) - Elapsed

    if (self.Init > 0) then 
        return 
    end

    self.Init = 10

    UpdateAddOnMemoryUsage()
    local AddOns, Total = Memory:GetAddOnMemoryList()

    if (self.Text) then
        self.Text:SetText(UI:FormVal(Total))
    end
end

function Memory:OnEnter()
    if InCombatLockdown() then
        return
    end

    collectgarbage()
    UpdateAddOnMemoryUsage()
    local AddOns, Total = Memory:GetAddOnMemoryList()

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

    for i = 1, #AddOns do
        local ContentList = AddOns[i]
        local R, G, B = UI:ColorGradientText(ContentList.Memory / 25000, unpack(GradientColorPalet))
        GameTooltip:AddDoubleLine(ContentList.Name, UI:FormVal(ContentList.Memory), 1, 0.82, 0, R, G, B)
    end

    local R, G, B = UI:ColorGradientText(Total / 25000, unpack(GradientColorPalet))
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Total AddOn Memory Usage:", UI:FormVal(Total), 1, 0.82, 0, R, G, B)
    GameTooltip:Show()
end

function Memory:OnLeave()
    GameTooltip:Hide()
end

function Memory:Create()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(160, 50)
    Frame:Point("CENTER", Panels.DataTextHolder, 0, -3)
    Frame:SetScript("OnEnter", self.OnEnter)
    Frame:SetScript("OnLeave", self.OnLeave)

    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetFontTemplate("Default")
    Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

    self.Frame = Frame
    self.Text = Text
end

function Memory:OnUpdate()
    self:SetScript("OnUpdate", self.Update)
end

function Memory:Initialize()
    if (not DB.Global.DataTexts.Memory) then 
        return 
    end

    self:Create()
    self:OnUpdate()
end