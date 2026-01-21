local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex
local GetAuraDuration = _G.C_UnitAuras.GetAuraDuration
local GetAuraApplicationDisplayCount = _G.C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDispelTypeColor = _G.C_UnitAuras.GetAuraDispelTypeColor

function UF:UpdateCooldownTextColor(Cooldown, Elapsed)
    if (not Cooldown:IsShown()) then
        return
    end

    self.Elapsed = (self.Elapsed or 0) + Elapsed

    if (self.Elapsed < 0.1) then
        return
    end

    self.Elapsed = 0

    local Button = Cooldown:GetParent()

    if (not Button or not Button.Unit or not Button.AuraInstanceID) then
        return
    end

    local Duration = GetAuraDuration(Button.Unit, Button.AuraInstanceID)

    if (not Duration) then
        return
    end

    local EvaluateDuration = Duration:EvaluateRemainingDuration(UI.CooldownColorCurve)

    if (not EvaluateDuration) then
        return
    end

    for i = 1, Cooldown:GetNumRegions() do
        local Region = select(i, Cooldown:GetRegions())

        if (Region and Region.GetText and Region.SetText) then
            Region:SetVertexColor(EvaluateDuration:GetRGBA())
        end
    end
end

function UF:UpdateAuras(Frame, Unit, IsDebuff, IsExternal)
    if (not Frame or not Frame.unit) then
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

function UF:CreateAuraContainer(Frame, ButtonWidth, ButtonHeight, Spacing, AnchorPoint, OffsetX, OffsetY, Direction, InitialAnchor, NumAuras, Filter, ExtraBorder)
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

    Frame.Buffs = UF:CreateAuraContainer(Frame, 30, 18, 3, "TOPLEFT", 0, 32, "RIGHT", "RIGHT", 7, "HELPFUL", false)
end

function UF:CreateDebuffsTarget(Frame)
    if (Frame.Debuffs) then
        return
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame, 30, 18, 3, "TOPRIGHT", 0, 56, "LEFT", "LEFT", 7, "HARMFUL", true)
end

function UF:CreatePartyDebuffs(Frame)
    if (Frame.Debuffs) then
        return
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame, 32, 12, 3, "TOPRIGHT", 248, -12, "RIGHT", "RIGHT", 7, "HARMFUL|RAID", true)
end

function UF:CreatePartyBuffs(Frame)
    if (Frame.Buffs) then
        return
    end

    Frame.Buffs = UF:CreateAuraContainer(Frame, 32, 12, 3, "TOPLEFT", -248, -12, "TOPLEFT", "LEFT", 7, "HELPFUL|PLAYER|RAID", false)
end

function UF:CreatePartyExternal(Frame)
    if (Frame.External) then
        return
    end

    Frame.External = UF:CreateAuraContainer(Frame.InvisFrameHigher, 36, 12, 4, "CENTER", 0, 0, "CENTER", "RIGHT", 1, "HELPFUL|EXTERNAL_DEFENSIVE", false)
end

function UF:CreateRaidDebuffs(Frame)
    if (Frame.Debuffs) then
        return
    end

    Frame.Debuffs = UF:CreateAuraContainer(Frame.InvisFrameHigher, 26, 12, 4, "TOPLEFT", 12, -18, "RIGHT", "RIGHT", 2, "HARMFUL|RAID", true)
end

function UF:CreateRaidBuffs(Frame)
    if (Frame.Buffs) then
        return
    end

    Frame.Buffs = UF:CreateAuraContainer(Frame.InvisFrameHigher, 18, 12, 3, "TOPLEFT", 0, 0, "RIGHT", "RIGHT", 4, "HELPFUL|PLAYER|RAID", false)

    for i = 1, #Frame.Buffs.Buttons do
        local Button = Frame.Buffs.Buttons[i]

        if (Button and Button.Cooldown) then
            Button.Cooldown:SetHideCountdownNumbers(true)
        end
    end
end

function UF:CreateRaidExternal(Frame)
    if (Frame.External) then
        return
    end

    Frame.External = UF:CreateAuraContainer(Frame.InvisFrameHigher, 28, 12, 4, "CENTER", 0, -18, "CENTER", "RIGHT", 1, "HELPFUL|EXTERNAL_DEFENSIVE", false)
end