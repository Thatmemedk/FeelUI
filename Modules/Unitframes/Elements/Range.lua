local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateRange(Frame)
    local Range = {}
    Range.InRangeAlpha = 1
    Range.OutOfRangeAlpha = 0.3
    Range.FadeTime = 0.5

    Frame.Range = Range
end