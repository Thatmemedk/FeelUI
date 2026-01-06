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

    local ButtonWidth = Auras.Width or 16
    local ButtonHeight = Auras.Height or 16
    local Spacing = Auras.Spacing or 4
    local Direction = Auras.Direction or "RIGHT"
    local MaxAuras = Auras.NumAuras or 6
    local OnlyPlayer = Auras.ShowOnlyPlayer
    local HarmState = OnlyPlayer and "HARMFUL|PLAYER" or "HARMFUL"
    local HelpState = OnlyPlayer and "HELPFUL|PLAYER" or "HELPFUL"
    local AuraMinCount = 2
    local AuraMaxCount = 99
    local Active = 0
    local Index = 1
    local PreviousButton

    for _, Button in ipairs(Auras.Buttons) do
        Button:Hide()
        Button:ClearAllPoints()
    end

    if UnitIsUnit("target", Unit) then
        UI:UIFrameFadeIn(Auras, NP.FadeInTime, Auras:GetAlpha(), 1)
    else
        UI:UIFrameFadeOut(Auras, NP.FadeInTime, Auras:GetAlpha(), 0.5)
    end

    while Active < MaxAuras do
        local AuraData = GetAuraDataByIndex(Unit, Index, IsDebuff and HarmState or HelpState)
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

        if not PreviousButton then
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
            Button.Count:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(Unit, AuraInstanceID, AuraMinCount, AuraMaxCount))
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

                        local CooldownColorCurve = C_CurveUtil.CreateColorCurve()
                        CooldownColorCurve:SetType(Enum.LuaCurveType.Step)
                        CooldownColorCurve:AddPoint(0, CreateColor(unpack(DB.Global.CooldownFrame.ExpireColor)))
                        CooldownColorCurve:AddPoint(9, CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor)))
                        CooldownColorCurve:AddPoint(29, CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor2)))
                        CooldownColorCurve:AddPoint(59, CreateColor(unpack(DB.Global.CooldownFrame.NormalColor)))

                        local AuraDuration = C_UnitAuras.GetAuraDuration(Unit, AuraInstanceID)
                        local EvaluateDuration = AuraDuration:EvaluateRemainingDuration(CooldownColorCurve)
                        Region:SetVertexColor(EvaluateDuration:GetRGBA())
                    end
                end
            else
                Button.Cooldown:Hide()
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

function NP:CreateAuraContainer(Frame, ButtonWidth, ButtonHeight, Spacing, Point, PointX, PointY, InitialAnchor, Direction, NumAuras, ShowOnlyPlayer, ExtraBorder)
    local Container = CreateFrame("Frame", nil, Frame)
    Container:Size(100, 100)
    Container:Point(Point or "TOPLEFT", Frame, PointX or 0, PointY or 0)
    Container:SetAlpha(0.5)
    Container.Width = ButtonWidth
    Container.Height = ButtonHeight
    Container.NumAuras = NumAuras
    Container.Spacing = Spacing
    Container.InitialAnchor = InitialAnchor
    Container.Direction = Direction
    Container.ShowOnlyPlayer = ShowOnlyPlayer
    Container.Buttons = {}

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

    Frame.Debuffs = NP:CreateAuraContainer(Frame, 30, 18, 4, "TOPLEFT", -24, 28, "TOPRIGHT", "RIGHT", 7, true, true)
end