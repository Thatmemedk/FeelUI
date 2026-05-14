local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex
local GetAuraApplicationDisplayCount = _G.C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDispelTypeColor = _G.C_UnitAuras.GetAuraDispelTypeColor

function NP:UpdateAuraContainer(Unit, Auras)
    if (not Unit or not Auras) then
        return
    end

    local Buttons = Auras.Buttons
    local MaxAuras = Auras.NumAuras or 6
    local AuraMinCount = 2
    local AuraMaxCount = 99
    local IsFriendly = UnitCanCooperate("player", Unit)
    local Active = 0
    local Index = 1

    while true do
        local AuraData = GetAuraDataByIndex(Unit, Index, Auras.Filter)

        if (not AuraData or Active >= MaxAuras) then
            break
        end

        Index = Index + 1

        local Icon = AuraData.icon
        local AuraInstanceID = AuraData.auraInstanceID
        local AuraIsStealable = AuraData.isStealable

        if (AuraInstanceID) then
            Active = Active + 1

            local Button = Buttons[Active]

            if (not Button) then
                break
            end

            if (Icon) then
                Button.Icon:SetTexture(AuraData.icon)
                UI:KeepAspectRatio(Button, Button.Icon)
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

            if (AuraData.isHarmful) then
                local Color = GetAuraDispelTypeColor(Unit, AuraInstanceID, UI.DispelColorCurve)

                if (Color) then
                    Button:SetColorTemplate(Color:GetRGB())
                end
            else
                Button:SetColorTemplate(unpack(DB.Global.General.BorderColor))
            end

            if (Button.Highlight) then
                if (not IsFriendly) then
                    Button.Highlight:SetAlphaFromBoolean(AuraIsStealable, 1, 0)
                else
                    Button.Highlight:SetAlpha(0)
                end
            end

            -- Cache
            Button.Unit = Unit
            Button.AuraFilter = Auras.Filter
            Button.AuraIndex = Index -1
            Button.AuraInstanceID = AuraInstanceID

            if (not Button:IsShown()) then
                Button:Show()
            end
        end
    end

    for i = Active + 1, #Buttons do
        local Button = Buttons[i]

        if (Button:IsShown()) then
            Button:Hide()
        end

        Button.AuraInstanceID = nil
        Button.Unit = nil
    end
end

function NP:HideAuraContainer(Container)
    if (not Container or not Container.Buttons) then
        return
    end

    for i = 1, #Container.Buttons do
        local Button = Container.Buttons[i]

        if (Button) then
            Button:Hide()

            Button.AuraInstanceID = nil
            Button.Unit = nil
            Button.AuraFilter = nil
            Button.AuraIndex = nil
        end
    end
end

function NP:UpdateAuras(Frame, Unit)
    if (not Frame or not Unit or not UnitExists(Unit) or not UnitIsVisible(Unit)) then
        if (Frame) then
            NP:HideAuraContainer(Frame.Buffs)
            NP:HideAuraContainer(Frame.Debuffs)
            NP:HideAuraContainer(Frame.External)
            NP:HideAuraContainer(Frame.CrowdControl)
        end

        return
    end

    if (Frame.Buffs and Frame.Buffs.Filter) then
        NP:UpdateAuraContainer(Unit, Frame.Buffs)
    end

    if (Frame.Debuffs and Frame.Debuffs.Filter) then
        NP:UpdateAuraContainer(Unit, Frame.Debuffs)
    end

    if (Frame.External and Frame.External.Filter) then
        NP:UpdateAuraContainer(Unit, Frame.External)
    end

    if (Frame.CrowdControl and Frame.CrowdControl.Filter) then
        NP:UpdateAuraContainer(Unit, Frame.CrowdControl)
    end
end

function NP:OnEnter()
    if (_G.GameTooltip:IsForbidden() or not self:IsVisible()) then
        return
    end

    _G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    _G.GameTooltip:SetUnitAuraByAuraInstanceID(self.Unit, self.AuraInstanceID)
end

function NP:OnLeave()
    if (_G.GameTooltip:IsForbidden()) then
        return
    end

    _G.GameTooltip_Hide()
end

function NP:CreateAuraButton(Frame, ExtraBorder, CooldownStyle)
    if (not Frame) then
        return
    end
    
    local Button = CreateFrame("Button", nil, Frame)
    Button:SetTemplate(ExtraBorder)
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- Set Scripts
    Button:SetScript("OnEnter", NP.OnEnter)
    Button:SetScript("OnLeave", NP.OnLeave)

    local Overlay = CreateFrame("Frame", nil, Button)
    Overlay:SetFrameLevel(Button:GetFrameLevel() + 10)
    Overlay:SetInside()

    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetInside()

    local Count = Overlay:CreateFontString(nil, "OVERLAY")
    Count:Point("TOPRIGHT", Button, 2, 6)
    Count:SetFontTemplate("Default")

    local Highlight = CreateFrame("Frame", nil, Button)
    Highlight:SetFrameLevel(Button:GetFrameLevel() -1)
    Highlight:SetInside(Button, 4, 4)
    Highlight:CreateGlow(3, 3, 1, 0, 1, 1)

    local Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Cooldown:SetInside()
    Cooldown:SetDrawEdge(false)
    Cooldown:SetDrawBling(false)
    Cooldown:SetReverse(true)
    Cooldown:Hide()

    if (CooldownStyle == "BOTTOM") then
        UI:RegisterCooldown(Cooldown, Overlay, 0, -6, true, true)
    elseif (CooldownStyle == "CENTER") then
        UI:RegisterCooldown(Cooldown, Overlay, 0, 0, false, true)
    end

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
"HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY"; Auras that should be shown on nameplates.

"HELPFUL|EXTERNAL_DEFENSIVE"; Displays External Defensives such as [Pain Suppression] etc.
"HELPFUL|BIG_DEFENSIVE"; Displays Defensives such as [Barkskin] etc.
"HARMFUL|CROWD_CONTROL"; Returns auras that are flagged as Crowd Control.

--]]

function NP:CreateAuraContainer(Frame, ButtonWidth, ButtonHeight, Spacing, AnchorPoint, OffsetX, OffsetY, Direction, NumAuras, Filter, ExtraBorder, CooldownStyle)
    if (not Frame) then
        return
    end

    local Container = CreateFrame("Frame", nil, Frame)
    Container.Width = ButtonWidth
    Container.Height = ButtonHeight
    Container.Spacing = Spacing
    Container.Direction = Direction
    Container.NumAuras = NumAuras
    Container.Filter = Filter
    Container.Buttons = Container

    local Previous
    local TotalWidth = (ButtonWidth * NumAuras) + (Spacing * (NumAuras - 1))

    Container:Size(TotalWidth, ButtonHeight)
    Container:Point(AnchorPoint, Frame, AnchorPoint, OffsetX or 0, OffsetY or 0)

    for i = 1, NumAuras do
        local Button = NP:CreateAuraButton(Container, ExtraBorder, CooldownStyle)
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

        -- Direct indexing instead of Container.Buttons table
        Container[i] = Button

        -- Cache
        Previous = Button
    end

    return Container
end

function NP:CreateDebuffs(Frame)
    if (Frame.Debuffs) then
        return
    end

    Frame.Debuffs = NP:CreateAuraContainer(Frame, 28, 12, 2, "TOPRIGHT", -2, 24, "RIGHT", 2, "HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY", true, "CENTER")
end

function NP:CreateCrowdControlDebuffs(Frame)
    if (Frame.CrowdControl) then
        return
    end

    Frame.CrowdControl = NP:CreateAuraContainer(Frame, 36, 12, 4, "TOPLEFT", -240, 0, "LEFT", 6, "HARMFUL|CROWD_CONTROL", true, "BOTTOM")
end