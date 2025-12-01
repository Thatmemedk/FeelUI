local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local type = type

-- WoW Globals
local C_AddOns_GetAddOnEnableState = C_AddOns.GetAddOnEnableState
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

-- Locals
UI.Modules = {}

-- LIBS
do
	UI.Libs = {}
	UI.LibsMinor = {}
	
	function UI:AddLib(Name, Major, Minor)
		if not (Name) then 
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
	if (C_AddOns_GetAddOnEnableState(UI.MyName, "ElvUI") == 2) then
		UI:Print(Language.ElvUI.Print)
		StaticPopup_Show("ELVUI_INCOMPATIBLE")
	elseif (C_AddOns_GetAddOnEnableState(UI.MyName, "Tukui") == 2) then
		UI:Print(Language.Tukui.Print)
		StaticPopup_Show("TUKUI_INCOMPATIBLE")
	elseif not (IsAddOnLoaded("Tukui") or IsAddOnLoaded("ElvUI") or IsAddOnLoaded("FeelUI_PowerSuite")) then
		self:LoadModules()
	end
	
	self:UnregisterEvent(event)
end

-- ON EVENT
function UI:OnEvent(event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
end

UI:RegisterEvent("PLAYER_LOGIN")
UI:RegisterEvent("ADDON_LOADED")
UI:SetScript("OnEvent", UI.OnEvent)