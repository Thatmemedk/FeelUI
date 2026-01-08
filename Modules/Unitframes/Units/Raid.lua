local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreateRaid(Frame)
    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateRange(Frame)
    self:CreateHealth(Frame, 42, "VERTICAL")
    self:CreateHealthPrediction(Frame)
    self:CreateRaidTexts(Frame)
    self:CreateRaidDebuffs(Frame)
    self:CreateRaidBuffs(Frame)
    self:CreateRaidExternal(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateResurrectIcon(Frame)
    self:CreateLeaderIcon(Frame)
    self:CreateAssistantIcon(Frame)
    self:CreateSummonIcon(Frame)
    self:CreatePhaseIcon(Frame)
    self:CreateReadyCheckIcon(Frame)
    self:CreateThreatHighlight(Frame)
end