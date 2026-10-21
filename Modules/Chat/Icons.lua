local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local CH = UI:CallModule("Chat")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local type = type
local tonumber = tonumber
local format = format
local floor = floor
local gsub = string.gsub

-- Locals
local DummyFrame = {}
local DummyTexture = {}
local CoordCache = {}

-- Locals
CH.ItemIcons = true
CH.SpellIcons = true
CH.LinkIconWidth = 18
CH.LinkIconHeight = 12
CH.TexDim = 256

CH.LinkIcons = {
	item = function(ID) return C_Item.GetItemIconByID(ID) end,
	spell = function(ID) return C_Spell.GetSpellTexture(ID) end,
}

function DummyFrame:GetWidth()
	return CH.LinkIconWidth
end

function DummyFrame:GetHeight()
	return CH.LinkIconHeight
end

function DummyTexture:SetTexCoord(Left, Right, Top, Bottom)
	self.Left, self.Right, self.Top, self.Bottom = Left, Right, Top, Bottom
end

function CH:GetCoords()
	local Zoom = DB.Global.General.IconZoom[1]
	local Width = CH.LinkIconWidth
	local Height = CH.LinkIconHeight
	local Key = Zoom .. ":" .. Width .. ":" .. Height
	local Cached = CoordCache[Key]

	if (not Cached) then
		UI:KeepAspectRatio(DummyFrame, DummyTexture)

		Cached = format("%d:%d:%d:%d:%d:%d:%d:%d:%d:%d", Height, Width, 0, 0, CH.TexDim, CH.TexDim, 
			floor(DummyTexture.Left * CH.TexDim + 0.5), 
			floor(DummyTexture.Right * CH.TexDim + 0.5), 
			floor(DummyTexture.Top * CH.TexDim + 0.5), 
			floor(DummyTexture.Bottom * CH.TexDim + 0.5)
		)

		CoordCache[Key] = Cached
	end

	return Cached
end

local function AddLinkIcon(Start, Kind, ID, Label, Close)
	if ((Kind == "item" and not CH.ItemIcons) or (Kind == "spell" and not CH.SpellIcons)) then
		return
	end

	local GetIcon = CH.LinkIcons[Kind]
	local Icon = GetIcon and GetIcon(tonumber(ID))

	if (not Icon or Label:find("|T", 1, true)) then
		return
	end

	return format("%s|T%s:%s|t %s%s", Start, Icon, CH:GetCoords(), Label, Close)
end

function CH:AddLinkIcons(event, msg, ...)
	if (type(msg) ~= "string" or #msg > 4096) then
		return
	end

	local NewMsg, Found = gsub(msg, "(|H(%a+):(%d+)[^|]*|h)(%[.-%])(|h)", AddLinkIcon)

	if (NewMsg ~= msg) then
		return false, NewMsg, ...
	end
end

local LinkIcon_Events = {
	"CHAT_MSG_LOOT",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
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
	"CHAT_MSG_COMMUNITIES_CHANNEL",
}

function CH:EnableIcons()
	for _, Events in pairs(LinkIcon_Events) do
		ChatFrameUtil.AddMessageEventFilter(Events, CH.AddLinkIcons)
	end
end