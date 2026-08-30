local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local RaidUtility = UI:RegisterModule("RaidUtility")

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

function RaidUtility:CreateButton(Name, Parent, Template, Width, Height, Point, RelativeTo, RelativePoint, X, Y, Text)
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

function RaidUtility:CheckRaidStatus()
    local InInstance, InstanceType = IsInInstance()

    if (InInstance and (InstanceType == "pvp" or InstanceType == "arena")) then
        return false
    end

    if (IsInGroup() and not IsInRaid()) then
        return true
    end

    if (IsInRaid()) then
        return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
    end

    return false
end

function RaidUtility:UpdateVisibility()
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

function RaidUtility:ShowPanel()
    RaidUtilityPanel.toggled = true
end

function RaidUtility:ClosePanel()
    RaidUtilityPanel.toggled = false
end

function RaidUtility:DisbandGroup()
    StaticPopup_Show("DISBAND_RAID")
end

function RaidUtility:StartRoleCheck()
    InitiateRolePoll()
end

function RaidUtility:StartReadyCheck()
    DoReadyCheck()
end

function RaidUtility:ConvertGroup()
    if (UnitInRaid("player")) then
        C_PartyInfo.ConvertToParty()
    elseif (UnitInParty("player")) then
        C_PartyInfo.ConvertToRaid()
    end
end

function RaidUtility:StartCountdown()
    if (C_PartyInfo.DoCountdown) then
        C_PartyInfo.DoCountdown(10)
    end
end

function RaidUtility:CreateButtons()
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
        RaidUtility:ShowPanel()
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
        RaidUtility:ClosePanel()
    end)

    -- Actions
    RaidUtilityDisbandButton:SetScript("OnClick", function()
        RaidUtility:DisbandGroup()
    end)

    RaidUtilityRoleButton:SetScript("OnClick", function()
        RaidUtility:StartRoleCheck()
    end)

    RaidUtilityReadyCheckButton:SetScript("OnClick", function()
        RaidUtility:StartReadyCheck()
    end)

    RaidUtilityConvertButton:SetScript("OnClick", function()
        RaidUtility:ConvertGroup()
    end)

    RaidUtilityRaidCountdownButton:SetScript("OnClick", function()
        RaidUtility:StartCountdown()
    end)
end

function RaidUtility:OnEvent()
    self:UpdateVisibility()
end

function RaidUtility:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
end

function RaidUtility:Initialize()
    self:CreateButtons()
    self:RegisterEvents()
end