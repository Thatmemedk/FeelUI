local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreateRange(Frame)
    if (Frame.Range) then
        return
    end
    
    local Range = {}
    Range.InRangeAlpha = 1
    Range.OutOfRangeAlpha = 0.3
    Range.FadeTime = 0.5

    Frame.Range = Range
end