local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Date = UI:RegisterModule("DataTextDate")

-- Lib Globals
local unpack = unpack

-- WoW Globals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

function Date:OnClick()
	if InCombatLockdown() then 
		return 
	end

	if (not IsAddOnLoaded("Blizzard_Calendar")) then
		LoadAddOn("Blizzard_Calendar")
	end

	_G.Calendar_Toggle()
end

function Date:UpdateDateText()
	self.Text:SetFormattedText("%02d", tonumber(date("%d")))
end

function Date:Create()
	local Frame = CreateFrame("Button", nil, _G.Minimap)
	Frame:Size(20, 20)
	Frame:Point("TOPRIGHT", _G.Minimap, -12, -8)
	Frame:SetScript("OnClick", self.OnClick)
	Frame:SetScript("OnEnter", function() self.Text:SetTextColor(1, 1, 1, 0.8) end)
	Frame:SetScript("OnLeave", function() self.Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor)) end)

	local Text = Frame:CreateFontString(nil, "OVERLAY")
	Text:Point("CENTER", Frame, 0, 0)
	Text:SetFontTemplate("Default", 12)
	Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

	self.Frame = Frame
	self.Text = Text
end

function Date:Initialize()
	if (not DB.Global.DataTexts.Date) then 
		return 
	end

	self:Create()
	self:UpdateDateText()
end
