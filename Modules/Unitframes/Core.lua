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

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

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

-- BUFF / DEBUFFS

function UF:UpdateAuras(Frame, Unit, IsDebuff)
    local Auras = IsDebuff and Frame.Debuffs or Frame.Buffs

    if (not Auras) then 
        return 
    end

    local AuraWidth, AuraHeight = Auras:GetWidth(), Auras:GetHeight()
    local AurasToShow = Auras.NumAuras or 6
    local Spacing = Auras.Spacing or 4
    local OnlyPlayerDebuffs = Auras.ShowOnlyPlayer
    local ActiveButtons = 0
    local Index = 1
    local HarmState

    for _, Buttons in ipairs(Auras.Buttons) do
        Buttons:Hide()
    end

    if (OnlyPlayerDebuffs) then
        HarmState = "HARMFUL|PLAYER"
    else
        HarmState = "HARMFUl"
    end

    while ActiveButtons < AurasToShow do
        local AuraData = GetAuraDataByIndex(Unit, Index, IsDebuff and HarmState or "HELPFUL")

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

        if (not Button) then
            break
        end

        local Direction = Auras.Direction or "RIGHT"
        local OffsetMultiplier = (Direction == "RIGHT") and 1 or -1

        Button:Size(AuraWidth, AuraHeight)
        Button:ClearAllPoints()
        Button:Point(Auras.InitialAnchor, Auras, Auras.InitialAnchor, ActiveButtons * (AuraWidth + Spacing) * OffsetMultiplier, 0)
        Button:Show()

        if (Button.Icon) then
            Button.Icon:SetTexture(Icon)
            UI:KeepAspectRatio(Auras, Button.Icon)
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
                    Region:SetFontTemplate("Default")
                    Region:SetTextColor(1, 0.82, 0)
                end
            end
        end

        if (IsDebuff) then
            local Color = C_UnitAuras.GetAuraDispelTypeColor(Unit, AuraInstanceID, UI.DispelColorCurve)

            if (Color) then
                Button:SetColorTemplate(Color.r, Color.g, Color.b)
            end
        else
            Button:SetColorTemplate(unpack(DB.Global.General.BorderColor))
        end

        Button.Unit = Unit
        Button.AuraInstanceID = AuraInstanceID
        Button.AuraFilter = IsDebuff and HarmState or "HELPFUL"
        Button.AuraIndex = Index

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

function UF:CastStarted(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    local Name, Icon, StartTime, EndTime, TradeSkill, Interrupt, EmpowerStages

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_START") then
        Name, _, Icon, StartTime, EndTime, TradeSkill, _, Interrupt = UnitCastingInfo(Unit)

        -- Channel Casts
    elseif (Event == "UNIT_SPELLCAST_CHANNEL_START") then
        Name, _, Icon, StartTime, EndTime, TradeSkill, Interrupt = UnitChannelInfo(Unit)

        -- Empower Casts
    elseif (Event == "UNIT_SPELLCAST_EMPOWER_START") then
        Name, _, Icon, StartTime, EndTime, TradeSkill, Interrupt, _, _, EmpowerStages = UnitChannelInfo(Unit)
    end

    if (not Name or TradeSkill) then
        return
    end

    -- Update Events
    Castbar.Casting = (Event == "UNIT_SPELLCAST_START")
    Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_START")
    Castbar.Empower = (Event == "UNIT_SPELLCAST_EMPOWER_START")

    -- Empower
    if (Castbar.Empower) then
        EndTime = EndTime + GetUnitEmpowerHoldAtMaxTime(Unit)
    end

    -- Convert milliseconds to seconds
    EndTime = EndTime / 1000
    StartTime = StartTime / 1000

    -- Cache
    Castbar.Max = EndTime - StartTime
    Castbar.StartTime = StartTime
    Castbar.EndTime = EndTime
    Castbar.Interrupt = Interrupt
    Castbar.CastDelayed = 0
    Castbar.CastHold = 0

    if (Castbar.Channel) then
        Castbar.Duration = EndTime - GetTime()
    else
        Castbar.Duration = GetTime() - StartTime
    end

    -- Set Values
    Castbar:SetMinMaxValues(0, Castbar.Max)
    Castbar:SetValue(Castbar.Duration)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        Castbar.Text:SetText(Name)
    end

    -- Safe Zone
    if (Castbar.SafeZone) then
        local _, _, MSHome, MSWorld = GetNetStats()
        local MS = (MSHome + MSWorld) / 2
        local Latency = MS / 1000
        local Ratio = math.min(Latency / Castbar.Max, 1)
        local Width = Castbar:GetWidth() * Ratio

        Castbar.SafeZone:ClearAllPoints()
        Castbar.SafeZone:Width(Width)
        Castbar.SafeZone:Show()

        Castbar.SafeZoneText:ClearAllPoints()
        Castbar.SafeZoneText:SetText(string.format("%.0f", MS).."ms")

        if (Castbar.Channel) then
            Castbar.SafeZoneText:Point("LEFT", Castbar, "BOTTOMLEFT", 0, 0)

            Castbar.SafeZone:Point("TOPLEFT", Castbar, "TOPLEFT")
            Castbar.SafeZone:Point("BOTTOMLEFT", Castbar, "BOTTOMLEFT")
        else
            Castbar.SafeZoneText:Point("RIGHT", Castbar, "BOTTOMRIGHT", 0, 0)

            Castbar.SafeZone:Point("TOPRIGHT", Castbar, "TOPRIGHT")
            Castbar.SafeZone:Point("BOTTOMRIGHT", Castbar, "BOTTOMRIGHT")
        end
    end

    -- Call On Update
    Castbar:SetScript("OnUpdate", self.CastBarOnUpdate)

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 1)
end

function UF:CastStopped(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    -- Clear Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.Interrupt = nil

    -- Set Value
    Castbar:SetMinMaxValues(0, Castbar.Max or 1)
    Castbar:SetValue(Castbar.Duration or 1)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
end

function UF:CastFailed(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then 
        return 
    end

    -- Update Events
    if (Castbar.Text) then
        if (Event == "UNIT_SPELLCAST_FAILED") then
            Castbar.Text:SetText(FAILED)
        elseif (Event == "UNIT_SPELLCAST_INTERRUPTED") then
            Castbar.Text:SetText(INTERRUPTED)
        end
    end

    -- Hold
    Frame.Castbar.CastHold = Frame.Castbar.CastHold or 0

    -- Clear Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.Interrupt = nil

    Castbar:SetValue(Castbar.Max or 1)
    Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
end

function UF:CastInterrupted(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar

    if (not Frame or not Castbar) then
        return
    end

    if (Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.InterruptColor))

        if (Castbar.Icon) then 
            Castbar.Icon:SetDesaturated(true) 
        end

        Castbar.Interrupt = true
    else
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarColor))

        if (Castbar.Icon) then 
            Castbar.Icon:SetDesaturated(false) 
        end

        Castbar.Interrupt = nil
    end
end

function UF:CastUpdated(Unit, Event)
    local Frame = self.Frames[Unit]
    local Castbar = Frame.Castbar
    local Value

    if (not Frame or not Castbar) then
        return
    end

    local Name, StartTime, EndTime

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_DELAYED") then
        Name, _, _, StartTime, EndTime = UnitCastingInfo(Unit)

        -- Channel Casts
    elseif (Event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or Event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        Name, _, _, StartTime, EndTime = UnitChannelInfo(Unit)
    end

    if (not Name) then 
        return 
    end

    -- Empower
    if (Castbar.Empower) then
        EndTime = EndTime + GetUnitEmpowerHoldAtMaxTime(Unit)
    end

    -- Convert milliseconds to seconds
    StartTime = StartTime / 1000 
    EndTime = EndTime / 1000 

    if (Castbar.Channel) then
        Value = Castbar.StartTime - StartTime
        Castbar.Duration = EndTime - GetTime()
    else
        Value = StartTime - Castbar.StartTime
        Castbar.Duration = GetTime() - StartTime
    end

    if (Value < 0) then 
        Value = 0 
    end

    -- Cache
    Castbar.Max = EndTime - StartTime
    Castbar.StartTime = StartTime
    Castbar.EndTime = EndTime
    Castbar.CastDelayed = Castbar.CastDelayed + Value

    -- Set Values
    Castbar:SetMinMaxValues(0, Castbar.Max)
    Castbar:SetValue(Castbar.Duration)
end

function UF:CastBarOnUpdate(Elapsed)
    local Castbar = self

    if (Castbar.Casting or Castbar.Channel or Castbar.Empower) then
        if (Castbar.Casting or Castbar.Empower) then
            Castbar.Duration = Castbar.Duration + Elapsed

            if (Castbar.Duration >= Castbar.Max) then
                -- Clear Cache
                Castbar.Casting = nil
                Castbar.Channel = nil
                Castbar.Empower = nil
                Castbar.Interrupt = nil

                -- Call On Update
                Castbar:SetScript("OnUpdate", nil)

                -- Call Fade
                UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)

                return
            end
        else
            Castbar.Duration = Castbar.Duration - Elapsed

            if (Castbar.Duration <= 0) then
                -- Clear Cache
                Castbar.Casting = nil
                Castbar.Channel = nil
                Castbar.Empower = nil
                Castbar.Interrupt = nil

                -- Call On Update
                Castbar:SetScript("OnUpdate", nil)

                -- Call Fade
                UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)

                return
            end
        end

        if (Castbar.Time) then
            if (Castbar.CastDelayed ~= 0) then
                Castbar.Time:SetFormattedText("%.1f|cffff0000%s%.2f|r", Castbar.Duration, Castbar.Casting and "+" or "-", Castbar.CastDelay)
            else
                Castbar.Time:SetFormattedText("%.1f / %.1f", Castbar.Duration, Castbar.Max)
            end
        end

        Castbar:SetMinMaxValues(0, Castbar.Max)
        Castbar:SetValue(Castbar.Duration)

    elseif (Castbar.CastHold and Castbar.CastHold > 0) then
        Castbar.CastHold = Castbar.CastHold - Elapsed
    else
        -- Clear Cache
        Castbar.Casting = nil
        Castbar.Channel = nil
        Castbar.Empower = nil
        Castbar.Interrupt = nil

        -- Call On Update
        Castbar:SetScript("OnUpdate", nil)

        -- Call Fade
        UI:UIFrameFadeOut(Castbar, UF.FadeInTime, Castbar:GetAlpha(), 0)
    end
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
    local Percent = UnitHealthPercent(Unit, false, CurveConstants.ScaleTo100)

    if (not Frame.HealthTextPer) then
        return
    end

    Frame.HealthTextPer:SetFormattedText("%d%%", Percent or 0)
end

-- HEAL PRED

function UF:UpdateHealthPred(Frame)
    local Unit = Frame.unit

    if (not Frame.Health or not Frame.MyHeals or not Frame.OtherHeals or not Frame.Absorbs or not Frame.HealAbsorbs) then 
        return 
    end

    local Max = UnitHealthMax(Unit)
    local Current = UnitHealth(Unit)
    local MyIncomingHeal = UnitGetIncomingHeals(Unit, "player") or 0
    local AllIncomingHeal = UnitGetIncomingHeals(Unit) or 0
    local Absorb = UnitGetTotalAbsorbs(Unit) or 0
    local HealAbsorb = UnitGetTotalHealAbsorbs(Unit) or 0
    local HealthOrientation = Frame.Health:GetOrientation()
    local PreviousTexture = Frame.Health:GetStatusBarTexture()
    local Width = Frame.Health:GetWidth()
    local Height = Frame.Health:GetHeight()
    local BarWidth, BarHeight = Width, Height

    if (HealthOrientation ~= "HORIZONTAL") then
        BarWidth, BarHeight = Height, Width
    end

    Frame.MyHeals:SetOrientation(HealthOrientation)
    Frame.MyHeals:Size(BarWidth, BarHeight)
    Frame.MyHeals:SetMinMaxValues(0, Max)
    Frame.MyHeals:SetValue(MyIncomingHeal, UI.SmoothBars)
    Frame.MyHeals:Show()

    Frame.OtherHeals:SetOrientation(HealthOrientation)
    Frame.OtherHeals:Size(BarWidth, BarHeight)
    Frame.OtherHeals:SetMinMaxValues(0, Max)
    Frame.OtherHeals:SetValue(AllIncomingHeal, UI.SmoothBars)
    Frame.OtherHeals:Show()

    Frame.Absorbs:SetOrientation(HealthOrientation)
    Frame.Absorbs:SetReverseFill(true)
    Frame.Absorbs:Size(BarWidth, BarHeight)
    Frame.Absorbs:SetMinMaxValues(0, Max)
    Frame.Absorbs:SetValue(Absorb, UI.SmoothBars)
    Frame.Absorbs:Show()

    Frame.HealAbsorbs:SetOrientation(HealthOrientation)
    Frame.HealAbsorbs:SetReverseFill(true)
    Frame.HealAbsorbs:Size(BarWidth, BarHeight)
    Frame.HealAbsorbs:SetMinMaxValues(0, Max)
    Frame.HealAbsorbs:SetValue(HealAbsorb, UI.SmoothBars)
    Frame.HealAbsorbs:Show()

    if (HealthOrientation == "HORIZONTAL") then
        Frame.MyHeals:Point("TOPLEFT", PreviousTexture, "TOPRIGHT", 0, 0)
        Frame.MyHeals:Point("BOTTOMLEFT", PreviousTexture, "BOTTOMRIGHT", 0, 0)
        Frame.OtherHeals:Point("TOPLEFT", Frame.MyHeals:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        Frame.OtherHeals:Point("BOTTOMLEFT", Frame.MyHeals:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        Frame.Absorbs:Point("TOPRIGHT", PreviousTexture, "TOPRIGHT", 0, 0)
        Frame.Absorbs:Point("BOTTOMRIGHT", PreviousTexture, "BOTTOMRIGHT", 0, 0)
        Frame.HealAbsorbs:Point("TOPRIGHT", PreviousTexture, "TOPRIGHT", 0, 0)
        Frame.HealAbsorbs:Point("BOTTOMRIGHT", PreviousTexture, "BOTTOMRIGHT", 0, 0)
    else
        Frame.MyHeals:Point("BOTTOMLEFT", PreviousTexture, "TOPLEFT", 0, 0)
        Frame.MyHeals:Point("BOTTOMRIGHT", PreviousTexture, "TOPRIGHT", 0, 0)
        Frame.OtherHeals:Point("BOTTOMLEFT", Frame.MyHeals:GetStatusBarTexture(), "TOPLEFT", 0, 0)
        Frame.OtherHeals:Point("BOTTOMRIGHT", Frame.MyHeals:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        Frame.Absorbs:Point("TOPLEFT", PreviousTexture, "TOPLEFT", 0, 0)
        Frame.Absorbs:Point("TOPRIGHT", PreviousTexture, "TOPRIGHT", 0, 0)
        Frame.HealAbsorbs:Point("TOPLEFT", PreviousTexture, "TOPLEFT", 0, 0)
        Frame.HealAbsorbs:Point("TOPRIGHT", PreviousTexture, "TOPRIGHT", 0, 0)
    end
end

--- UPDATE POWER

function UF:UpdatePower(Frame)
    local Unit = Frame.unit
    local PowerType, PowerToken = UnitPowerType(Unit)
    local Min, Max = UnitPower(Unit, PowerType), UnitPowerMax(Unit, PowerType)
    local Percent = UnitPowerPercent(Unit, PowerType, false, CurveConstants.ScaleTo100)
    local PowerColor = UI.Colors.Power[PowerToken]

    if not (Frame.PowerText) then
        return
    end

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
    local Unit = Frame.unit
    local PowerType = UnitPowerType("player")
    local Min, Max = UnitPower("player", ADDITIONAL_POWER_BAR_INDEX), UnitPowerMax("player", ADDITIONAL_POWER_BAR_INDEX)
    local Percent = UnitPowerPercent("player", PowerType, false, CurveConstants.ScaleTo100)

    if (not Frame.AdditionalPower) then
        return
    end

    if (Max == 0 or PowerType == Enum.PowerType.Mana) then
        UI:UIFrameFadeOut(Frame.AdditionalPower, UF.FadeInTime, Frame.AdditionalPower:GetAlpha(), 0)
        UI:UIFrameFadeOut(Frame.AdditionalPowerText, UF.FadeInTime, Frame.AdditionalPowerText:GetAlpha(), 0)
        return
    end

    Frame.AdditionalPower:SetMinMaxValues(0, Max)
    Frame.AdditionalPower:SetValue(Min, UI.SmoothBars)
    Frame.AdditionalPowerText:SetFormattedText("%.0f%%", Percent)

    UI:UIFrameFadeIn(Frame.AdditionalPower, UF.FadeInTime, Frame.AdditionalPower:GetAlpha(), 1)
    UI:UIFrameFadeIn(Frame.AdditionalPowerText, UF.FadeInTime, Frame.AdditionalPowerText:GetAlpha(), 1)
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

function UF:UpdateReadyCheckIcon(Frame, event)
    local Unit = Frame.unit

    if (not Frame or not Unit) then
        return
    end

    if (not Frame.ReadyCheckIcon) then 
        return 
    end

    if (Frame.Animation.FadeOut and Frame.Animation.FadeOut:IsPlaying()) then
        Frame.Animation.FadeOut:Stop()
    end

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
    -- HEALTH PRED
    if (Frame.Health)then self:UpdateHealthPred(Frame) end
    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame) end
    if (Frame.ThreatRaid) then self:UpdateThreatHighlightRaid(Frame) end
end

-- ON EVENTS

function UF:OnEvent(event, arg1)
    local FramesUF = UF.Frames[arg1]

    -- LOGIN UPDATE
    if (event == "PLAYER_ENTERING_WORLD") then
        C_Timer.After(0.1, function()
            for Unit in pairs(UF.Frames) do
                UF:UpdateFrame(Unit)
            end
        end)

    -- TARGET
    elseif (event == "PLAYER_TARGET_CHANGED") then
        if UF.Frames["target"] then UF:UpdateFrame("target") end
        if UF.Frames["targettarget"] then UF:UpdateFrame("targettarget") end

    -- TARGET OF TARGET
    elseif (event == "UNIT_TARGET" and arg1 == "target") then
        if UF.Frames["targettarget"] then UF:UpdateFrame("targettarget") end

    -- PET
    elseif (event == "UNIT_PET") then
        if UF.Frames["pet"] then UF:UpdateFrame("pet") end

    -- FOCUS   
    elseif (event == "PLAYER_FOCUS_CHANGED") then
        if UF.Frames["focus"] then UF:UpdateFrame("focus") end

    -- BOSS FRAMES
    elseif (event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" or event == "UNIT_TARGETABLE_CHANGED") then
        for i = 1, 5 do
            local Unit = "boss"..i
            if UF.Frames[Unit] and UnitExists(Unit) then
                UF:UpdateFrame(Unit)
            end
        end
    end

    if (FramesUF) then
        -- AURAS
        if (event == "UNIT_AURA") then
            UF:UpdateAuras(FramesUF, arg1, false)
            UF:UpdateAuras(FramesUF, arg1, true)

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
        elseif (event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" or event == "UNIT_POWER_UPDATE") then
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
        elseif (event == "PLAYER_UPDATE_RESTING") then
            UF:UpdateRestingIcon(FramesUF)

        elseif (event == "RAID_TARGET_UPDATE") then
            UF:UpdateRaidIcon(FramesUF)

        elseif (event == "INCOMING_RESURRECT_CHANGED") then
            UF:UpdateResurrectionIcon(FramesUF)

        elseif (event == "UNIT_FLAGS" or event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE") then
            UF:UpdateCombatIcon(FramesUF)
            UF:UpdateLeaderIcon(FramesUF)
            UF:UpdateAssistantIcon(FramesUF)

        elseif (event == "INCOMING_SUMMON_CHANGED") then
            UF:UpdateSummonIcon(FramesUF)

        elseif (event == "UNIT_PHASE") then
            UF:UpdatePhaseIcon(FramesUF)

        elseif (event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" or event == "READY_CHECK_FINISHED") then
            UF:UpdateReadyCheckIcon(FramesUF, event)

        -- PORTRAITS
        elseif (event == "UNIT_MODEL_CHANGED" or event == "UNIT_PORTRAIT_UPDATE") then
            UF:UpdatePortrait(FramesUF)

        -- CASTBARS
        elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
            UF:CastStarted(arg1, event)

        elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
            UF:CastStopped(arg1)

        elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
            UF:CastUpdated(arg1, event)

        elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then
            UF:CastFailed(arg1, event)

        elseif (event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
            UF:CastInterrupted(arg1, event)
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