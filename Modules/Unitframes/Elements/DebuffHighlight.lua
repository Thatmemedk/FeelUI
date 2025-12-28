local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateDebuffHighlight(Frame)
    local DebuffHighlight = CreateFrame("Frame", nil, Frame)
    DebuffHighlight:SetInside()
    DebuffHighlight:CreateGlow(2.5, 3, 0, 0, 0, 0)

    Frame.DebuffHighlight = DebuffHighlight
end