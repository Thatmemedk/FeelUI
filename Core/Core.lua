local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local type = type
local match = string.match
local min, max = math.min, math.max
local floor = math.floor

-- WoW Globals
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetPhysicalScreenSize = GetPhysicalScreenSize
local Resolution = select(1, GetPhysicalScreenSize()).."x"..select(2, GetPhysicalScreenSize())
local PixelPerfectScale = 768 / match(Resolution, "%d+x(%d+)")
local SetCVar = C_CVar.SetCVar

-- Tables
UI.Modules = {}

-- LIBS
do
	UI.Libs = {}
	UI.LibsMinor = {}
	
	function UI:AddLib(Name, Major, Minor)
		if (not Name) then 
			return 
		end

		if (type(Major) == "table" and type(Minor) == "number") then
			UI.Libs[Name], UI.LibsMinor[Name] = Major, Minor
		else
			UI.Libs[Name], UI.LibsMinor[Name] = _G.LibStub(Major, Minor)
		end
	end
	
	UI:AddLib("LDB", "LibDataBroker-1.1")
	UI:AddLib("LDBI", "LibDBIcon-1.0")
	UI:AddLib("LSM", "LibSharedMedia-3.0")
end

-- REGISTER MODULE
function UI:RegisterModule(Name)
	if (self.Modules[Name]) then
		return self.Modules[Name]
	end

	local Module = CreateFrame("Frame", Name, _G.UIParent)
	Module.Name = Name
	Module.Initialized = false

	self.Modules[Name] = Module
	self.Modules[#self.Modules + 1] = Module

	return Module
end

-- CALL MODULE
function UI:CallModule(Name)
	if (self.Modules[Name]) then
		return self.Modules[Name]
	end
end

-- LOAD MODULE
function UI:LoadModules()
	for Index = 1, #self.Modules do
		if (self.Modules[Index].Initialize and not self.Modules[Index].Initialized) then
			self.Modules[Index]:Initialize()
			self.Modules[Index].Initialized = true
		end
	end
end

-- ADDON LOADED
function UI:ADDON_LOADED(event, addon)
	if (addon ~= "FeelUI" and addon ~= "FeelUI_Options") then
		return
	end
	
	self:LoadDB()
	self:UnregisterEvent(event)
end

-- PLAYER LOGIN
function UI:PLAYER_LOGIN(event)
	local Scale = max(DB.Global.General.UIScaleMin, min(1.15, DB.Global.General.UIScaleMax))

	if (DB.Global.General.UseUIScale) then
		SetCVar("useUiScale", 1)
		SetCVar("uiScale", Scale)
	end

	if (GetAddOnEnableState(UI.MyName, "ElvUI") == 2) then
		UI:Print(Language.ElvUI.Print)
		StaticPopup_Show("ELVUI_INCOMPATIBLE")
	elseif (GetAddOnEnableState(UI.MyName, "Tukui") == 2) then
		UI:Print(Language.Tukui.Print)
		StaticPopup_Show("TUKUI_INCOMPATIBLE")
	elseif not (IsAddOnLoaded("Tukui") or IsAddOnLoaded("ElvUI") or IsAddOnLoaded("FeelUI_PowerSuite")) then
		self:LoadModules()
	end
	
	self:UnregisterEvent(event)
end

function UI:Scale(x)
	local Mult = PixelPerfectScale / GetCVar("uiScale")
	return Mult * floor(x / Mult + 0.5)
end

-- ON EVENT
function UI:OnEvent(event, ...)
	if (self[event]) then
		self[event](self, event, ...)
	end
end

UI:RegisterEvent("PLAYER_LOGIN")
UI:RegisterEvent("ADDON_LOADED")
UI:SetScript("OnEvent", UI.OnEvent)