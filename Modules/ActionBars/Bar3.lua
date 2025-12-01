local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function AB:CreateBar3()
	local Bar = AB.ActionBar3
	local Spacing = DB.Global.ActionBars.ButtonSpacing

	local MultiBarBottomRight = _G.MultiBarBottomRight
	MultiBarBottomRight:EnableMouse(false)
	MultiBarBottomRight:SetParent(Bar)

	for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
		local Button = _G["MultiBarBottomRightButton"..i]
		Button:Size(unpack(DB.Global.ActionBars.ButtonSize))
		Button:ClearAllPoints()
		
		AB.SkinButton(Button)
	
		if (i == 1) then
			Button:Point("TOPLEFT", Bar, Spacing, -Spacing)
		else
			Button:Point("LEFT", _G["MultiBarBottomRightButton"..(i - 1)], "RIGHT", Spacing, 0)
		end

		Bar["Button"..i] = Button
	end
	
	if (DB.Global.ActionBars.Bar3) then
		RegisterStateDriver(Bar, "visibility", "[vehicleui][petbattle][overridebar] hide; show")
	else
		UnregisterStateDriver(Bar, "visibility")
		Bar:Hide()
	end
end