local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local RU = UI:RegisterModule("RaidUtility")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local C_PartyInfo = _G.C_PartyInfo
local InCombatLockdown = InCombatLockdown
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant

function RU:CreateButton(Name, Parent, Template, Width, Height, Point, RelativeTo, RelativePoint, X, Y, Text)
    local Button = CreateFrame("Button", Name, Parent, Template)
    Button:Size(Width, Height)
    Button:Point(Point, RelativeTo, RelativePoint, X, Y)
    Button:HandleButton()

    if (Text) then
        Button.Text = Button:CreateFontString(nil, "OVERLAY")
        Button.Text:SetFontTemplate("Default")
        Button.Text:Point("CENTER")
        Button.Text:SetText(Text)
    end

    return Button
end

function RU:CheckRaidStatus()
    local InInstance, InstanceType = IsInInstance()

    if (InInstance and (InstanceType == "pvp" or InstanceType == "arena")) then
        return false
    end

    if (IsInRaid()) then
        return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
    end

    if (IsInGroup()) then
        return UnitIsGroupLeader("player")
    end

    return false
end

function RU:UpdateVisibility()
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility")
        return
    end

    self:UnregisterEvent("PLAYER_REGEN_ENABLED")

    local Visible = self:CheckRaidStatus()
    local Expanded = Visible and RaidUtilityPanel.toggled

    RaidUtilityShowButton:SetShown(Visible and not Expanded)
    RaidUtilityPanel:SetShown(Expanded)
end

function RU:ShowPanel()
    RaidUtilityPanel.toggled = true
end

function RU:ClosePanel()
    RaidUtilityPanel.toggled = false
end

function RU:DisbandGroup()
    StaticPopup_Show("DISBAND_RAID")
end

function RU:StartRoleCheck()
    InitiateRolePoll()
end

function RU:StartReadyCheck()
    DoReadyCheck()
end

function RU:ConvertGroup()
    if (UnitInRaid("player")) then
        C_PartyInfo.ConvertToParty()
    elseif (UnitInParty("player")) then
        C_PartyInfo.ConvertToRaid()
    end
end

function RU:StartCountdown()
    if (C_PartyInfo.DoCountdown) then
        C_PartyInfo.DoCountdown(10)
    end
end

function RU:CreateButtons()
    local Anchor = CreateFrame("Frame", "RaidUtilityAnchor", _G.UIParent)
    Anchor:Size(124, 25)
    Anchor:Point("TOPLEFT", _G.UIParent, 6, -6)

    local Panel = CreateFrame("Frame", "RaidUtilityPanel", Anchor, "SecureHandlerBaseTemplate")
    Panel:Size(124, 132)
    Panel:Point("TOPLEFT", Anchor)
    Panel:CreateBackdrop()
    Panel:CreateShadow()
    Panel:Hide()
    Panel.toggled = false

    local ButtonWidth = Anchor:GetWidth() * 0.92
    local ButtonHeight = 18

    self:CreateButton("RaidUtilityShowButton", Anchor, "UIPanelButtonTemplate, SecureHandlerClickTemplate", ButtonWidth, ButtonHeight, "CENTER", Anchor, "CENTER", 0, 0, _G.RAID_CONTROL)
    self:CreateButton("RaidUtilityDisbandButton", Panel, "UIPanelButtonTemplate", ButtonWidth, ButtonHeight, "TOP", Panel, "TOP", 0, -4, Language.Group.Disband)
    self:CreateButton("RaidUtilityConvertButton", Panel, "UIPanelButtonTemplate", ButtonWidth, ButtonHeight, "TOP", RaidUtilityDisbandButton, "BOTTOM", 0, -4, UnitInRaid("player") and _G.CONVERT_TO_PARTY or _G.CONVERT_TO_RAID)
    self:CreateButton("RaidUtilityRoleButton", Panel, "UIPanelButtonTemplate", ButtonWidth, ButtonHeight, "TOP", RaidUtilityConvertButton, "BOTTOM", 0, -4, _G.ROLE_POLL)
    self:CreateButton("RaidUtilityReadyCheckButton", Panel, "UIPanelButtonTemplate", ButtonWidth, ButtonHeight, "TOP", RaidUtilityRoleButton, "BOTTOM", 0, -4, _G.READY_CHECK)
    self:CreateButton("RaidUtilityRaidCountdownButton", Panel, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", ButtonWidth, ButtonHeight, "TOP", RaidUtilityReadyCheckButton, "BOTTOM", 0, -4, "Pull Timer")
    self:CreateButton("RaidUtilityCloseButton", Panel, "UIPanelButtonTemplate, SecureHandlerClickTemplate", ButtonWidth, ButtonHeight, "TOP", RaidUtilityRaidCountdownButton, "BOTTOM", 0, -4, _G.CLOSE)

    -- Show Button
    SecureHandlerSetFrameRef(RaidUtilityShowButton, "RaidUtilityPanel", Panel)
    RaidUtilityShowButton:SetAttribute("_onclick", [=[
        local panel = self:GetFrameRef("RaidUtilityPanel")
        self:Hide()
        panel:Show()
    ]=])
    RaidUtilityShowButton:SetScript("OnMouseUp", function()
        RU:ShowPanel()
    end)

    -- Show Button Background
    local ShowPanel = CreateFrame("Frame", "RaidUtilityShowPanel", RaidUtilityShowButton)
    ShowPanel:SetFrameLevel(RaidUtilityShowButton:GetFrameLevel() - 1)
    ShowPanel:SetFrameStrata(RaidUtilityShowButton:GetFrameStrata())
    ShowPanel:Size(124, 25)
    ShowPanel:Point("CENTER", RaidUtilityShowButton)
    ShowPanel:CreateBackdrop()
    ShowPanel:CreateShadow()

    -- Close Button
    SecureHandlerSetFrameRef(RaidUtilityCloseButton, "RaidUtilityShowButton", RaidUtilityShowButton)
    RaidUtilityCloseButton:SetAttribute("_onclick", [=[
        self:GetParent():Hide()
        self:GetFrameRef("RaidUtilityShowButton"):Show()
    ]=])
    RaidUtilityCloseButton:SetScript("OnMouseUp", function()
        RU:ClosePanel()
    end)

    -- Actions
    RaidUtilityDisbandButton:SetScript("OnClick", function()
        RU:DisbandGroup()
    end)

    RaidUtilityRoleButton:SetScript("OnClick", function()
        RU:StartRoleCheck()
    end)

    RaidUtilityReadyCheckButton:SetScript("OnClick", function()
        RU:StartReadyCheck()
    end)

    RaidUtilityConvertButton:SetScript("OnClick", function()
        RU:ConvertGroup()
    end)

    RaidUtilityRaidCountdownButton:SetScript("OnClick", function()
        RU:StartCountdown()
    end)
end

function RU:OnEvent()
    self:UpdateVisibility()
end

function RU:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
end

function RU:Initialize()
    self:CreateButtons()
    self:RegisterEvents()
end