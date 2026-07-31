local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CH = UI:CallModule("Chat")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local tonumber = tonumber
local gsub = string.gsub
local strfind = string.find
local format = string.format
local strsub = string.sub
local strlen = string.len
local strupper = string.upper
local BetterDate = BetterDate
local RemoveExtraSpaces = RemoveExtraSpaces

--- Locals
CH.Lines = {}
CH.Lines.Count = 0
CH.Lines.Max = 200

local CanChangeMessage = function(Arg1, ID)
	if (ID and Arg1 == "") then 
		return ID 
	end
end

function CH:MessageIsProtected(Msg)
	if (UI:IsSecretValue(Msg)) then 
		return true 
	end

	return Msg and (Msg ~= gsub(Msg, "(:?|?)|K(.-)|k", CanChangeMessage))
end

function CH:GetChatTarget(ChatGroup, PlayerTarget, ChannelTarget)
	if (ChatGroup == "CHANNEL") then
		return tostring(ChannelTarget)
	elseif (ChatGroup == "WHISPER" or ChatGroup == "BN_WHISPER") then
		return PlayerTarget and strsub(PlayerTarget, 1, 2) ~= "|K" and strupper(PlayerTarget) or PlayerTarget
	end
end

function CH:FilterChatMessages(Frame, Event, Msg, Sender, Language, ChannelString, Target, Flags, ZoneChannelID, ChannelIndex, ChannelBaseName, LanguageID, LineID, SenderGUID, BNSenderID, IsMobile, _, _, SuppressRaidIcons)
	local IsProtected = CH:MessageIsProtected(Msg)

	if (not IsProtected and (strmatch(Msg, "^%s*$") or strmatch(Msg, "^|Helvtime|h") or strmatch(Msg, "^|Hcpl:"))) then
		return Msg
	end

	ChannelString = ChannelString or ""
	ChannelBaseName = ChannelBaseName or ""

	if (type(LineID) == "number" and LineID > 0) then
		local Key = (Frame:GetName() or "UnknownFrame") .. "_" .. LineID

		if (CH.Lines[Key]) then
			return true
		end

		CH.Lines[Key] = true
		CH.Lines.Count = (tonumber(CH.Lines.Count) or 0) + 1

		if ((tonumber(CH.Lines.Count) or 0) > (tonumber(CH.Lines.Max) or 200)) then
			wipe(CH.Lines)

			CH.Lines.Count = 0
			CH.Lines.Max = CH.Lines.Max or 200
		end
	end

	local ChatType = strsub(Event or "", 10)
	local ChatGroup = _G.ChatFrameUtil.GetChatCategory(ChatType)
	local ChannelLength = strlen(ChannelString)
	local ChatTarget

	-- Channel Filtering
	if (ChatType == "CHANNEL") then
		if (ChannelLength > 0) then
			local Found = false

			for Index, Value in pairs(Frame.channelList or {}) do
				if (type(Value) == "string") then
					local ValueLen = strlen(Value) or 0

					if (ChannelLength > ValueLen) then
						local ZoneMatch = false

						if (type(ZoneChannelID) == "number" and ZoneChannelID > 0 and Frame.zoneChannelList and Frame.zoneChannelList[Index] ~= nil) then
							ZoneMatch = (Frame.zoneChannelList[Index] == ZoneChannelID)
						end

						local NameMatch = (strupper(Value) == strupper(ChannelBaseName))

						if (ZoneMatch or NameMatch) then
							Found = true

							break
						end
					end
				end
			end

			if (not Found) then
				return true
			end
		end
	else
		ChatTarget = CH:GetChatTarget(ChatGroup, Sender, ChannelIndex)

		if (_G.FCFManager_ShouldSuppressMessage(Frame, ChatGroup, ChatTarget)) then
			return true
		end
	end

	-- Chat Info
	local Info

	if (type(ChannelIndex) == "number" and ChannelIndex > 0) then
		Info = ChatTypeInfo["CHANNEL" .. ChannelIndex] or ChatTypeInfo[ChatType]
	else
		Info = ChatTypeInfo[ChatType]
	end

	Info = Info or ChatTypeInfo.SYSTEM

	local FormatKey = _G["CHAT_" .. ChatType .. "_GET"]

	if (not FormatKey) then
		return
	end

	-- Name + Link
	local ColoredName = _G.ChatFrameUtil.GetDecoratedSenderName(
		Event,
		Msg,
		Sender,
		Language,
		ChannelString,
		Target,
		Flags,
		ZoneChannelID,
		ChannelIndex,
		ChannelBaseName,
		LanguageID,
		LineID,
		SenderGUID,
		BNSenderID,
		IsMobile
	)

	local PFlag = _G.ChatFrameUtil.GetPFlag(Flags, ZoneChannelID, ChannelIndex) or ""
	local PlayerLink

	if (ChatType == "BN_WHISPER" or ChatType == "BN_WHISPER_INFORM") then
		PlayerLink = _G.GetBNPlayerLink(Sender, "[" .. ColoredName .. "]", BNSenderID, LineID, ChatGroup, 0)
	else
		PlayerLink = _G.GetPlayerLink(Sender, "[" .. ColoredName .. "]", LineID, ChatGroup, 0)
	end

	PlayerLink = PlayerLink or Sender or ""

	-- Message Processing
	Msg = Msg or ""
	Msg = gsub(Msg, "%%", "%%%%")
	Msg = _G.C_ChatInfo.ReplaceIconAndGroupExpressions(Msg, SuppressRaidIcons)

	if (RemoveExtraSpaces) then
		Msg = RemoveExtraSpaces(Msg)
	end

	Msg = CH:ConvertURLs(Msg)

	local OutMsg = format(FormatKey .. Msg, PFlag .. PlayerLink)

	-- Channel Prefix
	if (ChannelLength > 0) then
		local ChannelName = _G.ChatFrameUtil.ResolvePrefixedChannelName(ChannelString)

		if (ChannelName) then
			OutMsg = "|Hchannel:channel:" .. (ChannelIndex or 0) .. "|h[" .. ChannelName .. "]|h " .. OutMsg
		end
	end

	-- Timestamp
	if (DB.Global.Chat.TimeStamps) then
		local TimeStamp = "|cff909090" .. BetterDate("[%H:%M:%S]") .. "|r "
		OutMsg = TimeStamp .. OutMsg
	end

	Frame:AddMessage(OutMsg, Info.r or 1, Info.g or 1, Info.b or 1, Info.id)

	-- Whisper Handling
	if (ChatType == "WHISPER" or ChatType == "BN_WHISPER") then
		_G.ChatFrameUtil.SetLastTellTarget(Sender, ChatType)

		if (not Frame.tellTimer or GetTime() > Frame.tellTimer) then
			PlaySound(SOUNDKIT.TELL_MESSAGE)
		end

		Frame.tellTimer = GetTime() + _G.ChatFrameConstants.WhisperSoundAlertCooldown

		if (FlashClientIcon) then
			FlashClientIcon()
		end
	end

	_G.ChatFrameUtil.FlashTabIfNotShown(Frame, Info, ChatType, ChatGroup, ChatTarget)

	return true
end

function CH:AddChatFilter()
	local Events = {
		"CHAT_MSG_SAY",
		"CHAT_MSG_YELL",
		"CHAT_MSG_EMOTE",
		"CHAT_MSG_AFK",
		"CHAT_MSG_DND",
		"CHAT_MSG_CHANNEL",
		"CHAT_MSG_WHISPER",
		"CHAT_MSG_WHISPER_INFORM",
		"CHAT_MSG_BN_WHISPER",
		"CHAT_MSG_BN_WHISPER_INFORM",
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
		"CHAT_MSG_COMMUNITIES_CHANNEL",
		"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	}

	for _, Event in ipairs(Events) do
		_G.ChatFrame_AddMessageEventFilter(Event, function(...)
			return CH:FilterChatMessages(...)
		end)
	end
end