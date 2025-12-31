local UI, DB, Media, Language = select(2, ...):Call()

local MyRealm = GetRealmName()
local MyName = UnitName("player")
local MyClass = select(2, UnitClass("player"))
local MyLevel = UnitLevel("player")

if (MyClass == "MAGE" or MyClass == "WARLOCK" or MyClass == "PALADIN") then
	DB.Global.DataBars.PowerBar = false
end