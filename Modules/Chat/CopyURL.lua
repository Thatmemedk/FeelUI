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

function CH:PrintURL(Url)
	return "|cff00aaff|Hurl:" .. Url .. "|h" .. Url .. "|h|r "
end

function CH:ConvertURLs(Msg)
	local NewMsg, Found

	NewMsg, Found = gsub(Msg, "(%a+)://(%S+)%s?", function(Protocol, Path)
		return CH:PrintURL(Protocol .. "://" .. Path)
	end)

	if (Found > 0) then
		Msg = NewMsg
	end

	NewMsg, Found = gsub(Msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", function(Domain, TLD)
		return CH:PrintURL("www." .. Domain .. "." .. TLD)
	end)

	if (Found > 0) then
		Msg = NewMsg
	end

	NewMsg, Found = gsub(Msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", function(A, B, C, D)
		return CH:PrintURL(A .. "@" .. B .. C .. D)
	end)

	if (Found > 0) then
		Msg = NewMsg
	end

	return Msg
end

function CH:EnableCopyURL()
	local CurrentLink
	local SetHyperlink = ItemRefTooltip.SetHyperlink

	ItemRefTooltip.SetHyperlink = function(self, Data, ...)
		if (strsub(Data, 1, 3) == "url") then
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()

			CurrentLink = Data:sub(5)

			if (not ChatFrameEditBox:IsShown()) then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end

			ChatFrameEditBox:Insert(CurrentLink)
			ChatFrameEditBox:HighlightText()

			CurrentLink = nil
		else
			SetHyperlink(self, Data, ...)
		end
	end
end