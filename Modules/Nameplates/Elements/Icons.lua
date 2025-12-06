local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreateRaidIcon(Frame)
    local RaidIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    RaidIcon:Size(32, 32)
    RaidIcon:Point("TOP", Frame, 0, -6)
    RaidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
    RaidIcon:Hide()
    
    Frame.RaidIcon = RaidIcon
end