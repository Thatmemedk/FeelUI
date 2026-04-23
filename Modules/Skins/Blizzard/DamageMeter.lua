local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DamageMeter = UI:RegisterModule("DamageMeter")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local GetTime = GetTime
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn
local SetCVar = C_CVar.SetCVar

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

function DamageMeter:UpdateBarSkin(Frame)
    if (not Frame) then
    	return
    end

    if (not Frame.NewBar) then
        Frame.NewBar = CreateFrame("StatusBar", nil, Frame)
        Frame.NewBar:SetFrameLevel(Frame:GetFrameLevel() - 1)
        Frame.NewBar:SetInside()
        Frame.NewBar:CreateBackdrop()
        Frame.NewBar:CreateShadow()
    end

    if (Frame.StatusBar) then
        Frame.StatusBar.Name:SetFontTemplate("Default")
        Frame.StatusBar.Value:SetFontTemplate("Default")

        if (Frame.StatusBar.Background) then
            Frame.StatusBar.Background:SetParent(UI.HiddenParent)
        end

        if (Frame.StatusBar.BackgroundEdge) then
            Frame.StatusBar.BackgroundEdge:SetParent(UI.HiddenParent)
        end

        Frame.StatusBar:GetStatusBarTexture():SetTexture(Media.Global.Texture)
    end

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
end

function DamageMeter:UpdateScrollBoxBars(ScrollBox)
    if (not ScrollBox) then
    	return
    end

    ScrollBox:ForEachFrame(function(Frame)
        self:UpdateBarSkin(Frame)
    end)
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

			if (Window.MinimizeContainer.ScrollBox) then
				self:UpdateScrollBoxBars(Window.MinimizeContainer.ScrollBox)

				hooksecurefunc(Window.MinimizeContainer.ScrollBox, "Update", function(Frame)
					DamageMeter:UpdateScrollBoxBars(Frame)
				end)
			end

			if (Window.MinimizeContainer.LocalPlayerEntry) then
				self:UpdateBarSkin(Window.MinimizeContainer.LocalPlayerEntry)
			end

			if (Window.MinimizeContainer.Background) then
				Window.MinimizeContainer.Background:Hide()
			end

			if (Window.MinimizeContainer.ScrollBar.Track.Middle) then
				Window.MinimizeContainer.ScrollBar.Track.Middle:SetAlpha(0)
			end

			if (Window.MinimizeContainer.ScrollBar.Track) then
				Window.MinimizeContainer.ScrollBar.Track:SetAlpha(0)
			end

			if (Window.MinimizeContainer.ScrollBar.Back) then
				Window.MinimizeContainer.ScrollBar.Back:SetAlpha(0)
			end

			if (Window.MinimizeContainer.ScrollBar.Forward) then
				Window.MinimizeContainer.ScrollBar.Forward:SetAlpha(0)
			end

			-- SOURCE WINDOW
			Window.MinimizeContainer.SourceWindow:StripTexture()

			if (Window.MinimizeContainer.SourceWindow.ScrollBox) then
				self:UpdateScrollBoxBars(Window.MinimizeContainer.SourceWindow.ScrollBox)

				hooksecurefunc(Window.MinimizeContainer.SourceWindow.ScrollBox, "Update", function(Frame)
					DamageMeter:UpdateScrollBoxBars(Frame)
				end)
			end
			
			if (not Window.MinimizeContainer.SourceWindow.NewBackdrop) then
				Window.MinimizeContainer.SourceWindow.NewBackdrop = CreateFrame("Frame", nil, Window.MinimizeContainer.SourceWindow)
		        Window.MinimizeContainer.SourceWindow.NewBackdrop:SetFrameLevel(Window.MinimizeContainer.SourceWindow:GetFrameLevel() -1)
		        Window.MinimizeContainer.SourceWindow.NewBackdrop:Size(348, 148)
		        Window.MinimizeContainer.SourceWindow.NewBackdrop:Point("CENTER", Window.MinimizeContainer.SourceWindow, -11, 1)
		        Window.MinimizeContainer.SourceWindow.NewBackdrop:CreateBackdrop()
		        Window.MinimizeContainer.SourceWindow.NewBackdrop:CreateShadow()
		    end

			if (Window.MinimizeContainer.SourceWindow.Background) then
				Window.MinimizeContainer.SourceWindow.Background:Hide()
			end

			if (Window.MinimizeContainer.SourceWindow.ScrollBar.Track.Middle) then
				Window.MinimizeContainer.SourceWindow.ScrollBar.Track.Middle:SetAlpha(0)
			end

			if (Window.MinimizeContainer.SourceWindow.ScrollBar.Track) then
				Window.MinimizeContainer.SourceWindow.ScrollBar.Track:SetAlpha(0)
			end

			if (Window.MinimizeContainer.SourceWindow.ScrollBar.Back) then
				Window.MinimizeContainer.SourceWindow.ScrollBar.Back:SetAlpha(0)
			end

			if (Window.MinimizeContainer.SourceWindow.ScrollBar.Forward) then
				Window.MinimizeContainer.SourceWindow.ScrollBar.Forward:SetAlpha(0)
			end

			if (Window.MinimizeContainer.SourceWindow.ResizeButton) then
				Window.MinimizeContainer.SourceWindow.ResizeButton:Hide()
			end

			if (Window.MinimizeButton) then
				Window.MinimizeButton:Hide()
			end

			-- NAME
			Window.DamageMeterTypeDropdown.TypeName:SetParent(Window)
			Window.DamageMeterTypeDropdown.TypeName:ClearAllPoints()
			Window.DamageMeterTypeDropdown.TypeName:Point("TOPLEFT", Window, 18, -16)
			Window.DamageMeterTypeDropdown.TypeName:SetFontTemplate("Default")
			Window.DamageMeterTypeDropdown.TypeName:SetTextColor(1, 1, 1)

			-- SETTINGS BUTTONS
			Window.SettingsDropdown:ClearAllPoints()
			Window.SettingsDropdown:Point("TOPRIGHT", Window, -32, -4)

			Window.SessionDropdown:ClearAllPoints()
			Window.SessionDropdown:Point("LEFT", Window.SettingsDropdown, -32, 0)

			Window.DamageMeterTypeDropdown:ClearAllPoints()
			Window.DamageMeterTypeDropdown:Point("LEFT", Window.SessionDropdown, -32, 0)

			-- SESSION TIMER
			Window.SessionTimer:ClearAllPoints()
			Window.SessionTimer:Point("RIGHT", Window.DamageMeterTypeDropdown.TypeName, 52, 0)
			Window.SessionTimer:SetFontTemplate("Default")

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

function DamageMeter:SetCVarOnLogin()
	SetCVar("damageMeterEnabled", "1")
end

function DamageMeter:Initialize()
    if (not DB.Global.Theme.Enable) then 
        return
    end

    if (not IsAddOnLoaded("Blizzard_DamageMeters")) then
        LoadAddOn("Blizzard_DamageMeters")
    end

    self:SetCVarOnLogin()
   	self:Skin()
end