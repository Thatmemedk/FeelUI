-- CREDITS: Spyro

local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CooldownManager = UI:RegisterModule("CooldownManager")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- Locals
local CooldownManagerFrames = { 
	_G.EssentialCooldownViewer, 
	_G.UtilityCooldownViewer, 
	_G.BuffIconCooldownViewer,
}

function CooldownManager:SkinIcons(Button)
	if not (Button or Button.CDMIsSkinned) then
		return
	end

	local Icon = Button.Icon or Button.icon or Button.Texture or Button.texture
	local Count = Button.Applications and Button.Applications.Applications
	local Cooldown = Button.Cooldown
	local Charges = Button.ChargeCount and Button.ChargeCount.Current

	if not (Icon) then
		return
	end

	select(3, Button:GetRegions()):Hide()

	Button:Size(36, 18)
	Button:CreateButtonPanel()
	Button:CreateButtonBackdrop()
	Button:CreateShadow()
	Button:SetShadowOverlay()

	local InvisFrame = CreateFrame("Frame", nil, Button)
	InvisFrame:SetFrameLevel(Button:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	if (Icon) then
		Icon:SetInside()
		UI:KeepAspectRatio(Button, Icon)
	end

	if (Cooldown) then
		Cooldown:SetInside()
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

function CooldownManager:RegisterEvents()
	EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
		for _, Frames in ipairs(CooldownManagerFrames) do
			for _, Button in pairs({ Frames:GetChildren() }) do
				self:SkinIcons(Button)
			end
		end
	end)
end

function CooldownManager:Initialize()
	self:RegisterEvents()
end