local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:CreatePet(Frame, Height, Orientation)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateRange(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    self:CreatePetCastbar(Frame)
    self:CreateNameTextCenter(Frame)
    self:CreateRaidIcon(Frame)
end