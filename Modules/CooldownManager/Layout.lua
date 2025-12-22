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

function CDM:CreateContainers(Viewer, Point, Anchor, X, Y, IconSpacing)
    if (not Viewer) then 
        return 
    end

    local AnchorFrame = CreateFrame("Frame", nil, _G.UIParent)
    AnchorFrame:Point(Point, Anchor, X or 0, Y or 0)
    AnchorFrame:Size(unpack(DB.Global.CooldownManager.ButtonSize))

    self.Anchors[Viewer] = {
        Frame = AnchorFrame,
        IconSpacing = IconSpacing
    }

    return AnchorFrame
end

function CDM:PositionContainers()
	local EssentialContainer = self:CreateContainers(EssentialCooldownViewer, "CENTER", _G.UIParent, 0, -136, 2)
    local BuffContainer = self:CreateContainers(BuffIconCooldownViewer, "BOTTOM", EssentialContainer, 0, -24, 2)
    local UtilityContainer = self:CreateContainers(UtilityCooldownViewer, "BOTTOM", BuffContainer, 0, -24, 2)
end

function CDM:ForceLayoutUpdate(Viewer)
	if (not Viewer or not Viewer.layoutFrame) then
		return
	end

	if InCombatLockdown() then
		return
	end

	Viewer.layoutFrame:MarkDirty()

	if (Viewer.layoutFrame.Layout) then
		Viewer.layoutFrame:Layout()
	end
end

function CDM:ApplyIconPositions(Viewer)
    if (not Viewer or not self.Anchors[Viewer]) then
        return
    end

    if InCombatLockdown() then
        return
    end

    local AnchorData = self.Anchors[Viewer]
    local AnchorFrame = AnchorData.Frame

    if (not AnchorFrame) then
        return
    end

    local Container = Viewer.viewerFrame or Viewer
    local Icons = {}

    for _, Child in ipairs({ Container:GetChildren() }) do
        if Child:IsShown() then
            Icons[#Icons + 1] = Child
        end
    end

    if (#Icons == 0) then
        return
    end

    local First = Icons[1]
    local Width = First:GetWidth()
    local Spacing = AnchorData.IconSpacing
    local TotalWidth = (#Icons * Width) + ((#Icons - 1) * Spacing)
    local StartX = -TotalWidth / 2 + Width / 2

    for i, Icon in ipairs(Icons) do
        Icon:ClearAllPoints()
        Icon:Point("CENTER", AnchorFrame, "CENTER", StartX + (i - 1) * (Width + Spacing), 0)
    end
end

function CDM:UpdateAnchors()
	if InCombatLockdown() then 
		return 
	end

    for Viewer, AnchorData in pairs(self.Anchors) do
        local AnchorFrame = AnchorData.Frame

        if (not AnchorFrame) then
            return
        end

        Viewer:SetParent(AnchorFrame)
        Viewer:ClearAllPoints()
        Viewer:Point("CENTER", AnchorFrame, "CENTER", 0, 0)
    end
end

function CDM:UpdateIconsLayout(Viewer)
    if not Viewer or InCombatLockdown() then 
    	return 
    end

    self:ApplyIconPositions(Viewer)
    self:ForceLayoutUpdate(Viewer)
end

function CDM:UpdateEditMode()
	self:UpdateAnchors()

    for Viewer in pairs(self.Anchors) do
        self:UpdateIconsLayout(Viewer)
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

    hooksecurefunc(Viewer, "Layout", function() self:UpdateIconsLayout(Viewer) end)
    hooksecurefunc(Viewer, "SetSize", function() self:UpdateIconsLayout(Viewer) end)
    hooksecurefunc(Viewer, "SetPoint", function() self:UpdateIconsLayout(Viewer) end)
    hooksecurefunc(Viewer, "SetParent", function() self:UpdateIconsLayout(Viewer) end)
end

function CDM:UpdateAllHooks(Viewer)
	for _, Viewer in ipairs(self.Viewers) do
        self:HookViewers(Viewer)
    end
end

function CDM:DeferredEditModeUpdate()
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    self:UpdateEditMode()
end

function CDM:OnEvent(event)
    if (event == "PLAYER_ENTERING_WORLD") then
        self:DeferredEditModeUpdate()

    elseif (event == "EDIT_MODE_LAYOUTS_UPDATED") then
        self:DeferredEditModeUpdate()

    elseif (event == "PLAYER_PVP_TALENT_UPDATE" or event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED") then
        C_Timer.After(0.5, function()
            self:DeferredEditModeUpdate()
        end)

    elseif (event == "PLAYER_REGEN_ENABLED") then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:UpdateEditMode()
    end
end

function CDM:RunAfterEditMode(RunNow)
    if (not C_EditMode) then
        return
    end

    local Func = function()
        self:DeferredEditModeUpdate()
    end

    hooksecurefunc(C_EditMode, "OnEditModeExit", Func)
    hooksecurefunc(C_EditMode, "SetActiveLayout", Func)

    if (RunNow) then
        Func()
    end
end

function CDM:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
    self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
    self:SetScript("OnEvent", self.OnEvent)
end

function CDM:UpdateLayout()
	self:PositionContainers()
	self:UpdateAllHooks()
	--self:RegisterEditMode()
	self:UpdateAnchors()
    self:RegisterEvents()
    self:RunAfterEditMode(true)
end