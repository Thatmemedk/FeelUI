local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function AB:CreateExtraActionButton()
	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local Button = _G["ExtraActionButton"..i]
		
		if (Button and not Button.ExtraActionButtonIsSkinned) then
			Button:Size(52, 28)
			Button:SetNormalTexture("")
			Button:CreateButtonPanel()
			Button:CreateButtonBackdrop()
			Button:CreateShadow()
			Button:StyleButton()
			Button:SetShadowOverlay()
		
			local Count = _G["ExtraActionButton"..i.."Count"]
			Count:ClearAllPoints()
			Count:Point("BOTTOMRIGHT", -2, 4)
			Count:SetFontTemplate("Default", 18)
			
			local HotKey = _G["ExtraActionButton"..i.."HotKey"]
			
			if (DB.Global.ActionBars.HotKey) then
				HotKey:ClearAllPoints()
				HotKey:Point("TOPRIGHT", -2, -4)
				HotKey:SetFontTemplate("Pixel")
			else
				HotKey:SetText("")
				HotKey:SetAlpha(0)
			end
		
			local Style = Button.style
			Style:SetAlpha(0)

			local Icon = _G["ExtraActionButton"..i.."Icon"]
			Icon:Size(52, 28)
			Icon:SetInside()
			UI:KeepAspectRatio(Icon, Icon)
			
			if (Button.cooldown) then
		        for i = 1, Button.cooldown:GetNumRegions() do
		            local Region = select(i, Button.cooldown:GetRegions())

		            if (Region and Region.GetText) then
		                local FontSize = UI:GetCooldownFontScale(Button.cooldown)

		                Region:ClearAllPoints()
		                Region:Point("CENTER", Button, 0, 0)
		                Region:SetFontTemplate("Default", FontSize)
		                Region:SetTextColor(1, 0.82, 0)
		            end
		        end
			end
		
			Button.ExtraActionButtonIsSkinned = true
		end
	end
	
	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(Frame)
		for Button in Frame.SpellButtonContainer:EnumerateActive() do

			if (Button and not Button.ZoneAbilityIsSkinned) then
				Button:Size(52, 28)
				Button.NormalTexture:SetAlpha(0)
				Button:CreateButtonPanel()
				Button:CreateButtonBackdrop()
				Button:CreateShadow()
				Button:StyleButton()
				Button:SetShadowOverlay()
				
				local Count = Button.Count
				Count:ClearAllPoints()
				Count:Point("BOTTOMRIGHT", -2, 4)
				Count:SetFontTemplate("Default", 18)

				local Style = Frame.Style
				Style:SetAlpha(0)
				
				local Icon = Button.Icon
				Icon:Size(52, 28)
				Icon:SetInside()				
				UI:KeepAspectRatio(Icon, Icon)
				
				if (Button.Cooldown) then
			        for i = 1, Button.Cooldown:GetNumRegions() do
			            local Region = select(i, Button.Cooldown:GetRegions())

			            if (Region and Region.GetText) then
			                local FontSize = UI:GetCooldownFontScale(Button.Cooldown)

			                Region:ClearAllPoints()
			                Region:Point("CENTER", Button, 0, 0)
			                Region:SetFontTemplate("Default", FontSize)
			                Region:SetTextColor(1, 0.82, 0)
			            end
			        end
				end

				Button.ZoneAbilityIsSkinned = true
			end
		end
	end)
end