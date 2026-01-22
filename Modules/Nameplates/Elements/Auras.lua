local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex
local GetAuraApplicationDisplayCount = _G.C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDispelTypeColor = _G.C_UnitAuras.GetAuraDispelTypeColor

function NP:UpdateAuras(Frame, Unit, IsDebuff, IsExternal)
    if (not Frame or not Unit) then
        return
    end

    local Auras = IsDebuff and Frame.Debuffs or IsExternal and Frame.External or Frame.Buffs

    if (not Auras or not Auras.Filter) then 
        return 
    end

    local ButtonWidth = Auras.Width or 16
    local ButtonHeight = Auras.Height or 16
    local Spacing = Auras.Spacing or 4
    local Direction = Auras.Direction or "RIGHT"
    local MaxAuras = Auras.NumAuras or 6
    local AuraMinCount = 2
    local AuraMaxCount = 99
    local Active = 0
    local Index = 1
    local PreviousButton

    for _, Button in ipairs(Auras.Buttons) do
        Button:Hide()
        Button:ClearAllPoints()
    end

    while Active < MaxAuras do
        local AuraData = GetAuraDataByIndex(Unit, Index, Auras.Filter)
        Index = Index + 1

        if (not AuraData or not AuraData.name) then
            break
        end

        local Icon = AuraData.icon
        local Count = AuraData.applications
        local Duration = AuraData.duration
        local ExpirationTime = AuraData.expirationTime
        local AuraInstanceID = AuraData.auraInstanceID
        local Button = Auras.Buttons[Active + 1]

        if (not Button) then
            break
        end

        Button:Size(ButtonWidth, ButtonHeight)
        Button:ClearAllPoints()

        if (not PreviousButton) then
            if (Direction == "RIGHT") then
                Button:Point("TOPLEFT", Auras, "TOPLEFT", 0, 0)
            else
                Button:Point("TOPRIGHT", Auras, "TOPRIGHT", 0, 0)
            end
        else
            if (Direction == "RIGHT") then
                Button:Point("LEFT", PreviousButton, "RIGHT", Spacing, 0)
            else
                Button:Point("RIGHT", PreviousButton, "LEFT", -Spacing, 0)
            end
        end

        Button:Show()

        if (Button.Icon) then
            Button.Icon:SetTexture(Icon)
            UI:KeepAspectRatio(Button, Button.Icon)
        end

        if (Button.Count) then
            Button.Count:SetText(GetAuraApplicationDisplayCount(Unit, AuraInstanceID, AuraMinCount, AuraMaxCount))
        end

        if (Button.Cooldown) then
            if (C_StringUtil.TruncateWhenZero(Duration)) then
                Button.Cooldown:SetCooldown(Duration, ExpirationTime)
                Button.Cooldown:SetCooldownFromExpirationTime(ExpirationTime, Duration)

                for i = 1, Button.Cooldown:GetNumRegions() do
                    local Region = select(i, Button.Cooldown:GetRegions())

                    if (Region and Region.GetText) then
                        Region:ClearAllPoints()
                        Region:Point("CENTER", Button.Overlay, 0, -8)
                        Region:SetFontTemplate("Default")
                    end
                end

                UI:RegisterCooldown(Button.Cooldown, true)
            else
                Button.Cooldown:Hide()
            end
        end

        if (IsDebuff) then
            local Color = GetAuraDispelTypeColor(Unit, AuraInstanceID, UI.DispelColorCurve)

            if (Color) then
                Button:SetColorTemplate(Color.r, Color.g, Color.b)
            end
        else
            Button:SetColorTemplate(unpack(DB.Global.General.BorderColor))
        end

        -- Cache
        Button.Unit = Unit
        Button.AuraInstanceID = AuraInstanceID
        Button.AuraFilter = Auras.Filter
        Button.AuraIndex = Index

        -- Cache
        PreviousButton = Button
        Active = Active + 1
    end
end

function NP:CreateAuraButton(Frame, ExtraBorder)
    local Button = CreateFrame("Button", nil, Frame)
    Button:SetTemplate(ExtraBorder)
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    local Overlay = CreateFrame("Frame", nil, Button)
    Overlay:SetFrameLevel(Button:GetFrameLevel() + 10)
    Overlay:SetInside()

    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetInside()

    local Count = Overlay:CreateFontString(nil, "OVERLAY")
    Count:Point("TOPRIGHT", Button, 2, 2)
    Count:SetFontTemplate("Default")

    local Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Cooldown:SetInside()
    Cooldown:SetDrawEdge(false)
    Cooldown:SetDrawBling(false)
    Cooldown:SetReverse(true)

    -- Cache
    Button.Overlay = Overlay
    Button.Icon = Icon
    Button.Count = Count
    Button.Cooldown = Cooldown

    return Button
end

function NP:CreateAuraContainer(Frame, ButtonWidth, ButtonHeight, Spacing, AnchorPoint, OffsetX, OffsetY, Direction, InitialAnchor, NumAuras, Filter, ExtraBorder)
    local Container = CreateFrame("Frame", nil, Frame)
    Container.Width = ButtonWidth
    Container.Height = ButtonHeight
    Container.Spacing = Spacing
    Container.Direction = Direction
    Container.InitialAnchor = InitialAnchor
    Container.NumAuras = NumAuras
    Container.Filter = Filter -- HELPFUL; HARMFUL; HELPFUL|PLAYER; HARMFUL|PLAYER; "HARMFUL|RAID"; "HELPFUL|RAID"; "HELPFUL|EXTERNAL_DEFENSIVE";
    Container.Buttons = {}
    
    local TotalWidth = (ButtonWidth * NumAuras) + (Spacing * (NumAuras - 1))

    Container:Size(TotalWidth, ButtonHeight)
    Container:Point(AnchorPoint, Frame, AnchorPoint, OffsetX or 0, OffsetY or 0)

    for i = 1, NumAuras do
        local Button = NP:CreateAuraButton(Container, ExtraBorder)
        Button:Hide()

        Container.Buttons[i] = Button
    end

    return Container
end

function NP:CreateDebuffs(Frame)
    if (Frame.Debuffs) then
        return
    end

    Frame.Debuffs = NP:CreateAuraContainer(Frame, 28, 12, 4, "TOPRIGHT", -2, 30, "RIGHT", "RIGHT", 6, "HARMFUL|PLAYER", true)
end