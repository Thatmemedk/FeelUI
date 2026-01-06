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

-- Locals
NP.Hooked = {}
NP.ForcedCasters = {}

-- Locals
NP.FadeInTime = 0.5
NP.CastHoldTime = 2

-- HEALTH UPDATE

function NP:UpdateHealth(Frame, Unit)
    if (not Frame or not Unit or not Frame.Health) then 
        return 
    end

    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)
    local Reaction = UnitReaction(Unit, "player") or 5
    local Color = UI.Colors.Reaction[Reaction]
    Frame.Health:SetMinMaxValues(0, Max)
    Frame.Health:SetValue(Min, UI.SmoothBars)

    if not UnitIsConnected(Unit) or UnitIsTapDenied(Unit) or UnitIsGhost(Unit) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    elseif UnitIsDead(Unit) then
        Frame.Health:SetStatusBarColor(0.25, 0, 0)
        Frame.Health:SetBackdropColorTemplate(0.25, 0, 0, 0.7)
    else
        Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.7)

        local HealthColorCurve = C_CurveUtil.CreateColorCurve()
        HealthColorCurve:SetType(Enum.LuaCurveType.Cosine)
        HealthColorCurve:AddPoint(0, CreateColor(0.6, 0, 0, 0.7))
        HealthColorCurve:AddPoint(0.90, CreateColor(0.6, 0.6, 0, 0.7))
        HealthColorCurve:AddPoint(1, CreateColor(Color.r, Color.g, Color.b, 0.7))

        local Color = UnitHealthPercent(Unit, true, HealthColorCurve)
        Frame.Health:GetStatusBarTexture():SetVertexColor(Color:GetRGB())
    end

    Frame.Health:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))

    if UnitIsUnit("target", Unit) then
        UI:UIFrameFadeOut(Frame.Health, NP.FadeInTime, Frame.Health:GetAlpha(), 1)
    else
        UI:UIFrameFadeOut(Frame.Health, NP.FadeInTime, Frame.Health:GetAlpha(), 0.5)
    end
end

function NP:UpdateHealthText(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthText) then 
        return
    end

    local Percent = UnitHealthPercent(Unit, false, UI.CurvePercent)
    Frame.HealthText:SetFormattedText("%d%%", Percent or 0)

    if UnitIsUnit("target", Unit) then
        UI:UIFrameFadeOut(Frame.HealthText, NP.FadeInTime, Frame.HealthText:GetAlpha(), 1)
    else
        UI:UIFrameFadeOut(Frame.HealthText, NP.FadeInTime, Frame.HealthText:GetAlpha(), 0.5)
    end
end

-- NAME UPDATE

function NP:UpdateName(Frame, Unit)
    if (not Frame or not Unit or not Frame.Name) then 
        return 
    end

    local Name = UnitName(Unit) or ""
    Frame.Name:SetText(Name)

    if UnitIsPlayer(Unit) then
        local _, Class = UnitClass(Unit)
        local Color = UI.Colors.Class[Class]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    else
        local Reaction = UnitReaction(Unit, "player") or 5
        local Color = UI.Colors.Reaction[Reaction]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    end

    if UnitIsUnit("target", Unit) then
        UI:UIFrameFadeOut(Frame.Name, NP.FadeInTime, Frame.Name:GetAlpha(), 1)
    else
        UI:UIFrameFadeOut(Frame.Name, NP.FadeInTime, Frame.Name:GetAlpha(), 0.5)
    end
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
    else
        Frame.Threat.Glow:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

-- HIGHLIGHT

function NP:HighlightOnNameplateTarget(Frame, Unit)
    if UnitIsUnit("target", Unit) then
        Frame.TargetIndicator.Left:Show()
        Frame.TargetIndicator.Right:Show()
    else
        Frame.TargetIndicator.Left:Hide()
        Frame.TargetIndicator.Right:Hide()
    end
end

-- FULL UPDATE

function NP:UpdateFriendly(Frame)
    if (not Frame or not Frame.Unit) then 
        return 
    end

    -- NAME
    if (Frame.Name) then self:UpdateName(Frame, Frame.Unit) end
    -- ICONS
    if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame, Frame.Unit) end
end

function NP:UpdateEnemy(Frame)
    if (not Frame or not Frame.Unit) then 
        return 
    end

    -- HEALTH
    if (Frame.Health) then self:UpdateHealth(Frame, Frame.Unit) end
    if (Frame.HealthText) then self:UpdateHealthText(Frame, Frame.Unit) end
    -- NAME
    if (Frame.Name) then self:UpdateName(Frame, Frame.Unit) end
    -- ICONS
    if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame, Frame.Unit) end
    -- HIGHLIGHT
    if (Frame.TargetIndicator) then self:HighlightOnNameplateTarget(Frame, Frame.Unit) end
    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame, Frame.Unit) end
    -- AURAS
    if (Frame.Debuffs) then self:UpdateAuras(Frame, Frame.Unit, true) end
end

-- EVENT HANDLER

function NP:OnEvent(event, unit, ...)
    local GNP = C_NamePlate.GetNamePlates()
    local GNPFU = unit and C_NamePlate.GetNamePlateForUnit(unit) or nil

    -- UPDATE ADDED NAMEPLATES
    if (event == "NAME_PLATE_UNIT_ADDED") then
        if (not unit or not GNPFU) then
            return
        end

        local FriendlyFrame = GNPFU.FeelUINameplatesFriendly
        local EnemyFrame = GNPFU.FeelUINameplatesEnemy
        local IsFriend = UnitIsFriend("player", unit)

        if (IsFriend and EnemyFrame) then
            EnemyFrame:Hide()
            EnemyFrame.Unit = nil
        elseif (not IsFriend and FriendlyFrame) then
            FriendlyFrame:Hide()
            FriendlyFrame.Unit = nil
        end

        if (IsFriend) then
            if (not FriendlyFrame) then
                self:CreateFriendly(GNPFU, unit)
            else
                FriendlyFrame:Show()
                FriendlyFrame.Unit = unit

                self:UpdateFriendly(FriendlyFrame)
            end
        else
            if (not EnemyFrame) then
                self:CreateEnemy(GNPFU, unit)
            else
                EnemyFrame:Show()
                EnemyFrame.Unit = unit

                self:UpdateEnemy(EnemyFrame)
                self:SetNameplateColor(EnemyFrame.Unit, false)
            end
        end

        -- UPDATE REMOVED NAMEPLATES
    elseif (event == "NAME_PLATE_UNIT_REMOVED") then
        if (not unit or not GNPFU) then
            return
        end

        local FriendlyFrame = GNPFU.FeelUINameplatesFriendly
        local EnemyFrame = GNPFU.FeelUINameplatesEnemy

        if (FriendlyFrame) then
            FriendlyFrame.Unit = nil
        end

        if (EnemyFrame) then
            EnemyFrame.Unit = nil
        end

        self:ClearForcedCasters(unit)

        -- UPDATE TARGET NAMEPLATES
    elseif (event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGETABLE_CHANGED") then
        for _, Plate in ipairs(GNP) do
            local FriendlyFrame = Plate.FeelUINameplatesFriendly
            local EnemyFrame = Plate.FeelUINameplatesEnemy

            if (FriendlyFrame and FriendlyFrame.Unit) then
                self:UpdateFriendly(FriendlyFrame)
            end

            if (EnemyFrame and EnemyFrame.Unit) then
                self:UpdateEnemy(EnemyFrame)
                self:SetNameplateColor(EnemyFrame.Unit, false)
            end
        end

        -- HEALTH
    elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
        if (not unit or not GNPFU) then
            return
        end

        local FriendlyFrame = GNPFU.FeelUINameplatesFriendly
        local EnemyFrame = GNPFU.FeelUINameplatesEnemy

        if UnitIsFriend("player", unit) then
            if (FriendlyFrame) then
                self:UpdateFriendly(FriendlyFrame)
            end
        else
            if (EnemyFrame) then
                self:UpdateEnemy(EnemyFrame)
                self:SetNameplateColor(unit, false)
            end
        end

        -- UPDATE AURAS
    elseif (event == "UNIT_AURA") then
        if (not unit or not GNPFU) then
            return
        end

        local EnemyFrame = GNPFU.FeelUINameplatesEnemy

        if (EnemyFrame and EnemyFrame.Unit) then
            self:UpdateAuras(EnemyFrame, EnemyFrame.Unit, true)
        end

        -- UPDATE ICONS
    elseif (event == "RAID_TARGET_UPDATE") then
        for _, Plate in ipairs(GNP) do
            local FriendlyFrame = Plate.FeelUINameplatesFriendly
            local EnemyFrame = Plate.FeelUINameplatesEnemy

            if (FriendlyFrame and FriendlyFrame.Unit) then
                self:UpdateRaidIcon(FriendlyFrame, FriendlyFrame.Unit)
            end

            if (EnemyFrame and EnemyFrame.Unit) then
                self:UpdateRaidIcon(EnemyFrame, EnemyFrame.Unit)
            end
        end

        -- CASTBARS
    elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
        if not unit or UnitIsFriend("player", unit) then
            return
        end

        self:CastStarted(event, unit)
        self:SetNameplateColor(unit, true)
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        if not unit or UnitIsFriend("player", unit) then
            return
        end

        self:CastStopped(event, unit)
    elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        if not unit or UnitIsFriend("player", unit) then
            return
        end
    
        self:CastUpdated(event, unit)
    elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then
        if not unit or UnitIsFriend("player", unit) then
            return
        end

        self:CastFailed(event, unit)
    elseif (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
        if not unit or UnitIsFriend("player", unit) then
            return
        end

        self:CastNonInterruptable(event, unit)
    end
end

-- SET CVARS

function NP:SetCVarOnLogin()
    SetCVar("nameplateSelectedScaleEnabled", 1)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateSelectedScaleFactor", 1)
    SetCVar("nameplateGlobalScale", 1)
    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateShowSelf", 0)
    SetCVar("nameplateMotion", 0)
    SetCVar("nameplateShowAll", 1)
    SetCVar("nameplateShowFriends", 0)
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("nameplateShowEnemyMinion", 1)
    SetCVar("nameplateShowEnemyMinus", 1)
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
    -- CASTBAR
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
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
end