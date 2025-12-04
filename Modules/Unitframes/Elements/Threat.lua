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
    Threat:SetInside()
    Threat:CreateGlow(2.5, 3, 0, 0, 0, 0)

    Frame.Threat = Threat
end

function UF:UpdateThreatHighlightRaid(Frame)
    local ThreatRaid = CreateFrame("Frame", nil, Frame)
    ThreatRaid:SetInside()
    ThreatRaid:CreateGlow(2.5, 3, 0, 0, 0, 0)

    Frame.ThreatRaid = ThreatRaid
end