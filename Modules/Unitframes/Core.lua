local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:RegisterModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local format = string.format

-- WoW Globals
local C_Timer = _G.C_Timer
local CreateFrame = CreateFrame
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitIsPlayer = UnitIsPlayer
local UnitExists = UnitExists
local UnitClass = UnitClass
local UnitName = UnitName
local UnitLevel = UnitLevel
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local UnitInRaid = UnitInRaid
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsConnected = UnitIsConnected
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitPhaseReason = UnitPhaseReason
local GetReadyCheckStatus = GetReadyCheckStatus
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitIsUnit = UnitIsUnit

-- WoW Globals
local ADDITIONAL_POWER_BAR_NAME = "MANA"
local ADDITIONAL_POWER_BAR_INDEX = 0

-- WoW Globals
local SUMMON_STATUS_NONE = Enum.SummonStatus.None or 0
local SUMMON_STATUS_PENDING = Enum.SummonStatus.Pending or 1
local SUMMON_STATUS_ACCEPTED = Enum.SummonStatus.Accepted or 2
local SUMMON_STATUS_DECLINED = Enum.SummonStatus.Declined or 3

-- WoW Globals
local READY_CHECK_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready"
local READY_CHECK_NOT_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local READY_CHECK_WAITING_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Waiting"

-- Locals
UF.HiddenFrames = {}
UF.Frames = {}
UF.Frames.Party = {}
UF.Frames.Raid = {}

-- Locals
UF.FadeInTime = 0.5

-- SecureFrame
UF.SecureFrame = CreateFrame("Frame", "UF_SecureFrame", _G.UIParent, "SecureHandlerStateTemplate")
UF.SecureFrame:SetAllPoints()
UF.SecureFrame:SetFrameStrata("LOW")
RegisterStateDriver(UF.SecureFrame, "visibility", "[petbattle] hide; show")

--- UTF8 & NAME ABBREV

local function UTF8Sub(self, i, dots)
    if not (self) then 
        return 
    end
    
    local Bytes = self:len()

    if (Bytes <= i) then
        return self
    else
        local Len, Pos = 0, 1
        
        while(Pos <= Bytes) do
            Len = Len + 1
            local c = self:byte(Pos)
            if (c > 0 and c <= 127) then
                Pos = Pos + 1
            elseif (c >= 192 and c <= 223) then
                Pos = Pos + 2
            elseif (c >= 224 and c <= 239) then
                Pos = Pos + 3
            elseif (c >= 240 and c <= 247) then
                Pos = Pos + 4
            end
            if (Len == i) then break end
        end

        if (Len == i and Pos <= Bytes) then
            return self:sub(1, Pos - 1)..(dots and "..." or "")
        else
            return self
        end
    end
end

local function NameAbbrev(Name)
    local Letters, LastWord = "", strmatch(Name, ".+%s(.+)$")
    
    if (LastWord) then
        for Words in gmatch(Name, ".-%s") do
            local FirstLetter = strsub(gsub(Words, "^[%s%p]*", ""), 1, 1)
            
            if (FirstLetter ~= strlower(FirstLetter)) then
                Letters = format("%s%s. ", Letters, FirstLetter)
            end
        end
        
        Name = format("%s%s", Letters, LastWord)
    end
    
    return Name
end

--- UPDATE HEALTH

function UF:UpdateHealth(Frame)
    if (not Frame or not Frame.unit or not Frame.Health) then
        return
    end

    local Unit = Frame.unit
    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)

    Frame.Health:SetMinMaxValues(0, Max)
    Frame.Health:SetValue(Min, UI.SmoothBars)
    Frame.Health:Show()

    if not (UnitIsConnected(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    elseif (UnitIsTapDenied(Unit) or UnitIsGhost(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    elseif (UnitIsDead(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0, 0)
        Frame.Health:SetBackdropColorTemplate(0.25, 0, 0, 0.7)
    else
        Frame.Health:SetStatusBarColor(0.1, 0.1, 0.1, 0.7)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    end
end

function UF:UpdateHealthTextCur(Frame)
    if (not Frame or not Frame.unit or not Frame.HealthTextCur) then
        return
    end

    local Unit = Frame.unit
    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)

    Frame.HealthTextCur:SetText(AbbreviateNumbers(Min))
end

function UF:UpdateHealthTextPer(Frame)
    if (not Frame or not Frame.unit or not Frame.HealthTextPer) then
        return
    end

    local Unit = Frame.unit
    local Percent = UnitHealthPercent(Unit, false, CurveConstants.ScaleTo100)

    Frame.HealthTextPer:SetFormattedText("%d%%", Percent or 0)
end

-- HEAL PRED

function UF:UpdateHealthPred(Frame)
    if (not Frame or not Frame.unit or not Frame.HealthPrediction) then
        return
    end

    local Unit = Frame.unit
    local Max = UnitHealthMax(Unit)
    local Current = UnitHealth(Unit)
    local MyIncomingHeal = UnitGetIncomingHeals(Unit, "player") or 0
    local AllIncomingHeal = UnitGetIncomingHeals(Unit) or 0
    local Absorb = UnitGetTotalAbsorbs(Unit) or 0
    local HealAbsorb = UnitGetTotalHealAbsorbs(Unit) or 0
    local Orientation = Frame.Health:GetOrientation()
    local PrevTexture = Frame.Health:GetStatusBarTexture()
    local Width, Height = Frame.Health:GetWidth(), Frame.Health:GetHeight()
    local BarWidth, BarHeight = Width, Height

    if (Orientation ~= "HORIZONTAL") then
        BarWidth, BarHeight = Height, Width
    end

    local FirstBar = Frame.HealthPrediction.MyHeals
    local SecondBar = Frame.HealthPrediction.OtherHeals
    local ThirdBar = Frame.HealthPrediction.Absorbs
    local FourthBar = Frame.HealthPrediction.HealAbsorbs

    -- Update bars
    FirstBar:SetOrientation(Orientation)
    FirstBar:Size(BarWidth, BarHeight)
    FirstBar:SetMinMaxValues(0, Max)
    FirstBar:SetValue(MyIncomingHeal, UI.SmoothBars)
    FirstBar:Show()

    SecondBar:SetOrientation(Orientation)
    SecondBar:Size(BarWidth, BarHeight)
    SecondBar:SetMinMaxValues(0, Max)
    SecondBar:SetValue(AllIncomingHeal, UI.SmoothBars)
    SecondBar:Show()

    ThirdBar:SetOrientation(Orientation)
    ThirdBar:SetReverseFill(true)
    ThirdBar:Size(BarWidth, BarHeight)
    ThirdBar:SetMinMaxValues(0, Max)
    ThirdBar:SetValue(Absorb, UI.SmoothBars)
    ThirdBar:Show()

    FourthBar:SetOrientation(Orientation)
    FourthBar:SetReverseFill(true)
    FourthBar:Size(BarWidth, BarHeight)
    FourthBar:SetMinMaxValues(0, Max)
    FourthBar:SetValue(HealAbsorb, UI.SmoothBars)
    FourthBar:Show()

    if (Orientation == "HORIZONTAL") then
        FirstBar:Point("TOPLEFT", PrevTexture, "TOPRIGHT", 0, 0)
        FirstBar:Point("BOTTOMLEFT", PrevTexture, "BOTTOMRIGHT", 0, 0)
        SecondBar:Point("TOPLEFT", FirstBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        SecondBar:Point("BOTTOMLEFT", FirstBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        ThirdBar:Point("TOPRIGHT", PrevTexture, "TOPRIGHT", 0, 0)
        ThirdBar:Point("BOTTOMRIGHT", PrevTexture, "BOTTOMRIGHT", 0, 0)
        FourthBar:Point("TOPRIGHT", PrevTexture, "TOPRIGHT", 0, 0)
        FourthBar:Point("BOTTOMRIGHT", PrevTexture, "BOTTOMRIGHT", 0, 0)
    else
        FirstBar:Point("BOTTOMLEFT", PrevTexture, "TOPLEFT", 0, 0)
        FirstBar:Point("BOTTOMRIGHT", PrevTexture, "TOPRIGHT", 0, 0)
        SecondBar:Point("BOTTOMLEFT", FirstBar:GetStatusBarTexture(), "TOPLEFT", 0, 0)
        SecondBar:Point("BOTTOMRIGHT", FirstBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        ThirdBar:Point("TOPLEFT", PrevTexture, "TOPLEFT", 0, 0)
        ThirdBar:Point("TOPRIGHT", PrevTexture, "TOPRIGHT", 0, 0)
        FourthBar:Point("TOPLEFT", PrevTexture, "TOPLEFT", 0, 0)
        FourthBar:Point("TOPRIGHT", PrevTexture, "TOPRIGHT", 0, 0)
    end
end

--- UPDATE POWER

function UF:UpdatePower(Frame)
    if (not Frame or not Frame.unit or not Frame.PowerText) then
        return
    end

    local Unit = Frame.unit
    local PowerType, PowerToken = UnitPowerType(Unit)
    local Min, Max = UnitPower(Unit, PowerType), UnitPowerMax(Unit, PowerType)
    local Percent = UnitPowerPercent(Unit, PowerType, false, CurveConstants.ScaleTo100)
    local PowerColor = UI.Colors.Power[PowerToken]

    if (PowerType == Enum.PowerType.Mana) then
        Frame.PowerText:SetFormattedText("%.0f%%", Percent)
    else
        Frame.PowerText:SetText(AbbreviateNumbers(Min))
    end

    if (PowerColor) then
        Frame.PowerText:SetTextColor(unpack(PowerColor))
    end
end

function UF:UpdateAdditionalPower(Frame)
    if (not Frame or not Frame.unit or not Frame.AdditionalPower) then
        return
    end

    local Unit = Frame.unit
    local PowerType = UnitPowerType("player")
    local Min, Max = UnitPower("player", ADDITIONAL_POWER_BAR_INDEX), UnitPowerMax("player", ADDITIONAL_POWER_BAR_INDEX)
    local Percent = UnitPowerPercent("player", PowerType, false, CurveConstants.ScaleTo100)
    local Bar = Frame.AdditionalPower
    local Text = Frame.AdditionalPowerText

    if (Max == 0 or PowerType == Enum.PowerType.Mana) then
        UI:UIFrameFadeOut(Bar, 0.25, Bar:GetAlpha(), 0)
        UI:UIFrameFadeOut(Text, 0.25, Text:GetAlpha(), 0)
    else
        UI:UIFrameFadeIn(Bar, 0.25, Bar:GetAlpha(), 1)
        UI:UIFrameFadeIn(Text, 0.25, Text:GetAlpha(), 1)

        Bar:SetMinMaxValues(0, Max)
        Bar:SetValue(Min, UI.SmoothBars)
        Text:SetFormattedText("%.0f%%", Percent)
    end
end

--- UPDATE NAME

function UF:UpdateName(Frame, TypeFrame)
    if (not Frame or not Frame.unit or not Frame.Name) then
        return
    end

    local Unit = Frame.unit
    local Name = UnitName(Unit) or ""

    if (Name) then
        if (TypeFrame == "Raid") then
            Frame.Name:SetText(UTF8Sub(Name, 8))
        elseif (TypeFrame == "Party") then
            Frame.Name:SetText(UTF8Sub(Name, 12))
        else
            Frame.Name:SetText(Name)
        end
    end

    if UnitIsPlayer(Unit) then
        local _, Class = UnitClass(Unit)
        local Color = UI.Colors.Class[Class]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    else
        local Reaction = UnitReaction(Unit, "player") or 5
        local Color = UI.Colors.Reaction[Reaction]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    end
end

--- UPDATE NAME & LEVEL

function UF:UpdateTargetNameLevel(Frame)
    if (not Frame or not Frame.unit or not Frame.NameLevel) then
        return
    end

    local Unit = Frame.unit
    local Name = UnitName(Unit) or ""
    local Level = UnitLevel(Unit) or -1
    local NameColor, LevelColor, LevelText

    if UnitIsPlayer(Unit) then
        local _, Class = UnitClass(Unit)
        local Color = UI.Colors.Class[Class]

        NameColor = format("|cff%02x%02x%02x", Color.r*255, Color.g*255, Color.b*255)
    else
        local Reaction = UnitReaction(Unit, "player") or 5
        local Color = UI.Colors.Reaction[Reaction]

        NameColor = format("|cff%02x%02x%02x", Color.r*255, Color.g*255, Color.b*255)
    end

    if (Level < 0) then
        LevelColor = "|cffff0000"
    elseif (Level == 0) then
        LevelColor = "|cffcccccc"
    else
        local DiffColor = GetQuestDifficultyColor(Level)
        LevelColor = format("|cff%02x%02x%02x", DiffColor.r*255, DiffColor.g*255, DiffColor.b*255)
    end

    if (Level < 0) then
        LevelText = "??"
    elseif (Level == 0) then
        LevelText = "?"
    else
        LevelText = tostring(Level)
    end

    if (Name and Level) then
        Frame.NameLevel:SetText(format("%s%s|r %s%s|r", NameColor or "", Name, LevelColor or "", LevelText))
        --Frame.NameLevel:SetText(format("%s%s|r %s%s|r", NameColor or "", UTF8Sub(Name, 14), LevelColor or "", LevelText))
    end
end

-- UPDATE PORTRAITS

function UF:UpdatePortrait(Frame)
    if (not Frame or not Frame.unit or not Frame.Portrait) then
        return
    end

    local Unit = Frame.unit

    if (not UnitExists(Unit)) then
        Frame.Portrait:ClearModel()
        return
    end

    C_Timer.After(0, function()
        if (not Frame or not Frame.unit or not Frame.Portrait or not UnitExists(Unit)) then
            if (Frame and Frame.Portrait) then
                Frame.Portrait:ClearModel()
            end
            return
        end

        Frame.Portrait:SetUnit(Unit)
        Frame.Portrait:SetCamDistanceScale(2.5)
        Frame.Portrait:SetPortraitZoom(1)
        Frame.Portrait:SetPosition(0, 0, 0)
    end)
end

-- ICONS

function UF:UpdateRestingIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.RestingIcon) then
        return
    end

    local IsResting = IsResting()

    if (IsResting) then
        UI:UIFrameFadeIn(Frame.RestingIcon, 2, Frame.RestingIcon:GetAlpha(), 1)
    else
        UI:UIFrameFadeOut(Frame.RestingIcon, 2, Frame.RestingIcon:GetAlpha(), 0)
    end
end

function UF:UpdateCombatIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.CombatIcon) then
        return
    end

    local UnitAffectingCombat = UnitAffectingCombat("player")

    if (UnitAffectingCombat) then
        Frame.CombatIcon:Show()
    else
        Frame.CombatIcon:Hide()
    end
end

function UF:UpdateRaidIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.RaidIcon) then
        return
    end

    local Unit = Frame.unit
    local Index = GetRaidTargetIndex(Unit)

    if (Index) then
        Frame.RaidIcon:Show()
        SetRaidTargetIconTexture(Frame.RaidIcon, Index)
    else
        Frame.RaidIcon:Hide()
    end
end

function UF:UpdateResurrectionIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.ResurrectIcon) then
        return
    end

    local Unit = Frame.unit
    local UnitHasIncomingResurrection = UnitHasIncomingResurrection(Unit)

    if (UnitHasIncomingResurrection) then
        Frame.ResurrectIcon:Show()
    else
        Frame.ResurrectIcon:Hide()
    end
end

function UF:UpdateAssistantIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.UpdateAssistantIcon) then
        return
    end

    local Unit = Frame.unit
    local IsAssistant = UnitInRaid(Unit) and UnitIsGroupAssistant(Unit) and not UnitIsGroupLeader(Unit)

    if (IsAssistant) then
        Frame.AssistantIcon:Show()
    else
        Frame.AssistantIcon:Hide()
    end
end

function UF:UpdateLeaderIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.LeaderIcon) then
        return
    end

    local Unit = Frame.unit
    local UnitIsGroupLeader = UnitIsGroupLeader(Unit)

    if (UnitIsGroupLeader) then
        Frame.LeaderIcon:Show()
    else
        Frame.LeaderIcon:Hide()
    end
end

function UF:UpdateSummonIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.SummonIcon) then
        return
    end

    local Unit = Frame.unit
    local IncomingSummon = C_IncomingSummon.IncomingSummonStatus(Unit)

    if (IncomingSummon ~= SUMMON_STATUS_NONE) then
        if (IncomingSummon == SUMMON_STATUS_PENDING) then
            Frame.SummonIcon:SetAtlas("Raid-Icon-SummonPending")
        elseif (IncomingSummon == SUMMON_STATUS_ACCEPTED) then
            Frame.SummonIcon:SetAtlas("Raid-Icon-SummonAccepted")
        elseif (IncomingSummon == SUMMON_STATUS_DECLINED) then
            Frame.SummonIcon:SetAtlas("Raid-Icon-SummonDeclined")
        end

        Frame.SummonIcon:Show()
    else
        Frame.SummonIcon:Hide()
    end
end

function UF:UpdatePhaseIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.PhaseIcon) then
        return
    end

    local Unit = Frame.unit
    local IsPhased = UnitIsPlayer(Unit) and UnitIsConnected(Unit) and UnitPhaseReason(Unit) or nil

    if (IsPhased) then
        Frame.PhaseIcon:Show()
    else
        Frame.PhaseIcon:Hide()
    end
end

function UF:UpdateReadyCheckIcon(Frame, event)
    if (not Frame or not Frame.unit or not Frame.ReadyCheckIcon) then
        return
    end

    if (Frame.Animation.FadeOut and Frame.Animation.FadeOut:IsPlaying()) then
        Frame.Animation.FadeOut:Stop()
    end

    local Unit = Frame.unit
    local GetReadyCheckStatus = GetReadyCheckStatus(Unit)

    if (GetReadyCheckStatus == "ready") then
        Frame.ReadyCheckIcon:SetTexture(READY_CHECK_READY_TEXTURE)
        Frame.ReadyCheckIcon:Show()
    elseif (GetReadyCheckStatus == "notready") then
        Frame.ReadyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
        Frame.ReadyCheckIcon:Show()
    elseif (GetReadyCheckStatus == "waiting") then
        Frame.ReadyCheckIcon:SetTexture(READY_CHECK_WAITING_TEXTURE)
        Frame.ReadyCheckIcon:Show()
    else
        if (event == "READY_CHECK_FINISHED") then
            C_Timer.After(5, function()
                if (Frame.ReadyCheckIcon:IsShown() and Frame.Animation.FadeOut) then
                    Frame.Animation.FadeOut:Play()
                end
            end)
        else
            Frame.ReadyCheckIcon:Hide()
        end
    end
end

-- THREAT

function UF:UpdateThreatHighlight(Frame)
    if (not Frame or not Frame.unit or not Frame.Threat) then
        return
    end

    local Unit = Frame.unit
    local Threat = UnitThreatSituation("player", Unit)
    
    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        Frame.Threat.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)
    else
        Frame.Threat.Glow:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

function UF:UpdateThreatHighlightRaid(Frame)
    if (not Frame or not Frame.unit or not Frame.Threat) then
        return
    end

    local Unit = Frame.unit
    local Threat = UnitThreatSituation(Unit)

    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        Frame.ThreatRaid.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)
    else
        Frame.ThreatRaid.Glow:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

--- UPDATE FRAMES

function UF:UpdateFrame(Unit)
    local Frame = self.Frames[Unit]

    if (not Frame or not UnitExists(Unit)) then
        return
    end

    -- HEALTH
    if (Frame.Health) then self:UpdateHealth(Frame) end
    if (Frame.HealthTextCur) then self:UpdateHealthTextCur(Frame) end
    if (Frame.HealthTextPer) then self:UpdateHealthTextPer(Frame) end
    -- HEALTH PRED
    if (Frame.HealthPrediction)then self:UpdateHealthPred(Frame) end
    -- POWER
    if (Frame.PowerText) then self:UpdatePower(Frame) end
    if (Frame.AdditionalPower) then self:UpdateAdditionalPower(Frame) end
    -- AURAS
    if (Frame.Buffs) then self:UpdateAuras(Frame, Unit, false) end
    if (Frame.Debuffs) then self:UpdateAuras(Frame, Unit, true) end
    -- NAME
    if (Frame.Name) then self:UpdateName(Frame) end
    if (Frame.NameLevel) then self:UpdateTargetNameLevel(Frame) end
    -- PORTRAITS
    if (Frame.Portrait) then self:UpdatePortrait(Frame) end
    -- ICONS
    if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame) end
    if (Frame.CombatIcon) then self:UpdateCombatIcon(Frame) end
    if (Frame.RestingIcon) then self:UpdateRestingIcon(Frame) end
    if (Frame.ResurrectionIcon) then self:UpdateResurrectionIcon(Frame) end
    if (Frame.LeaderIcon) then self:UpdateLeaderIcon(Frame) end
    if (Frame.AssistantIcon) then self:UpdateAssistantIcon(Frame) end
    if (Frame.SummonIcon) then self:UpdateSummonIcon(Frame) end
    if (Frame.PhaseIcon) then self:UpdatePhaseIcon(Frame) end
    if (Frame.ReadyCheckIcon) then self:UpdateReadyCheckIcon(Frame) end
    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame) end
    if (Frame.ThreatRaid) then self:UpdateThreatHighlightRaid(Frame) end
end

function UF:UpdateAll()
    for Units, Frames in pairs(self.Frames) do
        if (Frames and UnitExists(Units)) then
            self:UpdateFrame(Units)
        end
    end
end

-- ON EVENTS

function UF:OnEvent(event, unit, ...)
    local FramesUF = unit and UF.Frames[unit]

    -- LOGIN UPDATE
    if (event == "PLAYER_ENTERING_WORLD") then
        C_Timer.After(0.7, function()
            UF:UpdateAll()
        end)

        -- TARGET
    elseif (event == "PLAYER_TARGET_CHANGED") then
        UF:UpdateAll()
        UF:ClearCastBarOnUnit("target")

        -- TARGET OF TARGET
    elseif (event == "UNIT_TARGET" and unit == "target") then
        UF:UpdateAll()

        -- PET
    elseif (event == "UNIT_PET") then
        UF:UpdateAll()

        -- FOCUS
    elseif (event == "PLAYER_FOCUS_CHANGED") then
        UF:UpdateAll()

        -- BOSS FRAMES
    elseif (event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" or event == "UNIT_TARGETABLE_CHANGED") then
        UF:UpdateAll()

        -- ICONS
    elseif (event == "PLAYER_UPDATE_RESTING") then
        for _, Frame in pairs(UF.Frames) do
            UF:UpdateRestingIcon(Frame)
        end

    elseif (event == "RAID_TARGET_UPDATE") then
        for _, Frame in pairs(UF.Frames) do
            UF:UpdateRaidIcon(Frame)
        end

    elseif (event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" or event == "READY_CHECK_FINISHED") then
        for _, Frame in pairs(UF.Frames) do
            UF:UpdateReadyCheckIcon(Frame, event)
        end
    end

    if (not FramesUF) then
        return
    end

    -- AURAS
    if (event == "UNIT_AURA") then
        UF:UpdateAuras(FramesUF, unit, false)
        UF:UpdateAuras(FramesUF, unit, true)

    -- HEALTH
    elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
        UF:UpdateHealth(FramesUF)
        UF:UpdateHealthTextCur(FramesUF)
        UF:UpdateHealthTextPer(FramesUF)
        UF:UpdateHealthPred(FramesUF)

    -- HEALTH PRED
    elseif (event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED") then
        UF:UpdateHealthPred(FramesUF)

    -- POWER
    elseif (event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER") then
        UF:UpdatePower(FramesUF)
        UF:UpdateAdditionalPower(FramesUF)

    -- THREAT
    elseif (event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE") then
        UF:UpdateThreatHighlight(FramesUF)

    -- NAME
    elseif (event == "UNIT_NAME_UPDATE") then
        UF:UpdateName(FramesUF)

    -- LEVEL
    elseif (event == "UNIT_LEVEL" or event == "PLAYER_LEVEL_UP") then
        UF:UpdateTargetNameLevel(FramesUF)

    -- ICONS
    elseif (event == "UNIT_FLAGS" or event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE") then
        UF:UpdateCombatIcon(FramesUF)
        UF:UpdateLeaderIcon(FramesUF)
        UF:UpdateAssistantIcon(FramesUF)

    elseif (event == "INCOMING_RESURRECT_CHANGED") then
        UF:UpdateResurrectionIcon(FramesUF)

    elseif (event == "INCOMING_SUMMON_CHANGED") then
        UF:UpdateSummonIcon(FramesUF)

    elseif (event == "UNIT_PHASE") then
        UF:UpdatePhaseIcon(FramesUF)

    -- PORTRAITS
    elseif (event == "UNIT_MODEL_CHANGED" or event == "UNIT_PORTRAIT_UPDATE") then
        UF:UpdatePortrait(FramesUF)

    -- CASTBARS
    elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
        UF:CastStarted(unit, event)

    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        UF:CastStopped(unit)

    --elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        --UF:CastUpdated(unit, event)

    elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then
        UF:CastFailed(unit, event)

    elseif (event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        UF:CastInterrupted(unit, event)
    end
end

-- INITIALIZE & REGISTER EVENTS

function UF:RegisterEvents()
    local SecureEventFrame = UF.SecureFrame

    SecureEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- BUFFS / DEBUFFS
    SecureEventFrame:RegisterEvent("UNIT_AURA")
    -- HEALTH
    SecureEventFrame:RegisterEvent("UNIT_HEALTH")
    SecureEventFrame:RegisterEvent("UNIT_MAXHEALTH")
    -- HEALTH PRED
    SecureEventFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
    SecureEventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED")
    -- ICONS
    SecureEventFrame:RegisterEvent("UNIT_FLAGS")
    SecureEventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
    SecureEventFrame:RegisterEvent("RAID_TARGET_UPDATE")
    SecureEventFrame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    SecureEventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
    SecureEventFrame:RegisterEvent("INCOMING_SUMMON_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_PHASE")
    SecureEventFrame:RegisterEvent("READY_CHECK")
    SecureEventFrame:RegisterEvent("READY_CHECK_CONFIRM")
    SecureEventFrame:RegisterEvent("READY_CHECK_FINISHED")
    -- POWER
    SecureEventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
    SecureEventFrame:RegisterEvent("UNIT_MAXPOWER")
    SecureEventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    SecureEventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    -- UNITS
    SecureEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    SecureEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_TARGETABLE_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_TARGET")
    SecureEventFrame:RegisterEvent("UNIT_PET")
    SecureEventFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    SecureEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    -- CASTBAR
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    -- THREAT
    SecureEventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    -- NAME
    SecureEventFrame:RegisterEvent("UNIT_NAME_UPDATE")
    -- LEVEL
    SecureEventFrame:RegisterEvent("UNIT_LEVEL")
    SecureEventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    -- PORTRAITS
    SecureEventFrame:RegisterEvent("UNIT_MODEL_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    -- ON EVENT
    SecureEventFrame:SetScript("OnEvent", function(_, event, ...)
        UF:OnEvent(event, ...)
    end)
end

function UF:Initialize()
    if (not DB.Global.UnitFrames.Enable) then
        return
    end

    -- HIDE
    self:HideBlizzardFrames()
    -- SPAWN UNITFRAMES
    self:CreateUF()
    -- EVENTS
    self:RegisterEvents()
end