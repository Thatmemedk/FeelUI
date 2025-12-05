local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:RegisterModule("NamePlates")

-- HIDE BLIZZARD FRAMES

function NP:HideBlizzardFrames(Plate)
    local UF = Plate.UnitFrame

    if InCombatLockdown() then 
        return 
    end

    if UF.border then UF.border:Hide() end
    if UF.name then UF.name:SetAlpha(0) end
    if UF.healthBar then UF.healthBar:Hide() end
    if UF.levelText then UF.levelText:Hide() end
    if UF.selectionHighlight then UF.selectionHighlight:Hide() end
    if UF.ClassificationFrame then UF.ClassificationFrame:Hide() end
end

-- SET CVARS

function NP:SetCVarOnLogin()
    SetCVar("nameplateShowSelf", 0)
    SetCVar("nameplateMotion", 1)
    SetCVar("nameplateShowAll", 1)
    SetCVar("nameplateShowFriends", 0)
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("nameplateShowEnemyMinion", 1)
    SetCVar("nameplateShowEnemyMinus", 1)
end

-- CREATE NAMEPLATES

function NP:Create(Plate, Unit)
    if (not Plate or not Unit) then 
        return 
    end

    local Frame = Plate.FeelUINameplates

    if (Frame) then
        Frame.Unit = Unit
    else
        Frame = CreateFrame("Frame", nil, Plate)
        Frame:SetAllPoints()

        Plate.FeelUINameplates = Frame
        Frame.Unit = Unit

        self:CreatePanels(Frame)
        self:CreateTargetIndicator(Frame)
        self:CreateThreatHighlight(Frame)
        self:CreateHealth(Frame)
        self:CreateHealthText(Frame)
        self:CreateName(Frame)
    end

    self:HideBlizzardFrames(Plate)
    self:Update(Frame, Unit)
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

    local Reaction = UnitReaction and UnitReaction(Unit, "player") or 5
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

-- COLORING

function NP:GetUnitColor(Unit, IsCaster)
    if (not UnitExists(Unit)) then
        return
    end

    local InInstance, InstanceType = IsInInstance()
    local Reaction = UnitReaction and UnitReaction(Unit, "player") or 5
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

    if (not NamePlates or not NamePlates.FeelUINameplates) then
        return
    end

    local Frame = NamePlates.FeelUINameplates

    if (not Frame.Health) then
        return
    end

    local Color = self:GetUnitColor(Unit, IsCaster)
    Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b)
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
        local Reaction = UnitReaction and UnitReaction(Unit, "player") or 5
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

function NP:Update(Frame, Unit)
    if (not Frame or not UnitExists(Unit)) then 
        return 
    end

    if (Frame.Health) then self:UpdateHealth(Frame, Unit) end
    if (Frame.HealthText) then self:UpdateHealthText(Frame, Unit) end
    if (Frame.Name) then self:UpdateName(Frame, Unit) end
    if (Frame.TargetIndicatorLeft and Frame.TargetIndicatorRight) then self:HighlightOnNameplateTarget(Frame, Unit) end
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame, Unit) end
end

-- EVENT HANDLER

function NP:OnEvent(event, unit, ...)
    if (event == "NAME_PLATE_UNIT_ADDED") then
        local NamePlates = C_NamePlate.GetNamePlateForUnit(unit, issecure())

        if (NamePlates) then
            self:Create(NamePlates, unit)
            self:SetNameplateColor(unit, false)
        end

    elseif (event == "NAME_PLATE_UNIT_REMOVED") then
        local NamePlates = C_NamePlate.GetNamePlateForUnit(unit)

        if (NamePlates and NamePlates.FeelUINameplates) then
            NamePlates.FeelUINameplates.Unit = nil
        end

    elseif (event == "UNIT_SPELLCAST_START") then
        self:SetNameplateColor(unit, true)

    elseif (event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGETABLE_CHANGED") then
        for _, Plate in ipairs(C_NamePlate.GetNamePlates()) do
            local Frame = Plate.FeelUINameplates

            if (Frame and Frame.Unit) then
                self:Update(Frame, Frame.Unit)
                self:SetNameplateColor(Frame.Unit, false)
            end
        end

    elseif ((unit and event == "UNIT_HEALTH") or event == "UNIT_MAXHEALTH") then
        local NamePlates = C_NamePlate.GetNamePlateForUnit(unit)

        if (NamePlates and NamePlates.FeelUINameplates) then
            self:Update(NamePlates.FeelUINameplates, unit)
            self:SetNameplateColor(unit, false)
        end
    end
end

-- REGISTER EVENTS

function NP:CallEvents()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("UNIT_CONNECTION")
    self:RegisterEvent("UNIT_FACTION")
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

    self:CallEvents()
end