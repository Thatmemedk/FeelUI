local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

function UF:UpdateCooldownTextColor(Cooldown, Elapsed)
    if (not Cooldown:IsShown()) then
        return
    end

    Cooldown.Elapsed = (Cooldown.Elapsed or 0) + Elapsed

    if (Cooldown.Elapsed < 0.1) then
        return
    end

    Cooldown.Elapsed = 0

    local Button = Cooldown:GetParent()

    if (not Button or not Button.Unit or not Button.AuraInstanceID) then
        return
    end

    local Duration = C_UnitAuras.GetAuraDuration(Button.Unit, Button.AuraInstanceID)

    if (not Duration) then
        return
    end

    local EvaluateDuration = Duration:EvaluateRemainingDuration(UI.CooldownColorCurve)

    if (not EvaluateDuration) then
        return
    end

    for i = 1, Cooldown:GetNumRegions() do
        local Region = select(i, Cooldown:GetRegions())

        if (Region and Region.GetText) then
            Region:SetVertexColor(EvaluateDuration:GetRGBA())
        end
    end
end

function UF:UpdateAuras(Frame, Unit, IsDebuff)
    if (not Frame or not Frame.unit) then
        return
    end

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
    local OnlyRaidDebuff = Auras.ShowOnlyRaidDebuff
    local HarmState = OnlyPlayer and "HARMFUL|PLAYER" or OnlyRaidDebuff and "HARMFUL|RAID" or "HARMFUL"
    local HelpState = OnlyPlayer and "HELPFUL|RAID" or "HELPFUL"
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
                    end
                end

                if (not Button.Cooldown.CDIsHooked) then
                    Button.Cooldown:HookScript("OnUpdate", function(self, Elapsed)
                        UF:UpdateCooldownTextColor(self, Elapsed)
                    end)

                    Button.Cooldown.CDIsHooked = true
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

        -- Cache
        Button.Unit = Unit
        Button.AuraInstanceID = AuraInstanceID
        Button.AuraFilter = IsDebuff and HarmState or HelpState
        Button.AuraIndex = Index

        -- Cache
        PreviousButton = Button
        Active = Active + 1
    end
end

function UF:OnEnter()
    if _G.GameTooltip:IsForbidden() or not self:IsVisible() then
        return
    end

    _G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    _G.GameTooltip:SetUnitAuraByAuraInstanceID(self.Unit, self.AuraInstanceID)
end

function UF:OnLeave()
    if _G.GameTooltip:IsForbidden() then
        return
    end

    _G.GameTooltip_Hide()
end

function UF:CreateAuraButton(Frame, ExtraBorder, HideNumbers)
    local Button = CreateFrame("Button", nil, Frame)
    Button:SetTemplate(ExtraBorder)
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- Set Scripts
    Button:SetScript("OnEnter", UF.OnEnter)
    Button:SetScript("OnLeave", UF.OnLeave)

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

function UF:CreateAuraContainer(Frame, ButtonWidth, ButtonHeight, Spacing, Point, PointX, PointY, InitialAnchor, Direction, NumAuras, ShowOnlyPlayer, OnlyRaidDebuff, ExtraBorder)
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
    Container.ShowOnlyRaidDebuff = OnlyRaidDebuff
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

    Frame.Buffs = UF:CreateAuraContainer(Frame, 30, 18, 3, "TOPLEFT", 0, 32, "TOPLEFT", "RIGHT", 7, false, false, false)
end

function UF:CreateDebuffsTarget(Frame)
    if (Frame.Debuffs) then 
        return 
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame, 30, 18, 3, "TOPRIGHT", 0, 56, "TOPRIGHT", "LEFT", 7, false, false, true)
end

function UF:CreatePartyDebuffs(Frame)
    if (Frame.Debuffs) then 
        return 
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame, 32, 18, 4, "TOPRIGHT", 108, -12, "RIGHT", "RIGHT", 7, false, true, true)
end

function UF:CreatePartyBuffs(Frame)
    if (Frame.Buffs) then 
        return 
    end

    Frame.Buffs = UF:CreateAuraContainer(Frame, 32, 18, 3, "TOPLEFT", -108, -8, "TOPLEFT", "LEFT", 7, true, false, false)
end

function UF:CreateRaidDebuffs(Frame)
    if (Frame.Debuffs) then 
        return 
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame.InvisFrameHigher, 26, 16, 4, "TOPLEFT", 12, -14, "LEFT", "RIGHT", 2, false, true, true)
end

function UF:CreateRaidBuffs(Frame)
    if (Frame.Buffs) then 
        return 
    end

    Frame.Buffs = UF:CreateAuraContainer(Frame.InvisFrameHigher, 18, 12, 2, "TOPLEFT", 1, 4, "LEFT", "RIGHT", 4, true, false, false)

    for i = 1, #Frame.Buffs.Buttons do
        local Button = Frame.Buffs.Buttons[i]

        if (Button and Button.Cooldown) then
            Button.Cooldown:SetHideCountdownNumbers(true)
        end
    end
end