-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local CreateFrame = CreateFrame
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local GetPhysicalScreenSize = GetPhysicalScreenSize
local Windowed = Display_DisplayModeDropDown and Display_DisplayModeDropDown:windowedmode()
local Fullscreen = Display_DisplayModeDropDown and Display_DisplayModeDropDown:fullscreenmode()
local GetCVar = GetCVar
local GetBuildInfo = GetBuildInfo
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local GetRealmName = GetRealmName
local UnitFactionGroup = UnitFactionGroup
local GetLocale = GetLocale
local WOW_PROJECT_ID = _G.WOW_PROJECT_ID

-- Build The Engine
local AddOnName, Engine = ...

Engine[1] = CreateFrame("Frame", nil, _G.UIParent)
Engine[2] = {} -- DB
Engine[3] = {} -- Media
Engine[4] = {} -- Language

-- FeelUI
Engine[1].Title = GetAddOnMetadata(AddOnName, "Title")
Engine[1].Version = GetAddOnMetadata(AddOnName, "Version")
-- System
Engine[1].ScreenWidth, Engine[1].ScreenHeight = GetPhysicalScreenSize()
Engine[1].ScreenResolution = Resolution or (Windowed and GetCVar("gxWindowedResolution")) or GetCVar("gxFullscreenResolution")
-- WoW Patches
Engine[1].WoWPatch, Engine[1].WoWBuild, Engine[1].WoWPatchReleaseDate, Engine[1].TocVersion = GetBuildInfo()
-- WoW Clients	
Engine[1].Retail = WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
Engine[1].TBC = WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
Engine[1].Classic = WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
-- Player
Engine[1].MyName = UnitName("player")
Engine[1].MyClass = select(2, UnitClass("player"))
Engine[1].MyLocalizedRace, Engine[1].MyRace = UnitRace("player")
Engine[1].MyLevel = UnitLevel("player")
Engine[1].MyRealm = GetRealmName()
Engine[1].MyFaction = select(2, UnitFactionGroup("player"))
Engine[1].MyRegion = GetLocale()

-- Load Engine
function Engine:Call()
	return self[1], self[2], self[3], self[4]
end

_G[AddOnName] = Engine