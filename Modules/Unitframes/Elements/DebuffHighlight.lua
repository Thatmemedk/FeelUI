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

    --[[
    local DebuffHighlight = UI:CreateAuraHighlight(Frame, {
        Filter = "HARMFUL|RAID|DISPELLABLE",
        Unit = "player"
    })
    --]]

    Frame.DebuffHighlight = DebuffHighlight
end