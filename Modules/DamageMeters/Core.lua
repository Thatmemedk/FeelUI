local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DM = UI:RegisterModule("DamageMeters")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Locals
local MaxRows = 8
local RowHeight = 18
local BarSpacing = 2
local IconWidth = 28
local IconHeight = 18

-- Locals
local DropdownWidth = 202
local DropdownRowHeight = 18
local DropdownPadding = 4

-- Locals
local R, G, B = unpack(UI.GetClassColors)

-- TABLES

local DamageTypes = {
    Enum.DamageMeterType.DamageDone,
    Enum.DamageMeterType.Dps,
    Enum.DamageMeterType.DamageTaken,
    Enum.DamageMeterType.AvoidableDamageTaken,
    Enum.DamageMeterType.EnemyDamageTaken,
    Enum.DamageMeterType.HealingDone,
    Enum.DamageMeterType.Hps,
    Enum.DamageMeterType.Interrupts,
    Enum.DamageMeterType.Dispels,
    Enum.DamageMeterType.Deaths,
}

local DamageTypeNames = {
    [Enum.DamageMeterType.DamageDone] = DAMAGE_METER_TYPE_DAMAGE_DONE,
    [Enum.DamageMeterType.Dps] = DAMAGE_METER_TYPE_DPS,
    [Enum.DamageMeterType.DamageTaken] = DAMAGE_METER_TYPE_DAMAGE_TAKEN,
    [Enum.DamageMeterType.AvoidableDamageTaken] = DAMAGE_METER_TYPE_AVOIDABLE_DAMAGE_TAKEN,
    [Enum.DamageMeterType.EnemyDamageTaken] = DAMAGE_METER_TYPE_ENEMY_DAMAGE_TAKEN,
    [Enum.DamageMeterType.HealingDone] = DAMAGE_METER_TYPE_HEALING_DONE,
    [Enum.DamageMeterType.Hps] = DAMAGE_METER_TYPE_HPS,
    [Enum.DamageMeterType.Interrupts] = DAMAGE_METER_TYPE_INTERRUPTS,
    [Enum.DamageMeterType.Dispels] = DAMAGE_METER_TYPE_DISPELS,
    [Enum.DamageMeterType.Deaths] = DAMAGE_METER_TYPE_DEATHS,
}

local SessionTypeNames = {
    [Enum.DamageMeterSessionType.Current] = DAMAGE_METER_CURRENT_SESSION,
    [Enum.DamageMeterSessionType.Overall] = DAMAGE_METER_OVERALL_SESSION,
}

-- HELPERS

function DM:GetClassColor(ClassFilename)
    if (not ClassFilename or UI:IsSecretValue(ClassFilename)) then
        return nil
    end

    local Color = UI.Colors.Class[ClassFilename]

    if (not Color) then
        return nil
    end

    return Color.r, Color.g, Color.b
end

function DM:FormatCombatTime(Seconds)
    Seconds = math.max(Seconds or 0, 0)
    local Minutes = math.floor(Seconds / 60)
    local Secs = math.floor(Seconds % 60)
    return string.format("|cffffffff[|r%d:%02d|cffffffff]|r", Minutes, Secs)
end

-- DROPDOWN

local function CreateDropdown()
    local ClickCatcher = CreateFrame("Button", nil, _G.UIParent)
    ClickCatcher:SetFrameStrata("DIALOG")
    ClickCatcher:SetFrameLevel(99)
    ClickCatcher:EnableMouse(true)
    ClickCatcher:SetClampedToScreen(true)
    ClickCatcher:SetAllPoints(_G.UIParent)
    ClickCatcher:Hide()

    local Dropdown = CreateFrame("Frame", nil, _G.UIParent, "LibBackdropTemplate")
    Dropdown:SetFrameStrata("DIALOG")
    Dropdown:SetFrameLevel(100)
    Dropdown:SetClampedToScreen(true)
    Dropdown:EnableMouse(true)
    Dropdown:Width(DropdownWidth)
    Dropdown:CreateBackdrop()
    Dropdown:CreateShadow()
    Dropdown:Hide()

    Dropdown.Buttons = {}
    Dropdown.Count = 0

    function Dropdown:HideDropdown()
        self:Hide()
        ClickCatcher:Hide()
    end

    function Dropdown:ClearButtons()
        self.Count = 0

        for _, Button in ipairs(self.Buttons) do
            Button:Hide()
        end
    end

    function Dropdown:AddButton(Text, Checked, OnClick)
        self.Count = self.Count + 1

        local Index = self.Count
        local Button = self.Buttons[Index]

        if (not Button) then
            Button = CreateFrame("Button", nil, self)
            Button:Height(DropdownRowHeight)

            -- Text
            Button.Text = Button:CreateFontString(nil, "OVERLAY")
            Button.Text:Point("LEFT", Button, "LEFT", 6, 0)
            Button.Text:Point("RIGHT", Button, "RIGHT", -26, 0)
            Button.Text:SetJustifyH("LEFT")
            Button.Text:SetWordWrap(false)
            Button.Text:SetFontTemplate("Default")

            -- Checkbox
            Button.Check = CreateFrame("StatusBar", nil, Button)
            Button.Check:Size(14, 14)
            Button.Check:Point("RIGHT", Button, "RIGHT", -6, 0)
            Button.Check:SetStatusBarTexture(Media.Global.Texture)

            Button.CheckOverlay = CreateFrame("Frame", nil, Button)
            Button.CheckOverlay:SetFrameLevel(Button.Check:GetFrameLevel() - 1)
            Button.CheckOverlay:SetInside(Button.Check)
            Button.CheckOverlay:CreateBackdrop()
            Button.CheckOverlay:CreateShadow()

            Button.CheckHighlight = Button.Check:CreateTexture(nil, "OVERLAY")
            Button.CheckHighlight:SetInside(Button.Check, 1, 1)
            Button.CheckHighlight:SetTexture(Media.Global.Texture)
            Button.CheckHighlight:SetVertexColor(1, 1, 1, 0.25)
            Button.CheckHighlight:Hide()

            -- Highlight
            Button.Highlight = Button:CreateTexture(nil, "BACKGROUND")
            Button.Highlight:SetInside(Button, 1, 1)
            Button.Highlight:SetTexture(Media.Global.Highlight)
            Button.Highlight:SetVertexColor(R, G, B, 0.50)
            Button.Highlight:Hide()

            Button:SetScript("OnEnter", function(self)
                self.Highlight:Show()
                self.CheckHighlight:Show()
            end)

            Button:SetScript("OnLeave", function(self)
                self.Highlight:Hide()
                self.CheckHighlight:Hide()
            end)

            self.Buttons[Index] = Button
        end

        Button.Text:SetText(Text)

        if (Checked == true) then
            Button.Check:SetStatusBarColor(R, G, B)
        else
            Button.Check:SetStatusBarColor(0.25, 0.25, 0.25, 0.5)
        end

        Button:SetScript("OnClick", function()
            Dropdown:HideDropdown()

            if (OnClick) then
                OnClick()
            end
        end)

        Button:ClearAllPoints()
        Button:Width(self:GetWidth() - DropdownPadding * 2)
        Button:Point("TOPLEFT", self, "TOPLEFT", DropdownPadding, -DropdownPadding - ((Index - 1) * DropdownRowHeight))
        Button:Show()
    end

    function Dropdown:ShowDropdown(Owner, X, Y)
        self:ClearAllPoints()
        self:Height((self.Count * DropdownRowHeight) + DropdownPadding * 2)
        self:Point("BOTTOMLEFT", Owner, "TOPLEFT", X or 0, Y or 0)
        self:Show()
        self:Raise()

        ClickCatcher:Show()
    end

    ClickCatcher:SetScript("OnClick", function()
        Dropdown:HideDropdown()
    end)

    return Dropdown
end

-- WINDOW

function DM:CreateWindow()
    local Frame = CreateFrame("Frame", "FeelUI_DamageMeters", _G.UIParent, "BackdropTemplate")
    Frame:Size(414, 190)
    Frame:Point("BOTTOMRIGHT", _G.UIParent, -6, 6)

    local Header = CreateFrame("Button", nil, Frame)
    Header:Size(120, 18)
    Header:Point("TOPLEFT", Frame, 6, 0)
    Header:SetScript("OnClick", function()
        if (DM.DamageTypeDropdown:IsShown()) then
            DM.DamageTypeDropdown:HideDropdown()
        else
            DM.SessionDropdown:HideDropdown()
            DM:OpenDamageTypeMenu(Header)
        end
    end)

    Header.Text = Header:CreateFontString(nil, "OVERLAY")
    Header.Text:Point("LEFT", Header, 0, 0)
    Header.Text:SetFontTemplate("Default")

    Header.Timer = Header:CreateFontString(nil, "OVERLAY")
    Header.Timer:Point("LEFT", Header.Text, "RIGHT", 6, 0)
    Header.Timer:SetFontTemplate("Default")
    Header.Timer:SetText("|cffffffff[|r0:00|cffffffff]|r")
    Header.Timer:SetTextColor(1, 0.82, 0)
    Header.Timer:Hide()

    local Session = CreateFrame("Button", nil, Frame)
    Session:Size(18, 18)
    Session:Point("TOPRIGHT", Frame, -8, 0)
    Session:SetScript("OnClick", function()
        if (DM.SessionDropdown:IsShown()) then
            DM.SessionDropdown:HideDropdown()
        else
            DM.DamageTypeDropdown:HideDropdown()
            DM:OpenSessionMenu(Session)
        end
    end)

    Session.Icon = Session:CreateTexture(nil, "OVERLAY", nil)
    Session.Icon:Size(36, 36)
    Session.Icon:Point("CENTER", Session, 0, 0)
    Session.Icon:SetAtlas("GM-icon-settings-hover")
    Session.Icon:SetDesaturated(true)

    local Reset = CreateFrame("Button", nil, Frame)
    Reset:Size(18, 18)
    Reset:Point("LEFT", Session, -24, 0)
    Reset:SetScript("OnClick", function()
        DM:ResetDamageMeter()
    end)

    Reset.Icon = Reset:CreateTexture(nil, "OVERLAY", nil)
    Reset.Icon:Size(18, 18)
    Reset.Icon:Point("CENTER", Reset, 0, 0)
    Reset.Icon:SetAtlas("talents-button-undo")
    Reset.Icon:SetDesaturated(true)

    local Content = CreateFrame("Frame", nil, Frame)
    Content:Point("TOPLEFT", Frame, 6, -28)
    Content:Point("BOTTOMRIGHT", Frame, -6, 6)

    self.Frame = Frame
    self.Header = Header
    self.Session = Session
    self.Reset = Reset
    self.Content = Content
    self.Rows = {}

    self.DamageTypeDropdown = CreateDropdown()
    self.SessionDropdown = CreateDropdown()

    self.DamageTypeDropdown:Hide()
    self.SessionDropdown:Hide()

    self.DamageMeterType = Enum.DamageMeterType.DamageDone
    self.SessionType = Enum.DamageMeterSessionType.Current
    self.SessionID = nil

    -- Combat Timer
    self.CombatStartTime = nil
    self.TimerElapsed = 0

    local TimerFrame = CreateFrame("Frame", nil, Frame)
    TimerFrame:SetScript("OnUpdate", function(_, Elapsed)
        if (not self.CombatStartTime) then
            return
        end

        self.TimerElapsed = self.TimerElapsed + Elapsed

        if (self.TimerElapsed < 0.2) then
            return
        end

        self.TimerElapsed = 0
        self.Header.Timer:SetText(self:FormatCombatTime(GetTime() - self.CombatStartTime))
    end)

    self.TimerFrame = TimerFrame

    for Index = 1, MaxRows do
        self:CreateBars(Index)
    end

    self:UpdateHeader()
end

-- BARS

function DM:CreateBars(Index)
    local Bar = CreateFrame("Button", nil, self.Content)
    Bar:Height(RowHeight)

    Bar.StatusBar = CreateFrame("StatusBar", nil, Bar)
    Bar.StatusBar:SetInside()
    Bar.StatusBar:SetMinMaxValues(0, 1)
    Bar.StatusBar:SetValue(0)
    Bar.StatusBar:SetStatusBarTexture(Media.Global.Texture)
    Bar.StatusBar:CreateBackdrop()
    Bar.StatusBar:CreateShadow()

    Bar.InvisFrame = CreateFrame("Frame", nil, Bar)
    Bar.InvisFrame:SetFrameLevel(Bar:GetFrameLevel() + 10)
    Bar.InvisFrame:SetInside()

    Bar.Icon = Bar.InvisFrame:CreateTexture(nil, "ARTWORK")
    Bar.Icon:Size(IconWidth, IconHeight)
    Bar.Icon:Point("LEFT", 0, 0)

    Bar.IconOverlay = CreateFrame("Frame", nil, Bar)
    Bar.IconOverlay:SetFrameLevel(Bar:GetFrameLevel() + 11)
    Bar.IconOverlay:SetInside(Bar.Icon)
    Bar.IconOverlay:SetTemplate()
    Bar.IconOverlay:CreateShadow()
    Bar.IconOverlay:SetShadowOverlay()

    Bar.Rank = Bar.InvisFrame:CreateFontString(nil, "OVERLAY")
    Bar.Rank:Point("LEFT", Bar.Icon, "RIGHT", 3, 0)
    Bar.Rank:Width(18)
    Bar.Rank:SetJustifyH("LEFT")
    Bar.Rank:SetFontTemplate("Default")

    Bar.Name = Bar.InvisFrame:CreateFontString(nil, "OVERLAY")
    Bar.Name:Point("LEFT", Bar.Rank, "RIGHT", 2, 0)
    Bar.Name:Point("RIGHT", Bar, "RIGHT", -105, 0)
    Bar.Name:SetJustifyH("LEFT")
    Bar.Name:SetWordWrap(false)
    Bar.Name:SetFontTemplate("Default")

    Bar.Value = Bar.InvisFrame:CreateFontString(nil, "OVERLAY")
    Bar.Value:Point("RIGHT", Bar, "RIGHT", -4, 0)
    Bar.Value:SetJustifyH("RIGHT")
    Bar.Value:SetFontTemplate("Default")

    Bar:SetScript("OnClick", function()
        local Source = Bar.Source

        if (not Source) then
            return
        end

        local SourceWindow = self.SourceWindow

        if (not SourceWindow) then
            return
        end

        SourceWindow:SetSource(Source)
        SourceWindow:SetDamageMeterType(self.DamageMeterType)
        SourceWindow:SetSession(self.SessionType, self.SessionID)
        SourceWindow:Show()
    end)

    self.Rows[Index] = Bar
end

function DM:UpdateBars(Bar, Source, Index, MaxAmount)
    Bar.Source = Source

    Bar:ClearAllPoints()
    Bar:Point("TOPLEFT", self.Content, "TOPLEFT", 0, -(Index - 1) * (RowHeight + BarSpacing))
    Bar:Point("RIGHT", self.Content, "RIGHT")
    Bar:Show()

    local ClassFilename = Source.classFilename
    local ClassR, ClassG, ClassB = self:GetClassColor(ClassFilename)
    local SpecIconID = Source.specIconID

    if (type(SpecIconID) == "number" and SpecIconID ~= 0) then
        Bar.Icon:Size(IconWidth, IconHeight)
        Bar.Icon:SetTexture(SpecIconID)
        UI:KeepAspectRatio(Bar.Icon, Bar.Icon)
    else
        Bar.Icon:Size(IconWidth, IconHeight)
        Bar.Icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")

        local ClassIconCoords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[ClassFilename]

        if (ClassIconCoords) then
            UI:KeepAspectRatio(Bar.Icon, Bar.Icon, ClassIconCoords)
        else
            UI:KeepAspectRatio(Bar.Icon, Bar.Icon)
        end
    end

    if (ClassR) then
        Bar.StatusBar:SetStatusBarColor(ClassR, ClassG, ClassB)
    else
        Bar.StatusBar:SetStatusBarColor(0.15, 0.55, 1, 0.35)
    end

    Bar.StatusBar:SetMinMaxValues(0, MaxAmount, UI.SmoothBars)
    Bar.StatusBar:SetValue(Source.totalAmount, UI.SmoothBars)

    -- Name
    if (UI:IsSecretValue(Source.name)) then
        Bar.Name:SetText(Source.name)
    else
        Bar.Name:SetText(Source.name or UNKNOWN)
    end

    -- Rank
    Bar.Rank:SetText(Index .. ".")

    -- Value
    Bar.Value:SetFormattedText("%s | %s", AbbreviateNumbers(Source.totalAmount), AbbreviateNumbers(Source.amountPerSecond))
end

function DM:ClearBars(FromIndex)
    for Index = FromIndex or 1, MaxRows do
        local Bar = self.Rows[Index]

        Bar.Source = nil
        Bar.Name:SetText("")
        Bar.Rank:SetText("")
        Bar.Value:SetText("")
        Bar.StatusBar:SetMinMaxValues(0, 1)
        Bar.StatusBar:SetValue(0)
        Bar:Hide()
    end
end

-- UPDATE

function DM:UpdateHeader()
    self.Header.Text:SetText(DamageTypeNames[self.DamageMeterType] or DAMAGE_METER_TYPE_DAMAGE_DONE)
end

-- MENU

function DM:OpenDamageTypeMenu(Owner)
    local Dropdown = self.DamageTypeDropdown
    Dropdown:ClearButtons()

    for _, DamageMeterType in ipairs(DamageTypes) do
        local Name = DamageTypeNames[DamageMeterType]

        if (Name) then
            Dropdown:AddButton(Name, self.DamageMeterType == DamageMeterType, function()
                self.DamageMeterType = DamageMeterType
                self.SessionID = nil
                self.SessionType = Enum.DamageMeterSessionType.Current
                self:UpdateHeader()
                self:Refresh()
            end)
        end
    end

    Dropdown:ShowDropdown(Owner, -6, -18)
end

function DM:OpenSessionMenu(Owner)
    local Dropdown = self.SessionDropdown
    Dropdown:ClearButtons()

    Dropdown:AddButton(DAMAGE_METER_CURRENT_SESSION, not self.SessionID and self.SessionType == Enum.DamageMeterSessionType.Current, function()
        self.SessionType = Enum.DamageMeterSessionType.Current
        self.SessionID = nil
        self:UpdateHeader()
        self:Refresh()
    end)

    Dropdown:AddButton(DAMAGE_METER_OVERALL_SESSION, not self.SessionID and self.SessionType == Enum.DamageMeterSessionType.Overall, function()
        self.SessionType = Enum.DamageMeterSessionType.Overall
        self.SessionID = nil
        self:UpdateHeader()
        self:Refresh()
    end)

    local Sessions = C_DamageMeter.GetAvailableCombatSessions()

    if (Sessions and #Sessions > 0) then
        for _, Session in ipairs(Sessions) do
            local Name = Session.name

            if (Session.durationSeconds) then
                local Minutes = math.floor(Session.durationSeconds / 60)
                local Seconds = math.floor(Session.durationSeconds % 60)
                Name = string.format("%s (%d:%02d)", Name, Minutes, Seconds)
            end

            Dropdown:AddButton(Name, self.SessionID == Session.sessionID, function()
                self.SessionID = Session.sessionID
                self.SessionType = nil
                self:UpdateHeader()
                self:Refresh()
            end)
        end
    end

    Dropdown:ShowDropdown(Owner, -179, -18)
end

-- REFRESH

function DM:ResetDamageMeter()
    self.SessionID = nil
    self.SessionType = Enum.DamageMeterSessionType.Current
    self.CombatStartTime = nil
    self.Header.Timer:SetText("|cffffffff[|r 0:00 |cffffffff]|r")
    self.Header.Timer:Hide()

    self:ClearBars()

    self.DamageTypeDropdown:HideDropdown()
    self.SessionDropdown:HideDropdown()

    if (C_DamageMeter and C_DamageMeter.ResetAllCombatSessions) then
        C_DamageMeter.ResetAllCombatSessions()
    end

    self:UpdateHeader()
end

function DM:GetCombatSession()
    if (self.SessionID) then
        return C_DamageMeter.GetCombatSessionFromID(self.SessionID, self.DamageMeterType)
    end

    if (self.SessionType) then
        return C_DamageMeter.GetCombatSessionFromType(self.SessionType, self.DamageMeterType)
    end
end

function DM:Refresh()
    if (not self.Frame) then
        return
    end

    local CombatSession = self:GetCombatSession()
    local CombatSources = CombatSession and CombatSession.combatSources

    if (not CombatSources or not CombatSources[1]) then
        self:ClearBars()

        return
    end

    local MaxAmount = CombatSources[1].totalAmount
    local Count = math.min(#CombatSources, MaxRows)

    for Index = 1, Count do
        local Source = CombatSources[Index]
        local Bar = self.Rows[Index]

        if (Source) then
            self:UpdateBars(Bar, Source, Index, MaxAmount)
        else
            Bar.Source = nil
            Bar:Hide()
        end
    end

    self:ClearBars(Count + 1)
end

-- REGISTER EVENTS

function DM:RegisterEvents()
    self:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
    self:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
    self:RegisterEvent("DAMAGE_METER_RESET")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    self:SetScript("OnEvent", function(_, Event)
        if (Event == "PLAYER_REGEN_DISABLED") then
            self.CombatStartTime = GetTime()
            self.Header.Timer:SetText("|cffffffff[|r 0:00 |cffffffff]|r")
            self.Header.Timer:Show()
        elseif (Event == "PLAYER_REGEN_ENABLED") then
            self.CombatStartTime = nil
            self.Header.Timer:Hide()
        end

        self:Refresh()
    end)
end

-- SET CVARS

function DM:SetCVarOnLogin()
    SetCVar("damageMeterEnabled", 0)
end

-- INITIALIZE

function DM:Initialize()
    self:SetCVarOnLogin()
    self:CreateWindow()
    self:RegisterEvents()
    self:Refresh()
end