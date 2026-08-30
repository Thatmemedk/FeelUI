local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local BR = UI:RegisterModule("BattleRess")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local C_Spell = _G.C_Spell
local C_Timer = _G.C_Timer
local C_ChallengeMode = _G.C_ChallengeMode
local IsInGroup = IsInGroup
local GetInstanceInfo = GetInstanceInfo
local IsEncounterInProgress = IsEncounterInProgress
local UnitClass = UnitClass
local GetTime = GetTime

-- Locals
BR.Ticker = nil
BR.RessID = 20484

-- Tables
BR.ClassIcons = {
	DRUID = 3636839,
	DEATHKNIGHT = 2576086,
	WARLOCK = 1305158,
	PALADIN = 4726195,
}

-- Tables
BR.State = {
	InEncounter = false,
	EncounterIsRaid = false,
	InChallenge = false,
}

function BR:IsInPartyInstance()
	local _, InstanceType = GetInstanceInfo()
	return InstanceType == "party" or InstanceType == "raid"
end

function BR:IsChallengeActive()
	if (not C_ChallengeMode) then
		return false
	end

	if (not C_ChallengeMode.IsChallengeModeActive) then
		return false
	end

	return C_ChallengeMode.IsChallengeModeActive() == true
end

function BR:RefreshChallengeState()
	self.State.InChallenge = self:IsChallengeActive()
end

function BR:RefreshEncounterState()
	self.State.InEncounter = IsEncounterInProgress() or false

	if (self.State.InEncounter) then
		local _, InstanceType = GetInstanceInfo()

		self.State.EncounterIsRaid = InstanceType == "raid"
	else
		self.State.EncounterIsRaid = false
	end
end

function BR:ShouldShow()
	if (not self.Frame) then
		return false
	end

	if (not self:IsInPartyInstance()) then
		return false
	end

	if (self.State.InChallenge) then
		return true
	end

	if (self.State.InEncounter and self.State.EncounterIsRaid) then
		return true
	end

	return false
end

function BR:UpdateVisibility()
	if (self:ShouldShow()) then
		if (not self.Frame:IsShown()) then
			self.Frame:Show()
		end

		self:StartTicker()
		self:UpdateCharges()
	else
		if (self.Frame:IsShown()) then
			self.Frame:Hide()
		end

		self:StopTicker()
	end
end

function BR:UpdateCharges()
	if (not self.Frame) then
		return
	end

	local Info = C_Spell.GetSpellCharges(self.RessID)

	if (not Info or not Info.maxCharges) then
		self.Count:SetText("")
		self.Cooldown:Clear()
		self.Cooldown:Hide()
		self.Icon:SetAlpha(0)

		return
	end

	local Charges = Info.currentCharges or 0
	local MaxCharges = Info.maxCharges or 0
	local Start = Info.cooldownStartTime
	local Duration = Info.cooldownDuration

	self.Count:SetText(Charges)
	self.Icon:SetAlpha(1)

	if (Charges < MaxCharges and Start and Duration and Duration > 0) then
		self.Cooldown:SetCooldown(Start, Duration)
		self.Cooldown:Show()
	else
		self.Cooldown:Clear()
		self.Cooldown:Hide()
	end
end

function BR:StartTicker()
	if (self.Ticker) then
		return
	end

	self.Ticker = C_Timer.NewTicker(0.5, function()
		if (BR.Frame and BR.Frame:IsShown()) then
			BR:UpdateCharges()
		end
	end)
end

function BR:StopTicker()
	if (self.Ticker) then
		self.Ticker:Cancel()
		self.Ticker = nil
	end
end

function BR:CreateBattleRess()
	local Frame = CreateFrame("Button", "FeelUI_BattleRess", _G.UIParent)
	Frame:Size(172, 22)
	Frame:Point("BOTTOMLEFT", _G.UIParent, 368, 252)

	-- Icon
	local Icon = CreateFrame("Frame", nil, Frame)
	Icon:Size(42, 22)
	Icon:Point("CENTER", Frame, 0, 0)
	Icon:SetTemplate()
	Icon:CreateShadow()
	Icon:SetShadowOverlay()
	Icon:SetAlpha(0)

	local Class = select(2, UnitClass("player"))

	-- Handle The Icon
	Icon:HandlePixelIcon(BR.ClassIcons[Class] or BR.ClassIcons.DRUID)

	-- Keep Aspect Ratio
	UI:KeepAspectRatio(Icon, Icon.Icon)

	-- Invis Frame
	local InvisFrame = CreateFrame("Frame", nil, Icon)
	InvisFrame:SetFrameLevel(Icon:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	-- Count
	local Count = InvisFrame:CreateFontString(nil, "OVERLAY")
	Count:Point("TOP", InvisFrame, 0, 8)
	Count:SetFontTemplate("Default", 16)
	Count:SetText("0")
	Count:SetTextColor(0.9, 0.9, 0.9)

	-- Cooldown
	local Cooldown = CreateFrame("Cooldown", nil, Icon, "CooldownFrameTemplate")

	Cooldown:SetInside()
	Cooldown:SetReverse(true)
	Cooldown:SetDrawBling(false)
	Cooldown:SetDrawEdge(false)
	Cooldown:SetHideCountdownNumbers(true)

	-- Cooldown text
	UI:UpdateCooldownText(Cooldown, Icon, 0, -8,true)

	-- Cache
	self.Frame = Frame
	self.Icon = Icon
	self.Count = Count
	self.Cooldown = Cooldown
end

function BR:OnEvent(Event)
	if (Event == "ENCOUNTER_START") then
		self.State.InEncounter = true

		local _, InstanceType = GetInstanceInfo()

		self.State.EncounterIsRaid = InstanceType == "raid"
	elseif (Event == "ENCOUNTER_END") then
		self.State.InEncounter = false
		self.State.EncounterIsRaid = false
	elseif (Event == "CHALLENGE_MODE_START") then
		self:RefreshChallengeState()
	elseif (Event == "CHALLENGE_MODE_COMPLETED") or (Event == "CHALLENGE_MODE_RESET") then
		self.State.InChallenge = false
	elseif (Event == "PLAYER_ENTERING_WORLD") then
		self:RefreshEncounterState()
		self:RefreshChallengeState()
	end

	self:UpdateVisibility()
end

function BR:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END")
	self:RegisterEvent("CHALLENGE_MODE_START")
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	self:RegisterEvent("CHALLENGE_MODE_RESET")
	self:SetScript("OnEvent", self.OnEvent)
end

function BR:Initialize()
	self:CreateBattleRess()
	self:RegisterEvents()
	self:RefreshEncounterState()
	self:RefreshChallengeState()
	self:UpdateVisibility()
	self:UpdateCharges()
end