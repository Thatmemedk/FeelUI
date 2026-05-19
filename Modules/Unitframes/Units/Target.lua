local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreateTarget(Frame, Height, Orientation)
    self:CreateFadeInOut(Frame)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHighlightTarget(Frame)
    self:CreateRange(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    self:CreatePower(Frame, Orientation)
    self:CreateHealthPrediction(Frame)
    self:CreateBuffsTarget(Frame)
    self:CreateDebuffsTarget(Frame)
    self:CreateTargetCastbar(Frame)
    self:CreatePortrait(Frame)
    self:CreateTargetTexts(Frame)
    self:CreateLeaderIcon(Frame)
    self:CreateAssistantIcon(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateResurrectIcon(Frame)
    self:CreateSummonIcon(Frame)
    self:CreatePhaseIcon(Frame)
    self:CreateThreatHighlight(Frame)
end