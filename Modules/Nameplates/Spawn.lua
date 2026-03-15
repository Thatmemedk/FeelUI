local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- CREATE NAMEPLATES

function NP:CreateFriendlyPlates(Plate, Unit)
    if (Plate.FriendlyIsCreated) then
        return Plate.FeelUINameplatesFriendly
    end

    local Frame = Plate.FeelUINameplatesFriendly

    if (not Frame) then
        Frame = CreateFrame("Button", "FeelUI_NameplatesFriendly", Plate, "PingableUnitFrameTemplate")
        Frame:Size(unpack(DB.Global.Nameplates.Size))
        Frame:Point("CENTER", Plate, 0, 0)

        Plate.FeelUINameplatesFriendly = Frame
    end

    Frame.Unit = Unit

    -- Create Elements
    self:CreateFriendlyElements(Frame)
    self:QueueUpdate(Frame, Unit, "NeedsHealth")
    self:QueueUpdate(Frame, Unit, "NeedsName")

    Plate.FriendlyIsCreated = true

    return Frame
end

function NP:CreateEnemyPlates(Plate, Unit)
    if (Plate.EnemyIsCreated) then
        return Plate.FeelUINameplatesEnemy
    end

    local Frame = Plate.FeelUINameplatesEnemy

    if (not Frame) then
        Frame = CreateFrame("Button", "FeelUI_NameplatesEnemy", Plate, "PingableUnitFrameTemplate")
        Frame:Size(unpack(DB.Global.Nameplates.Size))
        Frame:Point("CENTER", Plate, 0, 0)

        Plate.FeelUINameplatesEnemy = Frame
    end

    Frame.Unit = Unit

    -- Create Elements
    self:CreateEnemyElements(Frame)
    self:QueueUpdate(Frame, Unit, "NeedsHealth")
    self:QueueUpdate(Frame, Unit, "NeedsName")

    Plate.EnemyIsCreated = true

    return Frame
end