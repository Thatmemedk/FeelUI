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

function Auras:CreateAnchors()
    local Buffs = CreateFrame("Frame", "FeelUI_PlayerBuffs", _G.UIParent)
    Buffs:Size(42, 42)
    Buffs:Point(unpack(DB.Global.Auras.Point))

    local Debuffs = CreateFrame("Frame", "FeelUI_PlayerDebuffs", _G.UIParent)
    Debuffs:Size(48, 48)
    Debuffs:Point("TOPRIGHT", Buffs, 0, -42*3)

    self.Buffs = Buffs
    self.Debuffs = Debuffs
end

function Auras:CreatePlayerAuras()
    local ButtonWidth, ButtonHeight = unpack(DB.Global.Auras.ButtonSize)

    -- Player Buffs
    local BuffsFrame = UI:CreateAuraContainer(self.Buffs, {
        GrowthDirection = "LEFT",
        Anchor = "TOPLEFT",
        X = 0,
        Y = 0,
        Width = ButtonWidth,
        Height = ButtonHeight,
        Spacing = DB.Global.Auras.ButtonSpacing,
        Cooldown = false,
        Count = true,
        Duration = true,
        Border = false,
        Filter = "HELPFUL",
        MaxAuras = 32,
        Unit = "player",
        ShowTempItemEnchantment = true,
    })

    -- Player Debuffs
    local DebuffFrame = UI:CreateAuraContainer(self.Debuffs, {
        GrowthDirection = "LEFT",
        Anchor = "TOPLEFT",
        X = 0,
        Y = 0,
        Width = ButtonWidth+6,
        Height = ButtonHeight+6,
        Spacing = DB.Global.Auras.ButtonSpacing+2,
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

function Auras:OnEvent()
    self.BuffsFrame:UpdateAllAuras()
    self.DebuffFrame:UpdateAllAuras()
end

function Auras:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", self.OnEvent)
end

function Auras:Initialize()
    if (not DB.Global.Auras.Enable) then 
        return 
    end

    self:DisableBlizzardAuras()
    self:CreateAnchors()
    self:CreatePlayerAuras()
    self:RegisterEvents()
end