local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

--[[

"HELPFUL"; Displays helpeful Buffs no filtering
"HARMFUL"; Displays harmful Debuffs, no filtering

"HELPFUL|PLAYER"; Displays helpful Buffs only from player and no filtering.
"HARMFUL|PLAYER"; Displays harmful Debuffs only from player and no filtering.

"HELPFUL|RAID"; Buffs filtered by the player's class, e.g. for Priests it will only return  [Power Word: Fortitude] etc.
"HARMFUL|RAID"; Certain Debuffs that only show up on raid frames, e.g. most Debuffs that are relevant in a Raid Setting.
"HARMFUL|RAID_PLAYER_DISPELLABLE"; Returns auras the player can be Dispelled.
"HELPFUL|PLAYER|RAID_IN_COMBAT; Returns auras that are flagged to show on raid frames in combat, this should return mostly just HotS.

"HELPFUL|EXTERNAL_DEFENSIVE"; Displays External Defensives such as [Pain Suppression] etc.
"HELPFUL|BIG_DEFENSIVE"; Displays Defensives such as [Barkskin] etc.
"HARMFUL|CROWD_CONTROL"; Returns auras that are flagged as Crowd Control.

--]]

function NP:CreateDebuffs(Frame)
    if (Frame.Debuffs) then
        return
    end

    --[[
    Frame.Debuffs = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPRIGHT",
        X = -2,
        Y = 24,
        Width = 28,
        Height = 12,
        Spacing = 2,
        Direction = "RIGHT",
        RelativeAnchor = "CENTER",
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = true,
        Filter = "HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY",
        MaxAuras = 2,
    })
    --]]
end

function NP:CreateCrowdControlDebuffs(Frame)
    if (Frame.CrowdControl) then
        return
    end

    --[[
    Frame.CrowdControl = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPLEFT",
        X = -240,
        Y = 0,
        Width = 36,
        Height = 12,
        Spacing = 4,
        Direction = "LEFT",
        RelativeAnchor = "BOTTOM",
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = true,
        Filter = "HARMFUL|CROWD_CONTROL",
        MaxAuras = 6,
    })
    --]]
end