local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ObjectiveTracker = UI:RegisterModule("ObjectiveTracker")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local ObjectiveTrackerFrame = _G.ObjectiveTrackerFrame

-- Locals
local R, G, B = unpack(UI.GetClassColors)

-- Locals
local Headers = {
	_G.CampaignQuestObjectiveTracker.Header,
	_G.QuestObjectiveTracker.Header,
	_G.MonthlyActivitiesObjectiveTracker.Header,
	_G.BonusObjectiveTracker.Header,
	_G.WorldQuestObjectiveTracker.Header,
	_G.AdventureObjectiveTracker.Header,
	_G.ScenarioObjectiveTracker.Header,
	_G.AchievementObjectiveTracker.Header,
	_G.ProfessionsRecipeTracker.Header,
}

function ObjectiveTracker:Disable()
	for _, Frames in pairs({		
		_G.ObjectiveTrackerFrame.Header,
		_G.QuestObjectiveTracker.Header.Background,
		_G.CampaignQuestObjectiveTracker.Header.Background,
		_G.MonthlyActivitiesObjectiveTracker.Header.Background,
		_G.BonusObjectiveTracker.Header.Background,
		_G.WorldQuestObjectiveTracker.Header.Background,
		_G.AdventureObjectiveTracker.Header.Background,
		_G.ScenarioObjectiveTracker.Header.Background,
		_G.AchievementObjectiveTracker.Header.Background,
		_G.ProfessionsRecipeTracker.Header.Background,
	}) do
		if (Frames) then
			Frames:SetParent(UI.HiddenParent)
		end
	end
end

function ObjectiveTracker:Skin(Frame)
	local HeaderBar = CreateFrame("StatusBar", nil, Frame)
	HeaderBar:Size(232, 6)
	HeaderBar:Point("TOP", Frame, -16, -18)
	HeaderBar:SetFrameLevel(Frame:GetFrameLevel() - 1)
	HeaderBar:SetFrameStrata("BACKGROUND")
	HeaderBar:SetStatusBarTexture(Media.Global.Texture)
	HeaderBar:SetStatusBarColor(R, G, B)
	HeaderBar:SetTemplate()
	HeaderBar:CreateShadow()
	HeaderBar.FrameRaised:SetFrameLevel(Frame:GetFrameLevel() - 1)
end

function ObjectiveTracker:SkinHeaders()
	if (self.HeaderIsSkinned) then 
		return 
	end

	for _, Header in ipairs(Headers) do
		if (Header) then
			self:Skin(Header)
		end
	end

	self.HeaderIsSkinned = true
end

function ObjectiveTracker:SetPoint()
	local GetTop = ObjectiveTrackerFrame:GetTop() or 0
	local ScreenHeight = GetScreenHeight()
	local GapFromTop = ScreenHeight - GetTop
	local MaxHeight = ScreenHeight - GapFromTop
	local SetObjectiveFrameHeight = min(MaxHeight, 480)

	local ObjectiveFrameHolder = CreateFrame("Frame", nil, _G.UIParent)
	ObjectiveFrameHolder:Size(130, 22)
	ObjectiveFrameHolder:Point("TOPRIGHT", _G.UIParent, -82, -272)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:Point("TOP", ObjectiveFrameHolder)
	ObjectiveTrackerFrame:Height(SetObjectiveFrameHeight)

	hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_,_, Parent)
		if (Parent ~= ObjectiveFrameHolder) then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:Point("TOP", ObjectiveFrameHolder, 0, 0)
		end
	end)
end

function ObjectiveTracker:ToggleButtonOnEvent(event)
	if InCombatLockdown() then
		return UI:Print(ERR_NOT_IN_COMBAT)
	end

	if (event == "PLAYER_REGEN_DISABLED") then
		ObjectiveTrackerFrame:SetParent(UI.HiddenParent)
		ObjectiveTrackerFrame:SetAlpha(0)
	elseif (event == "PLAYER_REGEN_ENABLED") then
		ObjectiveTrackerFrame:SetParent(_G.UIParent)
		ObjectiveTrackerFrame:SetAlpha(1)
	end
end

function ObjectiveTracker:ToggleButtonOnClick()
	if InCombatLockdown() then
		return UI:Print(ERR_NOT_IN_COMBAT)
	end
	
	if (ObjectiveTrackerFrame:IsVisible()) then
		ObjectiveTrackerFrame:SetParent(UI.HiddenParent)
		ObjectiveTrackerFrame:SetAlpha(0)

		self.Texture:Point("CENTER", self, 2, 0)
		self.Texture:SetTexture(Media.Global.PowerArrowLeft)
	else
		ObjectiveTrackerFrame:SetParent(_G.UIParent)
		ObjectiveTrackerFrame:SetAlpha(1)

		self.Texture:Point("CENTER", self, -2, 0)
		self.Texture:SetTexture(Media.Global.PowerArrowRight)
	end
end

function ObjectiveTracker:CreateToggleButtons()
    local ToggleButton = CreateFrame("Button", "FeelUI_ObjectiveTrackerToggle", _G.UIParent)
    ToggleButton:SetFrameStrata("HIGH")
    ToggleButton:Size(16, 352)
    ToggleButton:Point("RIGHT", _G.UIParent, -6, 0)
    ToggleButton:HandleButton()
    ToggleButton:RegisterForClicks("AnyUp")
    ToggleButton:RegisterEvent("PLAYER_REGEN_ENABLED")
	ToggleButton:RegisterEvent("PLAYER_REGEN_DISABLED")
    ToggleButton:SetScript("OnClick", self.ToggleButtonOnClick)
    ToggleButton:SetScript("OnEvent", self.ToggleButtonOnEvent)
    ToggleButton:SetAlpha(0)

    ToggleButton.Texture = ToggleButton:CreateTexture(nil, "OVERLAY", nil, 7)
    ToggleButton.Texture:Size(14, 14)
    ToggleButton.Texture:Point("CENTER", ToggleButton, -2, 0)
    ToggleButton.Texture:SetVertexColor(R, G, B)
    ToggleButton.Texture:SetTexture(Media.Global.ArrowRight)

    ToggleButton:HookScript("OnEnter", function(self)
        UI:UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
    end)

    ToggleButton:HookScript("OnLeave", function(self)
        UI:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
    end)
end

function ObjectiveTracker:Initialize()
	if (not DB.Global.ObjectiveTracker.Enable) then
		return
	end

	self:SetPoint()
	self:Disable()
	self:CreateToggleButtons()
	self:SkinHeaders()
end