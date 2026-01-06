local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreateParty(Frame)
    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateRange(Frame)
    self:CreateHealth(Frame)
    self:CreateHealthPrediction(Frame)
    self:CreatePartyTexts(Frame)
    self:CreatePartyDebuffs(Frame)
    self:CreatePartyBuffs(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateResurrectIcon(Frame)
    self:CreateLeaderIcon(Frame)
    self:CreateAssistantIcon(Frame)
    self:CreateSummonIcon(Frame)
    self:CreatePhaseIcon(Frame)
    self:CreateReadyCheckIcon(Frame)
    self:CreateThreatHighlight(Frame)
end