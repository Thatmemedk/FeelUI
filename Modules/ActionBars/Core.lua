local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:RegisterModule("ActionBars")
local Panels = UI:CallModule("Panels")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function AB:DisableBlizzard()
    local UntaintedFrames = {
    	BagsBar = true,
        MicroButtonAndBagsBar = true,
        OverrideActionBar = true,
		MainMenuBar = true,
		MainActionBar = true,
		--MultiBarBottomLeft = true,
    	--MultiBarBottomRight = true,
    	--MultiBarRight = true,
    	--MultiBarLeft = true,
		--MultiBar5 = true,
		--MultiBar6 = true,
		--MultiBar7 = true,
    }

    for Name in next, UntaintedFrames do
        if (_G.UIPARENT_MANAGED_FRAME_POSITIONS) then
            _G.UIPARENT_MANAGED_FRAME_POSITIONS[Name] = nil
        end

        local Frames = _G[Name]

        if (Frames) then
        	Frames:SetParent(UI.HiddenParent)
        	Frames:UnregisterAllEvents()
        end
    end

	for _, Frames in pairs({
		_G.CharacterMicroButton,
		_G.SpellbookMicroButton,
		_G.ProfessionMicroButton,
		_G.PlayerSpellsMicroButton,
		_G.AchievementMicroButton,
		_G.QuestLogMicroButton,
		_G.GuildMicroButton,
		_G.LFDMicroButton,
		_G.EJMicroButton,
		_G.CollectionsMicroButton,
		_G.MainMenuMicroButton,
		_G.HelpMicroButton,
		_G.StoreMicroButton,
		_G.HousingMicroButton,
	}) do
		if (Frames) then
			Frames:SetParent(UI.HiddenParent)
			Frames:UnregisterAllEvents()
		end
	end

    local Glows = {
        _G.MultiBarRight.QuickKeybindGlow,
        _G.MultiBarLeft.QuickKeybindGlow,
        _G.MultiBarBottomRight.QuickKeybindGlow,
        _G.MultiBarBottomLeft.QuickKeybindGlow
    }

    for _, Frames in ipairs(Glows) do
        if (Frames) then
            Frames:SetParent(UI.HiddenParent)
        end
    end

    -- StatusTrackingBarManager
    _G.StatusTrackingBarManager:Kill()

    -- IconIntroTracker
    if (DB.Global.ActionBars.AddNewSpells) then
        _G.IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
        UnregisterStateDriver(_G.IconIntroTracker, "visibility")
    else
        _G.IconIntroTracker:UnregisterAllEvents()
        RegisterStateDriver(_G.IconIntroTracker, "visibility", "hide")
    end
    
    -- ActionBarController
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarController:RegisterEvent("SETTINGS_LOADED")
	_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	-- ActionBarButtonEventsFrame
	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	_G.ActionBarButtonEventsFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	_G.ActionBarButtonEventsFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
end

function AB:CreateActionBars()
	local ButtonWidth, ButtonHeight = unpack(DB.Global.ActionBars.ButtonSize)
	local StanceButtonWidth, StanceButtonHeight = unpack(DB.Global.ActionBars.StanceButtonSize)
	local PetButtonWidth, PetButtonHeight = unpack(DB.Global.ActionBars.PetButtonSize)
	local Spacing = DB.Global.ActionBars.ButtonSpacing
	local ButtonPerRow = DB.Global.ActionBars.ButtonPerRow

	-- AB 1
	local ActionBar1 = CreateFrame("Frame", "FeelUI_AB1", _G.UIParent, "SecureHandlerStateTemplate")
	ActionBar1:Size((ButtonWidth * ButtonPerRow) + Spacing * (ButtonPerRow - 1), ButtonHeight)
	ActionBar1:Point(unpack(DB.Global.ActionBars.Bar1Point))

	-- AB 2
	local ActionBar2 = CreateFrame("Frame", "FeelUI_AB2", _G.UIParent, "SecureHandlerStateTemplate")
	ActionBar2:Size((ButtonWidth * ButtonPerRow) + Spacing * (ButtonPerRow - 1), ButtonHeight)
	ActionBar2:Point("BOTTOM", ActionBar1, 0, 21)

	-- AB 3
	local ActionBar3 = CreateFrame("Frame", "FeelUI_AB3", _G.UIParent, "SecureHandlerStateTemplate")

	-- AB BACKDROP
	local BackdropAB = CreateFrame("Frame", nil, _G.UIParent)
	BackdropAB:SetFrameLevel(ActionBar1:GetFrameLevel() - 1)
	BackdropAB:CreateBackdrop()
	BackdropAB:CreateShadow()

	if (DB.Global.ActionBars.Bar3) then
		ActionBar3:Size((ButtonWidth * ButtonPerRow) + Spacing * (ButtonPerRow - 1), ButtonHeight)
		ActionBar3:Point("BOTTOM", ActionBar2, 0, 21)

		BackdropAB:Point("BOTTOMLEFT", ActionBar1, "BOTTOMLEFT", -2, -6)
	    BackdropAB:Point("TOPRIGHT", ActionBar3, "TOPRIGHT", 4, 3)
	else
		BackdropAB:Point("BOTTOMLEFT", ActionBar1, "BOTTOMLEFT", -2, -6)
	    BackdropAB:Point("TOPRIGHT", ActionBar2, "TOPRIGHT", 4, 3)
	end

	-- AB 4
	local ActionBar4 = CreateFrame("Frame", "FeelUI_AB4", _G.UIParent, "SecureHandlerStateTemplate")
	ActionBar4:SetFrameStrata("LOW")
	ActionBar4:Size((ButtonWidth) + (Spacing * 2), (ButtonHeight * ButtonPerRow) + (Spacing * (10)))
	ActionBar4:Point("LEFT", _G.UIParent, 8, 0)
	
	ActionBar4.Backdrop = CreateFrame("Frame", nil, ActionBar4)
	ActionBar4.Backdrop:SetFrameLevel(ActionBar4:GetFrameLevel() - 1)
	ActionBar4.Backdrop:SetOutside(ActionBar4, 2, 2)
	ActionBar4.Backdrop:CreateBackdrop()
	ActionBar4.Backdrop:CreateShadow()

	-- AB 5
	local ActionBar5 = CreateFrame("Frame", "FeelUI_AB5", _G.UIParent, "SecureHandlerStateTemplate")
	ActionBar5:Size((ButtonWidth) + (Spacing * 2), (ButtonHeight * 6) + (Spacing * (6)))
	ActionBar5:Point("BOTTOMLEFT", Panels.ChatPanelRight, -46, 2)
		
	ActionBar5.Backdrop = CreateFrame("Frame", nil, ActionBar5)
	ActionBar5.Backdrop:SetFrameLevel(ActionBar5:GetFrameLevel() - 1)	
	ActionBar5.Backdrop:SetOutside(ActionBar5, 2, 2)
	ActionBar5.Backdrop:CreateBackdrop()
	ActionBar5.Backdrop:CreateShadow()
	
	-- STANCE BAR
	local StanceBar = CreateFrame("Frame", "FeelUI_StanceAB", _G.UIParent, "SecureHandlerStateTemplate")
	StanceBar:Size(StanceButtonWidth + Spacing, StanceButtonHeight + Spacing)
	StanceBar:Point("TOPLEFT", _G.UIParent, 10, -12)

	StanceBar.Backdrop = CreateFrame("Frame", nil, StanceBar)
	StanceBar.Backdrop:SetFrameLevel(StanceBar:GetFrameLevel() - 1)
	StanceBar.Backdrop:CreateBackdrop()
	StanceBar.Backdrop:CreateShadow()
	StanceBar.Backdrop:Hide()
	
	-- PET BAR
	local PetBar = CreateFrame("Frame", "FeelUI_PetAB", _G.UIParent, "SecureHandlerStateTemplate")
	PetBar:Size((PetButtonWidth * 10) + (Spacing * (8) + 8), (PetButtonHeight) + (Spacing * 2))
	PetBar:Point("BOTTOM", ActionBar1, 0, -34)

	PetBar.Backdrop = CreateFrame("Frame", nil, PetBar)
	PetBar.Backdrop:SetFrameLevel(PetBar:GetFrameLevel() - 1)
	PetBar.Backdrop:SetOutside(PetBar, 2, 2)
	PetBar.Backdrop:CreateBackdrop()
	PetBar.Backdrop:CreateShadow()

	-- REGISTER
	self.ActionBar1 = ActionBar1
	self.ActionBar2 = ActionBar2
	self.ActionBar3 = ActionBar3
	self.ActionBar4 = ActionBar4
	self.ActionBar5 = ActionBar5
	self.StanceBar = StanceBar
	self.PetBar = PetBar
	self.BackdropAB = BackdropAB
end

function AB:Load(event)
	if (event == "SETTINGS_LOADED") then
		self:CreateActionBars()
		self:CreateBar1()
		self:CreateBar2()
		self:CreateBar3()
		self:CreateBar4()
		self:CreateBar5()
		self:CreateBarPet()
		self:CreateBarStance()

		if (_G.EditModeManagerFrame) then
			_G.EditModeManagerFrame:UnregisterAllEvents()
			_G.EditModeManagerFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
		end
	end

    local ActionBarAnimationEvents = {
        "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_SUCCEEDED",
        "UNIT_SPELLCAST_FAILED",
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_STOP",
        "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_CHANNEL_STOP",
        "UNIT_SPELLCAST_RETICLE_TARGET",
        "UNIT_SPELLCAST_RETICLE_CLEAR",
        "UNIT_SPELLCAST_EMPOWER_START",
        "UNIT_SPELLCAST_EMPOWER_STOP",
    }

    for _, Frames in ipairs(ActionBarAnimationEvents) do
        _G.ActionBarActionEventsFrame:UnregisterEvent(Frames)
    end
end

function AB:RegisterEvents()
	self:RegisterEvent("SETTINGS_LOADED")
	self:SetScript("OnEvent", AB.Load)
end

function AB:Initialize()
	if (not DB.Global.ActionBars.Enable) then
		return
	end

	self:DisableBlizzard()
	self:RegisterEvents()
	self:CreateVehicleExitButtons()
	self:CreateToggleButtons()
	self:CreateExtraActionButton()
	self:CreateGlow()
	self:CreateRange()
end