local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function AB:UpdateMainBarButtons()
	local Bar = AB.ActionBar1
	local Spacing = DB.Global.ActionBars.ButtonSpacing

	for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
		local Button = _G["ActionButton"..i]
        Button:Size(unpack(DB.Global.ActionBars.ButtonSize))
		Button:SetParent(Bar)
		Button:ClearAllPoints()
		
		AB.SkinButton(Button)

        if (i == 1) then
            Button:Point("TOPLEFT", Bar, Spacing, -Spacing)
        else
            Button:Point("LEFT", _G["ActionButton"..(i - 1)], "RIGHT", Spacing, 0)
        end
		
		Bar["Button"..i] = Button
	end
end

function AB:CreateBar1()
    local Bar = AB.ActionBar1

    -- Update All Buttons
    self:UpdateMainBarButtons()

    -- Set Frame References For Secure Execution
    for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
        Bar:SetFrameRef("ActionButton"..i, _G["ActionButton"..i])
    end

    -- Setup Paging Conditions
    local VehicleBar = format("[vehicleui][possessbar] %d;", GetVehicleBarIndex())
    local OverrideBar = format("[overridebar] %d;", GetOverrideBarIndex())
    local ShapeshiftBar = format("[shapeshift] %d;", GetTempShapeshiftBarIndex())

    Bar.Page = {
        ["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
        ["ROGUE"] = "[bonusbar:1] 7;",
        ["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
        ["PRIEST"] = "[bonusbar:1] 7;",
        ["DEFAULT"] = ShapeshiftBar .. VehicleBar .. OverrideBar .. "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;"
    }

    function AB:GetPages()
        local PageDefault = Bar.Page["DEFAULT"]
        local Class = select(2, UnitClass("player"))
        local Page = Bar.Page[Class]

        if (Page) then
            PageDefault = PageDefault .. " " .. Page
        end

        PageDefault = PageDefault .. " [form] 1; 1"

        return PageDefault
    end

    -- Prepare Secure Table For Buttons
    Bar:Execute([[
        Button = table.new()
        for i = 1, 12 do
            table.insert(Button, self:GetFrameRef("ActionButton"..i))
        end
    ]])

    -- Handle Action Page State Changes
    Bar:SetAttribute("_onstate-page", [[
        if newstate == "possess" or newstate == "11" then
            if HasVehicleActionBar() then
                newstate = GetVehicleBarIndex()
            elseif HasOverrideActionBar() then
                newstate = GetOverrideBarIndex()
            elseif HasTempShapeshiftActionBar() then
                newstate = GetTempShapeshiftBarIndex()
            elseif HasBonusActionBar() then
                newstate = GetBonusBarIndex()
            else
                newstate = 12
            end
        end

        for i, Button in ipairs(Button) do
            Button:SetAttribute("actionpage", tonumber(newstate))
        end
    ]])

    -- Register State Driver
    RegisterStateDriver(Bar, "page", self:GetPages())
end