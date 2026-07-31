local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreateDebuffHighlight(Frame)
    if (Frame.DebuffHighlight) then
        return
    end

    local DebuffHighlight = CreateFrame("Frame", nil, Frame.InvisFrame)
    DebuffHighlight:SetInside(Frame, 1, 1)

    local DebuffHighlightAura = UI:CreateAuraHighlight(DebuffHighlight, {
        Filter = "HARMFUL|RAID",
        Unit = "player"
    })

    Frame.DebuffHighlight = DebuffHighlight
end