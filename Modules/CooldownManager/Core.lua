local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:RegisterModule("CooldownManager")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer
local SetCVar = _G.C_CVar.SetCVar
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local LoadAddOn = _G.C_AddOns.LoadAddOn

-- Locals
CDM.Anchors = {}
CDM.ViewerHooks = {}

-- Locals
CDM.Viewers = {
    EssentialCooldownViewer,
    BuffIconCooldownViewer,
    UtilityCooldownViewer,
}

function CDM:SetCVarOnLogin()
	SetCVar("cooldownViewerEnabled", 1)
end

function CDM:Initialize()
	if (not DB.Global.CooldownManager.Enable) then
		return
	end

	if (not IsAddOnLoaded("Blizzard_CooldownViewer")) then
		LoadAddOn("Blizzard_CooldownViewer")
	end
	
	self:UpdateLayout()
	self:UpdateIcons()
	self:SetCVarOnLogin()
end