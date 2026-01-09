local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

function NP:CreateEnemyElements(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHealth(Frame)
    self:CreateHealthText(Frame)
    self:CreateName(Frame)
    self:CreateCastBar(Frame)
    self:CreateDebuffs(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateTargetIndicator(Frame)
    self:CreateThreatHighlight(Frame)
end