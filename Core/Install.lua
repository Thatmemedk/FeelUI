local UI, DB, Media, Language = select(2, ...):Call()

-- Register Modules
local Install = UI:RegisterModule("Install")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local Name = UI.MyName
local Realm = UI.MyRealm

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function Install:SetupUI()
    SetCVar("buffDurations", 1)
    SetCVar("countdownForCooldowns", 1)
    SetCVar("chatMouseScroll", 1)
    SetCVar("cameraDistanceMaxZoomFactor", 2.6)
    SetCVar("screenshotQuality", 10)
    SetCVar("showTutorials", 0)
    SetCVar("autoQuestWatch", 1)
    SetCVar("autoQuestProgress", 1)
    SetCVar("UberTooltips", 1)
    SetCVar("autoOpenLootHistory", 0)
    SetCVar("spamFilter", 0)
    SetCVar("chatStyle", "classic")
    SetCVar("whisperMode", "inline")
    SetCVar("alwaysShowActionBars", 1)
end

function Install:CloseOnMouseUp()
	Install:Toggle()
end

function Install:CreateInstall()	
	-- MAIN FRAME
	local Frame = CreateFrame("Frame", nil, _G.UIParent)
	Frame:Size(498, 168)
	Frame:SetFrameStrata("HIGH")
	Frame:Point("CENTER", _G.UIParent, 0, 0)
	Frame:CreateBackdrop()
	Frame:CreateShadow()
	Frame:SetAlpha(0)
	Frame:Hide()
	
	-- BG 
	Frame.BG = CreateFrame("Frame", nil, Frame)
	Frame.BG:SetFrameStrata(Frame:GetFrameStrata())
	Frame.BG:SetFrameLevel(Frame:GetFrameLevel() - 1)
	Frame.BG:Size(508, 208)
	Frame.BG:Point("CENTER", Frame, 0, 15)
	Frame.BG:CreateBackdrop()
	Frame.BG:CreateShadow()

	-- CREATE ANIMATIONS
	Frame.Fade = UI:CreateAnimationGroup(Frame)

	Frame.FadeIn = UI:CreateAnimation(Frame.Fade, "Fade")
	Frame.FadeIn:SetDuration(1)
	Frame.FadeIn:SetChange(1)
	Frame.FadeIn:SetEasing("In-SineEase")

	Frame.FadeOut = UI:CreateAnimation(Frame.Fade, "Fade")
	Frame.FadeOut:SetDuration(1)
	Frame.FadeOut:SetChange(0)
	Frame.FadeOut:SetEasing("Out-SineEase")
	Frame.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	-- TO BE ABLE TO PRESS "ESC"
	GameMenuFrame:HookScript("OnShow", function()
		if Install.Frame:IsShown() then
			Install:Toggle()
		end
	end)

	-- OVERLAY FRAME
	Frame.Overlay = CreateFrame("Frame", nil, Frame)
	Frame.Overlay:Size(Frame:GetWidth(), 26)
	Frame.Overlay:Point("TOP", Frame, 0, 28)
	Frame.Overlay:CreateBackdrop()
	Frame.Overlay:CreateShadow()
	
	-- OVERLAY TEXT
	Frame.OverlayText = Frame.Overlay:CreateFontString(nil, "OVERLAY", nil, 7)
	Frame.OverlayText:Point("CENTER", Frame.Overlay, 0, 0)
	Frame.OverlayText:SetFontTemplate("Default", 16)
	Frame.OverlayText:SetText("Installation")
	Frame.OverlayText:SetVertexColor(1, 0.82, 0)
	
	-- VERSION TEXT
	Frame.VersionText = Frame:CreateFontString(nil, "OVERLAY", nil, 7)
	Frame.VersionText:Point("TOP", Frame, 0, -12)
	Frame.VersionText:SetFontTemplate("Default", 22)
	Frame.VersionText:SetTextColor(1, 1, 1)
	Frame.VersionText:SetText("Welcome to " .. "|CFF00AAFF" .. UI.Title .. "|r" .. " |CFF4BEB2C" .. UI.Version .. "!")
	
	-- SETUP TEXT
	Frame.InstallText = Frame:CreateFontString(nil, "OVERLAY", nil, 7)
	Frame.InstallText:Point("BOTTOM", Frame.VersionText, 0, -28)
	Frame.InstallText:SetFontTemplate("Default")
	Frame.InstallText:SetTextColor(1, 1, 1)
	Frame.InstallText:SetText("This installation will change the chat settings and the default WoW settings.")
	
	-- COMPLETE TEXT
	Frame.CompleteText = Frame:CreateFontString(nil, "OVERLAY", nil, 7)
	Frame.CompleteText:Point("BOTTOM", Frame.InstallText, 0, -28)
	Frame.CompleteText:SetFontTemplate("Default")
	Frame.CompleteText:SetTextColor(1, 1, 1)
	Frame.CompleteText:SetText("Press 'Complete Installation' to complete the installation.")
	
	-- CLOSE BUTTON
	Frame.CloseButton = CreateFrame("Button", nil, Frame)
	Frame.CloseButton:Size(482, 26)
	Frame.CloseButton:Point("BOTTOM", Frame, 0, 6)
	Frame.CloseButton:HandleButton()
	Frame.CloseButton:SetScript("OnMouseUp", self.CloseOnMouseUp)
	
	Frame.CloseButtonText = Frame.CloseButton:CreateFontString(nil, "OVERLAY", nil, 7)
	Frame.CloseButtonText:Point("CENTER", Frame.CloseButton, 0, 1)
	Frame.CloseButtonText:SetFontTemplate("Default", 14)
	Frame.CloseButtonText:SetText("Close Installation")
	Frame.CloseButtonText:SetVertexColor(1, 0.82, 0)
	
	-- INSTALL BUTTON
	Frame.InstallButton = CreateFrame("Button", nil, Frame)
	Frame.InstallButton:Size(482, 26)
	Frame.InstallButton:Point("TOP", Frame.CloseButton, 0, 32)
	Frame.InstallButton:HandleButton()
	Frame.InstallButton:SetScript("OnClick", function()
		self:SetupUI()
		ReloadUI()
	end)

	-- INSTALL COMPLETE
	Frame.InstallButtonText = Frame.InstallButton:CreateFontString(nil, "OVERLAY", nil, 7)
	Frame.InstallButtonText:Point("CENTER", Frame.InstallButton, 0, 1)
	Frame.InstallButtonText:SetFontTemplate("Default", 14)
	Frame.InstallButtonText:SetText("Complete Installation")
	Frame.InstallButtonText:SetVertexColor(1, 0.82, 0)
	
	self.Frame = Frame
end

function Install:Toggle()
	if InCombatLockdown() then
		return
	end

	if self.Frame:IsShown() then
		self.Frame.FadeOut:Play()
	else
		self.Frame:Show()
		self.Frame.FadeIn:Play()
	end
end

function Install:PLAYER_REGEN_DISABLED()
	if self.Frame:IsShown() then
		self.Frame:SetAlpha(0)
		self.Frame:Hide()
		self.Frame.CombatClosed = true
	end
end

function Install:PLAYER_REGEN_ENABLED()
	if self.Frame.CombatClosed then
		self.Frame:Show()
		self.Frame:SetAlpha(1)
		self.Frame.CombatClosed = false
	end
end

function Install:OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then
		if not (FeelDB[Realm][Name].Install.Done) then
			Install:Toggle()
			
			FeelDB[Realm][Name].Install.Done = true
		end
	elseif (event == "PLAYER_REGEN_DISABLED") then
		self:PLAYER_REGEN_DISABLED()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		self:PLAYER_REGEN_ENABLED()
	end
end

function Install:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:SetScript("OnEvent", self.OnEvent)
end

function Install:Initialize()	
	self:CreateInstall()
	self:RegisterEvents()
end