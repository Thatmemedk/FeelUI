local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:RegisterModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local format = string.format
local pairs = pairs
local next = next

-- WoW Globals
local UnitReaction = UnitReaction
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthPercent = UnitHealthPercent
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsConnected = UnitIsConnected
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitName = UnitName
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsVisible = UnitIsVisible
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitPlayerControlled = UnitPlayerControlled
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitIsGameObject = UnitIsGameObject
local GetGuildInfo = GetGuildInfo
local IsInGuild = IsInGuild
local SetCVar = _G.C_CVar.SetCVar
local GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit

-- Tables
NP.Hooked = {}
NP.Modified = {}

-- Tables
NP.EnemyFrames = {}
NP.FriendlyFrames = {}

-- Locals
NP.FadeInTime = 0.5
NP.CastHoldTime = 2

-- Locals
NP.CurrentTargetFrame = nil
NP.CurrentMouseoverFrame = nil

-- Cache
NP.PlayerGuildCache = {
    InGuild = false,
    GuildName = nil,
}

-- SecureFrame
NP.SecureFrame = CreateFrame("Frame", "UF_SecureFrame", _G.UIParent, "SecureHandlerStateTemplate")
NP.SecureFrame:SetAllPoints()
NP.SecureFrame:SetFrameStrata("LOW")
RegisterStateDriver(NP.SecureFrame, "visibility", "[petbattle] hide; show")

-- HEALTH UPDATE

function NP:UpdateHealth(Frame, Unit)
    if (not Frame or not Unit or not Frame.Health) then
        return
    end

    UnitGetDetailedHealPrediction(Unit, "player", Frame.Health.Value)

    local Min = Frame.Health.Value:GetCurrentHealth()
    local Max = Frame.Health.Value:GetMaximumHealth()

    Frame.Health:SetMinMaxValues(0, Max)

    if (UnitIsConnected(Unit)) then
        Frame.Health:SetValue(Min, UI.SmoothBars)
    else
        Frame.Health:SetValue(Max, UI.SmoothBars)
    end
end

function NP:UpdateHealthText(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthText) then
        return
    end

    local Percent = UnitHealthPercent(Unit, true, UI.CurvePercent)
    Frame.HealthText:SetFormattedText("%d%%", Percent or 0)
end

function NP:UpdateHealthColor(Frame, Unit)
    if (not Frame or not Unit or not Frame.Health) then
        return
    end

    if (not UnitIsConnected(Unit) or UnitIsTapDenied(Unit) or UnitIsDead(Unit) or UnitIsGhost(Unit)) then
        Frame.Health:SetStatusBarColor(0.25, 0.25, 0.25)
        Frame.Health:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.7)

        return
    end

    if (DB.Global.Nameplates.ReactionColor) then
        local Reaction = UnitReaction(Unit, "player")
        local Color = UI.Colors.Reaction[Reaction]

        Frame.Health:SetStatusBarColor(Color.r, Color.g, Color.b, 0.70)
    elseif (DB.Global.Nameplates.UnitColors) then
        local IsCaster = UnitCastingInfo(Unit) or UnitChannelInfo(Unit)
        local UnitClassifColor = NP:GetUnitColor(Unit, IsCaster and true)

        if (UnitClassifColor) then
            Frame.Health:SetStatusBarColor(UnitClassifColor.r, UnitClassifColor.g, UnitClassifColor.b, 0.70)
        end
    else
        Frame.Health:SetStatusBarColor(unpack(DB.Global.Nameplates.HealthBarColor))

        local CurveColor = UnitHealthPercent(Unit, true, UI.NameplatesHealthColorCurve)
        Frame.Health:GetStatusBarTexture():SetVertexColor(CurveColor:GetRGB())
    end

    Frame.Health:SetBackdropColorTemplate(unpack(DB.Global.General.BackdropColor))
end

function NP:UpdateHealthAll(Frame, Unit)
    if (not Frame or not Unit or not Frame.Health) then
        return
    end

    self:UpdateHealth(Frame, Unit)
    self:UpdateHealthText(Frame, Unit)
    self:UpdateHealthColor(Frame, Unit)
end

-- HEAL PRED

function NP:UpdateHealthPredLayout(Frame)
    if (not Frame or not Frame.Health or not Frame.HealthPrediction) then
        return
    end

    local Health = Frame.Health
    local HealingPlayer = Frame.HealthPrediction.HealingPlayer
    local HealingOther = Frame.HealthPrediction.HealingOther
    local DamageAbsorb = Frame.HealthPrediction.DamageAbsorb
    local HealAbsorb = Frame.HealthPrediction.HealAbsorb
    local OverHealIndicator = Frame.HealthPrediction.OverHealIndicator
    local OverDamageAbsorbIndicator = Frame.HealthPrediction.OverDamageAbsorbIndicator
    local OverHealAbsorbIndicator = Frame.HealthPrediction.OverHealAbsorbIndicator
    local Orientation = Health:GetOrientation()
    local ReverseFill = Health:GetReverseFill()
    local HealthTexture = Health:GetStatusBarTexture()
    local BarWidth, BarHeight = Health:GetSize()

    -- Orientation
    HealingPlayer:SetOrientation(Orientation)
    HealingOther:SetOrientation(Orientation)
    DamageAbsorb:SetOrientation(Orientation)
    HealAbsorb:SetOrientation(Orientation)

    -- Reverse Fill
    HealingPlayer:SetReverseFill(ReverseFill)
    HealingOther:SetReverseFill(ReverseFill)
    DamageAbsorb:SetReverseFill(true)
    HealAbsorb:SetReverseFill(true)

    if (Orientation == "HORIZONTAL") then
        HealingPlayer:Size(BarWidth, BarHeight)
        HealingOther:Size(BarWidth, BarHeight)
        DamageAbsorb:Size(BarWidth, BarHeight)
        HealAbsorb:Size(BarWidth, BarHeight)
        OverHealIndicator:Size(2, BarHeight)
        OverDamageAbsorbIndicator:Size(2, BarHeight)
        OverHealAbsorbIndicator:Size(2, BarHeight)

        -- Player Heals
        HealingPlayer:Point("LEFT", Health)
        HealingPlayer:Point("LEFT", HealthTexture, "RIGHT")

        -- Other Heals
        HealingOther:Point("LEFT", Health)
        HealingOther:Point("LEFT", HealingPlayer:GetStatusBarTexture(), "RIGHT")

        -- Damage Absorbs
        DamageAbsorb:Point("BOTTOM", Health)
        DamageAbsorb:Point("BOTTOMRIGHT", Health, "BOTTOMRIGHT")

        -- Heal Absorbs
        HealAbsorb:Point("BOTTOM", Health)
        HealAbsorb:Point("BOTTOMRIGHT", Health, "BOTTOMRIGHT")

        -- Over Heals
        OverHealIndicator:Point("TOPLEFT", HealingOther, "TOPRIGHT")
        OverHealIndicator:Point("BOTTOMLEFT", HealingOther, "BOTTOMRIGHT")

        -- Over Damage Absorbs
        OverDamageAbsorbIndicator:Point("TOPLEFT", DamageAbsorb, "TOPRIGHT")
        OverDamageAbsorbIndicator:Point("BOTTOMLEFT", DamageAbsorb, "BOTTOMRIGHT")

        -- Over Heal Absorbs
        OverHealAbsorbIndicator:Point("TOPLEFT", HealAbsorb, "TOPRIGHT")
        OverHealAbsorbIndicator:Point("BOTTOMLEFT", HealAbsorb, "BOTTOMRIGHT")
    else
        HealingPlayer:Size(BarHeight, BarWidth)
        HealingOther:Size(BarHeight, BarWidth)
        DamageAbsorb:Size(BarHeight, BarWidth)
        HealAbsorb:Size(BarHeight, BarWidth)
        OverHealIndicator:Size(BarWidth, 2)
        OverDamageAbsorbIndicator:Size(BarWidth, 2)
        OverHealAbsorbIndicator:Size(BarWidth, 2)

        -- Player Heals
        HealingPlayer:Point("BOTTOMLEFT", HealthTexture, "TOPLEFT")
        HealingPlayer:Point("BOTTOMRIGHT", HealthTexture, "TOPRIGHT")

        -- Other Heals
        HealingOther:Point("BOTTOMLEFT", HealingPlayer:GetStatusBarTexture(), "TOPLEFT")
        HealingOther:Point("BOTTOMRIGHT", HealingPlayer:GetStatusBarTexture(), "TOPRIGHT")

        -- Damage Absorbs
        DamageAbsorb:Point("TOPLEFT", HealthTexture, "TOPLEFT")
        DamageAbsorb:Point("TOPRIGHT", HealthTexture, "TOPRIGHT")

        -- Heal Absorbs
        HealAbsorb:Point("TOPLEFT", HealthTexture, "TOPLEFT")
        HealAbsorb:Point("TOPRIGHT", HealthTexture, "TOPRIGHT")

        -- Over Heals
        OverHealIndicator:Point("BOTTOMLEFT", HealingOther, "TOPLEFT")
        OverHealIndicator:Point("BOTTOMRIGHT", HealingOther, "TOPRIGHT")

        -- Over Damage Absorbs
        OverDamageAbsorbIndicator:Point("BOTTOMLEFT", DamageAbsorb, "TOPLEFT")
        OverDamageAbsorbIndicator:Point("BOTTOMRIGHT", DamageAbsorb, "TOPRIGHT")

        -- Over Heal Absorbs
        OverHealAbsorbIndicator:Point("BOTTOMLEFT", HealAbsorb, "TOPLEFT")
        OverHealAbsorbIndicator:Point("BOTTOMRIGHT", HealAbsorb, "TOPRIGHT")
    end
end

function NP:UpdateHealthPred(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthPrediction) then
        return
    end

    local Calculator = Frame.HealthPrediction.Calculator
    local HealingPlayer = Frame.HealthPrediction.HealingPlayer
    local HealingOther = Frame.HealthPrediction.HealingOther
    local OverHealIndicator = Frame.HealthPrediction.OverHealIndicator
    local DamageAbsorb = Frame.HealthPrediction.DamageAbsorb
    local OverDamageAbsorbIndicator = Frame.HealthPrediction.OverDamageAbsorbIndicator
    local HealAbsorb = Frame.HealthPrediction.HealAbsorb
    local OverHealAbsorbIndicator = Frame.HealthPrediction.OverHealAbsorbIndicator

    UnitGetDetailedHealPrediction(Unit, "player", Calculator)

    -- Calculate Predictions
    local AllHeals, PlayerHeals, OtherHeals, HealingClamped = Calculator:GetIncomingHeals()
    local AbsorbsAmount, AbsorbsClamped = Calculator:GetDamageAbsorbs()
    local HealAbsorbAmount, HealAbsorbClamped = Calculator:GetHealAbsorbs()
    local Max = UnitHealthMax(Unit)

    if (HealingPlayer or HealingOther or OverHealIndicator) then
        if (HealingPlayer) then
            HealingPlayer:SetMinMaxValues(0, Max)
            HealingPlayer:SetValue(PlayerHeals, UI.SmoothBars)
        end

        if (HealingOther) then
            HealingOther:SetMinMaxValues(0, Max)
            HealingOther:SetValue(OtherHeals, UI.SmoothBars)
        end

        if (OverHealIndicator) then
            OverHealIndicator:SetAlphaFromBoolean(HealingClamped, 1, 0)
        end
    end

    if (DamageAbsorb or OverDamageAbsorbIndicator) then
        if (DamageAbsorb) then
            DamageAbsorb:SetMinMaxValues(0, Max)
            DamageAbsorb:SetValue(AbsorbsAmount, UI.SmoothBars)
        end

        if (OverDamageAbsorbIndicator) then
            OverDamageAbsorbIndicator:SetAlphaFromBoolean(AbsorbsClamped, 1, 0)
        end
    end

    if (HealAbsorb or OverHealAbsorbIndicator) then
        if (HealAbsorb) then
            HealAbsorb:SetMinMaxValues(0, Max)
            HealAbsorb:SetValue(HealAbsorbAmount, UI.SmoothBars)
        end

        if (OverHealAbsorbIndicator) then
            OverHealAbsorbIndicator:SetAlphaFromBoolean(HealAbsorbClamped, 1, 0)
        end
    end

    if (Frame.HealthPrediction) then
        self:UpdateHealthPredLayout(Frame)
    end
end

-- NAME UPDATE

function NP:UpdateName(Frame, Unit)
    if (not Frame or not Unit or not Frame.Name) then
        return
    end

    local Name = UnitName(Unit) or ""
    local R, G, B = 1, 1, 1

    if (UnitIsPlayer(Unit) or UnitInPartyIsAI(Unit) or UnitPlayerControlled(Unit) and not UnitIsPlayer(Unit)) then
        local _, Class = UnitClass(Unit)

        if (not UI:IsSecretValue(Class)) then
            local Color = UI.Colors.Class[Class]

            if (Color) then
                R, G, B = Color.r, Color.g, Color.b
            end
        end
    else
        local Reaction = UnitReaction(Unit, "player")
        local Color = UI.Colors.Reaction[Reaction]

        if (Color) then
            R, G, B = Color.r, Color.g, Color.b
        end
    end

    Frame.Name:SetText(Name)
    Frame.Name:SetTextColor(R, G, B)
end

function NP:UpdateGuild(Frame, Unit)
    if (not Frame or not Unit or not Frame.Guild) then
        return
    end

    local GuildName = GetGuildInfo(Unit)

    if (not GuildName) then
        Frame.Guild:SetText("")

        return
    end

    local Cache = NP.PlayerGuildCache
    local SameGuild = Cache.InGuild and Cache.GuildName == GuildName
    local ColorFormat = SameGuild and "|CFFFF66CC[%s]|r" or "|CFFFFFFFF[%s]|r"
    
    Frame.Guild:SetText(format(ColorFormat, GuildName))
end

function NP:RefreshPlayerGuildCache()
    local InGuild = IsInGuild()
    NP.PlayerGuildCache.InGuild = InGuild
    NP.PlayerGuildCache.GuildName = InGuild and GetGuildInfo("player") or nil
end


-- ICONS

function NP:UpdateRaidIcon(Frame, Unit)
    if (not Frame or not Unit or not Frame.RaidIcon) then
        return
    end

    local Index = GetRaidTargetIndex(Unit)

    if (Index) then
        Frame.RaidIcon:Show()
        SetRaidTargetIconTexture(Frame.RaidIcon, Index)
    else
        Frame.RaidIcon:Hide()
    end
end

-- THREAT

function NP:UpdateThreatHighlight(Frame, Unit)
    if (not Frame or not Unit or not Frame.Threat) then
        return
    end

    local Threat = UnitThreatSituation("player", Unit)
    
    if (Threat and Threat > 0) then
        local R, G, B = GetThreatStatusColor(Threat)
        Frame.Threat.Glow:SetBackdropBorderColor(R * 0.55, G * 0.55, B * 0.55, 0.8)
        Frame.Threat:Show()
    else
        Frame.Threat:Hide()
    end
end

-- HIGHLIGHT

function NP:UpdateTargetIndicator(Frame, Unit)
    if (not Frame or not Unit or not Frame.TargetIndicator) then
        return
    end

    local IsTarget = UnitIsUnit("target", Unit)

    if (IsTarget) then
        Frame.TargetIndicator:Show()
    else
        Frame.TargetIndicator:Hide()
    end
end

function NP:UpdateHighlight(Frame, Unit)
    if (not Frame or not Unit or not Frame.Highlight) then
        return
    end

    local IsTarget = UnitIsUnit("target", Unit)

    if (IsTarget) then
        Frame.Highlight:Show()
    else
        Frame.Highlight:Hide()
    end
end

function NP:UpdateHighlightMouseOver(Frame, Unit)
    if (not Frame or not Unit or not Frame.HighlightMouseOver) then
        return
    end

    local IsMouseover = UnitIsUnit("mouseover", Unit)

    if (IsMouseover) then
        Frame.HighlightMouseOver:Show()
    else
        Frame.HighlightMouseOver:Hide()
    end
end

-- FULL UPDATE

function NP:RefreshUnit(Frame, Unit)
    if (not Frame or not Unit or not UnitExists(Unit) or not UnitIsVisible(Unit)) then
        return
    end

    -- HEALTH
    if (Frame.Health) then self:UpdateHealthAll(Frame, Unit) end
    if (Frame.HealthPrediction) then self:UpdateHealthPred(Frame, Unit) end

    -- NAME
    if (Frame.Name) then self:UpdateName(Frame, Unit) end
    if (Frame.Guild) then self:UpdateGuild(Frame, Unit) end

    -- ICONS
    if (Frame.RaidIcon) then self:UpdateRaidIcon(Frame, Unit) end

    -- THREAT
    if (Frame.Threat) then self:UpdateThreatHighlight(Frame, Unit) end

    -- HIGHLIGHT
    if (Frame.TargetIndicator) then self:UpdateTargetIndicator(Frame, Unit) end
    if (Frame.Highlight) then self:UpdateHighlight(Frame, Unit) end
    if (Frame.HighlightMouseOver) then self:UpdateHighlightMouseOver(Frame, Unit) end
end

function NP:RefreshUnitAuras(Frame, Unit)
    if (not Frame or not Unit) then
        return
    end

    local Data = UI.AuraContainerData[Frame]

    if (not Data) then
        return
    end

    for _, Container in pairs(Data.Containers) do
        if (Container) then
            Container:SetEnabled(true)
            Container:SetUnit(Unit)
        end
    end
end

function NP:RefreshUnitRemovedAuras(Frame)
    if (not Frame) then
        return
    end

    local Data = UI.AuraContainerData[Frame]

    if (not Data) then
        return
    end

    for _, Container in pairs(Data.Containers) do
        if (Container) then
            Container:SetEnabled(false)
        end
    end
end

-- EVENT UPDATES

function NP:UnitHealth(Unit)
    if (not Unit) then
        return
    end

    local Frame = self.EnemyFrames[Unit]

    if (Frame and UnitExists(Unit)) then
        if (Frame.Health) then
            self:UpdateHealthAll(Frame, Unit)
        end
    end
end

function NP:UnitHealthPred(Unit)
    if (not Unit) then
        return
    end

    local Frame = self.EnemyFrames[Unit]

    if (Frame and UnitExists(Unit)) then
        if (Frame.HealthPrediction) then
            self:UpdateHealthPred(Frame, Unit)
        end
    end
end

function NP:UnitName(Unit)
    if (not Unit) then
        return
    end

    local Frame = self.EnemyFrames[Unit] or self.FriendlyFrames[Unit]

    if (Frame and UnitExists(Unit)) then
        if (Frame.Name) then
            self:UpdateName(Frame, Unit)
        end

        if (Frame.Guild) then
            self:UpdateGuild(Frame, Unit)
        end
    end
end

function NP:UnitThreat(Unit)
    if (not Unit) then
        return
    end

    local Frame = self.EnemyFrames[Unit]

    if (Frame and UnitExists(Unit)) then
        if (Frame.Threat) then
            self:UpdateThreatHighlight(Frame, Unit)
        end
    end
end

function NP:UnitTargetChanged()
    local NewFrame = nil

    if (UnitExists("target")) then
        local Plate = GetNamePlateForUnit("target")
        NewFrame = Plate and (Plate.EnemyNP or Plate.FriendlyNP)
    end

    if (self.CurrentTargetFrame and self.CurrentTargetFrame ~= NewFrame) then
        self:UpdateTargetIndicator(self.CurrentTargetFrame, self.CurrentTargetFrame.unit)
        self:UpdateHighlight(self.CurrentTargetFrame, self.CurrentTargetFrame.unit)
    end

    if (NewFrame) then
        self:UpdateTargetIndicator(NewFrame, NewFrame.unit)
        self:UpdateHighlight(NewFrame, NewFrame.unit)
    end

    self.CurrentTargetFrame = NewFrame
end

function NP:UnitMouseOver()
    local NewFrame = nil

    if (UnitExists("mouseover")) then
        local Plate = GetNamePlateForUnit("mouseover")
        NewFrame = Plate and Plate.EnemyNP
    end

    if (self.CurrentMouseoverFrame and self.CurrentMouseoverFrame ~= NewFrame) then
        self:UpdateHighlightMouseOver(self.CurrentMouseoverFrame, self.CurrentMouseoverFrame.unit)
    end

    if (NewFrame) then
        self:UpdateHighlightMouseOver(NewFrame, NewFrame.unit)
    end

    self.CurrentMouseoverFrame = NewFrame
end

function NP:UnitRaidIcon()
    for Key, Frame in next, self.EnemyFrames do
        self:UpdateRaidIcon(Frame, Frame.unit)
    end

    for Key, Frame in next, self.FriendlyFrames do
        self:UpdateRaidIcon(Frame, Frame.unit)
    end
end

function NP:CastBarOnNamePlateUnitAdded(Unit)
    if (not Unit or not UnitExists(Unit) or not UnitIsVisible(Unit)) then
        return
    end

    local Casting = UnitCastingInfo(Unit)
    local Channeling = UnitChannelInfo(Unit)

    if (Casting or Channeling) then
        NP:CastStarted("UNIT_SPELLCAST_START", Unit)
    end
end

function NP:CastBarOnNamePlateUnitRemoved(Unit)
    if (not Unit) then
        return
    end

    local Frame = self.EnemyFrames[Unit]
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    -- Reset CastBar
    NP:ResetCastBar(Frame.Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

-- EVENT HANDLER

function NP:ClearFrames(Frame, Cache)
    local OldUnit = Frame.unit

    if (OldUnit and Cache[OldUnit] == Frame) then
        Cache[OldUnit] = nil
    end

    Frame.unit = nil
    Frame:SetAttribute("unit", nil)
    Frame:Hide()
end

function NP:NameplateAdded(Unit)
    local Plate = GetNamePlateForUnit(Unit)

    if (not Plate) then
        return
    end

    local IsFriend = UnitIsFriend("player", Unit)
    local FriendlyFrame = Plate.FriendlyNP
    local EnemyFrame = Plate.EnemyNP

    if (IsFriend) then
        -- HIDE ENEMY
        if (EnemyFrame) then
            NP:ClearFrames(EnemyFrame, self.EnemyFrames)
        end

        -- CREATE FRIENDLY
        if (not FriendlyFrame) then
            FriendlyFrame = CreateFrame("Frame", "FeelUI_FriendlyNP" .. Plate:GetName(), Plate, "PingableUnitFrameTemplate")
            FriendlyFrame:EnableMouse(false)
            FriendlyFrame:Size(unpack(DB.Global.Nameplates.Size))
            FriendlyFrame:Point("CENTER", Plate, 0, 0)

            Plate.FriendlyNP = FriendlyFrame

            Plate.UnitFrame.SoftTargetFrame:SetParent(Plate)
            Plate.UnitFrame.WidgetContainer:SetParent(Plate)
            Plate.UnitFrame.WidgetContainer:SetPoint("TOP", Plate, "BOTTOM")
        end

        -- REMOVE STALE CACHE ENTRY
        local OldUnit = FriendlyFrame.unit

        if (OldUnit and OldUnit ~= Unit and self.FriendlyFrames[OldUnit] == FriendlyFrame) then
            self.FriendlyFrames[OldUnit] = nil
        end

        -- WIDGETS
        if (UnitNameplateShowsWidgetsOnly(Unit) or UnitIsGameObject(Unit)) then
            NP:ClearFrames(FriendlyFrame, self.FriendlyFrames)

            return
        end

        -- HIT TEST
        if (Plate.HitTestFrame ~= FriendlyFrame) then
            Plate:ClearAllHitTestPoints()
            Plate:SetAllHitTestPoints(FriendlyFrame)

            Plate.HitTestFrame = FriendlyFrame
        end

        -- SET UNIT
        FriendlyFrame.unit = Unit
        FriendlyFrame:SetAttribute("unit", Unit)

        self.FriendlyFrames[Unit] = FriendlyFrame

        -- ELEMENTS
        if (not FriendlyFrame.IsCreated) then
            NP:CreateFriendlyElements(FriendlyFrame)

            FriendlyFrame.IsCreated = true
        end

        -- SHOW
        FriendlyFrame:Show()

        -- REFRESH
        NP:RefreshUnit(FriendlyFrame, Unit)

    else
        -- HIDE FRIENDLY
        if (FriendlyFrame) then
            NP:ClearFrames(FriendlyFrame, self.FriendlyFrames)
        end

        -- CREATE ENEMY
        if (not EnemyFrame) then
            EnemyFrame = CreateFrame("Frame", "FeelUI_EnemyNP" .. Plate:GetName(), Plate, "PingableUnitFrameTemplate")
            EnemyFrame:EnableMouse(false)
            EnemyFrame:Size(unpack(DB.Global.Nameplates.Size))
            EnemyFrame:Point("CENTER", Plate, 0, 0)

            Plate.EnemyNP = EnemyFrame

            Plate.UnitFrame.SoftTargetFrame:SetParent(Plate)
            Plate.UnitFrame.WidgetContainer:SetParent(Plate)
            Plate.UnitFrame.WidgetContainer:Point("TOP", Plate, "BOTTOM")
        end

        -- REMOVE STALE CACHE ENTRY
        local OldUnit = EnemyFrame.unit

        if (OldUnit and OldUnit ~= Unit and self.EnemyFrames[OldUnit] == EnemyFrame) then
            self.EnemyFrames[OldUnit] = nil
        end

        -- WIDGETS
        if (UnitNameplateShowsWidgetsOnly(Unit) or UnitIsGameObject(Unit)) then
            NP:ClearFrames(EnemyFrame, self.EnemyFrames)

            return
        end

        -- HIT TEST
        if (Plate.HitTestFrame ~= EnemyFrame) then
            Plate:ClearAllHitTestPoints()
            Plate:SetAllHitTestPoints(EnemyFrame)

            Plate.HitTestFrame = EnemyFrame
        end

        -- SET UNIT
        EnemyFrame.unit = Unit
        EnemyFrame:SetAttribute("unit", Unit)

        self.EnemyFrames[Unit] = EnemyFrame

        -- ELEMENTS
        if (not EnemyFrame.IsCreated) then
            NP:CreateEnemyElements(EnemyFrame)

            EnemyFrame.IsCreated = true
        end

        -- SHOW
        EnemyFrame:Show()

        -- REFRESH
        NP:RefreshUnit(EnemyFrame, Unit)
        NP:RefreshUnitAuras(EnemyFrame, Unit)
    end
end

function NP:NameplateRemoved(Unit)
    local Plate = GetNamePlateForUnit(Unit)

    if (not Plate) then
        return
    end

    local FriendlyFrame = Plate.FriendlyNP
    local EnemyFrame = Plate.EnemyNP

    if (FriendlyFrame and FriendlyFrame.unit == Unit) then
        -- RESET UNIT
        FriendlyFrame:Hide()
        FriendlyFrame.unit = nil
        FriendlyFrame:SetAttribute("unit", nil)

        -- RESET CACHE
        self.FriendlyFrames[Unit] = nil
    end

    if (EnemyFrame and EnemyFrame.unit == Unit) then
        -- RESET UNIT
        EnemyFrame:Hide()
        EnemyFrame.unit = nil
        EnemyFrame:SetAttribute("unit", nil)

        -- REMOVE AURAS
        NP:RefreshUnitRemovedAuras(EnemyFrame)

        -- RESET CACHE
        self.EnemyFrames[Unit] = nil
    end
end

function NP:NameplatePlayerTargetChanged()
    local Plate = GetNamePlateForUnit("target")

    if (not Plate) then
        return
    end
    
    if (UnitNameplateShowsWidgetsOnly("target") or UnitIsGameObject("target")) then 
        return 
    end
end

local function IsNamePlateUnit(Unit)
    return Unit ~= nil and Unit:sub(1, 9) == "nameplate"
end

local NamePlateLifecycleEvents = {
    NAME_PLATE_UNIT_ADDED = function(unit)
        NP:NameplateAdded(unit)
        NP:CastBarOnNamePlateUnitAdded(unit)
    end,

    NAME_PLATE_UNIT_REMOVED = function(unit)
        NP:CastBarOnNamePlateUnitRemoved(unit)
        NP:NameplateRemoved(unit)
    end,
}

local GlobalEvents = {
    PLAYER_TARGET_CHANGED = function()
        NP:NameplatePlayerTargetChanged()
        NP:UnitTargetChanged()
    end,

    UPDATE_MOUSEOVER_UNIT = function() NP:UnitMouseOver() end,
    RAID_TARGET_UPDATE = function() NP:UnitRaidIcon() end,
    PLAYER_GUILD_UPDATE = function() NP:RefreshPlayerGuildCache() end,
}

local UnitDataEvents = {
    UNIT_HEALTH = function(unit) NP:UnitHealth(unit) end,
    UNIT_MAXHEALTH = function(unit) NP:UnitHealth(unit) end,
    UNIT_HEAL_PREDICTION = function(unit) NP:UnitHealthPred(unit) end,
    UNIT_ABSORB_AMOUNT_CHANGED = function(unit) NP:UnitHealthPred(unit) end,
    UNIT_HEAL_ABSORB_AMOUNT_CHANGED = function(unit) NP:UnitHealthPred(unit) end,
    UNIT_NAME_UPDATE = function(unit) NP:UnitName(unit) end,
    UNIT_THREAT_SITUATION_UPDATE = function(unit) NP:UnitThreat(unit) end,
    UNIT_THREAT_LIST_UPDATE = function(unit) NP:UnitThreat(unit) end,
}

local CastEvents = {
    UNIT_SPELLCAST_START = function(unit, event) NP:CastStarted(event, unit) end,
    UNIT_SPELLCAST_CHANNEL_START = function(unit, event) NP:CastStarted(event, unit) end,
    UNIT_SPELLCAST_EMPOWER_START = function(unit, event) NP:CastStarted(event, unit) end,
    UNIT_SPELLCAST_STOP = function(unit, event, ...) NP:CastStopped(event, unit, ...) end,
    UNIT_SPELLCAST_CHANNEL_STOP = function(unit, event, ...) NP:CastStopped(event, unit, ...) end,
    UNIT_SPELLCAST_EMPOWER_STOP = function(unit, event, ...) NP:CastStopped(event, unit, ...) end,
    UNIT_SPELLCAST_FAILED = function(unit, event, ...) NP:CastFailed(event, unit, ...) end,
    UNIT_SPELLCAST_INTERRUPTED = function(unit, event, ...) NP:CastInterrupted(event, unit, ...) end,
    UNIT_SPELLCAST_DELAYED = function(unit, event, ...) NP:CastUpdated(event, unit, ...) end,
    UNIT_SPELLCAST_CHANNEL_UPDATE = function(unit, event, ...) NP:CastUpdated(event, unit, ...) end,
    UNIT_SPELLCAST_EMPOWER_UPDATE = function(unit, event, ...) NP:CastUpdated(event, unit, ...) end,
    UNIT_SPELLCAST_INTERRUPTIBLE = function(unit, event) NP:CastNonInterruptable(event, unit) end,
    UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(unit, event) NP:CastNonInterruptable(event, unit) end,
}

function NP:OnEvent(event, unit, ...)
    if (unit and not IsNamePlateUnit(unit)) then
        return
    end

    local LifecycleHandler = NamePlateLifecycleEvents[event]
    local GlobalHandler = GlobalEvents[event]
    local DataHandler = UnitDataEvents[event]
    local CastHandler = CastEvents[event]

    if (LifecycleHandler) then
        LifecycleHandler(unit)
    end

    if (GlobalHandler) then
        GlobalHandler(unit)
    end

    if (DataHandler) then
        DataHandler(unit)
    end

    if (CastHandler) then
        CastHandler(unit, event, ...)
    end
end

-- REGISTER EVENTS

function NP:RegisterEvents()
    local SecureEventFrame = NP.SecureFrame

    -- NAMEPLATE
    SecureEventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    SecureEventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    SecureEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    SecureEventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    -- HEALTH
    SecureEventFrame:RegisterEvent("UNIT_HEALTH")
    SecureEventFrame:RegisterEvent("UNIT_MAXHEALTH")
    -- HEALTH PRED
    SecureEventFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
    SecureEventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    SecureEventFrame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    -- NAME
    SecureEventFrame:RegisterEvent("UNIT_NAME_UPDATE")
    -- GUILD (keeps NP.PlayerGuildCache correct)
    SecureEventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
    -- THREAT
    SecureEventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    -- CASTBAR
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    SecureEventFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    -- ICONS
    SecureEventFrame:RegisterEvent("RAID_TARGET_UPDATE")
    -- ON EVENT
    SecureEventFrame:SetScript("OnEvent", function(_, event, ...) 
        NP:OnEvent(event, ...) 
    end)
end

-- SET CVARS

function NP:SetCVarOnLogin()
    SetCVar("nameplateSelectedScaleEnabled", 1)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateSelectedScaleFactor", 1)
    SetCVar("nameplateGlobalScale", 1)
    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateMotion", 0)
    SetCVar("nameplateOverlapH", 0.8)
    SetCVar("nameplateOverlapV", 1.1)
    -- All
    SetCVar("nameplateShowAll", 1)
    -- Friendly
    SetCVar("nameplateShowFriends", 1)
    SetCVar("nameplateShowFriendlyNPCs", 0)
    SetCVar("nameplateShowFriendlyPets", 0)
    SetCVar("nameplateShowFriendlyTotems", 0)
    SetCVar("nameplateShowFriendlyMinions", 0)
    SetCVar("nameplateShowFriendlyGuardians", 0)
    -- Enemies
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("nameplateShowEnemyMinion", 1)
    SetCVar("nameplateShowEnemyMinus", 1)
    -- Names Only
    SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", 1)
    SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", 1)
    -- Never Show
    SetCVar("nameplateShowSelf", 0)
end

-- INITIALIZE

function NP:Initialize()
    if (not DB.Global.Nameplates.Enable) then 
        return 
    end

    self:DisableBlizzard()
    self:RegisterEvents()
    self:SetCVarOnLogin()
    self:RefreshPlayerGuildCache()
end