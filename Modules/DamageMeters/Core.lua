local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DM = UI:RegisterModule("DamageMeters")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Tables
DM.Rows = {}

-- Locals
DM.MaxRows = 8

-- Locals
DM.SessionID = nil

-- Locals
DM.ScrollMax = 0
DM.ScrollOffset = 0
DM.ScrollRows = 7

-- Locals
DM.TimerElapsed = 0
DM.CombatStartTime = nil

-- Local
DM.AbbreviateConfig = nil

-- TYPES

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

-- ABBREV HELPERS

local AbbreviateConfig = {
    config = CreateAbbreviateConfig({
        { breakpoint = 1000000000, abbreviation = "B", significandDivisor = 10000000, fractionDivisor = 100, abbreviationIsGlobal = false, },
        { breakpoint = 1000000, abbreviation = "M", significandDivisor = 10000, fractionDivisor = 100, abbreviationIsGlobal = false, },
        { breakpoint = 1000, abbreviation = "K", significandDivisor = 100, fractionDivisor = 10, abbreviationIsGlobal = false, },
        { breakpoint = 1, abbreviation = "", significandDivisor = 1, fractionDivisor = 1, abbreviationIsGlobal = false, },
    }),
}

function DM:AbbreviateNumber(Value)
    return AbbreviateNumbers(Value, AbbreviateConfig)
end

-- HELPERS

function DM:GetClassColor(ClassFilename)
    if (not ClassFilename or UI:IsSecretValue(ClassFilename)) then
        return nil
    end

    local Color = UI.Colors.Class[ClassFilename]

    if (not Color) then
        return nil
    end

    return { Color.r, Color.g, Color.b }
end

function DM:StripRealm(Name)
    if (not Name) then 
        return "Unknown" 
    end

    if (Ambiguate) then 
        return Ambiguate(Name, "short") or Name 
    end

    return Name
end

function DM:FormatCombatTime(Seconds)
    Seconds = math.max(Seconds or 0, 0)
    local Minutes = math.floor(Seconds / 60)
    local Secs = math.floor(Seconds % 60)
    return string.format("[|cffffd200%d:%02d|r]", Minutes, Secs)
end

-- WINDOW

function DM:CreateDamageMeters()
    if (DM.IsCreated) then
        return
    end

    -- Types
    self.DamageMeterType = Enum.DamageMeterType.DamageDone
    self.SessionType = Enum.DamageMeterSessionType.Current

    -- Main Frame
    local Frame = CreateFrame("Frame", "FeelUI_DamageMeters", _G.UIParent, "BackdropTemplate")
    Frame:Size(414, 190)
    Frame:Point("BOTTOMRIGHT", _G.UIParent, -6, 6)

    -- Header (Damage Done etc.)
    local Header = CreateFrame("Button", nil, Frame)
    Header:Size(180, 18)
    Header:Point("TOPLEFT", Frame, 6, 0)

    -- Header OnClick
    Header:SetScript("OnClick", function()
        if (DM.DamageTypeDropdown and DM.DamageTypeDropdown:IsShown()) then
            DM.DamageTypeDropdown:HideDropdown()
        else
            if (DM.SessionDropdown) then
                DM.SessionDropdown:HideDropdown()
            end

            DM:OpenDamageTypeMenu(Header)
        end
    end)

    Header.Text = Header:CreateFontString(nil, "OVERLAY")
    Header.Text:Point("LEFT", Header, 0, 0)
    Header.Text:SetFontTemplate("Default")

    -- Session (Current/Overall etc.)
    local Session = CreateFrame("Button", nil, Frame)
    Session:Size(18, 18)
    Session:Point("TOPRIGHT", Frame, -8, 0)

    -- Session OnClick
    Session:SetScript("OnClick", function()
        if (DM.SessionDropdown and DM.SessionDropdown:IsShown()) then
            DM.SessionDropdown:HideDropdown()
        else
            if (DM.DamageTypeDropdown) then
                DM.DamageTypeDropdown:HideDropdown()
            end

            DM:OpenSessionMenu(Session)
        end
    end)

    Session.Icon = Session:CreateTexture(nil, "OVERLAY", nil)
    Session.Icon:Size(36, 36)
    Session.Icon:Point("CENTER", Session, 0, 0)
    Session.Icon:SetAtlas("GM-icon-settings-hover")
    Session.Icon:SetDesaturated(true)

    -- Reset
    local Reset = CreateFrame("Button", nil, Frame)
    Reset:Size(18, 18)
    Reset:Point("LEFT", Session, -24, 0)

    -- Reset OnClick
    Reset:SetScript("OnClick", function()
        DM:ResetDamageMeter()
    end)

    Reset.Icon = Reset:CreateTexture(nil, "OVERLAY", nil)
    Reset.Icon:Size(18, 18)
    Reset.Icon:Point("CENTER", Reset, 0, 0)
    Reset.Icon:SetAtlas("talents-button-undo")
    Reset.Icon:SetDesaturated(true)

    -- Content
    local Content = CreateFrame("Frame", nil, Frame)
    Content:Point("TOPLEFT", Frame, 6, -28)
    Content:Point("BOTTOMRIGHT", Frame, -6, 6)
    Content:EnableMouseWheel(true)

    -- Content OnMouseWheel
    Content:SetScript("OnMouseWheel", function(_, Delta)
        local NewOffset = self.ScrollOffset - Delta
        self.ScrollOffset = math.max(0, math.min(NewOffset, self.ScrollMax))
        self:Refresh()
    end)

    -- Combat Timer
    DM:SetScript("OnUpdate", function(_, Elapsed)
        if (not self.CombatStartTime) then
            return
        end

        self.TimerElapsed = self.TimerElapsed + Elapsed

        if (self.TimerElapsed < 0.2) then
            return
        end

        local CombatTime = GetTime() - self.CombatStartTime
        self:UpdateHeader(CombatTime)

        self.TimerElapsed = 0
    end)

    -- Create Bars
    for Index = 1, self.MaxRows do
        local Bar = CreateFrame("Button", nil, Content)
        Bar:Height(DB.Global.DamageMeters.BarHeight)
        Bar:Point("TOPLEFT", Content, "TOPLEFT", 0, -(Index - 1) * (DB.Global.DamageMeters.BarHeight + DB.Global.DamageMeters.BarSpacing))
        Bar:Point("RIGHT", Content, "RIGHT")

        -- StatusBar
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

        -- Icon
        Bar.Icon = Bar.InvisFrame:CreateTexture(nil, "ARTWORK")
        Bar.Icon:Size(unpack(DB.Global.DamageMeters.IconSize))
        Bar.Icon:Point("LEFT", 0, 0)

        Bar.IconOverlay = CreateFrame("Frame", nil, Bar)
        Bar.IconOverlay:SetFrameLevel(Bar:GetFrameLevel() + 10)
        Bar.IconOverlay:SetInside(Bar.Icon)
        Bar.IconOverlay:SetTemplate()
        Bar.IconOverlay:CreateShadow()
        Bar.IconOverlay:SetShadowOverlay()

        -- Rank + Name
        Bar.Text = Bar.InvisFrame:CreateFontString(nil, "OVERLAY")
        Bar.Text:Point("LEFT", Bar.Icon, "RIGHT", 6, 0)
        Bar.Text:SetFontTemplate("Default")

        -- Damage Values
        Bar.Value = Bar.InvisFrame:CreateFontString(nil, "OVERLAY")
        Bar.Value:Point("RIGHT", Bar, "RIGHT", -6, 0)
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

    -- Cache
    self.Frame = Frame
    self.Header = Header
    self.Session = Session
    self.Reset = Reset
    self.Content = Content

    -- Update
    self:UpdateHeader()

    DM.IsCreated = true
end

-- BARS

function DM:UpdateBars(Bar, Source, Rank, MaxAmount)
    Bar.Source = Source
    Bar:Show()

    local ClassFileName = Source.classFilename
    local ClassColor = self:GetClassColor(ClassFileName)
    local SpecIconID = Source.specIconID

    if (type(SpecIconID) == "number" and SpecIconID ~= 0) then
        Bar.Icon:Size(unpack(DB.Global.DamageMeters.IconSize))
        Bar.Icon:SetTexture(SpecIconID)
        UI:KeepAspectRatio(Bar.Icon, Bar.Icon)
    else
        Bar.Icon:Size(unpack(DB.Global.DamageMeters.IconSize))
        Bar.Icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")

        local ClassIconCoords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[ClassFileName]

        if (ClassIconCoords) then
            UI:KeepAspectRatio(Bar.Icon, Bar.Icon, ClassIconCoords)
        else
            UI:KeepAspectRatio(Bar.Icon, Bar.Icon)
        end
    end

    if (ClassColor) then
        Bar.StatusBar:SetStatusBarColor(unpack(ClassColor))
    else
        Bar.StatusBar:SetStatusBarColor(1, 0.82, 0)
    end

    Bar.StatusBar:SetMinMaxValues(0, MaxAmount, UI.SmoothBars)
    Bar.StatusBar:SetValue(Source.totalAmount, UI.SmoothBars)

    -- Rank
    Bar.Text:SetText(Rank .. ". " .. DM:StripRealm(Source.name))

    -- Value
    Bar.Value:SetFormattedText("%s (%s)", DM:AbbreviateNumber(Source.totalAmount), DM:AbbreviateNumber(Source.amountPerSecond))
end

function DM:ClearBar(Bar)
    if (not Bar) then
        for Index = 1, self.MaxRows do
            self:ClearBar(self.Rows[Index])
        end

        return
    end

    Bar.Source = nil
    Bar.Text:SetText("")
    Bar.StatusBar:SetMinMaxValues(0, 1)
    Bar.StatusBar:SetValue(0)
    Bar:Hide()
end

-- UPDATE

function DM:UpdateHeader(CombatTime)
    local HeaderText = DamageTypeNames[self.DamageMeterType] or DAMAGE_METER_TYPE_DAMAGE_DONE

    if (self.CombatStartTime) then
        CombatTime = CombatTime or (GetTime() - self.CombatStartTime)
        HeaderText = HeaderText .. " " .. self:FormatCombatTime(CombatTime)
    end

    self.Header.Text:SetText(HeaderText)
end

-- DROPDOWN

function DM:OpenDamageTypeMenu(Owner)
    local Dropdown = UI:CreateDropdown(222, Owner, -6, -18)

    self.DamageTypeDropdown = Dropdown

    for _, DamageMeterType in ipairs(DamageTypes) do
        local Name = DamageTypeNames[DamageMeterType]

        if (Name) then
            Dropdown:AddDropdownButton(Name, self.DamageMeterType == DamageMeterType, function()
                self.DamageMeterType = DamageMeterType
                self.SessionID = nil
                self.SessionType = Enum.DamageMeterSessionType.Current
                self:UpdateHeader()
                self:Refresh()
            end)
        end
    end
end

function DM:OpenSessionMenu(Owner)
    local Dropdown = UI:CreateDropdown(252, Owner, -228, -18)

    self.SessionDropdown = Dropdown

    Dropdown:AddDropdownButton(DAMAGE_METER_CURRENT_SESSION, not self.SessionID and self.SessionType == Enum.DamageMeterSessionType.Current, function()
        self.SessionType = Enum.DamageMeterSessionType.Current
        self.SessionID = nil
        self:UpdateHeader()
        self:Refresh()
    end)

    Dropdown:AddDropdownButton(DAMAGE_METER_OVERALL_SESSION, not self.SessionID and self.SessionType == Enum.DamageMeterSessionType.Overall, function()
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

            Dropdown:AddDropdownButton(Name, self.SessionID == Session.sessionID, function()
                self.SessionID = Session.sessionID
                self.SessionType = nil
                self:UpdateHeader()
                self:Refresh()
            end)
        end
    end
end

-- SESSION

function DM:GetCombatSession()
    if (self.SessionID) then
        return C_DamageMeter.GetCombatSessionFromID(self.SessionID, self.DamageMeterType)
    end

    if (self.SessionType) then
        return C_DamageMeter.GetCombatSessionFromType(self.SessionType, self.DamageMeterType)
    end
end

-- RESET

function DM:ResetDamageMeter()
    self.SessionID = nil
    self.SessionType = Enum.DamageMeterSessionType.Current
    self.CombatStartTime = nil
    self.TimerElapsed = 0

    if (C_DamageMeter and C_DamageMeter.ResetAllCombatSessions) then
        C_DamageMeter.ResetAllCombatSessions()
    end

    self:ClearBar()
    self:UpdateHeader()
end

-- REFRESH

function DM:Refresh()
    if (not self.Frame) then
        return
    end

    local CombatSession = self:GetCombatSession()
    local CombatSources = CombatSession and CombatSession.combatSources

    if (not CombatSources or not CombatSources[1]) then
        self:ClearBar()
        self.ScrollOffset = 0
        self.ScrollMax = 0

        return
    end

    local MaxAmount = CombatSources[1].totalAmount
    local SourceCount = #CombatSources

    self.ScrollMax = math.max(0, SourceCount - self.ScrollRows)
    self.ScrollOffset = math.max(0, math.min(self.ScrollOffset, self.ScrollMax))

    local PlayerSource
    local PlayerRank

    for Rank, Source in ipairs(CombatSources) do
        if (Source.isLocalPlayer) then
            PlayerSource = Source
            PlayerRank = Rank

            break
        end
    end

    for RowIndex = 1, self.ScrollRows do
        local Bar = self.Rows[RowIndex]
        local SourceIndex = self.ScrollOffset + RowIndex
        local Source = CombatSources[SourceIndex]

        if (Source) then
            self:UpdateBars(Bar, Source, SourceIndex, MaxAmount)
        else
            self:ClearBar(Bar)
        end
    end

    local LastBar = self.Rows[self.MaxRows]

    if (PlayerSource and PlayerRank > self.MaxRows) then
        self:UpdateBars(LastBar, PlayerSource, PlayerRank, MaxAmount)
    else
        local SourceIndex = self.ScrollOffset + self.MaxRows
        local Source = CombatSources[SourceIndex]

        if (Source) then
            self:UpdateBars(LastBar, Source, SourceIndex, MaxAmount)
        else
            self:ClearBar(LastBar)
        end
    end
end

-- ON EVENT

function DM:OnEvent(event)
    self:Refresh()

    if (event == "PLAYER_REGEN_DISABLED") then
        self.CombatStartTime = GetTime()
        self.TimerElapsed = 0
        self:UpdateHeader()
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self.CombatStartTime = nil
        self.TimerElapsed = 0
        self:UpdateHeader()
    end
end

-- REGISTER EVENTS

function DM:RegisterEvents()
    self:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
    self:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
    self:RegisterEvent("DAMAGE_METER_RESET")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:SetScript("OnEvent", self.OnEvent)
end

-- SET CVARS

function DM:SetCVarOnLogin()
    SetCVar("damageMeterEnabled", 0)
end

-- INITIALIZE

function DM:Initialize()
    self:SetCVarOnLogin()
    self:CreateDamageMeters()
    self:RegisterEvents()
    self:Refresh()
end