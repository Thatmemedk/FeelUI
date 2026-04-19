local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreateBoss(Frame, Height, Orientation)
    self:CreateFadeInOut(Frame)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHighlightTarget(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    self:CreateRange(Frame)
    self:CreateBossCastbar(Frame)
    self:CreateTargetTexts(Frame)
    self:CreateThreatHighlight(Frame)
end