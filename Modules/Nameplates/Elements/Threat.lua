local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor

function NP:CreateThreatHighlight(Frame)
    local Threat = CreateFrame("Frame", nil, Frame)
    Threat:Size(192, 16)
    Threat:Point("CENTER", Frame, 0, -4)
    Threat:CreateGlow(2.5, 3, 0, 0, 0, 0)

    Frame.Threat = Threat
end