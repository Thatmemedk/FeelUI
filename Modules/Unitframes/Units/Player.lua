local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreatePlayer(Frame, Height, Orientation)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHighlightTarget(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    self:CreatePower(Frame, Orientation)
    self:CreateHealthPrediction(Frame)
    self:CreateAdditionalPower(Frame)
    self:CreatePlayerCastbar(Frame)
    self:CreatePortrait(Frame)
    self:CreatePlayerTexts(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateCombatIcon(Frame)
    self:CreateRestingIcon(Frame)
    self:CreateResurrectIcon(Frame)
    self:CreateLeaderIcon(Frame)
    self:CreateAssistantIcon(Frame)
    self:CreateSummonIcon(Frame)
    --self:CreateDebuffHighlight(Frame)
end