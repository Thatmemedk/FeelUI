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

			if (Window.ScrollBox) then
				self:UpdateScrollBoxBars(Window.ScrollBox)

				hooksecurefunc(Window.ScrollBox, "Update", function(ScrollBox)
					DamageMeter:UpdateScrollBoxBars(ScrollBox)
				end)
			end

			if (Window.LocalPlayerEntry) then
				self:UpdateBarSkin(Window.LocalPlayerEntry)
			end

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

			if (Window.SourceWindow.ScrollBox) then
				self:UpdateScrollBoxBars(Window.SourceWindow.ScrollBox)

				hooksecurefunc(Window.SourceWindow.ScrollBox, "Update", function(ScrollBox)
					DamageMeter:UpdateScrollBoxBars(ScrollBox)
				end)
			end

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