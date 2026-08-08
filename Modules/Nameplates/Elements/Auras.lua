local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function NP:CreateDebuffs(Frame)
    if (not Frame or Frame.Debuffs) then
        return
    end

    local Debuffs = UI:CreateAuraContainer(Frame, {
        GrowthDirection = "LEFT",
        Anchor = "TOPRIGHT",
        X = 0,
        Y = 32,
        Width = 28,
        Height = 12,
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = false,
        Filter = "HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY",
        MaxAuras = 4,
    })

    Frame.Debuffs = Debuffs
end

function NP:CreateCrowdControlDebuffs(Frame)
    if (not Frame or Frame.CrowdControl) then
        return
    end
    
    local CrowdControl = UI:CreateAuraContainer(Frame, {
        GrowthDirection = "LEFT",
        Anchor = "TOPLEFT",
        X = -42,
        Y = 0,
        Width = 36,
        Height = 12,
        Direction = "LEFT",
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = false,
        Filter = "HARMFUL|CROWD_CONTROL",
        MaxAuras = 6,
    })

    Frame.CrowdControl = CrowdControl
end