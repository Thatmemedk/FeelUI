local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreateFocus(Frame, Height, Orientation)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    self:CreateRange(Frame)
    self:CreateFocusCastbar(Frame)
    self:CreateNameTextCenter(Frame)
    self:CreateRaidIcon(Frame)
end