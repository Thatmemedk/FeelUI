local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreateTargetTarget(Frame, Height, Orientation)
    self:CreateFadeInOut(Frame)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHighlightTarget(Frame)
    self:CreateRange(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    self:CreateNameTextCenter(Frame)
    self:CreateRaidIcon(Frame)
end
