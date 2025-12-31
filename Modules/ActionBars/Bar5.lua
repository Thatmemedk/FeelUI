local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
    
-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

function AB:CreateBar5()
    local Bar = AB.ActionBar5
    local Spacing = DB.Global.ActionBars.ButtonSpacing
    local NumButtons = 6

    local MultiBarLeft = _G.MultiBarLeft
    MultiBarLeft:EnableMouse(false)
    MultiBarLeft:SetParent(Bar)

    for i = 1, NumButtons do
        local Button = _G["MultiBarLeftButton"..i]
        Button:Size(unpack(DB.Global.ActionBars.ButtonSize))
        Button:ClearAllPoints()

        AB.SkinButton(Button)

        if not InCombatLockdown() then
            Button:SetAttribute("flyoutDirection", "LEFT")
        end

        if (i == 1) then
            Button:Point("TOPRIGHT", Bar, -Spacing, -Spacing)
        else
            Button:Point("TOP", _G["MultiBarLeftButton"..(i - 1)], "BOTTOM", 0, -Spacing)
        end

        Bar["Button"..i] = Button
    end

    for i = NumButtons + 1, _G.NUM_ACTIONBAR_BUTTONS do
        local Button = _G["MultiBarLeftButton"..i]

        if (Button) then
            Button:ClearAllPoints()
            Button:SetPoint("TOP", _G.UIParent, "TOP", 0, 3000)
            Button:Hide()
        end
    end

    if (DB.Global.ActionBars.Bar5) then
        RegisterStateDriver(Bar, "visibility", "[vehicleui] hide; show")
    else
        UnregisterStateDriver(Bar, "visibility")
        Bar:Hide()
    end
end