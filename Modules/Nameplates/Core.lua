local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:RegisterModule("NamePlates")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

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
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitThreatSituation = UnitThreatSituation
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitIsGameObject = UnitIsGameObject
local SetCVar = C_CVar.SetCVar

-- Tables
NP.Hooked = {}
NP.Modified = {}

-- Tables
NP.EnemyFrames = {}
NP.FriendlyFrames = {}

-- Locals
NP.FadeInTime = 0.5
NP.CastHoldTime = 2

-- SecureFrame
NP.SecureFrame = CreateFrame("Frame", "UF_SecureFrame", _G.UIParent, "SecureHandlerStateTemplate")
NP.SecureFrame:SetAllPoints()
NP.SecureFrame:SetFrameStrata("LOW")
RegisterStateDriver(NP.SecureFrame, "visibility", "[petbattle] hide; show")

-- HEALTH UPDATE

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

    self:UpdateHealthColor(Frame, Unit)
end

function NP:UpdateHealthText(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthText) then
        return
    end

    local Percent = UnitHealthPercent(Unit, false, UI.CurvePercent)
    Frame.HealthText:SetFormattedText("%d%%", Percent or 0)
end

-- HEAL PRED

function NP:LayoutHealPred(Frame)
    if (not Frame or not Frame.Health or not Frame.HealthPrediction) then
        return
    end

    local Health = Frame.Health
    local Prediction = Frame.HealthPrediction
    local PlayerHealsBar = Prediction.PlayerHeals
    local OtherHealsBar = Prediction.OtherHeals
    local AllAbsorbsBar = Prediction.AllAbsorbs
    local HealAbsorbsBar = Prediction.HealAbsorbs
    local OverHealsBar = Prediction.OverHeals
    local OverAbsorbsBar = Prediction.OverAbsorbs
    local OverHealsAbsorbsBar = Prediction.OverHealsAbsorbs
    local Orientation = Health:GetOrientation()
    local PrevTexture = Health:GetStatusBarTexture()
    local BarWidth, BarHeight = Health:GetSize()    

    -- Orientation
    PlayerHealsBar:SetOrientation(Orientation)
    OtherHealsBar:SetOrientation(Orientation)
    AllAbsorbsBar:SetOrientation(Orientation)
    HealAbsorbsBar:SetOrientation(Orientation)

    -- Set Reverse Fill
    AllAbsorbsBar:SetReverseFill(true)
    HealAbsorbsBar:SetReverseFill(true)

    if (Orientation == "HORIZONTAL") then
        PlayerHealsBar:Size(BarWidth, BarHeight)
        OtherHealsBar:Size(BarWidth, BarHeight)
        AllAbsorbsBar:Size(BarWidth, BarHeight)
        HealAbsorbsBar:Size(BarWidth, BarHeight)

        -- Player Heals
        PlayerHealsBar:SetOutsideRight(PrevTexture, 0, 0)
        -- Other Heals
        OtherHealsBar:SetOutsideRight(PlayerHealsBar:GetStatusBarTexture(), 0, 0)
        -- All Absorbs
        AllAbsorbsBar:SetInsideRight(PrevTexture, 0, 0)
        -- Heal Absorbs
        HealAbsorbsBar:SetInsideRight(PrevTexture, 0, 0)
        -- OverHeals
        OverHealsBar:SetOutsideRight(OtherHealsBar:GetStatusBarTexture(), -1, 0)
        -- OverAbsorbs
        OverAbsorbsBar:SetOutsideRight(AllAbsorbsBar:GetStatusBarTexture(), 0, 0)
        -- OverHealsAbsorbs
        OverHealsAbsorbsBar:SetOutsideRight(HealAbsorbsBar:GetStatusBarTexture(), 0, 0)
    else
        PlayerHealsBar:Size(BarHeight, BarWidth)
        OtherHealsBar:Size(BarHeight, BarWidth)
        AllAbsorbsBar:Size(BarHeight, BarWidth)
        HealAbsorbsBar:Size(BarHeight, BarWidth)

        -- Player Heals
        PlayerHealsBar:SetOutsideTop(PrevTexture, 0, 0)
        -- Other Heals
        OtherHealsBar:SetOutsideTop(PlayerHealsBar:GetStatusBarTexture(), 0, 0)
        -- All Absorbs
        AllAbsorbsBar:SetInsideTop(PrevTexture, 0, 0)
        -- Heal Absorbs
        HealAbsorbsBar:SetInsideTop(PrevTexture, 0, 0)
        -- OverHeals
        OverHealsBar:SetOutsideTop(OtherHealsBar:GetStatusBarTexture(), 0, 0)
        -- OverAbsorbs
        OverAbsorbsBar:SetOutsideTop(AllAbsorbsBar:GetStatusBarTexture(), 0, 0)
        -- OverHealsAbsorbs
        OverHealsAbsorbsBar:SetOutsideTop(HealAbsorbsBar:GetStatusBarTexture(), 0, 0)
    end

    Prediction.LayoutIsCreated = true
end

function NP:UpdateHealthPred(Frame, Unit)
    if (not Frame or not Unit or not Frame.HealthPrediction) then
        return
    end

    local Prediction = Frame.HealthPrediction

    if (not Prediction.LayoutIsCreated) then
        NP:LayoutHealPred(Frame)
    end

    local Calculator = Prediction.Calculator

    local PlayerHealsBar = Prediction.PlayerHeals
    local OtherHealsBar = Prediction.OtherHeals
    local AllAbsorbsBar = Prediction.AllAbsorbs
    local HealAbsorbsBar = Prediction.HealAbsorbs
    local OverHealsBar = Prediction.OverHeals
    local OverAbsorbsBar = Prediction.OverAbsorbs
    local OverHealsAbsorbsBar = Prediction.OverHealsAbsorbs

    UnitGetDetailedHealPrediction(Unit, "player", Calculator)

    -- Calculate Predictions
    local AllHeals, PlayerHeals, OtherHeals, HealingClamped = Calculator:GetIncomingHeals()
    local AbsorbsAmount, AbsorbsClamped = Calculator:GetDamageAbsorbs()
    local HealAbsorbAmount, HealAbsorbClamped = Calculator:GetHealAbsorbs()
    local Max = UnitHealthMax(Unit)

    PlayerHealsBar:SetMinMaxValues(0, Max)
    PlayerHealsBar:SetValue(PlayerHeals, UI.SmoothBars)

    OtherHealsBar:SetMinMaxValues(0, Max)
    OtherHealsBar:SetValue(OtherHeals, UI.SmoothBars)

    AllAbsorbsBar:SetMinMaxValues(0, Max)
    AllAbsorbsBar:SetValue(AbsorbsAmount, UI.SmoothBars)

    HealAbsorbsBar:SetMinMaxValues(0, Max)
    HealAbsorbsBar:SetValue(HealAbsorbAmount, UI.SmoothBars)

    -- Healing Prediction
    PlayerHealsBar:SetAlphaFromBoolean(PlayerHeals, 1, 0)
    OtherHealsBar:SetAlphaFromBoolean(OtherHeals, 1, 0)
    AllAbsorbsBar:SetAlphaFromBoolean(AbsorbsAmount, 1, 0)
    HealAbsorbsBar:SetAlphaFromBoolean(HealAbsorbAmount, 1, 0)

    -- Over Healing/Absorbs
    OverHealsBar:SetAlphaFromBoolean(HealingClamped, 1, 0)
    OverAbsorbsBar:SetAlphaFromBoolean(AbsorbsClamped, 1, 0)
    OverHealsAbsorbsBar:SetAlphaFromBoolean(HealAbsorbClamped, 1, 0)
end

-- NAME UPDATE

function NP:UpdateName(Frame, Unit)
    if (not Frame or not Unit or not Frame.Name) then
        return
    end

    local Name = UnitName(Unit) or ""
    Frame.Name:SetText(Name)

    if (UnitIsPlayer(Unit) or UnitInPartyIsAI(Unit) or UnitPlayerControlled(Unit) and not UnitIsPlayer(Unit)) then
        local _, Class = UnitClass(Unit)

        if (not UI:IsSecretValue(Class)) then
            local Color = UI.Colors.Class[Class]
            Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
        end
    else
        local Reaction = UnitReaction(Unit, "player")
        local Color = UI.Colors.Reaction[Reaction]
        Frame.Name:SetTextColor(Color.r, Color.g, Color.b)
    end
end

function NP:UpdateGuild(Frame, Unit)
    if (not Frame or not Unit or not Frame.Guild) then
        return
    end

    local GuildName, GuildRankName = GetGuildInfo(Unit)

    if (not GuildName) then
        Frame.Guild:SetText("")
        return
    end

    local SameGuild = IsInGuild() and GetGuildInfo("player") == GuildName
    local ColorFormat = SameGuild and "|CFFFF66CC[%s]|r" or "|CFFFFFFFF[%s]|r"
    Frame.Guild:SetText(string.format(ColorFormat, GuildName))
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
    if (Frame.Health) then self:UpdateHealth(Frame, Unit) end
    if (Frame.HealthText) then self:UpdateHealthText(Frame, Unit) end
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
            self:UpdateHealth(Frame, Unit)
        end

        if (Frame.HealthText) then 
            self:UpdateHealthText(Frame, Unit)
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
    for Key, Frame in next, self.EnemyFrames do
        self:UpdateTargetIndicator(Frame, Frame.unit)
        self:UpdateHighlight(Frame, Frame.unit)
    end

    for Key, Frame in next, self.FriendlyFrames do
        self:UpdateHighlight(Frame, Frame.unit)
    end
end

function NP:UnitMouseOver()
    for Key, Frame in next, self.EnemyFrames do
        self:UpdateHighlightMouseOver(Frame, Frame.unit)
    end
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
    local Casting = UnitCastingInfo(Unit)
    local Channeling = UnitChannelInfo(Unit)

    if (not Unit or not UnitExists(Unit) or not UnitIsVisible(Unit)) then
        return
    end

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

function NP:NameplateAdded(Unit)
    local Plate = C_NamePlate.GetNamePlateForUnit(Unit)

    if (not Plate) then
        return
    end

    local IsFriend = UnitIsFriend("player", Unit)
    local FriendlyFrame = Plate.FriendlyNP
    local EnemyFrame = Plate.EnemyNP

    if (IsFriend) then
        -- HIDE ENEMY
        if (EnemyFrame) then
            local OldUnit = EnemyFrame.unit

            if (OldUnit and self.EnemyFrames[OldUnit] == EnemyFrame) then
                self.EnemyFrames[OldUnit] = nil
            end

            EnemyFrame:Hide()
            EnemyFrame.unit = nil
            EnemyFrame:SetAttribute("unit", nil)
        end

        if (not FriendlyFrame) then
            FriendlyFrame = CreateFrame("Frame", "FeelUI_FriendlyNP" .. Plate:GetName(), Plate, "PingableUnitFrameTemplate")
            FriendlyFrame:EnableMouse(false)
            FriendlyFrame:Size(unpack(DB.Global.Nameplates.Size))
            FriendlyFrame:Point("CENTER", Plate, 0, 0)

            Plate.FriendlyNP = FriendlyFrame

            FriendlyFrame:HookScript("OnHide", function(Frame)
                local OldUnit = Frame.unit

                if (OldUnit and self.FriendlyFrames[OldUnit] == Frame) then
                    self.FriendlyFrames[OldUnit] = nil
                end

                Frame.unit = nil
                Frame:SetAttribute("unit", nil)
            end)

            Plate.UnitFrame.WidgetContainer:SetParent(Plate)
            Plate.UnitFrame.WidgetContainer:SetPoint("TOP", Plate, "BOTTOM")
            Plate.UnitFrame.SoftTargetFrame:SetParent(Plate)  
        end

        -- REMOVE STALE CACHE ENTRY
        local OldUnit = FriendlyFrame.unit

        if (OldUnit and OldUnit ~= Unit and self.FriendlyFrames[OldUnit] == FriendlyFrame) then
            self.FriendlyFrames[OldUnit] = nil
        end

        if (UnitNameplateShowsWidgetsOnly(Unit) or UnitIsGameObject(Unit)) then
            FriendlyFrame:Hide()

            self.FriendlyFrames[Unit] = nil
        else
            FriendlyFrame.unit = Unit
            FriendlyFrame:SetAttribute("unit", Unit)
            FriendlyFrame:Show()

            Plate:ClearAllHitTestPoints()
            Plate:SetAllHitTestPoints(FriendlyFrame)
        end

        -- SET UNIT
        FriendlyFrame.unit = Unit
        FriendlyFrame:SetAttribute("unit", Unit)
        FriendlyFrame:Show()

        -- UPDATE CACHE
        self.FriendlyFrames[Unit] = FriendlyFrame

        -- ELEMENTS
        if (not FriendlyFrame.IsCreated) then
            NP:CreateFriendlyElements(FriendlyFrame)

            FriendlyFrame.IsCreated = true
        end

        -- REFRESH
        NP:RefreshUnit(FriendlyFrame, Unit)
    else
        if (FriendlyFrame) then
            local OldUnit = FriendlyFrame.unit

            if (OldUnit and self.FriendlyFrames[OldUnit] == FriendlyFrame) then
                self.FriendlyFrames[OldUnit] = nil
            end

            FriendlyFrame:Hide()
            FriendlyFrame.unit = nil
            FriendlyFrame:SetAttribute("unit", nil)
        end

        local EnemyFrame = Plate.EnemyNP

        if (not EnemyFrame) then
            EnemyFrame = CreateFrame("Frame", "FeelUI_EnemyNP" .. Plate:GetName(), Plate, "PingableUnitFrameTemplate")
            EnemyFrame:EnableMouse(false)
            EnemyFrame:Size(unpack(DB.Global.Nameplates.Size))
            EnemyFrame:Point("CENTER", Plate, 0, 0)

            Plate.EnemyNP = EnemyFrame

            EnemyFrame:HookScript("OnHide", function(Frame)
                local OldUnit = Frame.unit

                if (OldUnit and self.EnemyFrames[OldUnit] == Frame) then
                    self.EnemyFrames[OldUnit] = nil
                end

                Frame.unit = nil
                Frame:SetAttribute("unit", nil)
            end)

            Plate.UnitFrame.WidgetContainer:SetParent(Plate)
            Plate.UnitFrame.WidgetContainer:SetPoint("TOP", Plate, "BOTTOM")
            Plate.UnitFrame.SoftTargetFrame:SetParent(Plate)
        end

        -- REMOVE STALE CACHE ENTRY
        local OldUnit = EnemyFrame.unit

        if (OldUnit and OldUnit ~= Unit and self.EnemyFrames[OldUnit] == EnemyFrame) then
            self.EnemyFrames[OldUnit] = nil
        end

        -- SET UNIT
        if (UnitNameplateShowsWidgetsOnly(Unit) or UnitIsGameObject(Unit)) then
            EnemyFrame:Hide()

            self.EnemyFrames[Unit] = nil
        else
            EnemyFrame.unit = Unit
            EnemyFrame:SetAttribute("unit", Unit)
            EnemyFrame:Show()

            Plate:ClearAllHitTestPoints()
            Plate:SetAllHitTestPoints(EnemyFrame)
        end

        -- UPDATE CACHE
        self.EnemyFrames[Unit] = EnemyFrame

        -- ELEMENTS
        if (not EnemyFrame.IsCreated) then
            NP:CreateEnemyElements(EnemyFrame)

            EnemyFrame.IsCreated = true
        end

        -- REFRESH
        NP:RefreshUnit(EnemyFrame, Unit)
        NP:RefreshUnitAuras(EnemyFrame, Unit)
    end
end

function NP:NameplateRemoved(Unit)
    local Plate = C_NamePlate.GetNamePlateForUnit(Unit)

    if (not Plate or Plate.FriendlyNP or Plate.EnemyNP) then 
        return
    end

    local FriendlyFrame = Plate.FriendlyNP
    local EnemyFrame = Plate.EnemyNP

    if (FriendlyFrame) then
        -- RESET UNIT
        FriendlyFrame:Hide()
        FriendlyFrame.unit = nil
        FriendlyFrame:SetAttribute("unit", nil)

        -- RESET CACHE
        self.FriendlyFrames[Unit] = nil
    end

    if (EnemyFrame) then
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
    local Plate = C_NamePlate.GetNamePlateForUnit("target")

    if (not Plate) then
        return
    end
    
    if (UnitNameplateShowsWidgetsOnly("target") or UnitIsGameObject("target")) then 
        return 
    end
end

function NP:OnEvent(event, unit, ...)
    if (unit and not unit:match("^nameplate%d+$")) then
        return
    end
    
    if (event == "NAME_PLATE_UNIT_ADDED") then
        NP:NameplateAdded(unit)
        NP:CastBarOnNamePlateUnitAdded(unit)
    elseif (event == "NAME_PLATE_UNIT_REMOVED") then
        NP:CastBarOnNamePlateUnitRemoved(unit)
        NP:NameplateRemoved(unit)
    elseif (event == "PLAYER_TARGET_CHANGED") then
        NP:NameplatePlayerTargetChanged()
        NP:UnitTargetChanged()
    elseif (event == "UPDATE_MOUSEOVER_UNIT") then
        NP:UnitMouseOver()
    elseif (event == "RAID_TARGET_UPDATE") then
        NP:UnitRaidIcon()
    elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_CONNECTION") then
        NP:UnitHealth(unit)
    elseif (event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED") then
        NP:UnitHealthPred(unit)
    elseif (event == "UNIT_NAME_UPDATE") then
        NP:UnitName(unit)
    elseif (event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE") then
        NP:UnitThreat(unit)
    end

    if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START") then
        NP:CastStarted(event, unit)
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
        NP:CastStopped(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_FAILED") then
        NP:CastFailed(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
        NP:CastInterrupted(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
        --NP:CastSucceeded(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
        NP:CastUpdated(event, unit, ...)
    elseif (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
        NP:CastNonInterruptable(event, unit)
    end
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
    SecureEventFrame:RegisterEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED")
    -- NAME
    SecureEventFrame:RegisterEvent("UNIT_NAME_UPDATE")
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

-- INITIALIZE

function NP:Initialize()
    if (not DB.Global.Nameplates.Enable) then 
        return 
    end

    self:DisableBlizzard()
    self:RegisterEvents()
    self:SetCVarOnLogin()
end