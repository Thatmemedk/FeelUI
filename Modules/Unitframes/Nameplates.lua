local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- HIDE NPS

function UF:NPHideBlizzardFrames(Frame)
    local Border = Frame.UnitFrame.border
    local Highlight = Frame.UnitFrame.selectionHighlight
    local Health = Frame.UnitFrame.healthBar
    local Name = Frame.UnitFrame.name
    local Level = Frame.UnitFrame.levelText
    local Classif = Frame.UnitFrame.ClassificationFrame

    if Border then Border:Hide() end
    if Highlight then Highlight:Hide()  end
    if Health then Health:Hide()  end
    if Name then Name:SetAlpha(0)  end
    if Level then Level:Hide() end
    if Classif then Classif:Hide()  end
end

-- SET CVAR

function UF:SetCVarOnLogin()
    SetCVar("nameplateShowSelf", 0)
    SetCVar("nameplateMotion", 1)
    SetCVar("nameplateShowAll", 1)
    SetCVar("nameplateShowFriends", 0)
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("nameplateShowEnemyMinion", 1)
    SetCVar("nameplateShowEnemyMinus", 1)
end

-- CREATE NPS

function UF:CreateNameplate(Plate, Unit)
    if (not Plate or not Unit) then
        return
    end

    if (Plate.FeelUIPlate) then
        return
    end

    local Frame = CreateFrame("Frame", "FeelUI_Nameplates", Plate)
    Frame:SetAllPoints()
    Plate.FeelUIPlate = Frame

    self:NPCreatePanels(Frame)
    --self:NPCreateTargetIndicator(Frame, Unit)
    self:NPCreateHealth(Frame)
    self:NPCreateHealthText(Frame)
    --self:CreateName(Frame, Unit)

    Frame.IsCreated = true
end

-- HEALTH UPDATE

function UF:NPUpdateHealth(Frame, Unit)
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
    local Color = UI.Colors and UI.Colors.Reaction and UI.Colors.Reaction[Reaction]

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
        Frame.Health:SetStatusBarColor(Color[1], Color[2], Color[3], 0.7)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)
    end
end

function UF:NPUpdateHealthText(Frame, Unit)
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

function UF:NPUpdateName(Frame, Unit)
    if (not Frame or not Unit) then
        return
    end

    if (not Frame.Name) then
        return
    end

    local Name = UnitName(Unit) or ""
    local Level = UnitLevel(Unit) or -1
    local NameColor, LevelColor, LevelText

    if (Name) then
        --Frame.Name:SetText(UTF8Sub(Name, 12))
        Frame.Name:SetText(Name)
    end

    if UnitIsPlayer(Unit) then
        local _, Class = UnitClass(Unit)
        local Color = RAID_CLASS_COLORS[Class]

        if (Color) then
            Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
        end
    else
        local Reaction = UnitReaction and UnitReaction(Unit, "player") or 5
        local Color = UI.Colors and UI.Colors.Reaction and UI.Colors.Reaction[Reaction]

        if (Color) then
            Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
        end
    end

    --[[
    if UnitIsPlayer(Unit) then
        local _, Class = UnitClass(Unit)
        local Color = RAID_CLASS_COLORS[Class]

        if (Color) then
            NameColor = format("|cff%02x%02x%02x", Color.r*255, Color.g*255, Color.b*255)
        end
    else
        local Reaction = UnitReaction and UnitReaction(Unit, "player") or 5
        local Color = UI.Colors and UI.Colors.Reaction and UI.Colors.Reaction[Reaction]

        if (Color) then
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

    if (Name and Level) then
        Frame.Name:SetText(format("%s%s|r %s%s|r", NameColor or "", Name, LevelColor or "", LevelText))
    end
    --]]
end

-- UPDATE NPS

function UF:UpdateNameplate(Frame, Unit)
    if (not Frame or not UnitExists(Unit)) then
        return 
    end

    -- HEALTH
    if (Frame.Health) then self:NPUpdateHealth(Frame, Unit) end
    if (Frame.HealthText) then self:NPUpdateHealthText(Frame, Unit) end
    -- NAME
    if (Frame.Name) then self:NPUpdateName(Frame, Unit) end
    -- TARGET INDICATORS
    if (Frame.TargetIndicatorLeft and Frame.TargetIndicatorRight) then self:NPHighlightOnNameplateTarget(Frame, Unit) end
    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame) end
end