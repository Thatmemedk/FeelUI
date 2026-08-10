local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

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
"HARMFUL|DISPELLABLE; Include only auras that are dispellable/purgeable/stealable, regardless of whether the player or someone in the player's raid can
"HELPFUL|PLAYER|RAID_IN_COMBAT; Returns auras that are flagged to show on raid frames in combat, this should return mostly just HotS.

"HELPFUL|EXTERNAL_DEFENSIVE"; Displays External Defensives such as [Pain Suppression] etc.
"HELPFUL|BIG_DEFENSIVE"; Displays Defensives such as [Barkskin] etc.
"HARMFUL|CROWD_CONTROL"; Returns auras that are flagged as Crowd Control.

--]]

function UF:CreateBuffsTarget(Frame)
    if (not Frame or Frame.Buffs) then
        return
    end

    local Buffs = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPLEFT",
        X = 0,
        Y = 32,
        Width = 30,
        Height = 18,
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = false,
        Filter = "HELPFUL",
        MaxAuras = 7,
    })

    Frame.Buffs = Buffs
end

function UF:CreateDebuffsTarget(Frame)
    if (not Frame or Frame.Debuffs) then
        return
    end

    local Debuffs = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPLEFT",
        X = 0,
        Y = 56,
        Width = 30,
        Height = 18,
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = true,
        Filter = "HARMFUL|PLAYER",
        MaxAuras = 7,
    })

    Frame.Debuffs = Debuffs
end

function UF:CreatePartyDebuffs(Frame)
    if (not Frame or Frame.Debuffs) then
        return
    end

    local Debuffs = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPRIGHT",
        X = 248,
        Y = -12,
        Width = 32,
        Height = 12,
        Spacing = 3,
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = true,
        Filter = "HARMFUL|RAID_PLAYER_DISPELLABLE",
        MaxAuras = 7,
    })

    Frame.Debuffs = Debuffs
end

function UF:CreatePartyBuffs(Frame)
    if (not Frame or Frame.Buffs) then
        return
    end

    local Buffs = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPLEFT",
        X = -248,
        Y = -12,
        Width = 32,
        Height = 12,
        Spacing = 3,
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = false,
        Filter = "HELPFUL|PLAYER|RAID",
        MaxAuras = 7,
    })

   Frame.Buffs = Buffs
end

function UF:CreatePartyExternal(Frame)
    if (not Frame or Frame.External) then
        return
    end

    local External = UI:CreateAuraContainer(Frame.InvisFrameHigher, {
        Anchor = "CENTER",
        X = 0,
        Y = 0,
        Width = 36,
        Height = 12,
        Spacing = 4,
        Cooldown = true,
        Count = true,
        Duration = true,
        Filter = "HELPFUL|BIG_DEFENSIVE",
        MaxAuras = 1,
    })

    Frame.External = External
end

function UF:CreateRaidDebuffs(Frame)
    if (not Frame or Frame.Debuffs) then
        return
    end
    
    local Debuffs = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPLEFT",
        X = 12,
        Y = -14,
        Width = 26,
        Height = 16,
        CountY = 6,
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = false,
        Filter = "HARMFUL|RAID|DISPELLABLE",
        MaxAuras = 2,
    })

    Frame.Debuffs = Debuffs
end

function UF:CreateRaidBuffs(Frame)
    if (not Frame or Frame.Buffs) then
        return
    end

    local Buffs = UI:CreateAuraContainer(Frame, {
        Anchor = "TOPLEFT",
        X = 0,
        Y = 0,
        Width = 18,
        Height = 12,
        Cooldown = true,
        Count = false,
        Duration = false,
        Filter = "HELPFUL|PLAYER|RAID_IN_COMBAT",
        MaxAuras = 3,
    })

    Frame.Buffs = Buffs
end

function UF:CreateRaidExternal(Frame)
    if (not Frame or Frame.External) then
        return
    end

    Frame.External = UI:CreateAuraContainer(Frame, {
        Anchor = "CENTER",
        X = 0,
        Y = -18,
        Width = 28,
        Height = 12,
        Cooldown = true,
        Count = true,
        Duration = true,
        Border = false,
        DebuffIndicator = false,
        Filter = "HELPFUL|BIG_DEFENSIVE",
        MaxAuras = 1,
    })

    Frame.External = External
end