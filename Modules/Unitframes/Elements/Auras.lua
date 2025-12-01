local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function AuraTooltipOnEnter(self)
    if _G.GameTooltip:IsForbidden() or not self:IsVisible() then 
        return 
    end

    _G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

    if self.AuraInstanceID and type(self.AuraInstanceID) == "number" then
        if self.AuraFilter == "HARMFUL" then
            _G.GameTooltip:SetUnitDebuffByAuraInstanceID(self.Unit, self.AuraInstanceID)
        else
            _G.GameTooltip:SetUnitBuffByAuraInstanceID(self.Unit, self.AuraInstanceID)
        end
    elseif self.AuraIndex and type(self.AuraIndex) == "number" then
        if self.AuraFilter == "HARMFUL" then
            _G.GameTooltip:SetUnitDebuff(self.Unit, self.AuraIndex)
        else
            _G.GameTooltip:SetUnitBuff(self.Unit, self.AuraIndex)
        end
    end

    _G.GameTooltip:Show()
end

function AuraTooltipOnLeave(self)
    if _G.GameTooltip:IsForbidden() then 
        return 
    end

    _G.GameTooltip:Hide()
end

function UF:CreateAuraButton(Frame)
    local Button = CreateFrame("Button", nil, Frame)
    Button:Size(30, 18)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- TOOLTIP
    --Button:SetScript("OnEnter", AuraTooltipOnEnter)
    --Button:SetScript("OnLeave", AuraTooltipOnLeave)

    -- OVERLAY
    local Overlay = CreateFrame("Frame", nil, Button)
    Overlay:SetFrameLevel(Button:GetFrameLevel() + 10)
    Overlay:SetInside()

    -- ICON
    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetInside()
    UI:KeepAspectRatio(Button, Icon)
    
    -- COOLDOWNS
    local Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Cooldown:SetInside()
    Cooldown:SetDrawEdge(false)
    Cooldown:SetReverse(true)

    -- COUNT
    local Count = Overlay:CreateFontString(nil, "OVERLAY")
    Count:Point("TOPRIGHT", Button, 2, 2)
    Count:SetFontTemplate("Default")

    Button.Overlay = Overlay
    Button.Icon = Icon
    Button.Cooldown = Cooldown
    Button.Count = Count

    return Button
end

function UF:CreateBuffs(Frame)
    local Buffs = CreateFrame("Frame", nil, Frame)
    Buffs:Size(30, 18)  
    Buffs:Point("TOPLEFT", Frame, 0, 32)
    Buffs.NumAuras = 7
    Buffs.Spacing = 9
    Buffs.InitialAnchor = "TOPLEFT"
    Buffs.Buttons = {}

    -- Pre-allocate buttons to avoid creation in combat
    for i = 1, Buffs.NumAuras do
        local btn = UF:CreateAuraButton(Buffs)
        btn:Hide()
        Buffs.Buttons[i] = btn
    end

    Frame.Buffs = Buffs
end

function UF:CreateDebuffs(Frame)
    local Debuffs = CreateFrame("Frame", nil, Frame)
    Debuffs:Size(30, 18)
    Debuffs:Point("TOPRIGHT", Frame, 0, 28*2)
    Debuffs.NumAuras = 7
    Debuffs.Spacing = 9
    Debuffs.InitialAnchor = "TOPRIGHT"
    Debuffs.Buttons = {}

    -- Pre-allocate buttons to avoid creation in combat
    for i = 1, Debuffs.NumAuras do
        local btn = UF:CreateAuraButton(Debuffs)
        btn:Hide()
        Debuffs.Buttons[i] = btn
    end

    Frame.Debuffs = Debuffs
end