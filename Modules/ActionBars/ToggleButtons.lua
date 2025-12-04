local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local InCombatLockdown = InCombatLockdown

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function AB:ToggleButtonOnClick()
	if InCombatLockdown() then
		return UI:Print(ERR_NOT_IN_COMBAT)
	end

	local Bar = AB.ActionBar4

	if (Bar:IsVisible()) then
		UnregisterStateDriver(Bar, "visibility")
		Bar:Hide()

		self:Point("LEFT", _G.UIParent, 6, 0)
		self.Texture:Point("CENTER", self, -2, 0)
		self.Texture:SetTexture(Media.Global.PowerArrowRight)

		if (DB.Global.UnitFrames.RaidFrames) then
			if (FeelUI_Raid) then
				FeelUI_Raid:Point("LEFT", _G.UIParent, 6, 1)
			end
		end
	else
		RegisterStateDriver(Bar, "visibility", "[combat][vehicleui][petbattle][overridebar] hide; show")
		Bar:Show()
		
		self:Point("LEFT", _G.UIParent, 54, 0)
		self.Texture:Point("CENTER", self, 2, 0)
		self.Texture:SetTexture(Media.Global.PowerArrowLeft)

		if (DB.Global.UnitFrames.RaidFrames) then
			if (FeelUI_Raid) then
				FeelUI_Raid:Point("LEFT", _G.UIParent, 78, 1)
			end
		end
	end
end

function AB:ToggleButtonOnEvent(event)
	if InCombatLockdown() then
		return UI:Print(ERR_NOT_IN_COMBAT)
	end

	if (event == "PLAYER_REGEN_DISABLED") then
		self:Point("LEFT", _G.UIParent, 6, 0)

		if (DB.Global.UnitFrames.RaidFrames) then
			if (FeelUI_Raid) then
				FeelUI_Raid:Point("LEFT", _G.UIParent, 6, 1)
			end
		end
	elseif (event == "PLAYER_REGEN_ENABLED") then
		self:Point("LEFT", _G.UIParent, 54, 0)
	end
end

function AB:CreateToggleButtons()
    local ToggleButton = CreateFrame("Button", "FeelUI_ActionBarToggle", _G.UIParent)
    ToggleButton:SetFrameStrata("HIGH")
    ToggleButton:Size(16, 352)
    ToggleButton:Point("LEFT", _G.UIParent, 54, 0)
    ToggleButton:HandleButton()
    ToggleButton:RegisterEvent("PLAYER_REGEN_ENABLED")
	ToggleButton:RegisterEvent("PLAYER_REGEN_DISABLED")
	ToggleButton:RegisterForClicks("AnyUp")
	ToggleButton:SetScript("OnClick", self.ToggleButtonOnClick)
	ToggleButton:SetScript("OnEvent", self.ToggleButtonOnEvent)
    ToggleButton:SetAlpha(0)

    ToggleButton.Texture = ToggleButton:CreateTexture(nil, "OVERLAY")
    ToggleButton.Texture:Size(14, 14)
    ToggleButton.Texture:Point("CENTER", ToggleButton, 2, 0)
    ToggleButton.Texture:SetVertexColor(R, G, B)
    ToggleButton.Texture:SetTexture(Media.Global.PowerArrowLeft)

    ToggleButton:HookScript("OnEnter", function(self)
        UI:UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
    end)

    ToggleButton:HookScript("OnLeave", function(self)
        UI:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
    end)
end