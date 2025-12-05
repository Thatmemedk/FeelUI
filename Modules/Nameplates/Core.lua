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
local UnitThreatSituation = UnitThreatSituation

-- Locals
NP.HiddenFrames = {}

-- HIDE BLIZZARD FRAMES

function NP:HideBlizzardFrames(Plate)
    if (not Plate or NP.HiddenFrames[Plate]) then 
        return 
    end

    local UF = Plate.UnitFrame

    if (UF) then
        UF:UnregisterAllEvents()
        UF:SetParent(UI.HiddenParent)
    end

    NP.HiddenFrames[Plate] = true
end

function NP:ShowBlizzardFrames(Plate)
    if (not Plate or not NP.HiddenFrames[Plate]) then 
        return 
    end

    local UF = Plate.UnitFrame

    if (UF) then
        UF:SetParent(Plate)
        UF:Show()

        NP.HiddenFrames[Plate] = nil
    end
end

-- CREATE NAMEPLATES

function NP:CreateFriendly(Plate, Unit)
    if (Plate.FriendlyIsCreated) then
        return
    end

    local Frame = Plate.FeelUINameplatesFriendly

    if (not Frame) then
        Frame = CreateFrame("Frame", nil, Plate)
        Frame:SetAllPoints()

        Plate.FeelUINameplatesFriendly = Frame
    end

    Frame.Unit = Unit

    -- Hide Elements
    --self:HideBlizzardFrames(Plate)

    -- Elements
    self:CreatePanelsFriendly(Frame)
    self:CreateNameMiddle(Frame)

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
        Frame = CreateFrame("Frame", nil, Plate)
        Frame:SetAllPoints()

        Plate.FeelUINameplatesEnemy = Frame
    end

    Frame.Unit = Unit

    -- Hide Elements
    --self:HideBlizzardFrames(Plate)

    -- Elements
    self:CreatePanels(Frame)
    self:CreateTargetIndicator(Frame)
    self:CreateThreatHighlight(Frame)
    self:CreateHealth(Frame)
    self:CreateHealthText(Frame)
    self:CreateName(Frame)

    -- Update Elements
    self:UpdateEnemy(Frame)

    Plate.EnemyIsCreated = true
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

    Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b)
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

    local Percent = UnitHealthPercent(Unit, false, true)
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
        local Color = RAID_CLASS_COLORS[Class]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    else
        local Reaction = UnitReaction(Unit, "player") or 5
        local Color = UI.Colors.Reaction[Reaction]

        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
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

    if (Frame.Name) then self:UpdateName(Frame, Frame.Unit) end
end

function NP:UpdateEnemy(Frame)
    if (not Frame or not Frame.Unit) then 
        return 
    end

    if (Frame.Health) then self:UpdateHealth(Frame, Frame.Unit) end
    if (Frame.HealthText) then self:UpdateHealthText(Frame, Frame.Unit) end
    if (Frame.Name) then self:UpdateName(Frame, Frame.Unit) end
    if (Frame.TargetIndicatorLeft and Frame.TargetIndicatorRight) then self:HighlightOnNameplateTarget(Frame, Frame.Unit) end
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame, Frame.Unit) end
end

-- EVENT HANDLER

function NP:OnEvent(event, unit, ...)
    if (event == "NAME_PLATE_UNIT_ADDED") then
        local Plate = C_NamePlate.GetNamePlateForUnit(unit, issecure())

        if (not Plate) then 
            return 
        end

        self:HideBlizzardFrames(Plate)

        if UnitIsFriend("player", unit) then
            if (not Plate.FeelUINameplatesFriendly) then
                self:CreateFriendly(Plate, unit)
            else
                Plate.FeelUINameplatesFriendly.Unit = unit
                self:UpdateFriendly(Plate.FeelUINameplatesFriendly)
            end
        else
            if (not Plate.FeelUINameplatesEnemy) then
                self:CreateEnemy(Plate, unit)
            else
                Plate.FeelUINameplatesEnemy.Unit = unit
                self:UpdateEnemy(Plate.FeelUINameplatesEnemy)
                self:SetNameplateColor(unit, false)
            end
        end
    elseif (event == "NAME_PLATE_UNIT_REMOVED") then
        local Plate = C_NamePlate.GetNamePlateForUnit(unit)

        if (not Plate) then 
            return 
        end

        if (Plate.FeelUINameplatesFriendly) then
            Plate.FeelUINameplatesFriendly.Unit = nil
        end

        if (Plate.FeelUINameplatesEnemy) then
            Plate.FeelUINameplatesEnemy.Unit = nil
        end

        self:ShowBlizzardFrames(Plate)
    elseif (event == "UNIT_SPELLCAST_START") then
        if not UnitIsFriend("player", unit) then
            self:SetNameplateColor(unit, true)
        end

    elseif (event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGETABLE_CHANGED") then
        for _, Plate in ipairs(C_NamePlate.GetNamePlates()) do
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
    elseif (unit and event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
        local Plate = C_NamePlate.GetNamePlateForUnit(unit)

        if (not Plate) then 
            return 
        end

        if UnitIsFriend("player", unit) and Plate.FeelUINameplatesFriendly then
            self:UpdateFriendly(Plate.FeelUINameplatesFriendly)
        elseif (Plate.FeelUINameplatesEnemy) then
            self:UpdateEnemy(Plate.FeelUINameplatesEnemy)
            self:SetNameplateColor(unit, false)
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