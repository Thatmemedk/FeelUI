local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function AB:CreateBar2()
	local Bar = AB.ActionBar2
	local Spacing = DB.Global.ActionBars.ButtonSpacing

	local MultiBarBottomLeft = _G.MultiBarBottomLeft
	MultiBarBottomLeft:EnableMouse(false)
	MultiBarBottomLeft:SetParent(Bar)

	for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
		local Button = _G["MultiBarBottomLeftButton"..i]
		Button:Size(unpack(DB.Global.ActionBars.ButtonSize))
		Button:ClearAllPoints()
		
		AB.SkinButton(Button)
	
		if (i == 1) then
			Button:Point("TOPLEFT", Bar, Spacing, -Spacing)
		else
			Button:Point("LEFT", _G["MultiBarBottomLeftButton"..(i - 1)], "RIGHT", Spacing, 0)
		end

		Bar["Button"..i] = Button
	end

	RegisterStateDriver(Bar, "visibility", "[vehicleui] hide; show")
end