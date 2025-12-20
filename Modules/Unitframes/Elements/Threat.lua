local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor

function UF:CreateThreatHighlight(Frame)
    local Threat = CreateFrame("Frame", nil, Frame)
    Threat:SetInside(Frame, 1, 1)
    Threat:CreateGlow(2.5, 3, 0, 0, 0, 0)

    Frame.Threat = Threat
end