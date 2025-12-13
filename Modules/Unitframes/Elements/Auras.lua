local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

function UF:UpdateAuras(Frame, Unit, IsDebuff)
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

        Button.Unit = Unit
        Button.AuraInstanceID = AuraInstanceID
        Button.AuraFilter = IsDebuff and HarmState or "HELPFUL"
        Button.AuraIndex = Index

        ActiveButtons = ActiveButtons + 1
        Index = Index + 1
    end

    for i = ActiveButtons + 1, #Auras.Buttons do
        if Auras.Buttons[i] then
            Auras.Buttons[i]:Hide()
        end
    end
end

function AuraTooltipOnEnter(self)
    if _G.GameTooltip:IsForbidden() or not self:IsVisible() then 
        return 
    end

    _G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

    if (self.AuraInstanceID and type(self.AuraInstanceID) == "number") then
        if (self.AuraFilter == "HARMFUL") then
            _G.GameTooltip:SetUnitDebuffByAuraInstanceID(self.Unit, self.AuraInstanceID)
        else
            _G.GameTooltip:SetUnitBuffByAuraInstanceID(self.Unit, self.AuraInstanceID)
        end
    elseif (self.AuraIndex and type(self.AuraIndex) == "number") then
        if (self.AuraFilter == "HARMFUL") then
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
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- TOOLTIP
    Button:SetScript("OnEnter", AuraTooltipOnEnter)
    Button:SetScript("OnLeave", AuraTooltipOnLeave)

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

function UF:CreateBuffs(Frame)
    local Buffs = CreateFrame("Frame", nil, Frame)
    Buffs:Size(30, 18)  
    Buffs:Point("TOPLEFT", Frame, 0, 32)
    Buffs.NumAuras = 7
    Buffs.Spacing = 3
    Buffs.InitialAnchor = "TOPLEFT"
    Buffs.Direction = "RIGHT"
    Buffs.Buttons = {}

    for i = 1, Buffs.NumAuras do
        local Button = UF:CreateAuraButton(Buffs)
        Button:Hide()

        Buffs.Buttons[i] = Button
    end

    Frame.Buffs = Buffs
end

function UF:CreateDebuffs(Frame)
    local Debuffs = CreateFrame("Frame", nil, Frame)
    Debuffs:Size(30, 18)
    Debuffs:Point("TOPRIGHT", Frame, 0, 28*2)
    Debuffs.NumAuras = 7
    Debuffs.Spacing = 3
    Debuffs.InitialAnchor = "TOPRIGHT"
    Debuffs.Direction = "LEFT"
    Debuffs.Buttons = {}

    for i = 1, Debuffs.NumAuras do
        local Button = UF:CreateAuraButton(Debuffs)
        Button:Hide()

        Debuffs.Buttons[i] = Button
    end

    Frame.Debuffs = Debuffs
end

function UF:CreatePartyDebuffs(Frame)
    local Debuffs = CreateFrame("Frame", nil, Frame)
    Debuffs:Size(32, 18)
    Debuffs:Point("RIGHT", Frame, 40, 0)
    Debuffs.NumAuras = 7
    Debuffs.Spacing = 3
    Debuffs.InitialAnchor = "TOPLEFT"
    Debuffs.Direction = "RIGHT"
    Debuffs.Buttons = {}

    for i = 1, Debuffs.NumAuras do
        local Button = UF:CreateAuraButton(Debuffs)
        Button:Hide()

        Debuffs.Buttons[i] = Button
    end

    Frame.Debuffs = Debuffs
end

function UF:CreateRaidDebuffs(Frame)
    local Debuffs = CreateFrame("Frame", nil, Frame.InvisFrameHigher)
    Debuffs:Size(26, 16)
    Debuffs:Point("LEFT", Frame, 12, 0)
    Debuffs.NumAuras = 2
    Debuffs.Spacing = 4
    Debuffs.InitialAnchor = "TOPLEFT"
    Debuffs.Direction = "RIGHT"
    Debuffs.Buttons = {}

    for i = 1, Debuffs.NumAuras do
        local Button = UF:CreateAuraButton(Debuffs)
        Button:Hide()

        Debuffs.Buttons[i] = Button
    end

    Frame.Debuffs = Debuffs
end