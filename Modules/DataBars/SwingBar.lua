local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local SwingBar = UI:RegisterModule("SwingBar")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local C_SwingTimer = _G.C_SwingTimer
local C_DurationUtil = _G.C_DurationUtil
local GetTime = _G.GetTime
local UnitAttackSpeed = _G.UnitAttackSpeed
local IsSecretValue = _G.issecretvalue
local MainHand = Enum.PlayerSwingType.MainHand
local OffHand = Enum.PlayerSwingType.OffHand
local Ranged = Enum.PlayerSwingType.Ranged
local ElapsedTime = Enum.StatusBarTimerDirection.ElapsedTime
local RemainingTime = Enum.StatusBarTimerDirection.RemainingTime

-- Locals
SwingBar.UpdateElapsed = 0
SwingBar.UpdateInterval = 0.05
SwingBar.EndMH = 0
SwingBar.EndOH = 0
SwingBar.EndRanged = 0
SwingBar.DurationMH = 0
SwingBar.DurationOH = 0
SwingBar.DurationRanged = 0
SwingBar.ActiveMH = false
SwingBar.ActiveOH = false
SwingBar.ActiveRanged = false
SwingBar.IsShown = false
SwingBar.HasOffHand = false
SwingBar.SameSpeed = false
SwingBar.MainHandSpeed = nil
SwingBar.OffHandSpeed = nil

function SwingBar:Create()
    local BarMH = CreateFrame("StatusBar", "FeelUI_SwingBar", _G.UIParent)
    BarMH:Size(263, 8)
    BarMH:Point("CENTER", _G.UIParent, 0, -181)
    BarMH:SetStatusBarTexture(Media.Global.Texture)
    BarMH:SetStatusBarColor(0.5, 0.5, 0.5)
    BarMH:SetMinMaxValues(0, 1, UI.SmoothBars)
    BarMH:SetValue(0, UI.SmoothBars)
    BarMH:SetAlpha(0)
    BarMH:CreateBackdrop()
    BarMH:CreateShadow()
    BarMH:CreateSpark()

    local BarOH = CreateFrame("StatusBar", nil, BarMH)
    BarOH:SetInside()
    BarOH:SetStatusBarTexture(Media.Global.Texture)
    BarOH:SetStatusBarColor(0.5, 0.5, 0.5, 0.50)
    BarOH:SetMinMaxValues(0, 1, UI.SmoothBars)
    BarOH:SetValue(0, UI.SmoothBars)
    BarOH:CreateSpark()
    BarOH:Hide()

    local InvisFrame = CreateFrame("Frame", nil, BarMH)
    InvisFrame:SetFrameLevel(BarMH:GetFrameLevel() + 10)
    InvisFrame:SetInside()

    local SwingTimerMH = InvisFrame:CreateFontString(nil, "OVERLAY")
    SwingTimerMH:Point("CENTER", BarMH, 0, 6)
    SwingTimerMH:SetFontTemplate("Default", 16)

    local SwingTimerOH = InvisFrame:CreateFontString(nil, "OVERLAY")
    SwingTimerOH:Point("RIGHT", BarOH, -6, 6)
    SwingTimerOH:SetFontTemplate("Default", 16)

    -- Cache
    self.Frame = BarMH
    self.OffHand = BarOH
    self.SwingTimerMH = SwingTimerMH
    self.SwingTimerOH = SwingTimerOH
    self.DurationObjMH = C_DurationUtil.CreateDuration()
    self.DurationObjOH = C_DurationUtil.CreateDuration()
    self.DurationObjRanged = C_DurationUtil.CreateDuration()

    self:ParkSwingSide(MainHand)
    self:ParkSwingSide(OffHand)
    self:ParkSwingSide(Ranged)
end

function SwingBar.OnUpdate(_, Elapsed)
    SwingBar.UpdateElapsed = SwingBar.UpdateElapsed + Elapsed

    if (SwingBar.UpdateElapsed < SwingBar.UpdateInterval) then
        return
    end

    local Now = GetTime()

    SwingBar:UpdateSwingSide(Now, MainHand)
    SwingBar:UpdateSwingSide(Now, OffHand)
    SwingBar:UpdateSwingSide(Now, Ranged)

    if (not SwingBar.ActiveMH and not SwingBar.ActiveOH and not SwingBar.ActiveRanged) then
        SwingBar:HideBar()
    end

    SwingBar.UpdateElapsed = 0
end

function SwingBar:GetSwingSide(SwingType)
    if (SwingType == MainHand) then
        return self.Frame, self.SwingTimerMH, "EndMH", "DurationMH", "ActiveMH", "DurationObjMH"
    elseif (SwingType == OffHand) then
        return self.OffHand, self.SwingTimerOH, "EndOH", "DurationOH", "ActiveOH", "DurationObjOH"
    elseif (SwingType == Ranged) then
        return self.Frame, self.SwingTimerMH, "EndRanged", "DurationRanged", "ActiveRanged", "DurationObjRanged"
    end
end

function SwingBar:ParkSwingSide(SwingType)
    local Bar, _, _, _, _, DurationObjKey = self:GetSwingSide(SwingType)
    local DurationObj = self[DurationObjKey]

    DurationObj:SetTimeFromStart(GetTime() - 1, 1)
    Bar:SetTimerDuration(DurationObj, UI.SmoothBars, RemainingTime)
    Bar:SetValue(0, UI.SmoothBars)
end

function SwingBar:UpdateSwingSide(Now, SwingType)
    local Bar, Timer, EndKey, DurationKey, ActiveKey = self:GetSwingSide(SwingType)

    if (not self[ActiveKey]) then
        return
    end

    local Remaining = self[EndKey] - Now

    if (Remaining > 0) then
        Timer:SetFormattedText("%.1f", Remaining)
    else
        self[EndKey] = 0
        self[DurationKey] = 0
        self[ActiveKey] = false
        Bar:SetValue(1, UI.SmoothBars)
        Timer:SetText("")
    end
end

function SwingBar:ShowBar()
    if (self.IsShown) then
        return
    end

    self.IsShown = true
    self.UpdateElapsed = 0
    self.Frame:SetScript("OnUpdate", self.OnUpdate)

    UI:UIFrameFadeIn(self.Frame, 0.25, self.Frame:GetAlpha(), 1)
end

function SwingBar:HideBar()
    if (not self.IsShown) then
        return
    end

    self.IsShown = false
    self.Frame:SetScript("OnUpdate", nil)

    UI:UIFrameFadeOut(self.Frame, 1, self.Frame:GetAlpha(), 0)
end

function SwingBar:StartSwing(SwingType, Duration)
    if (UI:IsSecretValue(SwingType) or UI:IsSecretValue(Duration)) then
        return
    end

    if (not Duration or Duration <= 0) then
        return
    end

    local Bar, Timer, EndKey, DurationKey, ActiveKey, DurationObjKey = self:GetSwingSide(SwingType)
    local Now = GetTime()

    self[DurationKey] = Duration
    self[EndKey] = Now + Duration
    self[ActiveKey] = true

    local DurationObj = self[DurationObjKey]
    DurationObj:SetTimeFromStart(Now, Duration)
    Bar:SetTimerDuration(DurationObj, UI.SmoothBars, ElapsedTime)
    Timer:SetFormattedText("%.1f", Duration)

    self:ShowBar()
end

function SwingBar:ResetSwing()
    self:ParkSwingSide(MainHand)
    self:ParkSwingSide(OffHand)
    self:ParkSwingSide(Ranged)

    self.EndMH = 0
    self.EndOH = 0
    self.EndRanged = 0
    self.DurationMH = 0
    self.DurationOH = 0
    self.DurationRanged = 0
    self.ActiveMH = false
    self.ActiveOH = false
    self.ActiveRanged = false
    self.SwingTimerMH:SetText("")
    self.SwingTimerOH:SetText("")
    self:HideBar()
end

function SwingBar:UpdateRange(SwingType, IsInRange, ChecksRange)
    if (not ChecksRange) then
        return
    end

    local Color = IsInRange and 0.5 or 0.4

    if (SwingType == MainHand or SwingType == Ranged) then
        self.Frame:SetStatusBarColor(Color, Color, Color)
    elseif (SwingType == OffHand) then
        self.OffHand:SetStatusBarColor(Color, Color, Color, 0.50)
    end
end

function SwingBar:UpdateCurrentRange(SwingType)
    local IsInRange = C_SwingTimer.IsTargetWithinSwingRange(SwingType)

    if (IsInRange == nil) then
        return
    end

    self:UpdateRange(SwingType, IsInRange, true)
end

function SwingBar:UpdateBar()
    local MainHandSpeed, OffHandSpeed = UnitAttackSpeed("player")

    if (not UI:IsSecretValue(MainHandSpeed) and type(MainHandSpeed) == "number") then
        self.MainHandSpeed = MainHandSpeed
    end

    if (not UI:IsSecretValue(OffHandSpeed) and type(OffHandSpeed) == "number") then
        self.OffHandSpeed = OffHandSpeed

        if (OffHandSpeed > 0) then
            self.HasOffHand = true

            if (not UI:IsSecretValue(MainHandSpeed) and type(MainHandSpeed) == "number") then
                self.SameSpeed = math.abs(MainHandSpeed - OffHandSpeed) < 0.01
            end
        else
            self.HasOffHand = false
            self.SameSpeed = false
        end
    elseif (not UI:IsSecretValue(OffHandSpeed)) then
        self.OffHandSpeed = nil
        self.HasOffHand = false
        self.SameSpeed = false
    end

    -- Same MH/OH speed:
    -- Only use the main-hand visual bar.
    -- OH swings are still tracked internally.
    if (self.HasOffHand and self.SameSpeed) then
        self.SwingTimerMH:ClearAllPoints()
        self.SwingTimerMH:Point("CENTER", self.Frame, 0, 6)

        self.SwingTimerOH:SetText("")
        self.SwingTimerOH:Hide()

        self.OffHand:Hide()

    elseif (self.HasOffHand) then
        -- Different speeds:
        -- Show separate MH/OH visuals.
        self.SwingTimerMH:ClearAllPoints()
        self.SwingTimerMH:Point("LEFT", self.Frame, 6, 6)

        self.SwingTimerOH:ClearAllPoints()
        self.SwingTimerOH:Point("RIGHT", self.OffHand, -6, 6)

        self.OffHand:Show()
        self.SwingTimerOH:Show()

    else
        -- No off-hand.
        self.SwingTimerMH:ClearAllPoints()
        self.SwingTimerMH:Point("CENTER", self.Frame, 0, 6)

        self.SwingTimerOH:SetText("")
        self.SwingTimerOH:Hide()

        self.EndOH = 0
        self.DurationOH = 0
        self.ActiveOH = false

        self:ParkSwingSide(OffHand)
        self.OffHand:Hide()
    end

    C_SwingTimer.EnableRangeCheck(MainHand, true)
    C_SwingTimer.EnableRangeCheck(OffHand, self.HasOffHand)
    C_SwingTimer.EnableRangeCheck(Ranged, true)

    self:UpdateCurrentRange(MainHand)
    self:UpdateCurrentRange(Ranged)

    if (self.HasOffHand) then
        self:UpdateCurrentRange(OffHand)
    end
end

function SwingBar:OnEvent(event, ...)
    if (event == "PLAYER_SWING") then
        local Duration, SwingType = ...

        self:StartSwing(SwingType, Duration)
    elseif (event == "PLAYER_SWING_RANGE_UPDATE") then
        local SwingType, IsInRange, ChecksRange = ...

        self:UpdateRange(SwingType, IsInRange, ChecksRange)
    elseif (event == "PLAYER_TARGET_CHANGED") then
        self:UpdateCurrentRange(MainHand)
        self:UpdateCurrentRange(Ranged)

        if (self.HasOffHand) then
            self:UpdateCurrentRange(OffHand)
        end
    elseif (event == "UNIT_ATTACK_SPEED") then
        local Unit = ...

        if (Unit == "player") then
            self:UpdateBar()
        end
    elseif (event == "PLAYER_EQUIPMENT_CHANGED") then
        self:UpdateBar()
    elseif (event == "PLAYER_ENTERING_WORLD") then
        self:UpdateBar()
    end
end

function SwingBar:RegisterEvents()
    self:RegisterEvent("PLAYER_SWING")
    self:RegisterEvent("PLAYER_SWING_RANGE_UPDATE")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UNIT_ATTACK_SPEED")
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end)
end

function SwingBar:Initialize()
    if (not DB.Global.DataBars.SwingBar) then
        return
    end

    self:Create()
    self:RegisterEvents()
    self:UpdateBar()
end