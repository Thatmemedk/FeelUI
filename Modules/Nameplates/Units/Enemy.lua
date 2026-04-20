local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function NP:CreateEnemyElements(Frame)
    self:CreateStackingBounds(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHighlightMouseOver(Frame)
    self:CreateHealth(Frame)
    self:CreateHealthText(Frame)
    self:CreateHealthPrediction(Frame)
    self:CreateName(Frame)
    self:CreateCastBar(Frame)
    --self:CreateDebuffs(Frame)
    self:CreateCrowdControlDebuffs(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateTargetIndicator(Frame)
    self:CreateThreatHighlight(Frame)
end