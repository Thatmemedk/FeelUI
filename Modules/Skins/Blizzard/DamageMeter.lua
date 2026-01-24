local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DamageMeter = UI:RegisterModule("DamageMeter")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GetTime = GetTime
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

-- Locals
DamageMeter.Time = nil
DamageMeter.LastUpdate = nil
DamageMeter.IsActive = false
DamageMeter.OnlyEncounters = false

function DamageMeter:CreateCombatTimers()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(26, 26)
    Frame:Point("LEFT", DamageMeterSessionWindow1.DamageMeterTypeDropdown.TypeName, -38, 0)
    Frame:SetAlpha(0)

    -- UPDATE
    Frame:SetScript("OnUpdate", function(_, Elapsed)
        if (self.IsActive) then
            self:CombatTimerOnUpdate(Elapsed)
        end
    end)

    -- TEXT
    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetFontTemplate("Default", 12)

    -- CACHE
    self.Frame = Frame
    self.Text = Text
end

function DamageMeter:FormattedTime(Value)
    local Minutes = math.floor(Value / 60)
    local Seconds = math.floor(Value % 60)
    return string.format("(%02d:%02d)", Minutes, Seconds)
end

function DamageMeter:CombatTimerOnUpdate()
    local Elapsed = math.floor(GetTime() - self.Time)

    if (Elapsed ~= self.LastUpdate) then
        self.LastUpdate = Elapsed
        self.Text:SetText(self:FormattedTime(Elapsed))
    end
end

function DamageMeter:OnEvent(event)
	if (self.OnlyEncounters) then
		if (event == "ENCOUNTER_START") then
		    self.IsActive = true
		    self.Time = GetTime()
		    self.LastUpdate = -1

			UI:UIFrameFadeIn(self.Frame, 0.5, self.Frame:GetAlpha(), 1)
		elseif (event == "ENCOUNTER_END") then
		    self.IsActive = false
		    self.Time = nil
		    self.LastUpdate = nil

		    UI:UIFrameFadeOut(self.Frame, 0.5, self.Frame:GetAlpha(), 0)
		end
	else
	    if (event == "PLAYER_REGEN_DISABLED") then
	        self.IsActive = true
	        self.Time = GetTime()
	        self.LastUpdate = -1

	    	UI:UIFrameFadeIn(self.Frame, 0.5, self.Frame:GetAlpha(), 1)
	    elseif (event == "PLAYER_REGEN_ENABLED") then
	        self.IsActive = false
	        self.Time = nil
	        self.LastUpdate = nil

	        UI:UIFrameFadeOut(self.Frame, 0.5, self.Frame:GetAlpha(), 0)
	    end
	end
end

function DamageMeter:RegisterEvents()
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:SetScript("OnEvent", function(_, event)
        self:OnEvent(event)
    end)
end

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
			DamageMeters.DamageMeterTypeDropdown.TypeName:Point("TOPLEFT", DamageMeters, 62, -8)
			DamageMeters.DamageMeterTypeDropdown.TypeName:SetFontTemplate("Default", 12)
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

	if (not IsAddOnLoaded("Blizzard_DamageMeters")) then
		LoadAddOn("Blizzard_DamageMeters")
	end

    self:CreateCombatTimers()
    self:RegisterEvents()
    self:Skin()
end