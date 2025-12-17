local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CooldownManager = UI:RegisterModule("CooldownManager")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local CooldownViewerSettings = _G.CooldownViewerSettings
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

function CooldownManager:SkinIcons(Button)
	if (Button.CDMIsSkinned) then
		return
	end

	local Icon = Button.Icon or Button.icon or Button.Texture or Button.texture
	local Count = Button.Applications and Button.Applications.Applications
	local Charges = Button.ChargeCount and Button.ChargeCount.Current
	local Cooldown = Button.Cooldown
	local OutOfRange = Button.OutOfRange
	local CooldownFlash = Button.CooldownFlash
	local Border = Button.DebuffBorder
	local BorderTex = select(3, Button:GetRegions())
	--local PandemIcon = Button.PandemicIcon or Button.pandemicIcon or Button.Pandemic or Button.pandemic

	if (not Button and not Icon) then
		return
	end

	-- Button Size
	Button:Size(unpack(DB.Global.CooldownManager.ButtonSize))

	-- Keep Aspect Ratio
	UI:KeepAspectRatio(Button, Icon)

	local OverlayFrame = CreateFrame("Frame", nil, Button)
	OverlayFrame:SetInside(Button, 1, 1)
	OverlayFrame:SetTemplate()
	OverlayFrame:CreateShadow()
	OverlayFrame:SetShadowOverlay()

	local InvisFrame = CreateFrame("Frame", nil, Button)
	InvisFrame:SetFrameLevel(Button:GetFrameLevel() + 10)
	InvisFrame:SetInside()

    if (BorderTex) then
    	BorderTex:SetAlpha(0)
    end

   	if (Border) then
		Border:SetAlpha(0)

		--[[
		local Index = 10
		local AuraData = GetAuraDataByIndex("Target", Index, "HARMFUL")

	    if (AuraData) then
			local Color = C_UnitAuras.GetAuraDispelTypeColor("Target", AuraData.auraInstanceID, UI.DispelColorCurve)
			    
		    if (Color) then
		        OverlayFrame:SetColorTemplate(Color.r, Color.g, Color.b)
		    else
		   	    OverlayFrame:SetColorTemplate(unpack(DB.Global.General.BorderColor))
		    end
		end
		--]]
	end

	if (Icon) then
		Icon:ClearAllPoints()
		Icon:SetInside(OverlayFrame, 1, 1)
	end

	if (Cooldown) then
		Cooldown:ClearAllPoints()
		Cooldown:SetInside(OverlayFrame, 1, 1)
		Cooldown:SetReverse(true)
		Cooldown:SetSwipeTexture(Media.Global.Blank)
	end

	if (CooldownFlash) then
		CooldownFlash:ClearAllPoints()
		CooldownFlash:SetInside(OverlayFrame, 1, 1)
	end

	if (OutOfRange) then
		OutOfRange:ClearAllPoints()
		OutOfRange:SetInside(OverlayFrame, 1, 1)
	end
 
	if (Charges) then
    	Charges:ClearAllPoints()
    	Charges:Point("TOPRIGHT", Button, -1, -1)
    	Charges:SetFontTemplate("Default", 12)
	end

	if (Count) then
		Count:SetParent(InvisFrame)
    	Count:ClearAllPoints()
    	Count:Point("TOP", Button, 0, 6)
    	Count:SetFontTemplate("Default", 14)
    end

	Button.CDMIsSkinned = true
end

function CooldownManager:UpdateAcquireItemsFrame(Frames)
	CooldownManager:SkinIcons(Frames)
end

function CooldownManager:UpdateIcons(Elements)
	hooksecurefunc(Elements, "OnAcquireItemFrame", CooldownManager.UpdateAcquireItemsFrame)

	for Frames in Elements.itemFramePool:EnumerateActive() do
		CooldownManager:SkinIcons(Frames)
	end
end

function CooldownManager:Update()
	self:UpdateIcons(UtilityCooldownViewer)
	self:UpdateIcons(BuffIconCooldownViewer)
	self:UpdateIcons(EssentialCooldownViewer)
end

function CooldownManager:Initialize()
	if (not DB.Global.CooldownManager.Enable) then
		return
	end

	if not IsAddOnLoaded("Blizzard_CooldownViewer") then
		LoadAddOn("Blizzard_CooldownViewer")
	end

	self:Update()
end