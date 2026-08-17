local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

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
        DebuffIndicator = false,
        Filter = "HARMFUL|PLAYER",
        MaxAuras = 7,
        HideTooltipInCombat = true,
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

    local External = UI:CreateAuraContainer(Frame, {
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
        Filter = "HARMFUL",
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