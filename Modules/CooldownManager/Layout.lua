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
local EditModeManager = _G.EditModeManager
local C_EditMode = _G.C_EditMode

function CDM:CreateContainers(Frame, Point, Anchor, X, Y, IconSpacing)
    if (not Frame) then 
        return 
    end

    local AnchorFrame = CreateFrame("Frame", nil, _G.UIParent)
    AnchorFrame:Point(Point, Anchor, X or 0, Y or 0)
    AnchorFrame:Size(unpack(DB.Global.CooldownManager.ButtonSize))

    self.Anchors[Frame] = {
        Frame = AnchorFrame,
        IconSpacing = IconSpacing
    }

    return AnchorFrame
end

function CDM:PositionContainers()
    local Spacing = DB.Global.CooldownManager.ButtonSpacing
    local RowSpacing = DB.Global.CooldownManager.ButtonRowSpacing
    local AnchorPoint, AnchorParent, AnchorX, AnchorY = unpack(DB.Global.CooldownManager.AnchorPoint)

	local EssentialContainer = self:CreateContainers(EssentialCooldownViewer, AnchorPoint, AnchorParent, AnchorX, AnchorY, Spacing)
    local BuffContainer = self:CreateContainers(BuffIconCooldownViewer, "BOTTOM", EssentialContainer, 0, RowSpacing, Spacing)
    local UtilityContainer = self:CreateContainers(UtilityCooldownViewer, "BOTTOM", BuffContainer, 0, RowSpacing, Spacing)
end

function CDM:GetShownViewerIcons(ViewerIcons)
    local Icons = {}

    for _, Child in ipairs(ViewerIcons) do
        if (Child:IsShown()) then
            table.insert(Icons, Child)
        end
    end

    return Icons
end

function CDM:LockIconAnchor(Icon)
    if (Icon.AnchorLocked) then
        return
    end

    Icon.AnchorLocked = true

    hooksecurefunc(Icon, "SetPoint", function()
        if (Icon.IsUpdating) then
            return
        end

        Icon.IsUpdating = true
        Icon:ClearAllPoints()
        Icon.IsUpdating = false
    end)
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

    local ActiveIcons = Viewer:GetItemFrames()
    local VisibleIcons = self:GetShownViewerIcons(ActiveIcons)

    if (#VisibleIcons == 0) then 
        return 
    end

    for _, Icon in ipairs(VisibleIcons) do
        self:LockIconAnchor(Icon)
        Icon.IsUpdating = true
    end

    local ReversedIcons = {}

    for Index = #VisibleIcons, 1, -1 do
        ReversedIcons[#ReversedIcons + 1] = VisibleIcons[Index]
    end

    VisibleIcons = ReversedIcons

    local IconSpacing = AnchorData.IconSpacing
    local IconCount = #VisibleIcons
    local HasTwoCenters = IconCount % 2 == 0
    local LeftMiddle = HasTwoCenters and (IconCount / 2) or nil
    local RightMiddle = HasTwoCenters and (LeftMiddle + 1) or nil
    local Middle = not HasTwoCenters and math.ceil(IconCount / 2) or nil

    if (HasTwoCenters) then
        local LeftMiddleIcon = VisibleIcons[LeftMiddle]
        local RightMiddleIcon = VisibleIcons[RightMiddle]

        if (LeftMiddleIcon) then
            LeftMiddleIcon:ClearAllPoints()
            LeftMiddleIcon:Point("RIGHT", AnchorFrame, "CENTER", -IconSpacing / 2, 0)
        end

        if (RightMiddleIcon) then
            RightMiddleIcon:ClearAllPoints()
            RightMiddleIcon:Point("LEFT", AnchorFrame, "CENTER", IconSpacing / 2, 0)
        end
    else
        local MiddleIcon = VisibleIcons[Middle]

        if (MiddleIcon) then
            MiddleIcon:ClearAllPoints()
            MiddleIcon:Point("CENTER", AnchorFrame, "CENTER", 0, 0)
        end
    end

    local LeftStart = (HasTwoCenters and (LeftMiddle - 1)) or (Middle - 1)

    for i = LeftStart, 1, -1 do
        local Icon = VisibleIcons[i]
        local NextIcon = VisibleIcons[i + 1]

        if (Icon and NextIcon) then
            Icon:ClearAllPoints()
            Icon:Point("RIGHT", NextIcon, "LEFT", -IconSpacing, 0)
        end
    end

    local RightStart = (HasTwoCenters and (RightMiddle + 1)) or (Middle + 1)

    for i = RightStart, IconCount do
        local Icon = VisibleIcons[i]
        local NextIcon = VisibleIcons[i - 1]

        if (Icon and NextIcon) then
            Icon:ClearAllPoints()
            Icon:Point("LEFT", NextIcon, "RIGHT", IconSpacing, 0)
        end
    end

    for _, Icon in ipairs(VisibleIcons) do
        Icon.IsUpdating = false
    end
end

function CDM:UpdateAnchors()
    for Viewer, AnchorData in pairs(self.Anchors) do
        local AnchorFrame = AnchorData.Frame

        if (not AnchorFrame) then
            return
        end

        --Viewer:SetParent(AnchorFrame)
        --Viewer:ClearAllPoints()
        --Viewer:Point("CENTER", AnchorFrame, "CENTER", 0, 0)
    end
end

function CDM:UpdateEditMode()
	--self:UpdateAnchors()

    for Viewer in pairs(self.Anchors) do
        self:ApplyIconPositions(Viewer)
    end
end

function CDM:RegisterEditMode()
    if (not EditModeManager) then
        self:RegisterEvent("PLAYER_LOGIN")
        self:SetScript("OnEvent", function()
            self:UnregisterEvent("PLAYER_LOGIN")
            self:UpdateEditMode()
        end)

        return
    end

    if (EditModeManager.OnEditModeEnter) then
        hooksecurefunc(EditModeManager, "OnEditModeEnter", function()
            self:UpdateEditMode()
        end)
    end

    if (EditModeManager.OnEditModeExit) then
        hooksecurefunc(EditModeManager, "OnEditModeExit", function()
            self:UpdateEditMode()
        end)
    end

    local EditModeFuncs = {
        "Refresh",
        "RefreshAll",
        "RefreshEditMode",
        "OnEditModeStateChanged"
    }

    for _, func in ipairs(EditModeFuncs) do
        if (type(EditModeManager[func]) == "function") then
            hooksecurefunc(EditModeManager, func, function()
                self:UpdateEditMode()
            end)
        end
    end

    if (EditModeManager.RegisterCallback) then
        pcall(function()
            EditModeManager:RegisterCallback("EditMode.Enter", function()
            	self:UpdateEditMode()
            end)

            EditModeManager:RegisterCallback("EditMode.Exit", function()
            	self:UpdateEditMode()
            end)
        end)
    end
end

function CDM:HookViewers(Viewer)
    if (not Viewer) then
    	return
    end

    hooksecurefunc(Viewer, "Layout", function()
        self:ApplyIconPositions(Viewer)
    end)

    --hooksecurefunc(Viewer, "SetPoint", function()
    --  self:ApplyIconPositions(Viewer)
    --end)
end

function CDM:UpdateAllHooks(Viewer)
	for _, Viewer in ipairs(self.Viewers) do
        self:HookViewers(Viewer)
    end
end

function CDM:UpdateLayout()
	self:PositionContainers()
	self:UpdateAllHooks()
	self:RegisterEditMode()
	--self:UpdateAnchors()
end