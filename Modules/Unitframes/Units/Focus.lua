local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreateFocus(Frame, Height, Orientation)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateRange(Frame)
    self:CreateFocusCastbar(Frame)
    self:CreateNameTextCenter(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateThreatHighlight(Frame)
end