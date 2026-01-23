local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DamageMeter = UI:RegisterModule("DamageMeter")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

function DamageMeter:OnEnter()
	for _, Buttons in ipairs(self.OptionsButtons) do
		UI:UIFrameFadeIn(Buttons, 0.25, Buttons:GetAlpha(), 1)
	end
end

function DamageMeter:OnLeave()
	for _, Buttons in ipairs(self.OptionsButtons) do
		UI:UIFrameFadeOut(Buttons, 0.5, Buttons:GetAlpha(), 0)
	end
end

function DamageMeter:Skin()
	if (self.IsSkinned) then
		return
	end

	for i = 1, 3 do
		local DamageMeters = _G["DamageMeterSessionWindow"..i]

		if (DamageMeters) then
			DamageMeters:StripTexture()
			DamageMeters.Background:Hide()

			-- NAME
			DamageMeters.DamageMeterTypeDropdown.TypeName:SetParent(DamageMeters)
			DamageMeters.DamageMeterTypeDropdown.TypeName:ClearAllPoints()
			DamageMeters.DamageMeterTypeDropdown.TypeName:Point("TOPLEFT", DamageMeters, 22, -8)
			DamageMeters.DamageMeterTypeDropdown.TypeName:SetFontTemplate("Default", 14)
			DamageMeters.DamageMeterTypeDropdown.TypeName:SetTextColor(1, 1, 1)

			-- BUTTONS
			DamageMeters.OptionsButtons = {
				DamageMeters.SettingsDropdown,
				DamageMeters.SessionDropdown,
				DamageMeters.DamageMeterTypeDropdown
			}

			DamageMeters.SettingsDropdown:Size(26, 26)
			DamageMeters.SettingsDropdown:ClearAllPoints()
			DamageMeters.SettingsDropdown:Point("TOPRIGHT", DamageMeters, 22, 0)

			DamageMeters.SessionDropdown:Size(26, 26)
			DamageMeters.SessionDropdown:ClearAllPoints()
			DamageMeters.SessionDropdown:Point("LEFT", DamageMeters.SettingsDropdown, -32, 0)

			DamageMeters.DamageMeterTypeDropdown:Size(26, 26)
			DamageMeters.DamageMeterTypeDropdown:ClearAllPoints()
			DamageMeters.DamageMeterTypeDropdown:Point("LEFT", DamageMeters.SessionDropdown, -32, 0)

			-- FADE
			for _, Buttons in ipairs(DamageMeters.OptionsButtons) do
				Buttons:SetAlpha(0)

				Buttons:HookScript("OnEnter", function()
					DamageMeter.OnEnter(DamageMeters)
				end)

				Buttons:HookScript("OnLeave", function()
					DamageMeter.OnLeave(DamageMeters)
				end)
			end

			DamageMeters:SetScript("OnEnter", function(self)
				DamageMeter.OnEnter(self)
			end)

			DamageMeters:SetScript("OnLeave", function(self)
				DamageMeter.OnLeave(self)
			end)
		end
	end
		
	self.IsSkinned = true
end

function DamageMeter:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end

	if not IsAddOnLoaded("Blizzard_DamageMeters") then
		LoadAddOn("Blizzard_DamageMeters")
	end

	self:Skin()
end