local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")

-- Lib Globals
local _G = _G
local unpack = unpack

-- WoW Globals
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local GetPetActionInfo = GetPetActionInfo
local IsPetAttackAction = IsPetAttackAction
local GetPetActionSlotUsable = GetPetActionSlotUsable
local SetDesaturation = SetDesaturation
local UnitExists = UnitExists
local UnitHasVehicleUI = UnitHasVehicleUI

function AB:CreateBarPet()
    local Bar = AB.PetBar
    local Spacing = DB.Global.ActionBars.ButtonSpacing
    local PreviousButton

    local PetActionBar = _G.PetActionBar
    PetActionBar.ignoreFramePositionManager = true
    PetActionBar:EnableMouse(false)
    PetActionBar:ClearAllPoints()
    PetActionBar:SetParent(Bar)

    for i = 1, NUM_PET_ACTION_SLOTS do
        local Button = _G["PetActionButton"..i]
        Button:Size(unpack(DB.Global.ActionBars.PetButtonSize))
        Button:SetParent(Bar)
        Button:ClearAllPoints()

        if (i == 1) then
            Button:Point("TOPLEFT", Bar, "TOPLEFT", Spacing, -Spacing)
        else
            Button:Point("LEFT", PreviousButton, "RIGHT", Spacing, 0)
        end

        PreviousButton = Button
        Bar["Button"..i] = Button
    end

    self:SkinPetButtons()

    RegisterStateDriver(Bar, "visibility", "[@pet,exists,nopossessbar] show; hide")
end
