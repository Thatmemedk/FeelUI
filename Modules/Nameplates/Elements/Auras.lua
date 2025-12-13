local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

function NP:UpdateAuras(Frame, Unit, IsDebuff)
    local Auras = IsDebuff and Frame.Debuffs or Frame.Buffs

    if (not Auras) then 
        return 
    end

    local AuraWidth, AuraHeight = Auras:GetWidth(), Auras:GetHeight()
    local AurasToShow = Auras.NumAuras or 6
    local Spacing = Auras.Spacing or 4
    local OnlyPlayerDebuffs = Auras.ShowOnlyPlayer
    local ActiveButtons = 0
    local Index = 1
    local HarmState

    for _, Buttons in ipairs(Auras.Buttons) do
        Buttons:Hide()
    end

    if (OnlyPlayerDebuffs) then
        HarmState = "HARMFUL|PLAYER"
    else
        HarmState = "HARMFUl"
    end

    while ActiveButtons < AurasToShow do
        local AuraData = GetAuraDataByIndex(Unit, Index, IsDebuff and HarmState or "HELPFUL")

        if (not AuraData or not AuraData.name) then
            break
        end

        local Name = AuraData.name
        local Icon = AuraData.icon
        local Count = AuraData.applications
        local Duration = AuraData.duration
        local ExpirationTime = AuraData.expirationTime
        local AuraInstanceID = AuraData.auraInstanceID
        local Button = Auras.Buttons[ActiveButtons + 1]

        if (not Button) then
            break
        end

        local Direction = Auras.Direction or "RIGHT"
        local OffsetMultiplier = (Direction == "RIGHT") and 1 or -1

        Button:Size(AuraWidth, AuraHeight)
        Button:ClearAllPoints()
        Button:Point(Auras.InitialAnchor, Auras, Auras.InitialAnchor, ActiveButtons * (AuraWidth + Spacing) * OffsetMultiplier, 0)
        Button:Show()

        if (Button.Icon) then
            Button.Icon:SetTexture(Icon)
            UI:KeepAspectRatio(Auras, Button.Icon)
        end

        if (Button.Count) then
            if (Count) then
                Button.Count:SetText(C_StringUtil.TruncateWhenZero(Count))
            else
                Button.Count:SetText("")
            end
        end

        if (Button.Cooldown) then
            if C_StringUtil.TruncateWhenZero(Duration) then
                Button.Cooldown:SetCooldown(Duration, ExpirationTime)
                Button.Cooldown:SetCooldownFromExpirationTime(ExpirationTime, Duration)
            end

            local NumRegions = Button.Cooldown:GetNumRegions()

            for i = 1, NumRegions do
                local Region = select(i, Button.Cooldown:GetRegions())

                if (Region.GetText) then
                    Region:ClearAllPoints()
                    Region:Point("CENTER", Button.Overlay, 0, -7)
                    Region:SetFontTemplate("Default")
                    Region:SetTextColor(1, 0.82, 0)
                end
            end
        end

        if (IsDebuff) then
            local Color = C_UnitAuras.GetAuraDispelTypeColor(Unit, AuraInstanceID, UI.DispelColorCurve)

            if (Color) then
                Button:SetColorTemplate(Color.r, Color.g, Color.b)
            end
        else
            Button:SetColorTemplate(unpack(DB.Global.General.BorderColor))
        end

        ActiveButtons = ActiveButtons + 1
        Index = Index + 1
    end

    for i = ActiveButtons + 1, #Auras.Buttons do
        if Auras.Buttons[i] then
            Auras.Buttons[i]:Hide()
        end
    end
end

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
    Debuffs.ShowOnlyPlayer = true
    Debuffs.Buttons = {}

    for i = 1, Debuffs.NumAuras do
        local Button = NP:CreateAuraButton(Debuffs)
        Button:Hide()

        Debuffs.Buttons[i] = Button
    end

    Frame.Debuffs = Debuffs
end