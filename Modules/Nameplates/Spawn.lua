local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- CREATE NAMEPLATES

function NP:CreateFriendlyPlates(Plate, Unit)
    if (not Unit) then
        return
    end

    local Frame = CreateFrame("Button", nil, Plate, "PingableUnitFrameTemplate")
    Frame:Size(unpack(DB.Global.Nameplates.Size))
    Frame:Point("CENTER", Plate, 0, 0)

    if (not Frame.Initialized) then
        -- Create Elements
        self:CreateFriendlyElements(Frame)

        Frame.Initialized = true
    end

    return Frame
end

function NP:CreateEnemyPlates(Plate, Unit)
    if (not Unit) then
        return
    end

    local Frame = CreateFrame("Button", nil, Plate, "PingableUnitFrameTemplate")
    Frame:Size(unpack(DB.Global.Nameplates.Size))
    Frame:Point("CENTER", Plate, 0, 0)

    if (not Frame.Initialized) then
        -- Create Elements
        self:CreateEnemyElements(Frame)

        Frame.Initialized = true
    end

    return Frame
end