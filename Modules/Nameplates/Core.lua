local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:RegisterModule("NamePlates")

-- WoW Globals
local UnitExists = UnitExists
local UnitReaction = UnitReaction
local UnitLevel = UnitLevel
local UnitClassification = UnitClassification
local UnitIsBossMob = UnitIsBossMob
local UnitPowerType = UnitPowerType
local UnitIsEnemy = UnitIsEnemy
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

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

-- HIDE BLIZZARD FRAMES

function NP:HideBlizzardFrames(Plate)
    if (not Plate) then 
        return 
    end

    local UF = Plate.UnitFrame

    if (UF) then
        UF:UnregisterAllEvents()
        UF:Hide()
    end
end

function NP:ShowBlizzardFrames(Plate)
    if (not Plate) then 
        return 
    end

    local UF = Plate.UnitFrame

    if (UF) then
        UF:SetParent(Plate)
        UF:Show()
    end
end

-- CREATE NAMEPLATES

function NP:CreateFriendly(Plate, Unit)
    if (Plate.FriendlyIsCreated) then
        return
    end

    local Frame = Plate.FeelUINameplatesFriendly

    if (not Frame) then
        Frame = CreateFrame("Frame", "FeelUI_NameplatesFriendly", Plate)
        Frame:SetAllPoints()

        Plate.FeelUINameplatesFriendly = Frame
    end

    Frame.Unit = Unit

    -- Elements
    self:CreatePanelsFriendly(Frame)
    self:CreateNameMiddle(Frame)
    self:CreateRaidIcon(Frame)

    -- Update Elements
    self:UpdateFriendly(Frame)

    Plate.FriendlyIsCreated = true
end

function NP:CreateEnemy(Plate, Unit)
    if (Plate.EnemyIsCreated) then
        return
    end

    local Frame = Plate.FeelUINameplatesEnemy

    if (not Frame) then
        Frame = CreateFrame("Frame", "FeelUI_NameplatesEnemy", Plate)
        Frame:SetAllPoints()

        Plate.FeelUINameplatesEnemy = Frame
    end

    Frame.Unit = Unit

    -- Elements
    self:CreatePanels(Frame)
    self:CreateTargetIndicator(Frame)
    self:CreateThreatHighlight(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateHealth(Frame)
    self:CreateHealthText(Frame)
    self:CreateName(Frame)
    self:CreateDebuffs(Frame)

    -- Update Elements
    self:UpdateEnemy(Frame)

    Plate.EnemyIsCreated = true
end

-- AURAS

function NP:UpdateAuras(Frame, Unit, IsDebuff)
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

        ActiveButtons = ActiveButtons + 1
        Index = Index + 1
    end

    for i = ActiveButtons + 1, #Auras.Buttons do
        if Auras.Buttons[i] then
            Auras.Buttons[i]:Hide()
        end
    end
end

-- COLORING

function NP:GetUnitColor(Unit, IsCaster)
    if (not UnitExists(Unit)) then
        return
    end

    local InInstance, InstanceType = IsInInstance()
    local Reaction = UnitReaction(Unit, "player") or 5
    local Color = UI.Colors.Reaction[Reaction]

    if not (InInstance and InstanceType == "party") then
        return Color
    end

    local Level = UnitLevel(Unit)
    local Classific = UnitClassification(Unit)
    local IsBoss = UnitIsBossMob(Unit)
    local _, PowerType = UnitPowerType(Unit)

    if (IsBoss) then
        return UI.Colors.Classification.BOSS
    end

    if (Level == 91 and Classific == "elite") then
        return UI.Colors.Classification.RARE
    end

    if (Level == 90 and Classific == "elite") then
        if (PowerType == "MANA" or IsCaster) then
            return UI.Colors.Classification.CASTER
        else
            return UI.Colors.Classification.ELITE
        end
    end

    return Color
end

function NP:SetNameplateColor(Unit, IsCaster)
    if (not Unit or not UnitIsEnemy("player", Unit)) then
        return
    end

    local NamePlates = C_NamePlate.GetNamePlateForUnit(Unit)

    if (not NamePlates) then 
        return 
    end

    local Frame = NamePlates.FeelUINameplatesEnemy

    if (not Frame or not Frame.Health) then 
        return 
    end

    local Color = self:GetUnitColor(Unit, IsCaster)

    if (not Color) then
        return
    end

    Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.70)
end

-- HEALTH UPDATE

function NP:UpdateHealth(Frame, Unit)
    if (not Frame or not Unit) then 
        return 
    end

    if (not Frame.Health) then
        return
    end

    local Min, Max = UnitHealth(Unit), UnitHealthMax(Unit)
    Frame.Health:SetMinMaxValues(0, Max)
    Frame.Health:SetValue(Min, UI.SmoothBars)

    local Reaction = UnitReaction(Unit, "player") or 5
    local Color = UI.Colors.Reaction[Reaction]

    if not UnitIsConnected(Unit) or UnitIsTapDenied(Unit) or UnitIsGhost(Unit) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    elseif UnitIsDead(Unit) then
        Frame.Health:SetStatusBarColor(0.25, 0, 0)
        Frame.Health:SetBackdropColorTemplate(0.25, 0, 0, 0.7)
    else
        Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.7)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    end
end

function NP:UpdateHealthText(Frame, Unit)
    if (not Frame or not Unit) then 
        return
    end

    if (not Frame.HealthText) then
        return
    end

    local Percent = UnitHealthPercent(Unit, false, CurveConstants.ScaleTo100)
    Frame.HealthText:SetFormattedText("%d%%", Percent or 0)
end

-- NAME UPDATE

function NP:UpdateName(Frame, Unit)
    if (not Frame or not Unit) then 
        return 
    end

    if (not Frame.Name) then
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
end

-- ICONS

function NP:UpdateRaidIcon(Frame, Unit)
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

-- THREAT

function NP:UpdateThreatHighlight(Frame, Unit)
    if (not Frame or not Unit) then 
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
    if (Frame.TargetIndicatorLeft and Frame.TargetIndicatorRight) then self:HighlightOnNameplateTarget(Frame, Frame.Unit) end
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
                FriendlyFrame.Unit = unit
                FriendlyFrame:Show()

                self:UpdateFriendly(FriendlyFrame)
            end
        else
            if (not EnemyFrame) then
                self:CreateEnemy(GNPFU, unit)
            else
                EnemyFrame.Unit = unit
                EnemyFrame:Show()

                self:UpdateEnemy(EnemyFrame)
                self:SetNameplateColor(unit, false)
            end
        end

        self:HideBlizzardFrames(GNPFU)

        return

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

        self:ShowBlizzardFrames(GNPFU)

        return

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

        return

        -- UPDATE COLORS
    elseif (event == "UNIT_SPELLCAST_START") then
        if (not unit) then
            return
        end

        if not UnitIsFriend("player", unit) then
            self:SetNameplateColor(unit, true)
        end

        return

        -- HEALTH
    elseif ((event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") and unit) then
        if (not GNPFU) then
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

        return

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

        return

        -- UPDATE AURAS
    elseif (event == "UNIT_AURA") then
        if (not unit or not GNPFU) then
            return
        end

        local EnemyFrame = GNPFU.FeelUINameplatesEnemy

        if (EnemyFrame and EnemyFrame.Unit) then
            self:UpdateAuras(EnemyFrame, EnemyFrame.Unit, true)
        end

        return
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
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("RAID_TARGET_UPDATE")
    self:RegisterEvent("UNIT_AURA")
    self:SetScript("OnEvent", function(_, event, ...) 
        NP:OnEvent(event, ...) 
    end)
end

-- INITIALIZE

function NP:Initialize()
    if (not DB.Global.UnitFrames.Enable) then 
        return 
    end

    self:RegisterEvents()
    self:SetCVarOnLogin()
end