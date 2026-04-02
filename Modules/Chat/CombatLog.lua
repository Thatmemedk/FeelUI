local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local CH = UI:CallModule("Chat")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function CH:SkinCombatLog()
	if (self.IsSkinned) then
		return
	end
	
	local CombatLogButton = _G.CombatLogQuickButtonFrame_Custom	
	CombatLogButton:StripTexture()
	CombatLogButton:Size(404, 26)
	CombatLogButton:ClearAllPoints()
	CombatLogButton:Point("TOP", Panels.ChatPanelLeft, 0, -6)
	CombatLogButton:CreateBackdrop()
	CombatLogButton:CreateShadow()
	
	for i = 1, 2 do
		local CombatLogQuickButton = _G["CombatLogQuickButtonFrameButton"..i]
		local CombatLogText = CombatLogQuickButton:GetFontString()
		CombatLogText:SetFontTemplate("Default")
	end

	local CombatLogProgressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
	CombatLogProgressBar:SetInside(CombatLogButton)
	CombatLogProgressBar:SetStatusBarTexture(Media.Global.Texture)
	CombatLogProgressBar:SetStatusBarColor(R, G, B, 0.80)

	self.IsSkinned = true
end

function CH:StyleCombatLog()
	if (not IsAddOnLoaded("Blizzard_CombatLog")) then
		LoadAddOn("Blizzard_CombatLog")
	end

	self:SkinCombatLog()
end