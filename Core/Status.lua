local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Status = UI:RegisterModule("Status")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetNumAddOns = C_AddOns.GetNumAddOns
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetCVarBool = C_CVar.GetCVarBool
local GetLocale = GetLocale
local GetNumAddOns = GetNumAddOns
local GetRealZoneText = GetRealZoneText
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo

-- Locals
local R, G, B = unpack(UI.GetClassColors)

-- Class Tables
local ClassNames = {
	HUNTER = "Hunter",
	WARLOCK = "Warlock",
	PRIEST = "Priest",
	PALADIN = "Paladin",
	MAGE = "Mage",
	ROGUE = "Rogue",
	DRUID = "Druid",
	SHAMAN = "Shaman",
	WARRIOR = "Warrior",
	DEATHKNIGHT = "Death Knight",
	MONK = "Monk",
	DEMONHUNTER = "Demon Hunter",
	EVOKER = "Evoker",
}

-- Class Tables
local SpecNames = {
	-- Hunter
	[253] = "Beast Mastery",
	[254] = "Marksmanship",
	[255] = "Survival",
	-- Warlock
	[265] = "Affliction",
	[266] = "Demonology",
	[267] = "Destruction",
	-- Priest
	[256] = "Discipline",
	[257] = "Holy",
	[258] = "Shadow",
	-- Paladin
	[65] = "Holy",
	[66] = "Protection",
	[70] = "Retribution",
	-- Mage
	[62] = "Arcane",
	[63] = "Fire",
	[64] = "Frost",
	-- Rogue
	[259] = "Assassination",
	[260] = "Combat",
	[261] = "Subtlety",
	-- Druid
	[102] = "Balance",
	[103] = "Feral",
	[104] = "Guardian",
	[105] = "Restoration",
	-- Shaman
	[262] = "Elemental",
	[263] = "Enhancement",
	[264] = "Restoration",
	-- Warrior
	[71] = "Arms",
	[72] = "Fury",
	[73] = "Protection",
	-- Death Knight
	[250] = "Blood",
	[251] = "Frost",
	[252] = "Unholy",
	-- Monk
	[268] = "Brewmaster",
	[269] = "Windwalker",
	[270] = "Mistweaver",
	-- Demon Hunter
	[577] = "Havoc",
	[581] = "Vengeance",
	[1480] = "Devourer",
	-- Evoker
	[1467] = "Devastation",
	[1468] = "Preservation",
	[1473] = "Augmentation",
}

function Status:GetLocTextColor()
	local GetZonePVPInfo = GetZonePVPInfo()

	if (GetZonePVPInfo == "friendly") then
		return 0.1, 1.0, 0.1
	elseif (GetZonePVPInfo == "hostile") then
		return 1.0, 0.1, 0.1
	elseif (GetZonePVPInfo == "contested") then
		return 1.0, 0.7, 0.0
	elseif (GetZonePVPInfo == "sanctuary") then
		return 0.41, 0.8, 0.94
	elseif (GetZonePVPInfo == "arena") then
		return 1.0, 0.1, 0.1
	else
		return 1, 0.82, 0
	end
end

function Status:GetSpecialization()
	return SpecNames[GetSpecializationInfo(GetSpecialization())] or _G.UNKNOWN
end

function Status:UpdateStatusFrameSpec()
	self.Frame.Spec:SetFormattedText("|CFFFFFFFFSpec:|r %s", Status:GetSpecialization())
end

function Status:UpdateStatusFrameZone()
    local ZoneText = GetRealZoneText() or _G.UNKNOWN
    local r, g, b = self:GetLocTextColor()

    self.Frame.Zone:SetFormattedText("Current Zone: |cff%02x%02x%02x%s", r * 255, g * 255, b * 255, ZoneText)
end

function Status:GetClient()
	if IsWindowsClient() then
		return "Windows"
	elseif IsMacClient() then
		return "Mac"
	elseif IsLinuxClient() then
		return "Linux"
	else
		return "Unknown"
	end
end

function Status:GetDisplay()
	return GetCVarBool("gxMaximize") and "Windowed" or "Fullscreen"
end

function Status:AddonsCheck()
	for i = 1, GetNumAddOns() do
		local Name = GetAddOnInfo(i)
		
		if (Name ~= "FeelUI" and Name ~= "FeelUI_Options" and Status:IsAddOnEnabled(Name)) then
			return "|CFFFF3333No"
		end
	end
	
	return "|CFF4BEB2CYes"
end

function Status:GetNumLoadedAddOns()
	local NumLoaded = 0
	
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			NumLoaded = NumLoaded + 1
		end
	end
	
	return NumLoaded
end

function Status:IsAddOnEnabled(AddOn)
	return GetAddOnEnableState(UI.MyName, AddOn) == 2
end

function Status:CreateCategories(Parent, Name, FontSize, ShadowOffsetX, ShadowOffsetY, InsertText, R, G, B, A, Anchor, OffsetX, OffsetY)
	local Text = Parent:CreateFontString(nil, "OVERLAY")
	Text:Point("TOP", Anchor, OffsetX or 0, OffsetY or 0)
	Text:SetFontTemplate("Default", FontSize, ShadowOffsetX or 1, ShadowOffsetY or 1)
	Text:SetText(InsertText)
	Text:SetTextColor(R, G, B, A)

	if (Name) then
		Parent[Name] = Text
	end

	return Text
end

function Status:CreateDividerLeft(Parent, Name, R, G, B, Anchor, OffsetX, OffsetY)
	local Divider = CreateFrame("StatusBar", nil, Parent)
	Divider:Size(292/2, 2)
	Divider:Point("LEFT", Anchor, OffsetX or 0, OffsetY or 0)
	Divider:SetStatusBarTexture(Media.Global.Highlight)
	Divider:SetStatusBarColor(R, G, B, 0.7)
	
	if (Name) then
		Parent[Name] = Divider
	end

	return Divider
end

function Status:CreateDividerRight(Parent, Name, R, G, B, Anchor, OffsetX, OffsetY)
	local Divider = CreateFrame("StatusBar", nil, Parent)
	Divider:Size(292/2, 2)
	Divider:Point("RIGHT", Anchor, OffsetX or 0, OffsetY or 0)
	Divider:SetStatusBarTexture(Media.Global.Highlight)
	Divider:SetStatusBarColor(R, G, B, 0.7)
	
	if (Name) then
		Parent[Name] = Divider
	end

	return Divider
end

function Status:CreateStatus()	
	-- MAIN FRAME
	local Frame = CreateFrame("Frame", nil, _G.UIParent)
	Frame:Raise()
	Frame:Size(342, 432)
	Frame:Point("CENTER",_G.UIParent, 0, 112)
	Frame:CreateBackdrop()
	Frame:CreateShadow()
	Frame:SetAlpha(0)
	Frame:Hide()

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
	
	_G.GameMenuFrame:HookScript("OnShow", function()
		if Status.Frame:IsShown() then
			Status:Toggle()
		end
	end)
	
	-- INVIS FRAME
	local InvisFrame = CreateFrame("Frame", nil, Frame)
	InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
	InvisFrame:SetInside()
	
	-- LOGO
	local Logo = InvisFrame:CreateTexture(nil, "OVERLAY")
	Logo:Size(192, 192)
	Logo:Point("TOP", Frame, 0, 98)
	Logo:SetTexture(Media.Global.Logo)

	-- TEXTS
	self:CreateCategories(InvisFrame, "AddonInfoText", 20, 1, 1, "AddOn Info", 1, 0.82, 0, 1, Frame, 0, -22)
	self:CreateCategories(InvisFrame, "WoWInfoText", 20, 1, 1, "WoW Info", 1, 0.82, 0, 1, Frame, 0, -150)
	self:CreateCategories(InvisFrame, "CharacterInfoText", 20, 1, 1, "Character Info", 1, 0.82, 0, 1, Frame, 0, -280)
	
	-- DIVIDERS
	self:CreateDividerLeft(Frame, "AddonInfoDividerLeft", 0, 0.66, 1, InvisFrame.AddonInfoText, 72, -2)
	self:CreateDividerRight(Frame, "AddonInfoDividerRight", 0, 0.66, 1, InvisFrame.AddonInfoText, -72, -2)
	self:CreateDividerLeft(Frame, "WoWInfoDividerLeft", 0, 0.66, 1, InvisFrame.WoWInfoText, 68, -2)
	self:CreateDividerRight(Frame, "WoWInfoDividerRight", 0, 0.66, 1, InvisFrame.WoWInfoText, -68, -2)
	self:CreateDividerLeft(Frame, "CharacterInfoDividerLeft", 0, 0.66, 1, InvisFrame.CharacterInfoText, 88, -2)
	self:CreateDividerRight(Frame, "CharacterInfoDividerRight", 0, 0.66, 1, InvisFrame.CharacterInfoText, -88, -2)
	
	-- ADDON INFO
	self:CreateCategories(Frame, "TotalAddOns", 16, 1, 1, "Total AddOns: |CFF4BEB2C" .. GetNumAddOns(), 1, 1, 1, 1, InvisFrame.AddonInfoText, 0, -26)
	self:CreateCategories(Frame, "LoadedAddOns", 16, 1, 1, "Loaded AddOns: |CFF4BEB2C" .. self:GetNumLoadedAddOns(), 1, 1, 1, 1, Frame.TotalAddOns, 0, -20)
	self:CreateCategories(Frame, "OtherAddOnsEnabled", 16, 1, 1, "|CFF00AAFFFeelUI|r Only Loaded: " .. self.AddonsCheck(), 1, 1, 1, 1, Frame.LoadedAddOns, 0, -20)
	self:CreateCategories(Frame, "Version", 16, 1, 1, "|CFF00AAFFFeelUI|r Version: |CFF4BEB2C".. UI.Version, 1, 1, 1, 1, Frame.OtherAddOnsEnabled, 0, -20)
	self:CreateCategories(Frame, "UIScale", 16, 1, 1, "UI Scale: |CFF4BEB2C" .. DB.Global.General.UIScaleMax, 1, 1, 1, 1, Frame.Version, 0, -20)
	
	-- WOW INFO
	self:CreateCategories(Frame, "WoWPatch", 16, 1, 1, "WoW Patch: |CFF4BEB2C" .. UI.WoWPatch .. " (Build: " .. UI.WoWBuild .. ")", 1, 1, 1, 1, InvisFrame.WoWInfoText, 0, -26)
	self:CreateCategories(Frame, "Language", 16, 1, 1, "Language: |CFF4BEB2C" .. GetLocale(), 1, 1, 1, 1, Frame.WoWPatch, 0, -20)
	self:CreateCategories(Frame, "DisplayMode", 16, 1, 1, "Display Mode: |CFF4BEB2C" .. self:GetDisplay(), 1, 1, 1, 1, Frame.Language, 0, -20)
	self:CreateCategories(Frame, "Resolution", 16, 1, 1, "Resolution: |CFF4BEB2C" .. UI.ScreenResolution, 1, 1, 1, 1, Frame.DisplayMode, 0, -20)
	self:CreateCategories(Frame, "OS", 16, 1, 1, "Operating System: |CFF4BEB2C" .. self:GetClient(), 1, 1, 1, 1, Frame.Resolution, 0, -20)
	
	-- CHARACTER INFO
	self:CreateCategories(Frame, "Faction", 16, 1, 1, "Faction: |CFF4BEB2C" .. UI.MyFaction, 1, 1, 1, 1, InvisFrame.CharacterInfoText, 0, -26)	
	self:CreateCategories(Frame, "Race", 16, 1, 1, "Race: |CFF4BEB2C" .. UI.MyRace, 1, 1, 1, 1, Frame.Faction, 0, -20)
	self:CreateCategories(Frame, "Class", 16, 1, 1, "|CFFFFFFFFClass:|r " .. ClassNames[UI.MyClass], R, G, B, 1, Frame.Race, 0, -20)
	self:CreateCategories(Frame, "Spec", 16, 1, 1, nil, R, G, B, 1, Frame.Class, 0, -20)
	self:CreateCategories(Frame, "Level", 16, 1, 1, "|CFFFFFFFFLevel:|r ".. UI.MyLevel, 1, 0.82, 0, 1, Frame.Spec, 0, -20)
	self:CreateCategories(Frame, "Zone", 16, 1, 1, nil, 1, 1, 1, 1, Frame.Level, 0, -20)
	
	self.Frame = Frame
	self.InvisFrame = InvisFrame
end

function Status:Toggle()
	if InCombatLockdown() then
		UI:Print("You can't access |CFF00AAFFFeelUI|r_Status while in combat.")
		return
	end

	if self.Frame:IsShown() then
		self.Frame.FadeOut:Play()
	else
		self.Frame:Show()
		self.Frame.FadeIn:Play()
	end
end

function Status:PLAYER_REGEN_DISABLED()
	if self.Frame:IsShown() then
		self.Frame:SetAlpha(0)
		self.Frame:Hide()
		self.Frame.CombatClosed = true
	end
end

function Status:PLAYER_REGEN_ENABLED()
	if self.Frame.CombatClosed then
		self.Frame:Show()
		self.Frame:SetAlpha(1)
		self.Frame.CombatClosed = false
	end
end

function Status:OnEvent(event)
	self:UpdateStatusFrameZone()
	self:UpdateStatusFrameSpec()

	if (event == "PLAYER_REGEN_DISABLED") then
		self:PLAYER_REGEN_DISABLED()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		self:PLAYER_REGEN_ENABLED()
	end
end

function Status:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)
end

function Status:Initialize()	
	self:CreateStatus()
	self:RegisterEvents()
end