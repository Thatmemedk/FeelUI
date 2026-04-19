local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreateFocus(Frame, Height, Orientation)
    self:CreateFadeInOut(Frame)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHighlightTarget(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    self:CreateRange(Frame)
    self:CreateFocusCastbar(Frame)
    self:CreateNameTextCenter(Frame)
    self:CreateRaidIcon(Frame)
end