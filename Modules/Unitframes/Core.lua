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
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitCanAttack = UnitCanAttack

-- WoW Globals
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local DEAD = _G.DEAD
local GHOST = "Ghost"

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor

-- WoW Globals
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

-- Tables
UF.Frames = {}
UF.Frames.Party = {}
UF.Frames.Raid = {}
UF.Frames.Hidden = {}
UF.Frames.Range = {}

-- Tables
UF.UpdateQueue = {}
UF.UpdaterTicker = 0

-- Locals
UF.FadeInTime = 0.5
UF.CastHoldTime = 1.25

-- SecureFrame
UF.SecureFrame = CreateFrame("Frame", "UF_SecureFrame", _G.UIParent, "SecureHandlerStateTemplate")
UF.SecureFrame:SetAllPoints()
UF.SecureFrame:SetFrameStrata("LOW")
RegisterStateDriver(UF.SecureFrame, "visibility", "[petbattle] hide; show")

--- UPDATE HEALTH

function UF:UpdateHealth(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.Health) then
        return
    end

    --local Unit = Frame.unit
    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)

    Frame.Health:SetMinMaxValues(0, Max, UI.SmoothBars)
    Frame.Health:SetValue(Min, UI.SmoothBars)

    if (not UnitIsConnected(Unit) or UnitIsTapDenied(Unit) or UnitIsGhost(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    elseif (UnitIsDead(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0, 0)
        Frame.Health:SetBackdropColorTemplate(0.25, 0, 0, 0.7)
    else
        if (DB.Global.UnitFrames.ClassColor) then
            if (UnitIsPlayer(Unit) or UnitInPartyIsAI(Unit) or UnitPlayerControlled(Unit) and not UnitIsPlayer(Unit)) then
                local _, Class = UnitClass(Unit)
                local Color = UI.Colors.Class[Class]

                Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.7)
            else
                local Reaction = UnitReaction(Unit, "player")
                local Color = UI.Colors.Reaction[Reaction]

                Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.7)
            end
        else
            Frame.Health:SetStatusBarColor(unpack(DB.Global.UnitFrames.HealthBarColor))

            local CurveColor = UnitHealthPercent(Unit, true, UI.UnitFramesHealthColorCurve)
            Frame.Health:GetStatusBarTexture():SetVertexColor(CurveColor:GetRGB())
        end

        Frame.Health:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))
    end
end

function UF:UpdateHealthTextCur(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.HealthTextCur) then
        return
    end

    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)

    if (not UnitIsConnected(Unit)) then
        Frame.HealthTextCur:SetText(PLAYER_OFFLINE)
        Frame.HealthTextCur:SetTextColor(0.35, 0.35, 0.35)
    elseif (UnitIsGhost(Unit)) then
        Frame.HealthTextCur:SetText(GHOST)
        Frame.HealthTextCur:SetTextColor(0.35, 0.35, 0.35)
    elseif (UnitIsDead(Unit)) then
        Frame.HealthTextCur:SetText(DEAD)
        Frame.HealthTextCur:SetTextColor(0.35, 0.35, 0.35)
    else
        Frame.HealthTextCur:SetText(AbbreviateNumbers(Min))
        Frame.HealthTextCur:SetTextColor(1, 1, 1)
    end
end

function UF:UpdateHealthTextPer(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.HealthTextPer) then
        return
    end

    local Percent = UnitHealthPercent(Unit, false, UI.CurvePercent)
    Frame.HealthTextPer:SetFormattedText("%d%%", Percent or 0)
end

-- HEAL PRED

function UF:UpdateHealthPred(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.HealthPrediction) then
        return
    end

    local Calculator = Frame.HealthPrediction.Calculator
    local PlayerHealsBar = Frame.HealthPrediction.PlayerHeals
    local OtherHealsBar = Frame.HealthPrediction.OtherHeals
    local AllAbsorbsBar = Frame.HealthPrediction.AllAbsorbs
    local HealAbsorbsBar = Frame.HealthPrediction.HealAbsorbs
    local OverHealsBar = Frame.HealthPrediction.OverHeals
    local OverAbsorbsBar = Frame.HealthPrediction.OverAbsorbs
    local OverHealsAbsorbsBar = Frame.HealthPrediction.OverHealsAbsorbs

    UnitGetDetailedHealPrediction(Unit, "player", Calculator)

    -- Calculate Predictions
    local AllHeals, PlayerHeals, OtherHeals, HealingClamped = Calculator:GetIncomingHeals()
    local AbsorbsAmount, AbsorbsClamped = Calculator:GetDamageAbsorbs()
    local HealAbsorbAmount, HealAbsorbClamped = Calculator:GetHealAbsorbs()
    local Max = UnitHealthMax(Unit)

    local Orientation = Frame.Health:GetOrientation()
    local PrevTexture = Frame.Health:GetStatusBarTexture()
    local BarWidth, BarHeight = Frame.Health:GetSize()

    PlayerHealsBar:SetOrientation(Orientation)
    PlayerHealsBar:SetMinMaxValues(0, Max, UI.SmoothBars)
    PlayerHealsBar:SetValue(PlayerHeals, UI.SmoothBars)

    OtherHealsBar:SetOrientation(Orientation)
    OtherHealsBar:SetMinMaxValues(0, Max, UI.SmoothBars)
    OtherHealsBar:SetValue(OtherHeals, UI.SmoothBars)

    AllAbsorbsBar:SetOrientation(Orientation)
    AllAbsorbsBar:SetReverseFill(true)
    AllAbsorbsBar:SetMinMaxValues(0, Max, UI.SmoothBars)
    AllAbsorbsBar:SetValue(AbsorbsAmount, UI.SmoothBars)

    HealAbsorbsBar:SetOrientation(Orientation)
    HealAbsorbsBar:SetReverseFill(true)
    HealAbsorbsBar:SetMinMaxValues(0, Max, UI.SmoothBars)
    HealAbsorbsBar:SetValue(HealAbsorbAmount, UI.SmoothBars)

    -- Healing Prediction
    PlayerHealsBar:SetAlphaFromBoolean(PlayerHeals, 1, 0)
    OtherHealsBar:SetAlphaFromBoolean(OtherHeals, 1, 0)
    AllAbsorbsBar:SetAlphaFromBoolean(AbsorbsAmount, 1, 0)
    HealAbsorbsBar:SetAlphaFromBoolean(HealAbsorbAmount, 1, 0)

    -- Over Healing/Absorbs
    OverHealsBar:SetAlphaFromBoolean(HealingClamped, 1, 0)
    OverAbsorbsBar:SetAlphaFromBoolean(AbsorbsClamped, 1, 0)
    OverHealsAbsorbsBar:SetAlphaFromBoolean(HealAbsorbClamped, 1, 0)

    if (Orientation == "HORIZONTAL") then
        PlayerHealsBar:Size(BarWidth, BarHeight)
        OtherHealsBar:Size(BarWidth, BarHeight)
        AllAbsorbsBar:Size(BarWidth, BarHeight)
        HealAbsorbsBar:Size(BarWidth, BarHeight)

        -- Player Heals
        PlayerHealsBar:SetOutsideRight(PrevTexture, 0, 0)
        -- Other Heals
        OtherHealsBar:SetOutsideRight(PlayerHealsBar:GetStatusBarTexture(), 0, 0)
        -- All Absorbs
        AllAbsorbsBar:SetInsideRight(PrevTexture, 0, 0)
        -- Heal Absorbs
        HealAbsorbsBar:SetInsideRight(PrevTexture, 0, 0)
        -- OverHeals
        OverHealsBar:SetOutsideRight(OtherHealsBar:GetStatusBarTexture(), -1, 0)
        -- OverAbsorbs
        OverAbsorbsBar:SetOutsideRight(AllAbsorbsBar:GetStatusBarTexture(), 0, 0)
        -- OverHealsAbsorbs
        OverHealsAbsorbsBar:SetOutsideRight(HealAbsorbsBar:GetStatusBarTexture(), 0, 0)
    else
        PlayerHealsBar:Size(BarHeight, BarWidth)
        OtherHealsBar:Size(BarHeight, BarWidth)
        AllAbsorbsBar:Size(BarHeight, BarWidth)
        HealAbsorbsBar:Size(BarHeight, BarWidth)

        -- Player Heals
        PlayerHealsBar:SetOutsideTop(PrevTexture, 0, 0)
        -- Other Heals
        OtherHealsBar:SetOutsideTop(PlayerHealsBar:GetStatusBarTexture(), 0, 0)
        -- All Absorbs
        AllAbsorbsBar:SetInsideTop(PrevTexture, 0, 0)
        -- Heal Absorbs
        HealAbsorbsBar:SetInsideTop(PrevTexture, 0, 0)
        -- OverHeals
        OverHealsBar:SetOutsideTop(OtherHealsBar:GetStatusBarTexture(), 0, 0)
        -- OverAbsorbs
        OverAbsorbsBar:SetOutsideTop(AllAbsorbsBar:GetStatusBarTexture(), 0, 0)
        -- OverHealsAbsorbs
        OverHealsAbsorbsBar:SetOutsideTop(HealAbsorbsBar:GetStatusBarTexture(), 0, 0)
    end
end

--- UPDATE POWER

function UF:UpdatePower(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.PowerText) then
        return
    end

    local PowerType, PowerToken = UnitPowerType(Unit)
    local Min, Max = UnitPower(Unit, PowerType), UnitPowerMax(Unit, PowerType)
    local Percent = UnitPowerPercent(Unit, PowerType, false, UI.CurvePercent)
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

    local Min, Max = UnitPower("player", ADDITIONAL_POWER_BAR_INDEX), UnitPowerMax("player", ADDITIONAL_POWER_BAR_INDEX)
    local Percent = UnitPowerPercent("player", ADDITIONAL_POWER_BAR_INDEX, false, UI.CurvePercent)
    local PowerType = UnitPowerType("player")
    local Class = select(2, UnitClass("player"))
    local DisplayInfo = DisplayInfo
    local EnableState = false

    if (not DisplayInfo) then
        DisplayInfo = CopyTable(ALT_POWER_BAR_PAIR_DISPLAY_INFO)
    end

    if (not UnitHasVehicleUI("player") and Max ~= 0 and DisplayInfo[Class]) then
        EnableState = DisplayInfo[Class][PowerType]
    end

    if (EnableState) then
        Frame.AdditionalPower:SetMinMaxValues(0, Max, UI.SmoothBars)
        Frame.AdditionalPower:SetValue(Min, UI.SmoothBars)
        Frame.AdditionalPower:Show()

        Frame.AdditionalPowerText:SetFormattedText("%.0f%%", Percent)
        Frame.AdditionalPowerText:Show()
    else
        Frame.AdditionalPower:Hide()
        Frame.AdditionalPowerText:Hide()
    end
end

--- UPDATE NAME

function UF:UpdateName(Frame, Unit, TypeFrame)
    if (not Frame or not Frame.unit or not Frame.Name) then
        return
    end

    local Name = UnitName(Unit) or ""

    if (TypeFrame == "Raid") then
        Frame.Name:SetText(UI:UTF8Sub(Name, 8))
    elseif (TypeFrame == "Party") then
        Frame.Name:SetText(UI:UTF8Sub(Name, 12))
    else
        Frame.Name:SetText(Name)
    end

    if (DB.Global.UnitFrames.ClassColor) then
        Frame.Name:SetTextColor(1, 1, 1)
    else
        if (UnitIsPlayer(Unit) or UnitInPartyIsAI(Unit) or UnitPlayerControlled(Unit) and not UnitIsPlayer(Unit)) then
            local _, Class = UnitClass(Unit)
            local Color = UI.Colors.Class[Class]

            if (Color) then
                Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
            end
        else
            local Reaction = UnitReaction(Unit, "player") or 5
            local Color = UI.Colors.Reaction[Reaction]

            Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
        end
    end
end

--- UPDATE NAME & LEVEL

local function NameAbbrev(Text)
    local Letters, LastWord = "", strmatch(Text, ".+%s(.+)$")
    
    if (LastWord) then
        for Words in gmatch(Text, ".-%s") do
            local FirstLetter = strsub(gsub(Words, "^[%s%p]*", ""), 1, 1)
            
            if (FirstLetter ~= strlower(FirstLetter)) then
                Letters = format("%s%s. ", Letters, FirstLetter)
            end
        end
        
        Text = format("%s%s", Letters, LastWord)
    end
    
    return Text
end

function UF:UpdateTargetNameLevel(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.NameLevel) then
        return
    end

    local Name = UnitName(Unit) or ""
    local Level = UnitLevel(Unit) or -1
    local NameColor, LevelColor, LevelText

    if (DB.Global.UnitFrames.ClassColor) then
        NameColor = format("|cff%02x%02x%02x", 1*255, 1*255, 1*255)
    else
        if (UnitIsPlayer(Unit) or UnitInPartyIsAI(Unit) or UnitPlayerControlled(Unit) and not UnitIsPlayer(Unit)) then
            local _, Class = UnitClass(Unit)
            local Color = UI.Colors.Class[Class]

            NameColor = format("|cff%02x%02x%02x", Color.r*255, Color.g*255, Color.b*255)
        else
            local Reaction = UnitReaction(Unit, "player") or 5
            local Color = UI.Colors.Reaction[Reaction]

            NameColor = format("|cff%02x%02x%02x", Color.r*255, Color.g*255, Color.b*255)
        end
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

    Frame.NameLevel:SetText(format("%s%s|r %s%s|r", NameColor or "", Name, LevelColor or "", LevelText))
end

-- UPDATE PORTRAITS

function UF:UpdatePortrait(Frame, Unit)
    if (not Frame or not Frame.Portrait or not UnitExists(Unit)) then
        return
    end

    if (Frame.Portrait:IsObjectType("PlayerModel")) then
        Frame.Portrait:ClearModel()

        if (not UnitIsVisible(Unit) or not UnitIsConnected(Unit)) then
            Frame.Portrait:SetCamDistanceScale(1)
            Frame.Portrait:SetPortraitZoom(1)
            Frame.Portrait:SetPosition(0, 0, 0.20)
            Frame.Portrait:SetModel("Interface\\Buttons\\TalkToMeQuestionMark.m2")
        else
            Frame.Portrait:SetCamDistanceScale(3)
            Frame.Portrait:SetPortraitZoom(1)
            Frame.Portrait:SetPosition(0, 0, 0)
            Frame.Portrait:SetUnit(Unit)
        end
    end
end

function UF:UpdatePlayerPortrait()
    local Frame = self.Frames["player"]

    if (Frame and Frame.Portrait) then
        self:UpdatePortrait(Frame, "player")
    end
end

function UF:UpdateTargetPortrait()
    local Frame = self.Frames["target"]

    if (Frame and Frame.Portrait) then
        self:UpdatePortrait(Frame, "target")
    end
end

-- ICONS

function UF:UpdateRestingIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.RestingIcon) then
        return
    end

    local IsResting = IsResting()

    if (IsResting) then
        if (not Frame.RestingIcon.Animation:IsPlaying()) then
            UI:UIFrameFadeIn(Frame.RestingIcon, 2, Frame.RestingIcon:GetAlpha(), 1)
            Frame.RestingIcon.Animation:Play()
        end
    else
        if (Frame.RestingIcon.Animation:IsPlaying()) then
            UI:UIFrameFadeOut(Frame.RestingIcon, 2, Frame.RestingIcon:GetAlpha(), 0)
            Frame.RestingIcon.Animation:Stop()
        end
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

function UF:UpdateResurrectionIcon(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.ResurrectionIcon) then
        return
    end

    local UnitHasIncomingResurrection = UnitHasIncomingResurrection(Unit)

    if (UnitHasIncomingResurrection) then
        Frame.ResurrectionIcon:Show()
    else
        Frame.ResurrectionIcon:Hide()
    end
end

function UF:UpdateAssistantIcon(Frame)
    if (not Frame or not Frame.unit or not Frame.AssistantIcon) then
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
    local HasLFGRestrictions = HasLFGRestrictions()
    local Leader

    if (IsInInstance()) then
        Leader = UnitIsGroupLeader(Unit)
    else
        Leader = UnitLeadsAnyGroup(Unit)
    end

    if (Leader) then
        if (HasLFGRestrictions) then
            Frame.LeaderIcon:SetAtlas("UI-HUD-UnitFrame-Player-Group-GuideIcon")
        else
            Frame.LeaderIcon:SetAtlas("UI-HUD-UnitFrame-Player-Group-LeaderIcon")
        end

        Frame.LeaderIcon:Show()
    else
        Frame.LeaderIcon:Hide()
    end
end

function UF:UpdateSummonIcon(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.SummonIcon) then
        return
    end

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

function UF:UpdatePhaseIcon(Frame, Unit)
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

function UF:UpdateReadyCheckIcon(Frame, Event)
    if (not Frame or not Frame.unit or not Frame.ReadyCheckIcon) then
        return
    end

    local Unit = Frame.unit
    local Status = GetReadyCheckStatus(Unit)

    if (Status) then
        if (Status == "ready") then
            Frame.ReadyCheckIcon:SetTexture(READY_CHECK_READY_TEXTURE)
        elseif (Status == "notready") then
            Frame.ReadyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
        else
            Frame.ReadyCheckIcon:SetTexture(READY_CHECK_WAITING_TEXTURE)
        end

        Frame.ReadyCheckIcon.Status = Status
        Frame.ReadyCheckIcon:Show()
    elseif (Event ~= "READY_CHECK_FINISHED") then
        Frame.ReadyCheckIcon.Status = nil
        Frame.ReadyCheckIcon:Hide()
    end

    if (Event == "READY_CHECK_FINISHED") then
        if (Frame.ReadyCheckIcon.Status == "waiting") then
            Frame.ReadyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
        end

        Frame.ReadyCheckIcon.Animation:Play()
    end
end

function UF:UpdateRoleIcon(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.RoleIcon) then
        return
    end

    local Unit = Frame.unit
    local Role = UnitGroupRolesAssignedEnum(Unit)

    if (Role == Enum.LFGRole.Tank) then
        Frame.RoleIcon:SetAtlas("roleicon-tiny-tank")
        Frame.RoleIcon:Show()
    elseif (Role == Enum.LFGRole.Healer) then
        Frame.RoleIcon:SetAtlas("roleicon-tiny-healer")
        Frame.RoleIcon:Show()
    elseif (Role == Enum.LFGRole.Damage) then
        Frame.RoleIcon:SetAtlas("roleicon-tiny-dps")
        Frame.RoleIcon:Show()
    else
        Frame.RoleIcon:Hide()
    end
end

-- THREAT

function UF:UpdateThreatHighlight(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.Threat) then
        return
    end

    local Threat = UnitThreatSituation("player", Unit)
    
    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        Frame.Threat.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)

        Frame.Threat:Show()
    else
        Frame.Threat:Hide()
    end
end

function UF:UpdateThreatHighlightRaid(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.Threat) then
        return
    end

    local Threat = UnitThreatSituation(Unit)

    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        Frame.Threat.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)

        if (not Frame.Threat.Animation:IsPlaying()) then
            Frame.Threat:Show()
            Frame.Threat.Animation:Play()
        end 
    else
        if (Frame.Threat.Animation and Frame.Threat.Animation:IsPlaying()) then
            Frame.Threat.Animation:Stop()
            Frame.Threat:Hide()
        end
    end
end

-- DEBUFF HIGHLIGHT

function UF:UpdateDebuffHighlight(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.DebuffHighlight) then
        return
    end

    local Index = 1

    while true do
        local AuraData = GetAuraDataByIndex(Unit, Index, "HARMFUL")

        if (not AuraData or not AuraData.name) then
            break
        end

        local Color = GetAuraDispelTypeColor(Unit, AuraData.auraInstanceID, UI.DispelHighlightColorCurve)

        if (Color) then
            Frame.DebuffHighlight.Glow:SetBackdropBorderColor(Color.r * 0.55, Color.g * 0.55, Color.b * 0.55, 0.8)
        else
            Frame.DebuffHighlight.Glow:SetBackdropBorderColor(0, 0, 0, 0)
        end

        Index = Index + 1
    end
end

-- RANGE

function UF:IsAnySpellInRange(Unit, Spells)
    local AnySpellChecked = false

    for SpellID in pairs(Spells) do
        local Spell = C_Spell.IsSpellInRange(SpellID, Unit)

        if (Spell == true) then
            return true
        elseif (Spell ~= nil) then
            AnySpellChecked = true
        end
    end

    if (AnySpellChecked) then
        return false
    end

    return nil
end

function UF:CheckUnitCategoryRange(Unit, Category)
    local Spells = UF.RangeSpells[Category]
    local Class = select(2, UnitClass("player"))

    if (not Spells or not Class or not Spells[Class]) then
        if (Category == "FRIENDLY") then
            if InCombatLockdown() then
                return true
            else
                return CheckInteractDistance(Unit, 4)
            end
        else
            return nil
        end
    end

    local SpellList = Spells[Class]

    if (type(SpellList) == "number") then
        SpellList = { SpellList }
    end

    local Range = UF:IsAnySpellInRange(Unit, SpellList)

    if (Category == "FRIENDLY" and Range == nil) then
        if InCombatLockdown() then
            return true
        else
            return CheckInteractDistance(Unit, 4)
        end
    end

    return Range
end

function UF:IsFriendlyUnitReachable(Unit)
    if (UnitIsPlayer(Unit) and UnitPhaseReason(Unit)) then
        return false
    end

    local Range = UF:CheckUnitCategoryRange(Unit, "FRIENDLY")

    if (Range == nil) then
        return true
    end

    return Range
end

function UF:UpdateRangeState(Frame, Unit)
    if (not Frame or not Frame.unit or not Frame.Range) then
        return
    end

    local Range = UF.Frames.Range[Unit]

    if (UnitIsDeadOrGhost(Unit)) then
        return
    elseif (UnitCanAttack("player", Unit)) then
        Range = UF:CheckUnitCategoryRange(Unit, "ENEMY")
    --elseif UnitIsUnit("pet", Unit) then
    --    Range = UF:CheckUnitCategoryRange(Unit, "PET")
    elseif (UnitIsConnected(Unit)) then
        Range = UF:IsFriendlyUnitReachable(Unit)
    else
        Range = false
    end

    if (Range == true) then
        UI:UIFrameFadeIn(Frame, Frame.Range.FadeTime, Frame:GetAlpha(), Frame.Range.InRangeAlpha)
    elseif (Range == false) then
        UI:UIFrameFadeOut(Frame, Frame.Range.FadeTime, Frame:GetAlpha(), Frame.Range.OutOfRangeAlpha)
    end
end

function UF:UpdateRange(Frame, Unit)
    if (not Frame or not Frame.Range) then 
        return 
    end

    UF:UpdateRangeState(Frame, Unit)

    if (Frame.Range.Ticker) then
        return
    end

    Frame.Range.Ticker = C_Timer.NewTicker(0.2, function()
        if (Frame.unit and UnitExists(Frame.unit)) then
            UF:UpdateRangeState(Frame, Frame.unit)
        end
    end)

    Frame:SetScript("OnHide", function(self)
        if (self.Range.Ticker) then
            self.Range.Ticker:Cancel()
            self.Range.Ticker = nil
        end
    end)
end

--- UPDATE FRAMES

function UF:ProcessFrame(Frame)
    local Unit = Frame.unit

    if (not Unit or not UnitExists(Unit)) then
        return
    end

    -- HEALTH
    if (Frame.NeedsHealth) then
        if (Frame.Health) then self:UpdateHealth(Frame, Unit) end
        if (Frame.HealthTextCur) then self:UpdateHealthTextCur(Frame, Unit) end
        if (Frame.HealthTextPer) then self:UpdateHealthTextPer(Frame, Unit) end

        Frame.NeedsHealth = nil
    end

    -- HEALTH PRED
    if (Frame.NeedsHealthPred) then
        if (Frame.HealthPrediction) then self:UpdateHealthPred(Frame, Unit) end

        Frame.NeedsHealthPred = nil
    end

    -- POWER
    if (Frame.NeedsPower) then
        if (Frame.PowerText) then self:UpdatePower(Frame, Unit) end
        if (Frame.AdditionalPower) then self:UpdateAdditionalPower(Frame) end

        Frame.NeedsPower = nil
    end

    -- AURAS
    if (Frame.NeedsAuras) then
        if (Frame.Buffs) then self:UpdateAuras(Frame, Unit, false) end
        if (Frame.Debuffs) then self:UpdateAuras(Frame, Unit, true) end
        if (Frame.External) then self:UpdateAuras(Frame, Unit, false, true) end

        Frame.NeedsAuras = nil
    end

    -- NAME
    if (Frame.NeedsName) then
        if (Frame.Name) then self:UpdateName(Frame, Unit, Frame.IsParty and "Party" or Frame.IsRaid and "Raid") end
        if (Frame.NameLevel) then self:UpdateTargetNameLevel(Frame, Unit) end

        Frame.NeedsName = nil
    end

    -- ICONS
    if (Frame.NeedsIcons) then
        if (Frame.CombatIcon) then self:UpdateCombatIcon(Frame) end
        if (Frame.RestingIcon) then self:UpdateRestingIcon(Frame) end
        if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame) end
        if (Frame.LeaderIcon) then self:UpdateLeaderIcon(Frame) end
        if (Frame.AssistantIcon) then self:UpdateAssistantIcon(Frame) end
        if (Frame.ResurrectionIcon) then self:UpdateResurrectionIcon(Frame, Unit) end
        if (Frame.SummonIcon) then self:UpdateSummonIcon(Frame, Unit) end
        if (Frame.PhaseIcon) then self:UpdatePhaseIcon(Frame, Unit) end
        if (Frame.ReadyCheckIcon) then self:UpdateReadyCheckIcon(Frame) end
        if (Frame.RoleIcon) then self:UpdateRoleIcon(Frame, Unit) end

        Frame.NeedsIcons = nil
    end

    -- THREAT
    if (Frame.NeedsThreat) then
        if (Frame.Threat) then
            if (Frame.IsRaid) then
                self:UpdateThreatHighlightRaid(Frame, Unit)
            else
                self:UpdateThreatHighlight(Frame, Unit)
            end
        end

        Frame.NeedsThreat = nil
    end

    -- RANGE
    if (Frame.NeedsRange) then
        if (Frame.Range) then self:UpdateRange(Frame, Unit) end

        Frame.NeedsRange = nil
    end

    -- PORTRAIT
    if (Frame.NeedsPortrait) then
        if (Frame.Portrait) then self:UpdatePortrait(Frame, Unit) end

        Frame.NeedsPortrait = nil
    end
end

function UF:QueueUpdate(Frame, Unit, Flag)
    if (type(Frame) ~= "table" or not Unit) then
        return
    end

    if (Flag) then
        Frame[Flag] = true
    end

    local Queue = self.UpdateQueue
    local UnitQueue = Queue[Unit]

    if (not UnitQueue) then
        UnitQueue = {}
        Queue[Unit] = UnitQueue
    end

    UnitQueue[Frame] = true
end

local RefreshFlags = {
    "NeedsHealth",
    "NeedsHealthPred",
    "NeedsPower",
    "NeedsAuras",
    "NeedsName",
    "NeedsIcons",
    "NeedsThreat",
    "NeedsRange",
    "NeedsPortrait"
}

function UF:RefreshUnit(Unit)
    local Frame = self.Frames[Unit]

    if (not Frame) then
        return
    end

    for i = 1, #RefreshFlags do
        local Flag = RefreshFlags[i]
        self:QueueUpdate(Frame, Unit, Flag)
    end
end

function UF:FullRefresh()
    for Unit, Frame in next, self.Frames do
        if (type(Frame) == "table" and Frame.unit) then
            self:RefreshUnit(Unit)
        end
    end
end

function UF:FullRefreshGroup()
    for Group, Flags in next, RefreshFlags do
        local Frames = self.Frames[Group]

        if (Frames) then
            for Unit, Frame in next, Frames do
                for i = 1, #Flags do
                    local Flag = Flags[i]
                    self:QueueUpdate(Frame, Unit, Flag)
                end
            end
        end
    end
end

function UF:QueueIconsForAll()
    for Unit, Frame in next, self.Frames do
        if (type(Frame) == "table" and Frame.unit) then
            self:QueueUpdate(Frame, Frame.unit, "NeedsIcons")
        end
    end
end

function UF:UpdateQueueTicker()
    self:SetScript("OnUpdate", function(_, Elapsed)
        if (not next(UF.UpdateQueue)) then
            return
        end

        UF.UpdaterTicker = UF.UpdaterTicker + Elapsed

        if (UF.UpdaterTicker < 0.1) then
            return
        end

        UF.UpdaterTicker = 0

        for Unit, Frames in next, UF.UpdateQueue do
            for Frame in next, Frames do
                UF:ProcessFrame(Frame)
            end

            UF.UpdateQueue[Unit] = nil
        end
    end)
end

-- ON EVENTS

local IconEvents = {
    PLAYER_UPDATE_RESTING = true,
    RAID_TARGET_UPDATE = true,
    READY_CHECK = true,
    READY_CHECK_CONFIRM = true,
    READY_CHECK_FINISHED = true,
    PARTY_LEADER_CHANGED = true,
    GROUP_ROSTER_UPDATE = true,
    INCOMING_RESURRECT_CHANGED = true,
    INCOMING_SUMMON_CHANGED = true,
    UNIT_PHASE = true,
    PLAYER_ROLES_ASSIGNED = true,
}

function UF:OnEvent(event, unit, ...)
    local FramesUF = unit and UF.Frames[unit]

    if (event == "PLAYER_ENTERING_WORLD") then
        C_Timer.After(0.7, function()
            UF:FullRefresh()
            UF:UpdatePlayerPortrait()
            UF:UpdateTargetPortrait()
        end)
    elseif (event == "PLAYER_TARGET_CHANGED") then
        UF:RefreshUnit("target")
        UF:RefreshUnit("player")
        UF:RefreshUnit("targettarget")
        UF:UpdateTargetPortrait()
        UF:ClearCastBarOnUnit("target")
    elseif (event == "UNIT_TARGET" and unit == "target") then
        UF:RefreshUnit("targettarget")
    elseif (event == "UNIT_PET") then
        UF:RefreshUnit("pet")
    elseif (event == "PLAYER_FOCUS_CHANGED") then
        UF:RefreshUnit("focus")
    elseif (event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" or event == "UNIT_TARGETABLE_CHANGED") then
        for i = 1, 5 do
            UF:RefreshUnit("boss"..i)
        end
    end

    if (IconEvents[event]) then
        UF:QueueIconsForAll()
    end

    if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
        UF:CastStarted(event, unit)
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        UF:CastStopped(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then
        UF:CastFailed(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
        UF:CastSucceeded(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        UF:CastUpdated(event, unit)
    elseif (event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        UF:CastNonInterruptable(event, unit)
    end

    if (not FramesUF) then
        return
    end

    if (event == "UNIT_AURA") then
        UF:QueueUpdate(FramesUF, unit, "NeedsAuras")
    elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_CONNECTION") then
        UF:QueueUpdate(FramesUF, unit, "NeedsHealth")
        UF:RefreshUnit("targettarget")
    elseif (event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED") then
        UF:QueueUpdate(FramesUF, unit, "NeedsHealthPred")
    elseif (event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER") then
        UF:QueueUpdate(FramesUF, unit, "NeedsPower")
    elseif (event == "UNIT_NAME_UPDATE" or event == "UNIT_LEVEL" or event == "PLAYER_LEVEL_UP") then
        UF:QueueUpdate(FramesUF, unit, "NeedsName")
    elseif (event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE") then
        UF:QueueUpdate(FramesUF, unit, "NeedsThreat")
    elseif (event == "UNIT_MODEL_CHANGED" or event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED") then
        UF:QueueUpdate(FramesUF, unit, "NeedsPortrait")
    elseif (event == "UNIT_FLAGS") then
        UF:QueueUpdate(FramesUF, unit, "NeedsIcons")
    end
end

-- INITIALIZE & REGISTER EVENTS

function UF:RegisterEvents()
    local SecureEventFrame = UF.SecureFrame

    -- UNITS
    SecureEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
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
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    -- BUFFS / DEBUFFS
    SecureEventFrame:RegisterEvent("UNIT_AURA")
    -- HEALTH
    SecureEventFrame:RegisterEvent("UNIT_HEALTH")
    SecureEventFrame:RegisterEvent("UNIT_MAXHEALTH")
    SecureEventFrame:RegisterEvent("UNIT_CONNECTION")
    -- HEALTH PRED
    SecureEventFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
    SecureEventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED")
    -- POWER
    SecureEventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
    SecureEventFrame:RegisterEvent("UNIT_MAXPOWER")
    SecureEventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    SecureEventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    -- NAME
    SecureEventFrame:RegisterEvent("UNIT_NAME_UPDATE")
    -- LEVEL
    SecureEventFrame:RegisterEvent("UNIT_LEVEL")
    SecureEventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    -- THREAT
    SecureEventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
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
    SecureEventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    -- PORTRAITS
    SecureEventFrame:RegisterEvent("UNIT_MODEL_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    SecureEventFrame:RegisterEvent("PORTRAITS_UPDATED")
    -- ON EVENT
    SecureEventFrame:SetScript("OnEvent", function(_, event, ...)
        UF:OnEvent(event, ...)
    end)
end

function UF:Initialize()
    if (not DB.Global.UnitFrames.Enable) then
        return
    end

    self:DisableBlizzard()
    self:CreateUF()
    self:RegisterEvents()
    self:UpdateQueueTicker()
end