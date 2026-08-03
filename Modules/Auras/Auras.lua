local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Auras = UI:RegisterModule("Auras")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function Auras:DisableBlizzardAuras()
    if (_G.BuffFrame) then
        _G.BuffFrame:Kill()
    end

    if (_G.DebuffFrame) then
        _G.DebuffFrame:Kill()
    end
end

function Auras:CreatePlayerAuras()
    local ButtonWidth, ButtonHeight = unpack(DB.Global.Auras.ButtonSize)

    local Buffs = CreateFrame("Frame", "FeelUI_BuffsAnchor", _G.UIParent)
    Buffs:Size(42, 42)
    Buffs:Point(unpack(DB.Global.Auras.Point))

    local BuffsFrame = UI:CreateAuraContainer(Buffs, {
        GrowthDirection = "LEFT",
        Anchor = "TOPLEFT",
        X = 0,
        Y = 0,
        Width = ButtonWidth,
        Height = ButtonHeight,
        Cooldown = false,
        Count = true,
        Duration = true,
        Border = false,
        Filter = "HELPFUL",
        MaxAuras = 32,
        Unit = "player",
        ShowTempItemEnchantment = true,
    })

    local Debuffs = CreateFrame("Frame", "FeelUI_DebuffsAnchor", _G.UIParent)
    Debuffs:Size(48, 48)
    Debuffs:Point("TOPRIGHT", Buffs, 0, -42*3)

    local DebuffFrame = UI:CreateAuraContainer(Debuffs, {
        GrowthDirection = "LEFT",
        Anchor = "TOPLEFT",
        X = 0,
        Y = 0,
        Width = ButtonWidth+6,
        Height = ButtonHeight+6,
        Cooldown = false,
        Count = true,
        Duration = true,
        Border = true,
        DebuffIndicator = true,
        Filter = "HARMFUL",
        MaxAuras = 12,
        Unit = "player",
        TimeY = -10,
    })

    self.BuffsFrame = BuffsFrame
    self.DebuffFrame = DebuffFrame
end

function Auras:UpdateAuras()
    -- Make sure we update them on reload/login
    self.BuffsFrame:UpdateAllAuras()
    self.DebuffFrame:UpdateAllAuras()
end

function Auras:Initialize()
    if (not DB.Global.Auras.Enable) then 
        return 
    end

    self:DisableBlizzardAuras()
    self:CreatePlayerAuras()
    self:UpdateAuras()
end