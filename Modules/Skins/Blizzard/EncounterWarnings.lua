local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local EW = UI:RegisterModule("EncounterWarnings")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

function EW:SkinIcons(Button)
    if (self.IsSkinned) then
        return
    end

    local LeftIcon = Button.View.LeftIcon
    local RightIcon = Button.View.RightIcon
    local LeftMask = LeftIcon.IconMask
    local RightMask = RightIcon.IconMask
    local NormalOverlayLeft = LeftIcon.NormalOverlay
    local NormalOverlayRight = RightIcon.NormalOverlay
    local DeadlyOverlayLeft = LeftIcon.DeadlyOverlay
    local DeadlyOverlayRight = RightIcon.DeadlyOverlay
    local DeadlyOverlayGlowLeft = LeftIcon.DeadlyOverlayGlow
    local DeadlyOverlayGlowRight = RightIcon.DeadlyOverlayGlow

    -- HIDE
    if LeftMask then LeftMask:SetAlpha(0) end
    if RightMask then RightMask:SetAlpha(0) end
    if NormalOverlayLeft then NormalOverlayLeft:SetAlpha(0) end
    if NormalOverlayRight then NormalOverlayRight:SetAlpha(0) end
    if DeadlyOverlayLeft then DeadlyOverlayLeft:SetInside(LeftIcon, 1, 1) end
    if DeadlyOverlayRight then DeadlyOverlayRight:SetInside(RightIcon, 1, 1) end

    -- BUTTONS
    LeftIcon:Size(38, 22)
	LeftIcon:SetTemplate()
	LeftIcon:CreateShadow()
	LeftIcon:SetShadowOverlay()

    RightIcon:Size(38, 22)
	RightIcon:SetTemplate()
	RightIcon:CreateShadow()
	RightIcon:SetShadowOverlay()

	-- ICONS
    LeftIcon.Icon:ClearAllPoints()
    LeftIcon.Icon:SetInside(LeftIcon, 1, 1)
    UI:KeepAspectRatio(LeftIcon, LeftIcon.Icon)

    RightIcon.Icon:ClearAllPoints()
    RightIcon.Icon:SetInside(RightIcon, 1, 1)
    UI:KeepAspectRatio(RightIcon, RightIcon.Icon)

    self.IsSkinned = true
end

function EW:Skin()
    --self:SkinIcons(CriticalEncounterWarnings)
    --self:SkinIcons(MediumEncounterWarnings)
    --self:SkinIcons(MinorEncounterWarnings)

	_G.CriticalEncounterWarnings.View.Text:SetFontTemplate("Default", 48, 2, 2, 1)
	_G.MediumEncounterWarnings.View.Text:SetFontTemplate("Default", 38, 2, 2, 1)
	_G.MinorEncounterWarnings.View.Text:SetFontTemplate("Default", 28, 2, 2, 1)
end

function EW:Initialize()
    if (not DB.Global.Theme.Enable) then 
        return
    end

	if (not IsAddOnLoaded("Blizzard_EncounterWarnings")) then
		LoadAddOn("Blizzard_EncounterWarnings")
	end

    self:Skin()
end