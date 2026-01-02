local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

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