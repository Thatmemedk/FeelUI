local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function AB:CreateBar4()
	local Bar = AB.ActionBar4
	local Spacing = DB.Global.ActionBars.ButtonSpacing

	local MultiBarRight = _G.MultiBarRight
	MultiBarRight:EnableMouse(false)
	MultiBarRight:SetParent(Bar)

	for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
		local Button = _G["MultiBarRightButton"..i]
		Button:Size(unpack(DB.Global.ActionBars.ButtonSize))
		Button:ClearAllPoints()
		
		AB.SkinButton(Button)
	
		if not InCombatLockdown() then
			Button:SetAttribute("flyoutDirection", "RIGHT")
		end

		if (i == 1) then
			Button:Point("TOPLEFT", Bar, Spacing, -Spacing)
		else
			Button:Point("TOP", _G["MultiBarRightButton"..(i - 1)], "BOTTOM", 0, -Spacing)
		end

		Bar["Button"..i] = Button
	end

	if (DB.Global.ActionBars.Bar4) then
		RegisterStateDriver(Bar, "visibility", "[combat][vehicleui][petbattle][overridebar] hide; show")
	else
		UnregisterStateDriver(Bar, "visibility")
		Bar:Hide()
	end
end