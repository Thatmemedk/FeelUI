local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreateAuraButton(Frame)
    local Button = CreateFrame("Button", nil, Frame)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- OVERLAY
    local Overlay = CreateFrame("Frame", nil, Button)
    Overlay:SetFrameLevel(Button:GetFrameLevel() + 10)
    Overlay:SetInside()

    -- ICON
    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetInside()
    
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

function NP:CreateDebuffs(Frame)
    local Debuffs = CreateFrame("Frame", nil, Frame)
    Debuffs:Size(28, 16)
    Debuffs:Point("TOPLEFT", Frame, -8, 12)
    Debuffs.NumAuras = 6
    Debuffs.Spacing = 3
    Debuffs.InitialAnchor = "TOPRIGHT"
    Debuffs.Direction = "RIGHT"
    Debuffs.Buttons = {}

    for i = 1, Debuffs.NumAuras do
        local Button = NP:CreateAuraButton(Debuffs)
        Button:Hide()

        Debuffs.Buttons[i] = Button
    end

    Frame.Debuffs = Debuffs
end