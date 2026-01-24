local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Durability = UI:RegisterModule("DataTextDurability")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local unpack = unpack
local wipe = wipe
local floor = math.floor

-- WoW Globals
local GetInventoryItemDurability = GetInventoryItemDurability

-- Locals
local InvDurability = {}

-- Locals
local Slots = {
	[1] = _G.INVTYPE_HEAD,
	[3] = _G.INVTYPE_SHOULDER,
	[5] = _G.INVTYPE_CHEST,
	[6] = _G.INVTYPE_WAIST,
	[7] = _G.INVTYPE_LEGS,
	[8] = _G.INVTYPE_FEET,
	[9] = _G.INVTYPE_WRIST,
	[10] = _G.INVTYPE_HAND,
	[16] = _G.INVTYPE_WEAPONMAINHAND,
	[17] = _G.INVTYPE_WEAPONOFFHAND,
	[18] = _G.INVTYPE_RANGED,
}

-- Locals
local GradientColorPalet = {
	1, 0, 0,       -- Red
	1, 0.42, 0,    -- Orange
	1, 0.82, 0,    -- Yellow
	0, 1, 0        -- Green
}

function Durability:OnEvent()
	local TotalDurability = 100
	local TotalRepairCost = 0
	wipe(InvDurability)

	for Index in pairs(Slots) do
		local CurrentDurability, MaxDurability = GetInventoryItemDurability(Index)

		if (CurrentDurability and MaxDurability and MaxDurability > 0) then
			local Perc = floor((CurrentDurability / MaxDurability) * 100)
			InvDurability[Index] = Perc

			if (Perc < TotalDurability) then
				TotalDurability = Perc
			end
		end
	end

	local R, G, B = UI:ColorGradient(TotalDurability, 100, unpack(GradientColorPalet))
	local Hex = UI:RGBToHex(R, G, B)

	self.Text:SetFormattedText("|cffffffffDurability|r: %s%d%%|r", Hex, TotalDurability)
end

function Durability:Create()
	local Frame = CreateFrame("Frame", nil, _G.UIParent)
	Frame:Size(160, 50)
	Frame:Point("RIGHT", Panels.DataTextHolder, 32, -2)

	local Text = Frame:CreateFontString(nil, "OVERLAY")
	Text:Point("CENTER", Frame, 0, 0)
	Text:SetFontTemplate("Default", 12)
	Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

	self.Frame = Frame
	self.Text = Text
end

function Durability:RegisterEvents()
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", self.OnEvent)
end

function Durability:Initialize()
	if (not DB.Global.DataTexts.Durability) then 
		return 
	end

	self:Create()
	self:RegisterEvents()
end
