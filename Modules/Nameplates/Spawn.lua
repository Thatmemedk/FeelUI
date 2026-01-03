local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- HIDE BLIZZARD FRAMES

function NP:AddHooks()
    hooksecurefunc(_G.NamePlateDriverFrame, "OnNamePlateAdded", function(_, Unit)
        local BlizzNP = C_NamePlate.GetNamePlateForUnit(Unit, issecure())

        if (not BlizzNP and Unit) then
            return
        end

        BlizzNP.UnitFrame:UnregisterAllEvents()
        BlizzNP.UnitFrame:SetAlpha(0)

        if (BlizzNP.UnitFrame.castBar) then
            BlizzNP.UnitFrame.castBar:UnregisterAllEvents()
        end

        hooksecurefunc(BlizzNP.UnitFrame, "SetAlpha", function(Frame)
            if Frame:IsForbidden() or Frame:GetAlpha() == 0 then
                return
            end

            Frame:SetAlpha(0)
        end)

        if (BlizzNP.UnitFrame.WidgetContainer) then
            BlizzNP.UnitFrame.WidgetContainer:SetParent(BlizzNP)
        end

        NP.Hooked[Unit] = BlizzNP.UnitFrame
    end)

    hooksecurefunc(_G.NamePlateDriverFrame, "OnNamePlateRemoved", function(_, Unit)
        local BlizzNP = NP.Hooked[Unit]

        if (not BlizzNP and Unit) then
            return
        end

        if (BlizzNP.WidgetContainer) then
            BlizzNP.WidgetContainer:SetParent(BlizzNP)
        end

        NP.Hooked[Unit] = nil
    end)
end

-- CREATE NAMEPLATES

function NP:CreateFriendly(Plate, Unit)
    if (Plate.FriendlyIsCreated) then
        return
    end

    local Frame = Plate.FeelUINameplatesFriendly

    if (not Frame) then
        Frame = CreateFrame("Frame", "FeelUI_NameplatesFriendly", Plate)
        Frame:Size(192, 16)
        Frame:Point("CENTER", Plate, 0, 0)

        Plate.FeelUINameplatesFriendly = Frame
    end

    Frame.Unit = Unit

    -- Elements
    self:CreatePanels(Frame)
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
        Frame:Size(192, 16)
        Frame:Point("CENTER", Plate, 0, 0)

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
    self:CreateCastBar(Frame)

    -- Update Elements
    self:UpdateEnemy(Frame)

    Plate.EnemyIsCreated = true
end