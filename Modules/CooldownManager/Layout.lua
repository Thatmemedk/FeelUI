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

    local Existing = self.Anchors[Frame]
    local AnchorFrame = Existing and Existing.Frame

    if (not AnchorFrame) then
        AnchorFrame = CreateFrame("Frame", nil, _G.UIParent, "SecureHandlerStateTemplate")
        AnchorFrame:Size(36, 18)
        AnchorFrame:ClearAllPoints()
        AnchorFrame:Point(Point, Anchor, X or 0, Y or 0)
    end

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
    if (not Viewer) then
        return
    end

    local Container = Viewer:GetItemContainerFrame()

    if (not Container) then
        return
    end

    if (self.ViewerHooks[Viewer]) then
        return
    end

    self.ViewerHooks[Viewer] = true

    hooksecurefunc(Container, "RefreshLayout", function(self)
        if (not self) then
            return
        end

        local AnchorData = CDM.Anchors[Viewer]

        if (not AnchorData) then
            return
        end

        local Spacing = AnchorData.IconSpacing or 0

        if (not UI:IsSecretValue(self)) then
            if (self.childXPadding ~= Spacing) then
                self.childXPadding = UI:Scale(Spacing)
                self:Layout()
            end
        end

        CDM:UpdateAnchors()
    end)
end

function CDM:UpdateHooks()
    for _, Viewer in ipairs(self.Viewers) do
        self:HookViewer(Viewer)
    end
end

function CDM:UpdateLayout()
    self:PositionContainers()
    self:UpdateAnchors()
    self:UpdateHooks()
end