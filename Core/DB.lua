local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local pairs = pairs
local tonumber = tonumber
local type = type
local format = string.format
local gsub = string.gsub
local split = string.split

-- Locals
local MyVersion = UI.Version
local MyClass = UI.MyClass
local MyRegion = UI.MyRegion
local Name = UI.MyName
local Realm = UI.MyRealm

-- DATA BASE

function UI:LoadDB()
	if (not FeelDB) then
		FeelDB = {}
	end

	if (not FeelDB[Realm]) then
		FeelDB[Realm] = {}
	end

	if (not FeelDB[Realm][Name]) then
		FeelDB[Realm][Name] = {}
	end
	
	if (not FeelDB[Realm][Name].Install) then
		FeelDB[Realm][Name].Install = {}
	end
end

function UI:ResetDB()
	if (not FeelDB) then
		return
	end

	FeelDB = nil
	FeelDB = {}
	FeelDB[Realm] = {}
	FeelDB[Realm][Name] = {}
end