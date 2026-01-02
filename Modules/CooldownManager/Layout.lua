local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:CallModule("CooldownManager")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer

function CDM:CreateContainers(Frame, Point, Anchor, X, Y, IconSpacing)
    if (not Frame) then 
        return 
    end

    local AnchorFrame = CreateFrame("Frame", nil, _G.UIParent)
    AnchorFrame:Size(36, 18)
    AnchorFrame:Point(Point, Anchor, X or 0, Y or 0)

    self.Anchors[Frame] = {
        Frame = AnchorFrame,
        IconSpacing = IconSpacing
    }

    return AnchorFrame
end

function CDM:PositionContainers()
    local Point, Parent, X, Y
    local Spacing = DB.Global.CooldownManager.ButtonSpacing

    Point, Parent, X, Y = unpack(DB.Global.CooldownManager.BuffViewerPoint)
    local BuffContainer = self:CreateContainers(BuffIconCooldownViewer, Point, Parent, X, Y, Spacing)

    Point, Parent, X, Y = unpack(DB.Global.CooldownManager.EssentialViewerPoint)
    local EssentialContainer = self:CreateContainers(EssentialCooldownViewer, Point, Parent, X, Y, Spacing)

    Point, Parent, X, Y = unpack(DB.Global.CooldownManager.UtilityViewerPoint)
    local UtilityContainer = self:CreateContainers(UtilityCooldownViewer, Point, Parent, X, Y, Spacing)
end

function CDM:DisableViewerLayout(Viewer)
    if (not Viewer or Viewer.LayoutDisabled) then
        return
    end

    local Container = Viewer:GetItemContainerFrame()

    if (not Container) then
        return
    end

    Viewer.LayoutDisabled = true
end

function CDM:GetViewerIcons(Viewer)
    local Container = Viewer:GetItemContainerFrame()

    if (not Container) then 
        return nil 
    end

    return Container:GetLayoutChildren()
end

function CDM:ApplyIconPositions(Viewer)
    if (not Viewer or not self.Anchors[Viewer]) then 
        return 
    end

    local AnchorData = self.Anchors[Viewer]
    local AnchorFrame = AnchorData.Frame

    if (not AnchorFrame) then 
        return 
    end

    -- Disable Layout
    self:DisableViewerLayout(Viewer)

    -- GetIcons
    local Icons = self:GetViewerIcons(Viewer)

    if (not Icons or #Icons == 0) then 
        return 
    end

    local ShownIcons = {}

    for _, Icon in ipairs(Icons) do
        if Icon:IsShown() then
            table.insert(ShownIcons, Icon)
        end
    end

    if (#ShownIcons == 0) then 
        return
    end

    local FirstIcon = ShownIcons[1]
    local Width = FirstIcon:GetWidth()
    local Spacing = AnchorData.IconSpacing
    local TotalWidth = (#ShownIcons * Width) + ((#ShownIcons - 1) * Spacing)
    local StartX = -TotalWidth / 2 + Width / 2

    for i, Icon in ipairs(ShownIcons) do
        Icon:ClearAllPoints()
        Icon:Point("CENTER", AnchorFrame, "CENTER", StartX + (i - 1) * (Width + Spacing), 0)
    end
end

function CDM:UpdateAnchors()
    for Viewer, Data in pairs(self.Anchors) do
        local AnchorFrame = Data.Frame

        if (AnchorFrame) then
            Viewer:SetParent(AnchorFrame)
            Viewer:ClearAllPoints()
            Viewer:Point("CENTER", AnchorFrame, "CENTER", 0, 0)
        end
    end
end

function CDM:HookViewer(Viewer)
    if (not Viewer or Viewer.Hooked) then 
        return 
    end

    Viewer:HookScript("OnShow", function()
        CDM:ApplyIconPositions(Viewer)
    end)

    Viewer:HookScript("OnSizeChanged", function()
        CDM:ApplyIconPositions(Viewer)
    end)

    local UpdateInterval = (Viewer == BuffIconCooldownViewer) and 1.0 or 2.0

    if (not self.EventFrame) then
        self.EventFrame = self 
        self:RegisterEvent("UNIT_AURA")
        self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self:RegisterEvent("BAG_UPDATE_COOLDOWN")
        self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
        self:SetScript("OnEvent", function(_, Event, Unit)
            if (Event == "UNIT_AURA" and Unit == "player") then
                if BuffIconCooldownViewer:IsShown() then
                    CDM:ApplyIconPositions(BuffIconCooldownViewer)
                end
            elseif (Event ~= "UNIT_AURA") then
                for _, Frames in ipairs({ EssentialCooldownViewer, UtilityCooldownViewer }) do
                    if Frames:IsShown() then
                        CDM:ApplyIconPositions(Frames)
                    end
                end
            end
        end)
    end

    if (not Viewer.OnUpdateHooked) then
        Viewer:HookScript("OnUpdate", function(self, Elapsed)
            self.LastUpdate = (self.LastUpdate or 0) + Elapsed

            if (self.LastUpdate > UpdateInterval and not InCombatLockdown()) then
                self.LastUpdate = 0

                CDM:ApplyIconPositions(Viewer)
            end
        end)

        Viewer.OnUpdateHooked = true
    end

    Viewer.Hooked = true
end

function CDM:UpdateHooks()
    for _, Viewer in ipairs(self.Viewers) do
        self:HookViewer(Viewer)
        self:ApplyIconPositions(Viewer)
    end
end

function CDM:UpdateLayout()
    self:PositionContainers()
    self:UpdateAnchors()
    self:UpdateHooks()
end