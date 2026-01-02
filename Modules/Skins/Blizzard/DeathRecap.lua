local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DeathRecap = UI:RegisterModule("DeathRecap")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

function DeathRecap:Skin()
	if (self.IsSkinned) then
		return
	end

	local DeathRecapFrame = _G.DeathRecapFrame
	DeathRecapFrame:StripTexture()
	DeathRecapFrame:CreateBackdrop()
	DeathRecapFrame:CreateShadow()
	DeathRecapFrame.CloseButton:HandleButton()
	DeathRecapFrame.CloseXButton:HandleCloseButton()

	for i = 1, 5 do
		local DeathRecapFrameSpellInfo = DeathRecapFrame["Recap"..i].SpellInfo
		local Tombstone = DeathRecapFrame["Recap1"].tombstone
		local SmallText = DeathRecapFrame["Recap"..i].DamageInfo.Amount
		local BigText = DeathRecapFrame["Recap"..i].DamageInfo.AmountLarge
	
		DeathRecapFrameSpellInfo.Name:SetFontTemplate("Default")
		DeathRecapFrameSpellInfo.Caster:SetFontTemplate("Default")
		SmallText:SetFontTemplate("Default")
		SmallText:SetTextColor(1, 1, 1)
		BigText:SetFontTemplate("Default", 22)
		
		DeathRecapFrameSpellInfo.Icon:SetTexCoord(unpack(UI.TexCoords))
		DeathRecapFrameSpellInfo.IconBorder:Kill()
		
		local IconOverlay = CreateFrame("Frame", nil, DeathRecapFrameSpellInfo)
		IconOverlay:SetFrameLevel(DeathRecapFrameSpellInfo:GetFrameLevel() + 10)
		IconOverlay:SetInside(DeathRecapFrameSpellInfo.Icon)
		IconOverlay:SetTemplate()
		IconOverlay:CreateShadow()
		IconOverlay:SetShadowOverlay()
		
		local TombstoneIconOverlay = CreateFrame("Frame", nil, DeathRecapFrameSpellInfo)
		TombstoneIconOverlay:SetFrameLevel(DeathRecapFrameSpellInfo:GetFrameLevel() + 10)
		TombstoneIconOverlay:SetInside(Tombstone)
		TombstoneIconOverlay:SetTemplate()
		TombstoneIconOverlay:CreateShadow()
		TombstoneIconOverlay:SetShadowOverlay()
	end
		
	self.IsSkinned = true
end

function DeathRecap:Initialize()
	if (not DB.Global.Theme.Enable) then
		return
	end
	
	--[[
	if not IsAddOnLoaded("Blizzard_DeathRecap") then
		LoadAddOn("Blizzard_DeathRecap")
	end
	
	self:Skin()
	--]]
end