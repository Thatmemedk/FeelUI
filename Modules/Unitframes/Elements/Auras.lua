local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack
local floor = math.floor

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

function UF:UpdateAuras(Frame, Unit, IsDebuff)
    if not Frame or not Frame.unit then
        return
    end

    local Auras = IsDebuff and Frame.Debuffs or Frame.Buffs
    if not Auras then
        return
    end

    local ButtonWidth = Auras.Width or 16
    local ButtonHeight = Auras.Height or 16
    local Spacing = Auras.Spacing or 4
    local Direction = Auras.Direction or "RIGHT"
    local MaxAuras = Auras.NumAuras or 6
    local OnlyPlayer = Auras.ShowOnlyPlayer
    local HarmState = OnlyPlayer and "HARMFUL|PLAYER" or "HARMFUL"

    local PreviousButton
    local Active = 0
    local Index = 1

    for _, Button in ipairs(Auras.Buttons) do
        Button:Hide()
        Button:ClearAllPoints()
    end

    while Active < MaxAuras do
        local AuraData = GetAuraDataByIndex(Unit, Index, IsDebuff and HarmState or "HELPFUL")
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
            if (Count) then
                Button.Count:SetText(C_StringUtil.TruncateWhenZero(Count))
            else
                Button.Count:SetText("")
            end
        end

        if (Button.Cooldown) then
            if (C_StringUtil.TruncateWhenZero(Duration)) then
                Button.Cooldown:SetCooldown(Duration, ExpirationTime)
                Button.Cooldown:SetCooldownFromExpirationTime(ExpirationTime, Duration)

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

        Button.Unit = Unit
        Button.AuraInstanceID = AuraInstanceID
        Button.AuraFilter = IsDebuff and HarmState or "HELPFUL"
        Button.AuraIndex = Index

        PreviousButton = Button
        Active = Active + 1
    end
end

function AuraTooltipOnEnter(self)
    if _G.GameTooltip:IsForbidden() or not self:IsVisible() then
        return
    end

    _G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    _G.GameTooltip:SetUnitAuraByAuraInstanceID(self.Unit, self.AuraInstanceID)
end

function AuraTooltipOnLeave()
    if _G.GameTooltip:IsForbidden() then
        return
    end

    _G.GameTooltip:Hide()
end

function UF:CreateAuraButton(Frame, ExtraBorder)
    local Button = CreateFrame("Button", nil, Frame)
    Button:SetTemplate(ExtraBorder)
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    Button:SetScript("OnEnter", AuraTooltipOnEnter)
    Button:SetScript("OnLeave", AuraTooltipOnLeave)

    local Overlay = CreateFrame("Frame", nil, Button)
    Overlay:SetFrameLevel(Button:GetFrameLevel() + 10)
    Overlay:SetInside()

    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetInside()

    local Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Cooldown:SetInside()
    Cooldown:SetDrawEdge(false)
    Cooldown:SetReverse(true)

    local Count = Overlay:CreateFontString(nil, "OVERLAY")
    Count:Point("TOPRIGHT", Button, 2, 2)
    Count:SetFontTemplate("Default")

    Button.Overlay = Overlay
    Button.Icon = Icon
    Button.Cooldown = Cooldown
    Button.Count = Count

    return Button
end

function UF:CreateAuraContainer(Frame, ButtonWidth, ButtonHeight, NumAuras, Spacing, InitialAnchor, Direction, ShowOnlyPlayer, ExtraBorder, Point, PointX, PointY)
    local Container = CreateFrame("Frame", nil, Frame)
    Container:Size(100, 100)
    Container:Point(Point or "TOPLEFT", Frame, PointX or 0, PointY or 0)
    Container.Width = ButtonWidth
    Container.Height = ButtonHeight
    Container.NumAuras = NumAuras
    Container.Spacing = Spacing
    Container.InitialAnchor = InitialAnchor
    Container.Direction = Direction
    Container.ShowOnlyPlayer = ShowOnlyPlayer
    Container.Buttons = {}

    for i = 1, NumAuras do
        local Button = UF:CreateAuraButton(Container, ExtraBorder)
        Button:Hide()

        Container.Buttons[i] = Button
    end

    return Container
end

function UF:CreateBuffsTarget(Frame)
    if (Frame.Buffs) then 
        return 
    end

    Frame.Buffs = UF:CreateAuraContainer(Frame, 30, 18, 7, 3, "TOPLEFT", "RIGHT", false, false, "TOPLEFT", 0, 32)
end

function UF:CreateDebuffsTarget(Frame)
    if (Frame.Debuffs) then 
        return 
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame, 30, 18, 7, 3, "TOPRIGHT", "LEFT", false, true, "TOPRIGHT", 0, 56)
end

function UF:CreatePartyDebuffs(Frame)
    if (Frame.Debuffs) then 
        return 
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame, 32, 18, 7, 4, "TOPLEFT", "RIGHT", false, true, "RIGHT", 108, -42)
end

function UF:CreateRaidDebuffs(Frame)
    if (Frame.Debuffs) then 
        return 
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame.InvisFrameHigher, 26, 16, 2, 4, "TOPLEFT", "RIGHT", false, true, "LEFT", 12, -42)
end
