local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local CH = UI:CallModule("Chat")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local type = type
local gsub = gsub
local strsub = strsub

function CH:PrintURL(url)
	url = "|cff00aaff|Hurl:"..url.."|h"..url.."|h|r "
	return url
end

function CH:FindURL(event, msg, ...)
	local NewMsg, Found = gsub(msg, "(%a+)://(%S+)%s?", CH:PrintURL("%1://%2"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", CH:PrintURL("www.%1.%2"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", CH:PrintURL("%1@%2%3%4"))

	if (Found > 0) then
		return false, NewMsg, ...
	end
end

local FindURL_Events = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_AFK",
	"CHAT_MSG_DND",
	"CHAT_MSG_COMMUNITIES_CHANNEL",
}

function CH:EnableURL()
	for _, event in pairs(FindURL_Events) do
		_G.ChatFrame_AddMessageEventFilter(event, CH[event] or CH.FindURL)
	end

	local CurrentLink = nil
	local SetHyperlink = ItemRefTooltip.SetHyperlink

	ItemRefTooltip.SetHyperlink = function(self, data, ...)
		if (strsub(data, 1, 3) == "url") then
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()

			CurrentLink = (data):sub(5)

			if (not ChatFrameEditBox:IsShown()) then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end

			ChatFrameEditBox:Insert(CurrentLink)
			ChatFrameEditBox:HighlightText()
			CurrentLink = nil
		else
			SetHyperlink(self, data, ...)
		end
	end
end