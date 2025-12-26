local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

-- WoW Globals
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitChannelDuration = UnitChannelDuration
local UnitCastingDuration = UnitCastingDuration

-- WoW Globals
local FAILED = _G.FAILED or "Failed"
local INTERRUPTED = _G.INTERRUPTED or "Interrupted"

function NP:GetFrameForUnit(Unit)
    for _, Plate in ipairs(C_NamePlate.GetNamePlates()) do
        local Frame = Plate.FeelUINameplatesEnemy

        if (Frame and Frame.Unit == Unit) then
            return Frame
        end
    end

    return nil
end

function NP:CastStarted(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    -- Cache Names
    local Name, Icon, StartTime, EndTime, Interrupt, CastID, SpellID, Empowered

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_START") then
        Name, _, Icon, StartTime, EndTime, _, CastID, Interrupt, SpellID = UnitCastingInfo(Unit)

        Castbar.Duration = UnitCastingDuration(Unit)
        Castbar.Direction = Enum.StatusBarTimerDirection.ElapsedTime
    else
        -- Channel / Empower Casts
        Name, _, Icon, StartTime, EndTime, _, Interrupt, SpellID, Empowered, _, CastID = UnitChannelInfo(Unit)
        
        if (Empowered) then
            Event = "UNIT_SPELLCAST_EMPOWER_START"

            Castbar.Duration = UnitEmpoweredChannelDuration(Unit)
            Castbar.Direction = Enum.StatusBarTimerDirection.ElapsedTime
        else
            Event = "UNIT_SPELLCAST_CHANNEL_START"

            Castbar.Duration = UnitChannelDuration(Unit)
            Castbar.Direction = Enum.StatusBarTimerDirection.RemainingTime
        end
    end

    if (not Name) then
        return
    end

    -- Update Events
    Castbar.Casting = (Event == "UNIT_SPELLCAST_START")
    Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_START")
    Castbar.Empower = (Event == "UNIT_SPELLCAST_EMPOWER_START")

    -- Cache
    Castbar.Interrupt = Interrupt
    Castbar.CastID = CastID
    Castbar.SpellID = SpellID

    -- Set Values
    Castbar:SetTimerDuration(Castbar.Duration, UI.SmoothBarsImmediate, Castbar.Direction)

    -- Interrupt Color
    Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(Interrupt, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))

    -- Icon
    if (Castbar.Icon) then
        Castbar.Icon:SetTexture(Icon)
    end

    -- Text
    if (Castbar.Text) then
        Castbar.Text:SetText(Name)
    end

    -- Create EmpowerPips
    if (Castbar.Empower) then
        NP:SetupEmpowerPips(Castbar, UnitEmpoweredStagePercentages(Unit))
    end

    -- Call On Update
    Castbar:SetScript("OnUpdate", NP.OnUpdate)

    -- Call Fade
    UI:UIFrameFadeIn(Castbar, NP.FadeInTime, Castbar:GetAlpha(), 1)
end

function NP:CastStopped(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        NP:ResetCastBar(Castbar)
    end

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.FadeInTime, Castbar:GetAlpha(), 0)
end

function NP:CastFailed(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        return
    end

    -- Update Events
    if (Event == "UNIT_SPELLCAST_FAILED") then
        Castbar.Text:SetText(FAILED)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    elseif (Event == "UNIT_SPELLCAST_INTERRUPTED") then
        Castbar.Text:SetText(INTERRUPTED)
        Castbar:SetStatusBarColor(unpack(DB.Global.UnitFrames.CastBarInterruptColor))
    end

    -- Reset CastBar
    NP:ResetCastBar(Castbar)

    -- Call Fade
    UI:UIFrameFadeOut(Castbar, NP.CastHoldTime, Castbar:GetAlpha(), 0)
end

function NP:CastUpdated(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    if (Castbar.CastID ~= CastID or Castbar.SpellID ~= SpellID) then
        return
    end

    -- Cache Names
    local Name, Icon, StartTime, EndTime

    -- Normal Casts
    if (Event == "UNIT_SPELLCAST_DELAYED") then
        Name, _, _, StartTime, EndTime = UnitCastingInfo(Unit)

        Castbar.Duration = UnitChannelDuration(Unit)
        Castbar.Direction = Enum.StatusBarTimerDirection.ElapsedTime
    else
        -- Channel Casts / Empower Casts
        Name, _, _, StartTime, EndTime = UnitChannelInfo(Unit)

        if (Event == "UNIT_SPELLCAST_EMPOWER_UPDATE") then
            Castbar.Duration = UnitEmpoweredChannelDuration(Unit)
            Castbar.Direction = Enum.StatusBarTimerDirection.ElapsedTime
        else
            Castbar.Duration = UnitChannelDuration(Unit)
            Castbar.Direction = Enum.StatusBarTimerDirection.RemainingTime
        end
    end

    if (not Name) then
        return
    end

    -- Update Events
    Castbar.Casting = (Event == "UNIT_SPELLCAST_DELAYED")
    Castbar.Channel = (Event == "UNIT_SPELLCAST_CHANNEL_UPDATE")
    Castbar.Empower = (Event == "UNIT_SPELLCAST_EMPOWER_UPDATE")

    -- Set Values
    Castbar:SetTimerDuration(Castbar.Duration, UI.SmoothBarsImmediate, Castbar.Direction)
end

function NP:CastNonInterruptable(Unit, Event)
    local Frame = self:GetFrameForUnit(Unit)
    local Castbar = Frame and Frame.Castbar

    if (not Castbar) then
        return
    end

    -- Update Events
    if (Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
        Castbar:GetStatusBarTexture():SetVertexColorFromBoolean(Castbar.Interrupt, CreateColor(0.67, 0, 0, 0.7), CreateColor(0.45, 0.45, 0.45, 0.7))
    end
end

function NP.OnUpdate(Castbar)
    local Duration = Castbar:GetTimerDuration():GetElapsedDuration()
    local Total = Castbar:GetTimerDuration():GetTotalDuration()

    Castbar.Time:SetFormattedText("%.1fs / %.1fs", Duration, Total)
end

function NP:CreateEmpowerPips(Castbar, NumStages)
    Castbar.StagePips = Castbar.StagePips or {}

    for i = 1, NumStages do
        if (not Castbar.StagePips[i]) then
            local Pip = CreateFrame("Frame", nil, Castbar, "CastingBarFrameStagePipTemplate")
            Pip:Hide()

            Pip.Texture = Pip:CreateTexture(nil, "BACKGROUND", nil, 7)
            Pip.Texture:SetTexture(Media.Global.Texture)
            Pip.Texture:SetAllPoints()

            Pip.Overlay = CreateFrame("Frame", nil, Pip)
            Pip.Overlay:SetFrameLevel(Pip:GetFrameLevel() - 1)
            Pip.Overlay:SetInside(Pip.Texture)
            Pip.Overlay:SetTemplate()

            if (Pip.FillPip) then
                Pip.FillPip:Hide()
            end

            if (Pip.BasePip) then
                Pip.BasePip:SetAlpha(0)
            end

            Castbar.StagePips[i] = Pip
        end
    end

    for i = NumStages + 1, #Castbar.StagePips do
        Castbar.StagePips[i]:Hide()
    end
end

function NP:SetupEmpowerPips(Castbar, StagePercentages)
    if (type(StagePercentages) ~= "table") then
        return
    end

    local NumPips = #StagePercentages -1

    if (NumPips <= 0) then
        return
    end

    local TotalStages = NumPips + 1
    local PipWidth = 6

    -- Create Pip Frame
    self:CreateEmpowerPips(Castbar, NumPips)

    for i = 1, NumPips do
        local Pip = Castbar.StagePips[i]
        local OffsetX = (i / TotalStages) * Castbar:GetWidth()
        local Color = UI.Colors.EmpowerStagesColors[i]

        Pip:ClearAllPoints()
        Pip:Width(PipWidth)
        Pip:Point("TOP", Castbar, "TOPLEFT", OffsetX, 0)
        Pip:Point("BOTTOM", Castbar, "BOTTOMLEFT", OffsetX, 0)
        Pip:Show()

        if (Color) then
            Pip.Texture:SetVertexColor(Color.r, Color.g, Color.b)
        end

        Pip.Stage = i
    end
end

function NP:ResetCastBar(Castbar)
    -- Reset Cache
    Castbar.Casting = nil
    Castbar.Channel = nil
    Castbar.Empower = nil
    Castbar.Interrupt = nil
    Castbar.CastID = nil
    Castbar.SpellID = nil

    if (Castbar.StagePips) then
        for _, Pip in ipairs(Castbar.StagePips) do
            Pip:Hide()
        end
    end
end

-- CREATE CASTBAR

function NP:CreateCastBar(Frame)
    local Castbar = CreateFrame("StatusBar", nil, Frame)
    Castbar:Size(192, 20) 
    Castbar:Point("BOTTOM", Frame, 0, -10)
    Castbar:SetStatusBarTexture(Media.Global.Texture)
    Castbar:CreateBackdrop()
    Castbar:CreateShadow()
    Castbar:CreateSpark()
    Castbar:SetAlpha(0)

    local CastbarIcon = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    CastbarIcon:Size(36, 26)
    CastbarIcon:Point("LEFT", Castbar, "RIGHT", 4, 3)
    UI:KeepAspectRatio(CastbarIcon, CastbarIcon)
    
    local IconOverlay = CreateFrame("Frame", nil, Castbar)
    IconOverlay:SetInside(CastbarIcon)
    IconOverlay:SetTemplate()
    IconOverlay:CreateShadow()
    IconOverlay:SetShadowOverlay()
    
    local CastbarTime = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)    
    CastbarTime:Point("RIGHT", Castbar, -4, 0)
    CastbarTime:SetFontTemplate("Default")

    local CastbarText = Castbar:CreateFontString(nil, "OVERLAY", nil, 7)
    CastbarText:Point("LEFT", Castbar, 4, 0)
    CastbarText:SetFontTemplate("Default")
    
    Frame.Castbar = Castbar
    Frame.Castbar.Icon = CastbarIcon
    Frame.Castbar.Time = CastbarTime
    Frame.Castbar.Text = CastbarText
end