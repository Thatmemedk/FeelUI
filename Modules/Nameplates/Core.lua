local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:RegisterModule("NamePlates")

-- WoW Globals
local UnitReaction = UnitReaction
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthPercent = UnitHealthPercent
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsConnected = UnitIsConnected
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitName = UnitName
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitThreatSituation = UnitThreatSituation
local SetCVar = C_CVar.SetCVar

-- Tables
NP.Hooked = {}
NP.Modified = {}
NP.ForcedCasters = {}
NP.Range = {}

-- Tables
NP.UpdateQueue = {}
NP.ActivePlates = {}
NP.UpdaterTicker = 0

-- Locals
NP.FadeInTime = 0.5
NP.CastHoldTime = 2

-- HEALTH UPDATE

function NP:UpdateHealth(Frame, Unit)
    if (not Frame or not Unit or not Frame.Health) then 
        return 
    end

    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)
    local Reaction = UnitReaction(Unit, "player")
    local Color = UI.Colors.Reaction[Reaction]

    Frame.Health:SetMinMaxValues(0, Max, UI.SmoothBars)
    Frame.Health:SetValue(Min, UI.SmoothBars)

    if (not UnitIsConnected(Unit) or UnitIsTapDenied(Unit) or UnitIsGhost(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    elseif (UnitIsDead(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0, 0)
        Frame.Health:SetBackdropColorTemplate(0.25, 0, 0, 0.7)
    else
        if (DB.Global.Nameplates.ReactionColor) then
            Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.70)
        else
            Frame.Health:SetStatusBarColor(unpack(DB.Global.Nameplates.HealthBarColor))

            local CurveColor = UnitHealthPercent(Unit, true, UI.NameplatesHealthColorCurve)
            Frame.Health:GetStatusBarTexture():SetVertexColor(CurveColor:GetRGB())
        end

        Frame.Health:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))
    end
end

function NP:UpdateHealthText(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthText) then 
        return
    end

    local Percent = UnitHealthPercent(Unit, false, UI.CurvePercent)
    Frame.HealthText:SetFormattedText("%d%%", Percent or 0)
end

-- NAME UPDATE

function NP:UpdateName(Frame, Unit)
    if (not Frame or not Unit or not Frame.Name) then 
        return 
    end

    local Name = UnitName(Unit) or ""
    Frame.Name:SetText(Name)

    if (UnitIsPlayer(Unit) or UnitInPartyIsAI(Unit) or UnitPlayerControlled(Unit) and not UnitIsPlayer(Unit)) then
        local _, Class = UnitClass(Unit)
        local Color = UI.Colors.Class[Class]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    else
        local Reaction = UnitReaction(Unit, "player")
        local Color = UI.Colors.Reaction[Reaction]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    end
end

function NP:UpdateGuild(Frame, Unit)
    if (not Frame or not Unit or not Frame.Guild) then 
        return 
    end

    local GuildName, GuildRankName = GetGuildInfo(Unit)

    if (not GuildName) then 
        return 
    end

    local SameGuild = IsInGuild() and GetGuildInfo("player") == GuildName
    local ColorFormat = SameGuild and "|CFFFF66CC[%s]|r" or "|CFFFFFFFF[%s]|r"

    Frame.Guild:SetText(string.format(ColorFormat, GuildName))
end

-- ICONS

function NP:UpdateRaidIcon(Frame, Unit)
    if (not Frame or not Unit or not Frame.RaidIcon) then 
        return 
    end

    local Index = GetRaidTargetIndex(Unit)

    if (Index) then
        Frame.RaidIcon:Show()
        SetRaidTargetIconTexture(Frame.RaidIcon, Index)
    else
        Frame.RaidIcon:Hide()
    end
end

-- THREAT

function NP:UpdateThreatHighlight(Frame, Unit)
    if (not Frame or not Unit or not Frame.Threat) then 
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

-- HIGHLIGHT

function NP:UpdateTargetIndicator(Frame, Unit)
    if (UnitExists("target") and UnitIsUnit("target", Unit)) then
        Frame.TargetIndicator:Show()
    else
        Frame.TargetIndicator:Hide()
    end
end

function NP:UpdateHighlight(Frame, Unit)
    if (UnitExists("target") and UnitIsUnit("target", Unit)) then
        Frame.Highlight:Show()
    else
        Frame.Highlight:Hide()
    end
end

-- FULL UPDATE

function NP:ProcessFrame(Frame)
    local Unit = Frame.Unit

    if (not Unit or not UnitExists(Unit)) then 
        return 
    end

    -- HEALTH
    if (Frame.NeedsHealth) then
        if (Frame.Health) then self:UpdateHealth(Frame, Unit) end
        if (Frame.HealthText) then self:UpdateHealthText(Frame, Unit) end

        Frame.NeedsHealth = nil
    end

    -- NAME
    if (Frame.NeedsName) then
        if (Frame.Name) then self:UpdateName(Frame, Unit) end
        if (Frame.Guild) then self:UpdateGuild(Frame, Unit) end

        Frame.NeedsName = nil
    end

    -- ICONS
    if (Frame.NeedsIcons) then
        if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame, Unit) end

        Frame.NeedsIcons = nil
    end

    -- THREAT
    if (Frame.NeedsThreat) then
        if (Frame.Threat) then self:UpdateThreatHighlight(Frame, Unit) end

        Frame.NeedsThreat = nil
    end

    if (Frame.NeedsTargetIndicator) then
        if (Frame.TargetIndicator) then self:UpdateTargetIndicator(Frame, Unit) end
        if (Frame.Highlight) then self:UpdateHighlight(Frame, Unit) end

        Frame.NeedsTargetIndicator = nil
    end

    -- AURAS
    if (Frame.NeedsAuras) then
        if (Frame.Debuffs) then self:UpdateAuras(Frame, Unit, true) end

        Frame.NeedsAuras = nil
    end
end

function NP:QueueUpdate(Frame, Unit, Flag)
    if (type(Frame) ~= "table" or not Unit or not Frame:IsShown()) then
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

function NP:UpdateQueueTicker()
    self:SetScript("OnUpdate", function(_, Elapsed)
        NP.UpdaterTicker = (NP.UpdaterTicker or 0) + Elapsed
        
        if (NP.UpdaterTicker < 0.1) then 
            return 
        end

        NP.UpdaterTicker = 0

        local Processed = 0
        local MaxPerTick = 6

        for Unit, Frames in next, NP.UpdateQueue do
            for Frame in next, Frames do
                if (Frame and Frame:IsShown()) then
                    NP:ProcessFrame(Frame)
                end

                Frames[Frame] = nil
                Processed = Processed + 1

                if (Processed >= MaxPerTick) then 
                    return 
                end
            end

            if (not next(Frames)) then
                NP.UpdateQueue[Unit] = nil
            end
        end
    end)
end

-- EVENT HANDLER

function NP:OnEvent(event, unit, ...)
    if (type(unit) ~= "string") then 
        return 
    end

    if (not unit:match("^nameplate%d+$")) then
        return
    end

    local Plate = C_NamePlate.GetNamePlateForUnit(unit)

    if (not Plate) then
        return
    end

    local Enemy = Plate.FeelUINameplatesEnemy
    local Friendly = Plate.FeelUINameplatesFriendly
    local IsFriend = UnitIsFriend("player", unit)

    if (event == "NAME_PLATE_UNIT_ADDED") then
        if (IsFriend) then
            if (Enemy) then
                Enemy:Hide()
                Enemy.Unit = nil
                NP.ActivePlates[Enemy] = nil
            end

            if (not Friendly) then
                NP:CreateFriendlyPlates(Plate, unit)

                return
            end

            Friendly:Show()
            Friendly.Unit = unit
            NP.ActivePlates[Friendly] = true

            NP:QueueUpdate(Friendly, unit, "NeedsHealth")
            NP:QueueUpdate(Friendly, unit, "NeedsName")
            NP:QueueUpdate(Friendly, unit, "NeedsIcons")
        else
            if (Friendly) then
                Friendly:Hide()
                Friendly.Unit = nil
                NP.ActivePlates[Friendly] = nil
            end

            if (not Enemy) then
                NP:CreateEnemyPlates(Plate, unit)

                return
            end

            Enemy:Show()
            Enemy.Unit = unit
            NP.ActivePlates[Enemy] = true

            NP:QueueUpdate(Enemy, unit, "NeedsHealth")
            NP:QueueUpdate(Enemy, unit, "NeedsName")
            NP:QueueUpdate(Enemy, unit, "NeedsAura")
            NP:QueueUpdate(Enemy, unit, "NeedsIcons")
            NP:QueueUpdate(Enemy, unit, "NeedsThreat")
            NP:QueueUpdate(Enemy, unit, "NeedsTargetIndicator")
            NP:SetNameplateColor(unit, false)
        end
    end

    if (event == "NAME_PLATE_UNIT_REMOVED") then
        if (Friendly) then
            Friendly.Unit = nil
            NP.ActivePlates[Friendly] = nil
        end

        if (Enemy) then
            Enemy.Unit = nil
            NP.ActivePlates[Enemy] = nil
        end

        NP:ClearForcedCasters(unit)
    end

    if (event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGETABLE_CHANGED") then
        for Frame in next, NP.ActivePlates do
            if (Frame and Frame.Unit) then
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsHealth")
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsName")
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsAura")
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsIcons")
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsThreat")
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsTargetIndicator")
                NP:SetNameplateColor(Frame.Unit, false)
            end
        end
    end

    if (event == "RAID_TARGET_UPDATE") then
        for Frame in next, NP.ActivePlates do
            if (Frame and Frame.Unit) then
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsIcons")
            end
        end
    end

    if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
        NP:CastStarted(event, unit)
        NP:SetNameplateColor(unit, true)
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        NP:CastStopped(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then
        NP:CastFailed(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
        NP:CastSucceeded(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        NP:CastUpdated(event, unit)
    elseif (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
        NP:CastNonInterruptable(event, unit)
    end

    if (event == "UNIT_AURA") then
        for Frame in next, NP.ActivePlates do
            if (Frame and Frame.Unit) then
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsAuras")
            end
        end
    elseif (event == "UNIT_HEALTH") then
        for Frame in next, NP.ActivePlates do
            if (Frame and Frame.Unit) then
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsHealth")
            end
        end
    elseif (event == "UNIT_NAME_UPDATE" or event == "UNIT_LEVEL" or event == "PLAYER_LEVEL_UP") then
        for Frame in next, NP.ActivePlates do
            if (Frame and Frame.Unit) then
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsName")
            end
        end
    elseif (event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE") then
        for Frame in next, NP.ActivePlates do
            if (Frame and Frame.Unit) then
                NP:QueueUpdate(Frame, Frame.Unit, "NeedsThreat")
            end
        end
    end
end

-- SET CVARS

function NP:SetCVarOnLogin()
    SetCVar("nameplateSelectedScaleEnabled", 1)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateSelectedScaleFactor", 1)
    SetCVar("nameplateGlobalScale", 1)
    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateMotion", 0)
    SetCVar("nameplateOverlapH", 0.8)
    SetCVar("nameplateOverlapV", 1.1)
    -- All
    SetCVar("nameplateShowAll", 1)
    -- Friendly
    SetCVar("nameplateShowFriends", 1)
    SetCVar("nameplateShowFriendlyNPCs", 0)
    SetCVar("nameplateShowFriendlyPets", 0)
    SetCVar("nameplateShowFriendlyTotems", 0)
    SetCVar("nameplateShowFriendlyMinions", 0)
    SetCVar("nameplateShowFriendlyGuardians", 0)
    -- Enemies
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("nameplateShowEnemyMinion", 1)
    SetCVar("nameplateShowEnemyMinus", 1)
    -- Names Only
    SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", 1)
    SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", 1)
    -- Never Show
    SetCVar("nameplateShowSelf", 0)
end

-- REGISTER EVENTS

function NP:RegisterEvents()
    -- NAMEPLATE
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
    -- HEALTH
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    -- AURA
    self:RegisterEvent("UNIT_AURA")
    -- NAME
    self:RegisterEvent("UNIT_NAME_UPDATE")
    -- LEVEL
    self:RegisterEvent("UNIT_LEVEL")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    -- THREAT
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    -- CASTBAR
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("UNIT_SPELLCAST_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    -- ICONS
    self:RegisterEvent("RAID_TARGET_UPDATE")
    -- ON EVENT
    self:SetScript("OnEvent", function(_, event, ...) 
        NP:OnEvent(event, ...) 
    end)
end

-- INITIALIZE

function NP:Initialize()
    if (not DB.Global.Nameplates.Enable) then 
        return 
    end

    self:DisableBlizzard()
    self:RegisterEvents()
    self:SetCVarOnLogin()
    self:UpdateQueueTicker()
end