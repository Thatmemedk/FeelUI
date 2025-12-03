local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor

function UF:UpdateThreatHighlight(Frame)
    if (Frame ~= Frame.unit) then
        return
    end

    local Threat = UnitThreatSituation("player", Frame)
    
    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        self.Panel.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)
    else
        self.Panel.Glow:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

function UF:UpdateThreatHighlightRaid(Frame)
    if (Frame ~= self.Frame) then
        return
    end

    local Threat = UnitThreatSituation(Frame)

    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        self.Panel.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)
    else
        self.Panel.Glow:SetBackdropBorderColor(0, 0, 0, 0)
    end
end