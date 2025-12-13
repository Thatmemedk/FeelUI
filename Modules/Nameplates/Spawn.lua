local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

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
    self:CreateNamePlateCastBar(Frame)

    -- Update Elements
    self:UpdateEnemy(Frame)

    Plate.EnemyIsCreated = true
end