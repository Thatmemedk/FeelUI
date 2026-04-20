local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreatePet(Frame, Height, Orientation)
    self:CreateFadeInOut(Frame)
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateHighlightTarget(Frame)
    self:CreateRange(Frame)
    self:CreateHealth(Frame, Height, Orientation)
    --self:CreatePetCastbar(Frame)
    self:CreateNameTextCenter(Frame)
    self:CreateRaidIcon(Frame)
end