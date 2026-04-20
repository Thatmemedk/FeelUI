local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor

function NP:CreateThreatHighlight(Frame)
    if (Frame.Threat) then
        return
    end
    
    local Threat = CreateFrame("Frame", nil, Frame)
    Threat:SetInside(Frame, 1, 1)
    Threat:CreateGlow(2.5, 3, 0, 0, 0, 0)
    Threat:Hide()

    Frame.Threat = Threat
end