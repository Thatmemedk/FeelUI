local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:CallModule("CooldownManager")

-- Lib Globals
local _G = _G
local unpack = unpack

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer

function CDM:CreateContainers(Frame, Point, Anchor, X, Y, IconSpacing)
    if (not Frame) then
        return
    end

    local AnchorFrame = CreateFrame("Frame", nil, _G.UIParent, "SecureHandlerStateTemplate")
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

function CDM:GetViewerIcons(Viewer)
    if (not Viewer) then
        return nil
    end

    local Container = Viewer:GetItemContainerFrame()

    if (not Container) then
        return nil
    end

    return Container:GetLayoutChildren()
end

function CDM:ApplyIconPositions(Viewer)
    if (not Viewer) then
        return
    end

    local AnchorData = self.Anchors[Viewer]

    if (not AnchorData) then
        return
    end

    local AnchorFrame = AnchorData.Frame

    if (not AnchorFrame) then
        return
    end

    local Icons = self:GetViewerIcons(Viewer)

    if (not Icons or #Icons == 0) then
        return
    end

    local ShownIcons = {}

    for _, Icon in ipairs(Icons) do
        if (Icon:IsShown()) then
            ShownIcons[#ShownIcons + 1] = Icon
        end
    end

    if (#ShownIcons == 0) then
        return
    end

    local FirstIcon = ShownIcons[1]
    local Width = FirstIcon:GetWidth()

    if (not Width or Width <= 0) then
        return
    end

    local Spacing = AnchorData.IconSpacing or 0
    local TotalWidth =(#ShownIcons * Width) + ((#ShownIcons - 1) * Spacing)
    local StartX = -TotalWidth / 2 + Width / 2

    for i, Icon in ipairs(ShownIcons) do
        Icon:ClearAllPoints()
        Icon:Point("CENTER", AnchorFrame,"CENTER", StartX + (i - 1) * (Width + Spacing), 0)
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

    local Container = Viewer:GetItemContainerFrame()

    if (not Container) then
        return
    end

    Viewer.Hooked = true

    Viewer:HookScript("OnShow", function()
        CDM:ApplyIconPositions(Viewer)
    end)

    if (Container.Layout) then
        hooksecurefunc(Container, "Layout", function()
            if (Viewer:IsShown()) then
                CDM:ApplyIconPositions(Viewer)
            end
        end)
    end
end

function CDM:UpdateHooks()
    for _, Viewer in ipairs(self.Viewers) do
        self:HookViewer(Viewer)

        C_Timer.After(0, function()
            if (Viewer:IsShown()) then
                self:ApplyIconPositions(Viewer)
            end
        end)
    end
end

function CDM:UpdateLayout()
    self:PositionContainers()
    self:UpdateAnchors()
    self:UpdateHooks()
end