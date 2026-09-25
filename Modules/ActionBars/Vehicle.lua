local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local UnitOnTaxi = UnitOnTaxi
local TaxiRequestEarlyLanding = TaxiRequestEarlyLanding
local VehicleExit = VehicleExit
local CanExitVehicle = CanExitVehicle

function AB:CreateVehicleExitButton(Anchor, OffsetX)
    local Button = CreateFrame("Button", nil, _G.UIParent)
    Button:Size(32, 22)
    Button:Point(Anchor, Panels.DataTextHolder, OffsetX, 3)
    Button:StyleButtonHighlight()
    Button:SetTemplate()
    Button:CreateShadow()
    Button:SetShadowOverlay()
    Button:SetAlpha(0)

    -- Icons
    Button:SetNormalTexture(Media.Global.ExitVehicle)
    UI:KeepAspectRatio(Button, Button:GetNormalTexture())
    Button:GetNormalTexture():SetInside()

    Button:SetHighlightTexture(Media.Global.ExitVehicle)
    UI:KeepAspectRatio(Button, Button:GetHighlightTexture())
    Button:GetHighlightTexture():SetInside()

    -- OnEvents
    Button:RegisterEvent("PLAYER_ENTERING_WORLD")
    Button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    Button:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
    Button:RegisterEvent("UNIT_ENTERED_VEHICLE")
    Button:RegisterEvent("UNIT_EXITED_VEHICLE")
    Button:RegisterEvent("VEHICLE_UPDATE")
    Button:SetScript("OnEvent", function(self)
        if (CanExitVehicle()) then
            UI:UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
        else
            UI:UIFrameFadeOut(self, 0.25, self:GetAlpha(), 0)
            self:SetColorTemplate(unpack(DB.Global.General.BorderColor))
        end
    end)

    -- OnClick
    Button:RegisterForClicks("AnyUp")
    Button:SetScript("OnClick", function()
        if (UnitOnTaxi("player")) then
            TaxiRequestEarlyLanding()
        else
            VehicleExit()
        end

        AB.VehicleExitButtonLeft:SetColorTemplate(1, 0, 0)
        AB.VehicleExitButtonRight:SetColorTemplate(1, 0, 0)
    end)

    return Button
end

function AB:CreateVehicleExitButtons()
    local VehicleExitButtonLeft = self:CreateVehicleExitButton("LEFT", -68)
    local VehicleExitButtonRight = self:CreateVehicleExitButton("RIGHT", 68)

    -- Cache
    self.VehicleExitButtonLeft = VehicleExitButtonLeft
    self.VehicleExitButtonRight = VehicleExitButtonRight
end