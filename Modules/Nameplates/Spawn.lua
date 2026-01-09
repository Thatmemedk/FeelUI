local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- CREATE NAMEPLATES

function NP:CreateFriendlyPlates(Plate, Unit)
    if (Plate.FriendlyIsCreated) then
        return
    end

    local Frame = Plate.FeelUINameplatesFriendly

    if (not Frame) then
        Frame = CreateFrame("Frame", "FeelUI_NameplatesFriendly", Plate)
        Frame:Size(unpack(DB.Global.Nameplates.Size))
        Frame:Point("CENTER", Plate, 0, 0)

        Plate.FeelUINameplatesFriendly = Frame
    end

    Frame.Unit = Unit

    -- Create Elements
    self:CreateFriendlyElements(Frame)
    self:UpdateFriendlyPlates(Frame)

    Plate.FriendlyIsCreated = true
end

function NP:CreateEnemyPlates(Plate, Unit)
    if (Plate.EnemyIsCreated) then
        return
    end
    
    local Frame = Plate.FeelUINameplatesEnemy

    if (not Frame) then
        Frame = CreateFrame("Frame", "FeelUI_NameplatesEnemy", Plate)
        Frame:Size(unpack(DB.Global.Nameplates.Size))
        Frame:Point("CENTER", Plate, 0, 0)

        Plate.FeelUINameplatesEnemy = Frame
    end

    Frame.Unit = Unit

    -- Create Elements
    self:CreateEnemyElements(Frame)
    self:UpdateEnemyPlates(Frame)

    Plate.EnemyIsCreated = true
end