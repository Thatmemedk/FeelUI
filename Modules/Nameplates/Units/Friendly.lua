local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

function NP:CreateFriendlyElements(Frame)
    self:CreatePanels(Frame)
    self:CreateNameMiddle(Frame)
    self:CreateRaidIcon(Frame)
end