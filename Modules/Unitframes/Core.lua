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
local InCombatLockdown = InCombatLockdown
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
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
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

-- WoW Globals
local SUMMON_STATUS_NONE = Enum.SummonStatus.None or 0
local SUMMON_STATUS_PENDING = Enum.SummonStatus.Pending or 1
local SUMMON_STATUS_ACCEPTED = Enum.SummonStatus.Accepted or 2
local SUMMON_STATUS_DECLINED = Enum.SummonStatus.Declined or 3

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

-- Locals
UF.HiddenFrames = {}
UF.Frames = {}

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

-- BUFF / DEBUFFS

function UF:UpdateAuras(Frame, Unit, IsDebuff)
    local Auras = IsDebuff and Frame.Debuffs or Frame.Buffs

    if not (Auras) then 
        return 
    end

    local AurasToShow = Auras.NumAuras or 7
    local Spacing = Auras.Spacing or 4
    local ButtonSize = 24
    local ActiveButtons = 0
    local Index = 1

    for _, Buttons in ipairs(Auras.Buttons) do
        Buttons:Hide()
    end

    while ActiveButtons < AurasToShow do
        local AuraData = GetAuraDataByIndex(Unit, Index, IsDebuff and "HARMFUL" or "HELPFUL")

        if (not AuraData or not AuraData.name) then
            break
        end

        local Name = AuraData.name
        local Icon = AuraData.icon
        local Count = AuraData.applications
        local Duration = AuraData.duration
        local ExpirationTime = AuraData.expirationTime
        local AuraInstanceID = AuraData.auraInstanceID
        local Button = Auras.Buttons[ActiveButtons + 1]

        if not (Button) then
            break
        end

        if (Button.Icon) then
            if (Icon) then
                Button.Icon:SetTexture(Icon)
            end
        end

        if (Button.Count) then
            if (Count) then
                Button.Count:SetText(C_StringUtil.TruncateWhenZero(Count))
            else
                Button.Count:SetText("")
            end
        end

        if (Button.Cooldown) then
            if C_StringUtil.TruncateWhenZero(Duration) then
                Button.Cooldown:SetCooldown(Duration, ExpirationTime)
                Button.Cooldown:SetCooldownFromExpirationTime(ExpirationTime, Duration)
            end

            local NumRegions = Button.Cooldown:GetNumRegions()

            for i = 1, NumRegions do
                local Region = select(i, Button.Cooldown:GetRegions())

                if (Region.GetText) then
                    Region:ClearAllPoints()
                    Region:Point("CENTER", Button.Overlay, 0, -7)
                    Region:SetFontTemplate("Default", 13)
                    Region:SetTextColor(1, 0.82, 0)
                end
            end
        end

        if (IsDebuff) then
            -- Getting debuff color is SECRET.
            --local Color = DebuffTypeColor[AuraData.dispelName] or DebuffTypeColor.none

            Button:SetColorTemplate(1, 0, 0)
        else
            Button:SetColorTemplate(unpack(DB.Global.General.BorderColor))
        end

        local Direction = Auras.Direction or "RIGHT"
        local OffsetMultiplier = (Direction == "RIGHT") and 1 or -1

        Button:ClearAllPoints()
        Button:Point(Auras.InitialAnchor, Auras, Auras.InitialAnchor, ActiveButtons * (ButtonSize + Spacing) * OffsetMultiplier, 0)
        Button:Show()

        ActiveButtons = ActiveButtons + 1
        Index = Index + 1
    end

    for i = ActiveButtons + 1, #Auras.Buttons do
        if Auras.Buttons[i] then
            Auras.Buttons[i]:Hide()
        end
    end
end

-- CASTBARS

function UF:UpdateCastBars(Frame)
    local Castbar = Frame.Castbar

    if (not Castbar or not Castbar:IsShown()) then
        return
    end

    local StartTime = Castbar.StartTime
    local EndTime = Castbar.EndTime

    if (not StartTime or not EndTime) then
        return
    end

    local GetTime = GetTime()
    local Duration = EndTime - StartTime
    local Elapsed = GetTime - StartTime
    local Remaining = EndTime - GetTime
    Elapsed = math.max(0, math.min(Elapsed, Duration))
    Remaining = math.max(0, math.min(Remaining, Duration))

    Castbar:SetMinMaxValues(0, Duration)
    Castbar.Max = Duration
    Castbar.Delay = Castbar.Delay or 0

    if (not Castbar.Channeling) then
        Castbar:SetValue(Elapsed)

        if (Castbar.CustomTimeText) then
            Castbar:CustomTimeText(Elapsed)
        end
    else
        Castbar:SetValue(Remaining)

        if (Castbar.CustomTimeText) then
            Castbar:CustomTimeText(Remaining)
        end
    end
end

function UF:CastStart(Unit)
    local Frame = self.Frames[Unit]

    if (not Frame or not Frame.Castbar) then
        return
    end

    local Name, _, Icon, StartTime, EndTime, NotInterruptible = UnitCastingInfo(Unit)
    local Channeling = false

    if (not Name) then
        Name, _, Icon, StartTime, EndTime = UnitChannelInfo(Unit)
        Channeling = Name ~= nil
    end

    if (not Name) then
        self:CastStop(Unit)
        return
    end

    if (type(StartTime) == "number") then
        StartTime = StartTime / 1000
    end

    if (type(EndTime) == "number") then
        EndTime = EndTime / 1000
    end

    Frame.Castbar.StartTime = StartTime or GetTime()
    Frame.Castbar.EndTime = EndTime or (GetTime() + 1.5)
    Frame.Castbar.Channeling = Channeling
    --Frame.Castbar.NotInterruptible = NotInterruptible
    Frame.Castbar.Max = Frame.Castbar.EndTime - Frame.Castbar.StartTime
    Frame.Castbar.Delay = 0

    if (Frame.Castbar.Icon) then
        Frame.Castbar.Icon:SetTexture(Icon)
    end

    if (Frame.Castbar.Text) then
        Frame.Castbar.Text:SetText(Name)
    end

    if (Frame.Castbar.PostCastStart) then
        Frame.Castbar:PostCastStart(Frame.Castbar)
    end

    UI:UIFrameFadeOut(Frame.Castbar, UF.FadeInTime, Frame.Castbar:GetAlpha(), 1)
end

function UF:CastStop(Unit)
    local Frame = self.Frames[Unit]

    if (not Frame or not Frame.Castbar) then
        return
    end

    if (Frame.Castbar.PostCastStop) then
        Frame.Castbar:PostCastStop(Frame.Castbar)
    end

    Frame.Castbar.StartTime = nil
    Frame.Castbar.EndTime = nil
    Frame.Castbar.Channeling = nil
    Frame.Castbar.NotInterruptible = nil
    Frame.Castbar.Max = nil
    Frame.Castbar.Delay = nil

    UI:UIFrameFadeOut(Frame.Castbar, UF.FadeInTime, Frame.Castbar:GetAlpha(), 0)
end

function UF:PostCastStart()
    --[[
    if (self.NotInterruptible) then
        self:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))

        if (self.Icon) then
            self.Icon:SetDesaturated(1)
        end
    else
        self:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))

        if (self.Icon) then
            self.Icon:SetDesaturated(false)
        end
    end
    --]]

    UI:UIFrameFadeIn(self, UF.FadeInTime, self:GetAlpha(), 1)
end

function UF:PostCastStop()
    self:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))

    if (self.Text) then
        self.Text:SetText(FAILED or INTERRUPTED)
    end

    UI:UIFrameFadeOut(self, UF.FadeInTime, self:GetAlpha(), 0)
end

function UF:PostCastFailed()
    if (self.Text) then 
        self.Text:SetText(FAILED or INTERRUPTED) 
    end
    
    self:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))
    self:SetMinMaxValues(0, 1)
    self:SetValue(1)

    UI:UIFrameFadeOut(self, UF.FadeInTime, self:GetAlpha(), 0)
end

--- UPDATE HEALTH

function UF:UpdateHealth(Frame)
    local Unit = Frame.unit
    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)

    if (not Frame.Health) then
        return
    end

    Frame.Health:SetMinMaxValues(0, Max)
    Frame.Health:SetValue(Min, UI.SmoothBars)

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
    local Unit = Frame.unit
    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)

    if (not Frame.HealthTextCur) then
        return
    end

    Frame.HealthTextCur:SetText(AbbreviateNumbers(Min))
end

function UF:UpdateHealthTextPer(Frame)
    local Unit = Frame.unit
    local Percent = UnitHealthPercent(Unit, false, true)

    if (not Frame.HealthTextPer) then
        return
    end

    Frame.HealthTextPer:SetFormattedText("%d%%", Percent or 0)
end

-- HEAL PRED

function UF:UpdateHealthPred(Frame)
    local Unit = Frame.unit
    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)
    local AbsorbAmount = UnitGetTotalAbsorbs(Unit) or 0

    if (not Frame.AbsorbBar) then
        return
    end

    if (AbsorbAmount) then
        local HealthOrientation = Frame.Health:GetOrientation()
        local PreviousTexture = Frame.Health:GetStatusBarTexture()
        local TotalWidth = Frame.Health:GetWidth()
        local TotalHeight = Frame.Health:GetHeight()

        Frame.AbsorbBar:SetMinMaxValues(0, Max)
        Frame.AbsorbBar:SetValue(AbsorbAmount, Enum.StatusBarInterpolation.ExponentialEaseOut)

        Frame.AbsorbBar:SetOrientation(HealthOrientation)
        Frame.AbsorbBar:SetParent(Frame.Health)
        Frame.AbsorbBar:Size(TotalWidth, TotalHeight)
        Frame.AbsorbBar:Point("LEFT", PreviousTexture, "RIGHT", 0, 0)
        Frame.AbsorbBar:Show()
    else
        Frame.AbsorbBar:Hide()
    end
end

--- UPDATE POWER

function UF:UpdatePower(Frame)
    local Unit = Frame.unit
    local PowerType, PowerToken = UnitPowerType(Unit)
    local Min, Max = UnitPower(Unit, PowerType), UnitPowerMax(Unit, PowerType)
    local PowerColor = UI.Colors.Power[PowerToken]

    if not (Frame.PowerText) then
        return
    end

    Frame.PowerText:SetText(AbbreviateNumbers(Min))

    if (PowerColor) then
        Frame.PowerText:SetTextColor(unpack(PowerColor))
    end
end

--- UPDATE NAME

function UF:UpdateName(Frame)
    local Unit = Frame.unit

    if not (Frame.Name) then
        return
    end

    local Name = UnitName(Unit) or ""

    if (Name) then
        --Frame.Name:SetText(UTF8Sub(Name, 12))
        Frame.Name:SetText(Name)
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

function UF:UpdateNameRaid(Frame)
    local Unit = Frame.unit

    if not (Frame.Name) then
        return
    end

    local Name = UnitName(Unit) or ""

    if (Name) then
        Frame.Name:SetText(UTF8Sub(Name, 8))
        --Frame.Name:SetText(Name)
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

function UF:UpdateNameParty(Frame)
    local Unit = Frame.unit

    if not (Frame.Name) then
        return
    end

    local Name = UnitName(Unit) or ""

    if (Name) then
        Frame.Name:SetText(UTF8Sub(Name, 12))
        --Frame.Name:SetText(Name)
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
    local Unit = Frame.unit
    local Name = UnitName(Unit) or ""
    local Level = UnitLevel(Unit) or -1
    local NameColor, LevelColor, LevelText

    if not (Frame.NameLevel) then
        return
    end

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
    local Unit = Frame.unit

    if (not Frame.Portrait) then
        return
    end

    if (not UnitExists(Unit)) then
        Frame.Portrait:ClearModel()
        return
    end

    C_Timer.After(0, function()
        if (not UnitExists(Unit) or not Frame.Portrait) then
            if (Frame.Portrait) then 
                Frame.Portrait:ClearModel() 
            end
        else
            Frame.Portrait:SetUnit(Unit)
            Frame.Portrait:SetCamDistanceScale(2.5)
            Frame.Portrait:SetPortraitZoom(1)
            Frame.Portrait:SetPosition(0, 0, 0)
        end
    end)
end

-- ICONS

function UF:UpdateRestingIcon(Frame)
    local Unit = Frame.unit
    local IsResting = IsResting()

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.RestingIcon) then
        return
    end

    if (IsResting) then
        Frame.RestingIcon:Show()
    else
        Frame.RestingIcon:Hide()
    end
end

function UF:UpdateCombatIcon(Frame)
    local Unit = Frame.unit
    local UnitAffectingCombat = UnitAffectingCombat("player")

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.CombatIcon) then
        return
    end

    if (UnitAffectingCombat) then
        Frame.CombatIcon:Show()
    else
        Frame.CombatIcon:Hide()
    end
end

function UF:UpdateRaidIcon(Frame)
    local Unit = Frame.unit
    local Index = GetRaidTargetIndex(Unit)

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.RaidIcon) then
        return
    end

    if (Index) then
        Frame.RaidIcon:Show()
        SetRaidTargetIconTexture(Frame.RaidIcon, Index)
    else
        Frame.RaidIcon:Hide()
    end
end

function UF:UpdateResurrectionIcon(Frame)
    local Unit = Frame.unit

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.ResurrectIcon) then
        return
    end

    local UnitHasIncomingResurrection = UnitHasIncomingResurrection(Unit)

    if (UnitHasIncomingResurrection) then
        Frame.ResurrectIcon:Show()
    else
        Frame.ResurrectIcon:Hide()
    end
end

function UF:UpdateAssistantIcon(Frame)
    local Unit = Frame.unit

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.AssistantIcon) then
        return
    end

    local IsAssistant = UnitInRaid(Unit) and UnitIsGroupAssistant(Unit) and not UnitIsGroupLeader(Unit)

    if (IsAssistant) then
        Frame.AssistantIcon:Show()
    else
        Frame.AssistantIcon:Hide()
    end
end

function UF:UpdateLeaderIcon(Frame)
    local Unit = Frame.unit

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.LeaderIcon) then
        return
    end

    local UnitIsGroupLeader = UnitIsGroupLeader(Unit)

    if (UnitIsGroupLeader) then
        Frame.LeaderIcon:Show()
    else
        Frame.LeaderIcon:Hide()
    end
end

function UF:UpdateSummonIcon(Frame)
    local Unit = Frame.unit

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.SummonIcon) then
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

function UF:UpdatePhaseIcon(Frame)
    local Unit = Frame.unit

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.PhaseIcon) then
        return
    end

    local IsPhased = UnitIsPlayer(Unit) and UnitIsConnected(Unit) and UnitPhaseReason(Unit) or nil

    if (IsPhased) then
        Frame.PhaseIcon:Show()
    else
        Frame.PhaseIcon:Hide()
    end
end

-- THREAT

function UF:UpdateThreatHighlight(Frame)
    local Unit = Frame.unit

    if (not Unit) then
        return
    end

    if (not Frame.Threat) then
        return
    end

    local Threat = UnitThreatSituation("player", Unit)
    
    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        Frame.Threat.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)
    else
        Frame.Threat.Glow:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

function UF:UpdateThreatHighlightRaid(Frame)
    local Unit = Frame.unit

    if (not Unit) then
        return
    end

    if (not Frame.ThreatRaid) then
        return
    end

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
    -- POWER
    if (Frame.PowerText) then self:UpdatePower(Frame) end
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
    -- HEALTH PRED
    if (Frame.UpdateHealthPred)then self:UpdateHealthPred(Frame) end
    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame) end
    if (Frame.ThreatRaid) then self:UpdateThreatHighlightRaid(Frame) end
end

-- SECURE UPDATES

function UF:SecureUpdate()
    if (not UF._onupdate_set) then
        UF.SecureFrame:SetScript("OnUpdate", function(_, elapsed)
            for _, Frame in pairs(UF.Frames) do
                if (Frame.Castbar and Frame.Castbar:IsShown()) then
                    UF:UpdateCastBars(Frame)
                end
            end
        end)

        UF._onupdate_set = true
    end
end

function UF:ForceToTUpdate()
    local Frame = UF.Frames["targettarget"]

    if not Frame then 
        return 
    end

    if UnitExists("targettarget") then
        UF:UpdateFrame("targettarget")
    end
end

-- ON EVENTS

function UF:OnEvent(event, arg1)
    local FramesUF = UF.Frames[arg1]

    -- UNITFRAMES LOG IN UPDATE
    if (event == "PLAYER_ENTERING_WORLD") then
        C_Timer.After(0.1, function()
            for Unit, Frame in pairs(UF.Frames) do
                UF:UpdateFrame(Unit)
            end
        end)

        C_Timer.After(0.05, function()
            UF:ForceToTUpdate()
        end)

        -- UNITFRAMES UPDATE    
    elseif (event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGETABLE_CHANGED") then
        for Unit, Frame in pairs(UF.Frames) do
            UF:UpdateFrame(Unit)
        end

        UF:ForceToTUpdate()
    elseif (event == "UNIT_TARGET" and arg1 == "target") then
        UF:ForceToTUpdate()

    elseif (event == "UNIT_PET") then
        UF:UpdateFrame("pet")
    elseif (event == "PLAYER_FOCUS_CHANGED") then
        UF:UpdateFrame("focus")

        -- BUFFS / DEBUFFS
    elseif (event == "UNIT_AURA") then
        if (FramesUF) then
            UF:UpdateAuras(FramesUF, arg1, true)
            UF:UpdateAuras(FramesUF, arg1, false)
        end

        -- HEALTH UPDATE
    elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
        if (FramesUF) then
            UF:UpdateHealth(FramesUF)
            UF:UpdateHealthTextCur(FramesUF)
            UF:UpdateHealthTextPer(FramesUF)
        end
        
        -- HEAL PRED
    elseif (event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED") then
        if (FramesUF) then
            UF:UpdateHealthPred(FramesUF)
        end

        -- POWER UPDATE    
    elseif (event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER") then
        if (FramesUF) then
            UF:UpdatePower(FramesUF)
        end

        -- THREAT
    elseif (event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE") then
        if (FramesUF) then
            UF:UpdateThreatHighlight(FramesUF)
            UF:UpdateThreatHighlightRaid(FramesUF)
        end

        -- NAME UPDATE
    elseif (event == "UNIT_NAME_UPDATE") then
        if (FramesUF) then
            UF:UpdateName(FramesUF)
        end

        -- LEVEL UPDATE    
    elseif (event == "UNIT_LEVEL" or event == "PLAYER_LEVEL_UP") then
        if (FramesUF) then
            UF:UpdateTargetNameLevel(FramesUF)
        end

        -- ICONS
    elseif (event == "PLAYER_UPDATE_RESTING") then
        if (FramesUF) then
            UF:UpdateRestingIcon(FramesUF)
        end

    elseif (event == "RAID_TARGET_UPDATE") then
        if (FramesUF) then
            UF:UpdateRaidIcon(FramesUF)
        end

    elseif (event == "INCOMING_RESURRECT_CHANGED") then
        if (FramesUF) then
            UF:UpdateResurrectionIcon(FramesUF)
        end

    elseif (event == "UNIT_FLAGS" or event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE") then
        if (FramesUF) then
            UF:UpdateCombatIcon(FramesUF)
            UF:UpdateLeaderIcon(FramesUF)
            UF:UpdateAssistantIcon(FramesUF)
        end

    elseif (event == "INCOMING_SUMMON_CHANGED") then
        if (FramesUF) then
            UF:UpdateSummonIcon(FramesUF)
        end

    elseif (event == "UNIT_PHASE") then
        if (FramesUF) then
            UF:UpdatePhaseIcon(FramesUF)
        end

        -- CASTBAR UPDATE
    elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START") then
        if (FramesUF and FramesUF.Castbar) then
            UF:CastStart(arg1)
        end
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
        if (FramesUF and FramesUF.Castbar) then
            UF:CastStop(arg1)
        end
    elseif (event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED") then
        if (FramesUF and FramesUF.Castbar and FramesUF.Castbar.PostCastFailed) then
            FramesUF.Castbar:PostCastFailed()
        end

        -- PORTRAIT UPDATE
    elseif (event == "UNIT_MODEL_CHANGED" or event == "UNIT_PORTRAIT_UPDATE") then
        if (FramesUF and FramesUF.Portrait) then
            UF:UpdatePortrait(FramesUF)
        end
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
    SecureEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    SecureEventFrame:RegisterEvent("INCOMING_SUMMON_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_PHASE")
    -- POWER
    SecureEventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
    SecureEventFrame:RegisterEvent("UNIT_MAXPOWER")
    SecureEventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    -- UNITS
    SecureEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    SecureEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_TARGETABLE_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_TARGET")
    SecureEventFrame:RegisterEvent("UNIT_PET")
    -- CASTBAR
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
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
    -- SECURE UPDATE
    self:SecureUpdate()
    -- EVENTS
    self:RegisterEvents()
end