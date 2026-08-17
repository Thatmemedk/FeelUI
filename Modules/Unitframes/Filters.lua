local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- AURAS

UF.AuraFilter.Blacklist = {
    -- Druid
    [1126] = true,          -- Mark of the Wild
    [474754] = true,        -- Symbiotic Relationship
    -- Evoker
    [369459] = true,        -- Source of Magic
    [381732] = true,        -- Blessing of the Bronze
    [381741] = true,        -- Blessing of the Bronze
    [381746] = true,        -- Blessing of the Bronze
    [381748] = true,        -- Blessing of the Bronze
    [381749] = true,        -- Blessing of the Bronze
    [381750] = true,        -- Blessing of the Bronze
    [381751] = true,        -- Blessing of the Bronze
    [381752] = true,        -- Blessing of the Bronze
    [381753] = true,        -- Blessing of the Bronze
    [381754] = true,        -- Blessing of the Bronze
    [381756] = true,        -- Blessing of the Bronze
    [381757] = true,        -- Blessing of the Bronze
    [381758] = true,        -- Blessing of the Bronze
    [406789] = true,        -- Spatial Paradox (Others)
    -- Hunter
    [260286] = true,        -- Tip of the Spear
    -- Mage
    [1459] = true,          -- Arcane Intellect
    [205473] = true,        -- Icicles
    -- Monk
    [124255] = true,        -- Stagger
    -- Paladin
    [433568] = true,        -- Rite of Sanctification
    [433583] = true,        -- Rite of Adjuration
    -- Priest
    [21562] = true,         -- Power Word: Fortitude
    [1217607] = true,       -- Void Metamorphosis
    [1225789] = true,       -- Void Metamorphosis
    [1227702] = true,       -- Collapsing Star
    -- Rogue
    [2823] = true,          -- Deadly Poison
    [3408] = true,          -- Crippling Poison
    [5761] = true,          -- Numbing Poison
    [8679] = true,          -- Wound Poison
    [315584] = true,        -- Instant Poison
    [381637] = true,        -- Atrophic Poison
    [381664] = true,        -- Amplifying Poison
    -- Shaman
    [462854] = true,        -- Skyfury
    -- Imbuements
    [319773] = true,        -- Windfury Weapon
    [319778] = true,        -- Flametongue Weapon
    [344179] = true,        -- Maelstrom Weapon
    [382021] = true,        -- Earthliving Weapon
    [382022] = true,        -- Earthliving Weapon
    [457481] = true,        -- Tidecaller's Guard
    [457496] = true,        -- Tidecaller's Guard
    [462742] = true,        -- Thunderstrike Ward
    [462757] = true,        -- Thunderstrike Ward
    -- Warrior
    [6673] = true,          -- Battle Shout
    [405189] = true,        -- Overflowing Power | Berserk
    -- General / Miscellaneous
    [1283888] = true,       -- [DNT] Aura Never Secret Test Spell
    [308312] = true,        -- Time Trial Practice
    [369968] = true,        -- Racing
    [388367] = true,        -- Ohn'ahra's Gusts
    -- Skyriding
    [377234] = true,        -- Thrill of the Skies
    [404464] = true,        -- Flight Style: Skyriding
    [404468] = true,        -- Flight Style: Steady
    [418590] = true,        -- Static Charge
    [427490] = true,        -- Ride Along
    [447959] = true,        -- Ride Along - Enabled
    [447960] = true,        -- Ride Along - Inactive
    -- Bloodlust / Heroism
    [57723] = true,         -- Exhaustion | Heroism
    [57724] = true,         -- Sated | Bloodlust
    [80354] = true,         -- Temporal Displacement | Time Warp
    [95809] = true,         -- Insanity | Ancient Hysteria
    [160455] = true,        -- Fatigued | Netherwinds
    [264689] = true,        -- Fatigued | Primal Rage
    [390435] = true,        -- Exhaustion | Fury of the Aspects
    -- Dungeon
    [26013] = true,         -- Deserter | Battlegrounds
    [71041] = true,         -- Dungeon Deserter | Dungeon Finder or Raid Finder
    [1313593] = true,       -- Deserter
    [206151] = true,        -- Challenger's Burden
    [1254550] = true,       -- Arcane Empowerment
}

UF.AuraFilter.Whitelist = {
    [160029] = true,     -- Resurrecting
    [225080] = true,     -- Reincarnation
    [255234] = true,     -- Totemic Revival
    [10060] = true,      -- Power Infusion
    [29166] = true,      -- Innervate
    [406789] = true,     -- Spatial Paradox
}

-- RANGE

UF.RangeSpells = {
    FRIENDLY = {
        HUNTER = {
            [34477] = "Misdirection", -- 40 yards
        },

        WARLOCK = {
            [5697] = "Unending Breath", -- 30 yards
            [20707] = "Soulstone", -- 40 yards
        },

        PRIEST = {
            [21562] = "Power Word: Fortitude", -- 40 yards
            [17] = "Power Word: Shield", -- 40 yards
        },

        PALADIN = {
            [85673] = "Word of Glory", -- 40 yards
            [4987] = "Cleanse", -- 40 yards
            [1022] = "Blessing of Protection", -- 40 yards
        },

        MAGE = {
            [1459] = "Arcane Intellect", -- 40 yards
            [475]  = "Remove Curse", -- 40 yards
        },

        ROGUE = {
            [36554] = "Shadowstep", -- 25 yards
            [57934] = "Tricks of the Trade", -- 40 yards
        },

        DRUID = {
            [8936] = "Regrowth", -- 40 yards
            [774]  = "Rejuvenation", -- 40 yards
        },

        SHAMAN = {
            [8004] = "Healing Surge", -- 40 yards
            [546]  = "Water Walking", -- 30 yards
        },

        WARRIOR = {
            [3411]  = "Intervene", -- 25 yards
            [97462] = "Rallying Cry", -- 40 yards
        },

        DEATHKNIGHT = {
            [47541] = "Death Coil", -- 40 yards
        },

        MONK = {
            [116670] = "Vivify", -- 40 yards
            [115450] = "Detox", -- 40 yards
        },

        DEMONHUNTER = {
            [204021] = "Fiery Brand", -- 30 yards
        },

        EVOKER = {
            [361469] = "Living Flame", -- 25 yards
            [355913] = "Emerald Blossom", -- 25 yards
        },
    },

    ENEMY = {
        HUNTER = {
            [75] = "Auto Shot", -- 40 yards
        },

        WARLOCK = {
            [686] = "Shadow Bolt", -- 40 yards
            [234153] = "Drain Life", -- 40 yards
        },

        PRIEST = {
            [589] = "Shadow Word: Pain", -- 40 yards
        },

        PALADIN = {
            [20271] = "Judgment", -- 30 yards
            [20473] = "Holy Shock", -- 40 yards
        },

        MAGE = {
            [133] = "Fireball", -- 40 yards
            [2139] = "Counterspell", -- 40 yards
        },

        ROGUE = {
            [185565] = "Poisoned Knife", -- 30 yards
            [36554] = "Shadowstep", -- 25 yards
        },

        DRUID = {
            [8921] = "Moonfire", -- 40 yards
        },

        SHAMAN = {
            [188196] = "Lightning Bolt", -- 40 yards
            [8042] = "Earth Shock", -- 40 yards
        },

        WARRIOR = {
            [355] = "Taunt", -- 30 yards
            [772] = "Rend", -- 30 yards
        },

        DEATHKNIGHT = {
            [49576] = "Death Grip", -- 30 yards
        },

        MONK = {
            [115546] = "Provoke", -- 30 yards
        },

        DEMONHUNTER = {
            [278326] = "Consume Magic", -- 20 yards
            [185123] = "Throw Glaive", -- 30 yards
        },

        EVOKER = {
            [362969] = "Azure Strike", -- 25 yards
            [361469] = "Living Flame", -- 25 yards
        },
    },

    RESURRECT = {
        HUNTER = {},

        WARLOCK = {
            [20707] = "Soulstone", -- 40 yards
        },

        PRIEST = {
            [2006] = "Resurrection", -- 40 yards
        },

        PALADIN = {
            [7328] = "Redemption", -- 40 yards
        },

        MAGE = {},
        ROGUE = {},

        DRUID = {
            [50769] = "Revive", -- 40 yards
            [20484] = "Rebirth", -- 40 yards
        },

        SHAMAN = {
            [2008] = "Ancestral Spirit", -- 40 yards
        },

        WARRIOR = {},

        DEATHKNIGHT = {
            [61999] = "Raise Ally", -- 40 yards
        },

        MONK = {
            [115178] = "Resuscitate", -- 40 yards
        },

        DEMONHUNTER = {},

        EVOKER = {
            [361227] = "Return", -- 40 yards
        },
    },

    PET = {
        HUNTER = {
            [136] = "Mend Pet", -- 45 yards
        },

        WARLOCK = {
            [755] = "Health Funnel", -- 45 yards
        },

        PRIEST = {},
        PALADIN = {},
        MAGE = {},
        ROGUE = {},
        DRUID = {},
        SHAMAN = {},
        WARRIOR = {},

        DEATHKNIGHT = {
            [47541] = "Death Coil", -- 40 yards
        },

        MONK = {},
        DEMONHUNTER = {},
        EVOKER = {},
    },
}