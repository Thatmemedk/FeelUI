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

function AB:UpdatePetBar(event, unit)
    if (event == "UNIT_FLAGS" and unit ~= "pet" or event == "UNIT_PET" and unit ~= "player") then 
        return 
    end

    for i = 1, NUM_PET_ACTION_SLOTS do
        local Button = _G["PetActionButton"..i]
        local Icon = _G["PetActionButton"..i.."Icon"]
        local Name, Texture, IsToken, IsActive, AutoCastAllowed, AutoCastEnabled, SpellID = GetPetActionInfo(i)
        local AutoCast = Button.AutoCastOverlay or Button.AutoCastable

        Button.isToken = IsToken

        if (not IsToken) then
            Icon:SetTexture(Texture)
            Button.tooltipName = Name
        else
            Icon:SetTexture(_G[Texture])
            Button.tooltipName = _G[Name]
        end

        if (SpellID) then
            local Spell = Spell:CreateFromSpellID(SpellID)

            if (Spell) then
                Button.spellDataLoadedCancelFunc = Spell:ContinueWithCancelOnSpellLoad(function()
                    Button.tooltipSubtext = Spell:GetSpellSubtext()
                end)
            end
        end

        if (IsActive and Name ~= "PET_ACTION_FOLLOW") then
            Button:SetChecked(true)

            if (IsPetAttackAction(i)) then 
            	Button:StartFlash() 
            end
        else
            Button:SetChecked(false)

            if (IsPetAttackAction(i)) then 
            	Button:StopFlash()
           	end
        end

        if (AutoCastAllowed) then
			AutoCast:Show()
		else
			AutoCast:Hide()
		end

		AutoCast:ShowAutoCastEnabled(AutoCastEnabled)

        if (Texture) then
            SetDesaturation(Icon, GetPetActionSlotUsable(i) and nil or 1)
            Icon:Show()
        else
            Icon:Hide()
        end

        if (not UnitExists("pet") or UnitHasVehicleUI("pet") and Texture and Name ~= "PET_ACTION_FOLLOW") then
            Button:StopFlash()
            SetDesaturation(Icon, 1)
            Button:SetChecked(false)
        end
    end
end

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

    Bar:RegisterEvent("PLAYER_CONTROL_LOST")
    Bar:RegisterEvent("PLAYER_CONTROL_GAINED")
    Bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
    Bar:RegisterEvent("UNIT_PET")
    Bar:RegisterEvent("UNIT_FLAGS")
    Bar:RegisterEvent("PET_BAR_UPDATE")
    Bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
    Bar:SetScript("OnEvent", function(self, event, ...)         
        AB:UpdatePetBar()
    end)

    RegisterStateDriver(Bar, "visibility", "[@pet,exists,nopossessbar] show; hide")
end
