local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function NP:CreateFriendlyElements(Frame)
    self:CreatePanels(Frame)
    self:CreateHighlight(Frame)
    self:CreateNameMiddle(Frame)
    self:CreateRaidIcon(Frame)
end