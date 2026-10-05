local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AutoInvite = UI:RegisterModule("AutoInvite")

-- Lib Globals
local _G = _G
local pairs = pairs
local select = select
local gmatch = string.gmatch
local lower = string.lower
local match = string.match

-- WoW Globals
local C_BattleNet = _G.C_BattleNet
local C_FriendList = _G.C_FriendList
local AcceptGroup = _G.AcceptGroup
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumGuildMembers = _G.GetNumGuildMembers
local InviteUnit = _G.InviteUnit
local IsInGuild = _G.IsInGuild
local IsInGroup = _G.IsInGroup
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

-- WoW Globals
local QueueStatusButton = _G.QueueStatusButton
local MiniMapLFGFrame = _G.MiniMapLFGFrame
local MiniMapBattlefieldFrame = _G.MiniMapBattlefieldFrame
local LFGInvitePopup = _G.LFGInvitePopup

-- Tables
AutoInvite.List = {}
AutoInvite.KeyWords = "inv, invite"
AutoInvite.HideStatic = false

for Word in gmatch(AutoInvite.KeyWords or "", "[^,]+") do
    Word = match(Word, "^%s*(.-)%s*$")

    if (Word ~= "") then
        AutoInvite.List[lower(Word)] = true
    end
end

function AutoInvite:GetQueueStatusButton()
    return QueueStatusButton or MiniMapLFGFrame or MiniMapBattlefieldFrame
end

function AutoInvite:IsGuildMember(GUID)
    if (not GUID or not IsInGuild()) then
        return false
    end

    for Index = 1, GetNumGuildMembers() do
        local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, MemberGUID = GetGuildRosterInfo(Index)

        if (MemberGUID == GUID) then
            return true
        end
    end

    return false
end

function AutoInvite:IsAllowed(GUID)
    if (not GUID) then
        return false
    end

    return C_BattleNet.GetGameAccountInfoByGUID(GUID) or C_FriendList.IsFriend(GUID) or self:IsGuildMember(GUID)
end

function AutoInvite:AcceptInvite()
    self.HideStatic = true
    AcceptGroup()
end

function AutoInvite:OnInvite(Name, _, _, _, _, _, InviterGUID)
    if (not InviterGUID or IsInGroup()) then
        return
    end

    local QueueButton = self:GetQueueStatusButton()

    if (QueueButton and QueueButton:IsShown()) then
        return
    end

    if (self:IsAllowed(InviterGUID)) then
        self:AcceptInvite()
    end
end

function AutoInvite:OnGroupRosterUpdate()
    if (not self.HideStatic) then
        return
    end

    if (LFGInvitePopup) then
        StaticPopupSpecial_Hide(LFGInvitePopup)
    end

    StaticPopup_Hide("PARTY_INVITE")

    self.HideStatic = false
end

function AutoInvite:HasKeyword(Message)
    Message = lower(Message or "")

    for Word in pairs(self.List) do
        if (Message:find(Word, 1, true)) then
            return true
        end
    end

    return false
end

function AutoInvite:CanInvite()
    if (UnitExists("party1") and not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player")) then
        return false
    end

    local QueueButton = self:GetQueueStatusButton()

    return not QueueButton or not QueueButton:IsShown()
end

function AutoInvite:OnWhisper(Message, Sender, GUID)
    if (not self:CanInvite() or not self:HasKeyword(Message)) then
        return
    end

    if (C_FriendList.IsFriend(GUID) or self:IsGuildMember(GUID)) then
        InviteUnit(Sender)
    end
end

function AutoInvite:OnBattleNetWhisper(Message, _, _, _, _, _, _, _, _, AccountID)
    if (not self:CanInvite() or not self:HasKeyword(Message)) then
        return
    end

    local AccountInfo = C_BattleNet.GetAccountInfoByID(AccountID)
    local GameAccountInfo = AccountInfo and AccountInfo.gameAccountInfo

    if (GameAccountInfo and GameAccountInfo.gameAccountID) then
        C_BattleNet.InviteFriend(GameAccountInfo.gameAccountID)
    end
end

function AutoInvite:OnEvent(event, ...)
    if (event == "PARTY_INVITE_REQUEST") then
        self:OnInvite(...)
    elseif (event == "GROUP_ROSTER_UPDATE") then
        self:OnGroupRosterUpdate()
    elseif (event == "CHAT_MSG_WHISPER") then
        local Message, Sender, _, _, _, _, _, _, _, _, _, GUID = ...
        self:OnWhisper(Message, Sender, GUID)
    elseif (event == "CHAT_MSG_BN_WHISPER") then
        self:OnBattleNetWhisper(...)
    end
end

function AutoInvite:RegisterEvents()
    self:RegisterEvent("PARTY_INVITE_REQUEST")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("CHAT_MSG_BN_WHISPER")
    self:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end)
end

function AutoInvite:Initialize()
    self:RegisterEvents()
end