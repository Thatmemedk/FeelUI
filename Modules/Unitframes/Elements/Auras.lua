local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex
local GetAuraApplicationDisplayCount = _G.C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDispelTypeColor = _G.C_UnitAuras.GetAuraDispelTypeColor

function UF:UpdateAuras(Frame, Unit, IsDebuff, IsExternal)
    if (not Frame or not Frame.unit) then
        return
    end

    local Auras = IsDebuff and Frame.Debuffs or IsExternal and Frame.External or Frame.Buffs

    if (not Auras or not Auras.Filter) then 
        return 
    end

    local Buttons = Auras.Buttons
    local MaxAuras = Auras.NumAuras or 6
    local AuraMinCount = 2
    local AuraMaxCount = 99
    local Active = 0
    local Index = 1
    local IsFriendly = UnitCanCooperate("player", Unit)

    while Active < MaxAuras do
        local AuraData = GetAuraDataByIndex(Unit, Index, Auras.Filter)
        Index = Index + 1

        if (not AuraData) then
            break
        end

        local Button = Buttons[Active + 1]

        if (not Button) then
            break
        end

        local AuraInstanceID = AuraData.auraInstanceID
        local Icon = AuraData.icon
        local Duration = AuraData.duration
        local ExpirationTime = AuraData.expirationTime
        local AuraIsStealable = AuraData.isStealable

        if (Button.AuraInstanceID ~= AuraInstanceID) then
            if (Button.Icon) then
                Button.Icon:SetTexture(Icon)
                UI:KeepAspectRatio(Button, Button.Icon)
            end

            if (IsDebuff) then
                local Color = GetAuraDispelTypeColor(Unit, AuraInstanceID, UI.DispelColorCurve)

                if (Color) then
                    Button:SetColorTemplate(Color.r, Color.g, Color.b)
                end
            else
                Button:SetColorTemplate(unpack(DB.Global.General.BorderColor))
            end

            Button.AuraInstanceID = AuraInstanceID
        end

        if (Button.Count) then
            Button.Count:SetText(GetAuraApplicationDisplayCount(Unit, AuraInstanceID, AuraMinCount, AuraMaxCount))
        end

        if (Button.Cooldown) then
            local CD = C_UnitAuras.GetAuraDuration(Unit, AuraInstanceID)

            if (CD) then
                Button.Cooldown:SetCooldownFromDurationObject(CD)
                Button.Cooldown:Show()
            else
                Button.Cooldown:Hide()
            end
        end

        if (Button.Highlight) then
            if (not IsFriendly) then
                Button.Highlight:SetAlphaFromBoolean(AuraIsStealable, 1, 0)
            else
                Button.Highlight:SetAlpha(0)
            end
        end

        Button.Unit = Unit
        Button.AuraFilter = Auras.Filter
        Button.AuraIndex = Index
        Button:Show()

        Active = Active + 1
    end

    for i = Active + 1, #Buttons do
        local Button = Buttons[i]

        if Button:IsShown() then
            Button:Hide()
            Button.AuraInstanceID = nil
        end
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

    local Highlight = CreateFrame("Frame", nil, Button)
    Highlight:SetFrameLevel(Button:GetFrameLevel() -1)
    Highlight:SetInside(Button, 4, 4)
    Highlight:CreateGlow(3, 3, 1, 0, 1, 1)
    Highlight:SetAlpha(0)

    local Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Cooldown:SetInside()
    Cooldown:SetDrawEdge(false)
    Cooldown:SetDrawBling(false)
    Cooldown:SetReverse(true)
    Cooldown:Hide()

    UI:RegisterCooldown(Cooldown, Overlay, 0, -8, false, true)

    -- Cache
    Button.Overlay = Overlay
    Button.Icon = Icon
    Button.Count = Count
    Button.Highlight = Highlight
    Button.Cooldown = Cooldown

    return Button
end

--[[

"HELPFUL"; Displays helpeful Buffs no filtering
"HARMFUL"; Displays harmful Debuffs, no filtering

"HELPFUL|PLAYER"; Displays helpful Buffs only from player and no filtering.
"HARMFUL|PLAYER"; Displays harmful Debuffs only from player and no filtering.

"HELPFUL|RAID"; Buffs filtered by the player's class, e.g. for Priests it will only return  [Power Word: Fortitude] etc.
"HARMFUL|RAID"; Certain Debuffs that only show up on raid frames, e.g. most Debuffs that are relevant in a Raid Setting.
"HARMFUL|RAID_PLAYER_DISPELLABLE"; Returns auras the player can be Dispelled.
"HELPFUL|PLAYER|RAID_IN_COMBAT; Returns auras that are flagged to show on raid frames in combat, this should return mostly just HotS.

"HELPFUL|EXTERNAL_DEFENSIVE"; Displays External Defensives such as [Pain Suppression] etc.
"HELPFUL|BIG_DEFENSIVE"; Displays Defensives such as [Barkskin] etc.
"HARMFUL|CROWD_CONTROL"; Returns auras that are flagged as Crowd Control.

--]]

function UF:CreateAuraContainer(Frame, ButtonWidth, ButtonHeight, Spacing, AnchorPoint, OffsetX, OffsetY, Direction, InitialAnchor, NumAuras, Filter, ExtraBorder)
    local Container = CreateFrame("Frame", nil, Frame)
    Container.Width = ButtonWidth
    Container.Height = ButtonHeight
    Container.Spacing = Spacing
    Container.Direction = Direction
    Container.InitialAnchor = InitialAnchor
    Container.NumAuras = NumAuras
    Container.Filter = Filter
    Container.Buttons = {}

    local TotalWidth = (ButtonWidth * NumAuras) + (Spacing * (NumAuras - 1))

    Container:Size(TotalWidth, ButtonHeight)
    Container:Point(AnchorPoint, Frame, AnchorPoint, OffsetX or 0, OffsetY or 0)

    local Previous

    for i = 1, NumAuras do
        local Button = UF:CreateAuraButton(Container, ExtraBorder)
        Button:Size(ButtonWidth, ButtonHeight)
        Button:Hide()

        if (not Previous) then
            if (Direction == "RIGHT") then
                Button:Point("LEFT", Container, "LEFT", 0, 0)
            else
                Button:Point("RIGHT", Container, "RIGHT", 0, 0)
            end
        else
            if (Direction == "RIGHT") then
                Button:Point("LEFT", Previous, "RIGHT", Spacing, 0)
            else
                Button:Point("RIGHT", Previous, "LEFT", -Spacing, 0)
            end
        end

        Container.Buttons[i] = Button
        Previous = Button
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

    Frame.External = UF:CreateAuraContainer(Frame.InvisFrameHigher, 36, 12, 4, "CENTER", 0, 0, "CENTER", "RIGHT", 1, "HELPFUL|BIG_DEFENSIVE", false)
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

    Frame.Buffs = UF:CreateAuraContainer(Frame.InvisFrameHigher, 18, 12, 3, "TOPLEFT", 0, 0, "RIGHT", "RIGHT", 4, "HELPFUL|PLAYER|RAID_IN_COMBAT", false)

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

    Frame.External = UF:CreateAuraContainer(Frame.InvisFrameHigher, 28, 12, 4, "CENTER", 0, -18, "CENTER", "RIGHT", 1, "HELPFUL|BIG_DEFENSIVE", false)
end