local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:RegisterModule("CooldownManager")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

-- Locals
CDM.Anchors = {}

-- Locals
CDM.Viewers = {
    EssentialCooldownViewer,
    BuffIconCooldownViewer,
    UtilityCooldownViewer,
}

function CDM:Initialize()
	if (not DB.Global.CooldownManager.Enable) then
		return
	end

	if not IsAddOnLoaded("Blizzard_CooldownViewer") then
		LoadAddOn("Blizzard_CooldownViewer")
	end

	self:UpdateIcons()
	self:UpdateLayout()
end