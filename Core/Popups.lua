local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local InCombatLockdown = InCombatLockdown
local UnitInRaid = UnitInRaid
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UninviteUnit = UninviteUnit
local UnitExists = UnitExists
local PartyInfoLeaveParty = _G.C_PartyInfo.LeaveParty

local function DisbandRaidGroup()
	if (InCombatLockdown()) then 
		return 
	end

	if (UnitInRaid("player")) then
		for i = 1, GetNumGroupMembers() do
			local Name, _, _, _, _, _, _, Online = GetRaidRosterInfo(i)
			
			if (Online and Name ~= UI.MyName) then
				UninviteUnit(Name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if (UnitExists("party"..i)) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end

	PartyInfoLeaveParty()
end

StaticPopupDialogs["DISBAND_RAID"] = {
	text = Language.Group.Confirm,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() DisbandRaidGroup() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
}

StaticPopupDialogs["ELVUI_INCOMPATIBLE"] = {
	text = Language.ElvUI.Enabled,
	OnAccept = function() DisableAddOn("ElvUI") DisableAddOn("ElvUI_Options") DisableAddOn("ElvUI_Libraries") ReloadUI() end,
	button1 = Language.ElvUI.Disabled,
	whileDead = 1,
	hideOnEscape = false,
}

StaticPopupDialogs["TUKUI_INCOMPATIBLE"] = {
	text = Language.Tukui.Enabled,
	OnAccept = function() DisableAddOn("Tukui") ReloadUI() end,
	button1 = Language.Tukui.Disabled,
	whileDead = 1,
	hideOnEscape = false,
}

StaticPopupDialogs["ELLESMERESUI_INCOMPATIBLE"] = {
	text = Language.EllesmeresUI.Enabled,
	OnAccept = function() DisableAddOn("EllesmeresUI") ReloadUI() end,
	button1 = Language.EllesmeresUI.Disabled,
	whileDead = 1,
	hideOnEscape = false,
}