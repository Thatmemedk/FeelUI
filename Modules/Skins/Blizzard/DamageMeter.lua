local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DamageMeter = UI:RegisterModule("DamageMeter")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GetTime = GetTime
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn
local SetCVar = C_CVar.SetCVar

-- Locals
DamageMeter.Time = nil
DamageMeter.LastUpdate = nil
DamageMeter.IsActive = false
DamageMeter.OnlyEncounters = false

function DamageMeter:CreateCombatTimers()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(26, 26)
    Frame:Point("RIGHT", DamageMeterSessionWindow1.DamageMeterTypeDropdown.TypeName, 38, 0)
    Frame:SetAlpha(0)

    -- UPDATE
    Frame:SetScript("OnUpdate", function(_, Elapsed)
        if (self.IsActive) then
            self:CombatTimerOnUpdate(Elapsed)
        end
    end)

    -- TEXT
    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetFontTemplate("Default", 12)

    -- CACHE
    self.Frame = Frame
    self.Text = Text
end

function DamageMeter:FormattedTime(Value)
    local Minutes = math.floor(Value / 60)
    local Seconds = math.floor(Value % 60)
    return string.format("(%02d:%02d)", Minutes, Seconds)
end

function DamageMeter:CombatTimerOnUpdate()
    local Elapsed = math.floor(GetTime() - self.Time)

    if (Elapsed ~= self.LastUpdate) then
        self.LastUpdate = Elapsed
        self.Text:SetText(self:FormattedTime(Elapsed))
    end
end

function DamageMeter:OnEnter(Window)
    if (not Window.OptionsButtons) then 
    	return 
    end

    for _, Button in ipairs(Window.OptionsButtons) do
        UI:UIFrameFadeIn(Button, 0.25, Button:GetAlpha(), 1)
    end
end

function DamageMeter:OnLeave(Window)
    if (not Window.OptionsButtons) then 
    	return 
    end

    for _, Button in ipairs(Window.OptionsButtons) do
        UI:UIFrameFadeOut(Button, 0.8, Button:GetAlpha(), 0)
    end
end

function DamageMeter:SkinButtons(self, Size, Texture)
	if (not self or self.WindowButtonIsSkinned) then 
		return 
	end
	
	self:SetAlpha(0)
	self:Size(Size, Size)
	self:StripTexture()
	self:ClearFrameRegions()

	if (not self.NewTexture) then 
		self.NewTexture = self:CreateTexture(nil, "OVERLAY", nil, 7)
	    self.NewTexture:SetInside()
	    self.NewTexture:SetTexture(Texture)
	    self.NewTexture:SetVertexColor(0.8, 0.8, 0.8, 1)
	end

	if (self.Icon) then
		self.Icon:Hide()
	end

	if (self.Arrow) then
		self.Arrow:Hide()
	end

	if (self.SessionName) then
		self.SessionName:Hide()
	end

	self.WindowButtonIsSkinned = true
end

function DamageMeter:Skin()
	if (self.IsSkinned) then
		return
	end

	for i = 1, 3 do
		local Window = _G["DamageMeterSessionWindow"..i]

		if (Window) then
			-- SESSION WINDOW
			Window:StripTexture()

			if (Window.Background) then
				Window.Background:Hide()
			end

			if (Window.ScrollBar.Track.Middle) then
				Window.ScrollBar.Track.Middle:SetAlpha(0)
			end

			if (Window.ScrollBar.Track) then
				Window.ScrollBar.Track:SetAlpha(0)
			end

			if (Window.ScrollBar.Back) then
				Window.ScrollBar.Back:SetAlpha(0)
			end

			if (Window.ScrollBar.Forward) then
				Window.ScrollBar.Forward:SetAlpha(0)
			end

			-- SOURCE WINDOW
			Window.SourceWindow:StripTexture()

			if (not Window.SourceWindow.NewBackdrop) then
				Window.SourceWindow.NewBackdrop = CreateFrame("Frame", nil, Window.SourceWindow)
		        Window.SourceWindow.NewBackdrop:SetFrameLevel(Window.SourceWindow:GetFrameLevel() -1)
		        Window.SourceWindow.NewBackdrop:Size(348, 148)
		        Window.SourceWindow.NewBackdrop:Point("CENTER", Window.SourceWindow, -11, 1)
		        Window.SourceWindow.NewBackdrop:CreateBackdrop()
		        Window.SourceWindow.NewBackdrop:CreateShadow()
		    end

			if (Window.SourceWindow.Background) then
				Window.SourceWindow.Background:Hide()
			end

			if (Window.SourceWindow.ScrollBar.Track.Middle) then
				Window.SourceWindow.ScrollBar.Track.Middle:SetAlpha(0)
			end

			if (Window.SourceWindow.ScrollBar.Track) then
				Window.SourceWindow.ScrollBar.Track:SetAlpha(0)
			end

			if (Window.SourceWindow.ScrollBar.Back) then
				Window.SourceWindow.ScrollBar.Back:SetAlpha(0)
			end

			if (Window.SourceWindow.ScrollBar.Forward) then
				Window.SourceWindow.ScrollBar.Forward:SetAlpha(0)
			end

			if (Window.SourceWindow.ResizeButton) then
				Window.SourceWindow.ResizeButton:Hide()
			end

			-- NAME
			Window.DamageMeterTypeDropdown.TypeName:SetParent(Window)
			Window.DamageMeterTypeDropdown.TypeName:ClearAllPoints()
			Window.DamageMeterTypeDropdown.TypeName:Point("TOPLEFT", Window, 18, -16)
			Window.DamageMeterTypeDropdown.TypeName:SetFontTemplate("Default")
			Window.DamageMeterTypeDropdown.TypeName:SetTextColor(1, 1, 1)

			-- SETTINGS BUTTONS
			Window.SettingsDropdown:ClearAllPoints()
			Window.SettingsDropdown:Point("TOPRIGHT", Window, 18, -4)

			Window.SessionDropdown:ClearAllPoints()
			Window.SessionDropdown:Point("LEFT", Window.SettingsDropdown, -32, 0)

			Window.DamageMeterTypeDropdown:ClearAllPoints()
			Window.DamageMeterTypeDropdown:Point("LEFT", Window.SessionDropdown, -32, 0)

			-- SKIN BUTTONS
			self:SkinButtons(Window.SettingsDropdown, 26, Media.Global.Cogwheel)
			self:SkinButtons(Window.SessionDropdown, 26, Media.Global.CurrentList)
			self:SkinButtons(Window.DamageMeterTypeDropdown, 26, Media.Global.ActionList)

			-- BUTTONS
			Window.OptionsButtons = {
				Window.SettingsDropdown,
				Window.SessionDropdown,
				Window.DamageMeterTypeDropdown,
			}

			-- FADE
			for _, Button in ipairs(Window.OptionsButtons) do
			    Button:HookScript("OnEnter", function()
			        DamageMeter:OnEnter(Window)
			    end)

			    Button:HookScript("OnLeave", function()
			        DamageMeter:OnLeave(Window)
			    end)
			end

			Window:SetScript("OnEnter", function()
			    DamageMeter:OnEnter(Window)
			end)

			Window:SetScript("OnLeave", function()
			    DamageMeter:OnLeave(Window)
			end)
		end
	end
		
	self.IsSkinned = true
end

function DamageMeter:UpdateBarValue(Frame)
    if (not Frame or not Frame.NewBar) then
        return
    end

    local Value = Frame.value
    local Max = Frame.maxValue

    Frame.NewBar:SetMinMaxValues(0, Max)
    Frame.NewBar:SetValue(Value, UI.SmoothBars)
end

function DamageMeter:UpdateBarColors(Frame, ElementData)
    local ClassFile = ElementData.classFilename

    if (ClassFile) then
        local Color = UI.Colors.Class[ClassFile]

        if (Color) then
            Frame.NewBar:SetStatusBarColor(Color.r, Color.g, Color.b, 1)
        end
    end
end

function DamageMeter:UpdateBarSkin(Frame)
    if (not Frame or Frame.IsSkinned) then 
    	return 
    end

    -- New Bar
    if (not Frame.NewBar) then
        Frame.NewBar = CreateFrame("StatusBar", nil, Frame)
        Frame.NewBar:SetFrameLevel(Frame:GetFrameLevel() - 1)
        Frame.NewBar:SetInside()
        Frame.NewBar:SetStatusBarTexture(Media.Global.Texture)
        Frame.NewBar:CreateBackdrop()
        Frame.NewBar:CreateShadow()
    end

    -- StatusBar
    local StatusBar = Frame.GetStatusBar and Frame:GetStatusBar()

    if (StatusBar) then
    	-- Fonts
        StatusBar.Name:SetFontTemplate("Default")
        StatusBar.Value:SetFontTemplate("Default")

        -- Background
        StatusBar.Background:SetParent(UI.HiddenParent)
        StatusBar.BackgroundEdge:SetParent(UI.HiddenParent)

        local Texture = StatusBar:GetStatusBarTexture()

        if (Texture) then
            Texture:SetAtlas(nil)
        end
    end

    -- Icon
    if (Frame.Icon and Frame.Icon.Icon) then
    	Frame.Icon.Icon:SetInside()
        Frame.Icon.Icon:SetTexCoord(unpack(UI.TexCoords))

        if (not Frame.IconOverlay) then
	        Frame.IconOverlay = CreateFrame("Frame", nil, Frame)
	        Frame.IconOverlay:SetFrameLevel(Frame:GetFrameLevel() + 1)
	        Frame.IconOverlay:SetInside(Frame.Icon.Icon, 0, 0)
	        Frame.IconOverlay:SetTemplate()
	        Frame.IconOverlay:CreateShadow()
	        Frame.IconOverlay:SetShadowOverlay()
    	end
    end

    Frame.IsSkinned = true
end

function DamageMeter:RefreshAllWindows()
    for i = 1, 3 do
        local Window = _G["DamageMeterSessionWindow"..i]

        if (Window and Window.Refresh) then
            Window:Refresh()
        end
    end
end

function DamageMeter:OnEvent(event)
    if (event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD") then
        C_Timer.After(1, function()
            self:RefreshAllWindows()
        end)
    end

	if (self.OnlyEncounters) then
		if (event == "ENCOUNTER_START") then
		    self.IsActive = true
		    self.Time = GetTime()
		    self.LastUpdate = -1

			UI:UIFrameFadeIn(self.Frame, 0.5, self.Frame:GetAlpha(), 1)
		elseif (event == "ENCOUNTER_END") then
		    self.IsActive = false
		    self.Time = nil
		    self.LastUpdate = nil

		    UI:UIFrameFadeOut(self.Frame, 0.5, self.Frame:GetAlpha(), 0)
		end
	else
	    if (event == "PLAYER_REGEN_DISABLED") then
	        self.IsActive = true
	        self.Time = GetTime()
	        self.LastUpdate = -1

	    	UI:UIFrameFadeIn(self.Frame, 0.5, self.Frame:GetAlpha(), 1)
	    elseif (event == "PLAYER_REGEN_ENABLED") then
	        self.IsActive = false
	        self.Time = nil
	        self.LastUpdate = nil

	        UI:UIFrameFadeOut(self.Frame, 0.5, self.Frame:GetAlpha(), 0)
	    end
	end
end

function DamageMeter:RegisterEvents()
   	self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:SetScript("OnEvent", function(_, event)
        self:OnEvent(event)
    end)
end

function DamageMeter:SetCVarOnLogin()
	SetCVar("damageMeterEnabled", "1")
end

function DamageMeter:AutoReset()
	local IsInInstance = IsInInstance()

    if (IsInInstance) then
        _G.C_DamageMeter.ResetAllCombatSessions()
    end
end

function DamageMeter:Initialize()
    if (not DB.Global.Theme.Enable) then 
        return
    end

    if (not IsAddOnLoaded("Blizzard_DamageMeters")) then
        LoadAddOn("Blizzard_DamageMeters")
    end

	hooksecurefunc(_G.DamageMeterEntryMixin, "Init", function(Frame, ElementData)
	    self:UpdateBarSkin(Frame)
	    self:UpdateBarColors(Frame, ElementData)
	    self:UpdateBarValue(Frame)
	end)

	hooksecurefunc(_G.DamageMeterSpellEntryMixin, "Init", function(Frame, ElementData)
	    self:UpdateBarSkin(Frame)
	    self:UpdateBarColors(Frame, ElementData)
	    self:UpdateBarValue(Frame)
	end)

    self:AutoReset()
    self:SetCVarOnLogin()
    self:CreateCombatTimers()
    self:RegisterEvents()
    self:Skin()
end