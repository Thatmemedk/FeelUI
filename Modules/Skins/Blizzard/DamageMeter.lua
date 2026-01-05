local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DamageMeter = UI:RegisterModule("DamageMeter")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function DamageMeter:Skin()
	if (self.IsSkinned) then
		return
	end

	for i = 1, 3 do
		local DamageMeters = _G["DamageMeterSessionWindow"..i]

		if (DamageMeters) then
			DamageMeters:StripTexture()
			DamageMeters.DamageMeterTypeDropdown.TypeName:SetFontTemplate("Default", 14)
			DamageMeters.DamageMeterTypeDropdown.TypeName:SetTextColor(1, 1, 1)
		end
	end
		
	self.IsSkinned = true
end

function DamageMeter:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end

	self:Skin()
end