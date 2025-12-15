local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local EW = UI:RegisterModule("EncounterWarnings")

function EW:SkinIcons(Button)
    if (Button.IsSkinned) then
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

    -- Hide masks
    if LeftMask then LeftMask:SetAlpha(0) end
    if RightMask then RightMask:SetAlpha(0) end
    if NormalOverlayLeft then NormalOverlayLeft:SetAlpha(0) end
    if NormalOverlayRight then NormalOverlayRight:SetAlpha(0) end
    if DeadlyOverlayLeft then DeadlyOverlayLeft:SetInside(LeftIcon, 1, 1) end
    if DeadlyOverlayRight then DeadlyOverlayRight:SetInside(RightIcon, 1, 1) end

    -- Set size
    LeftIcon:Size(38, 22)
    RightIcon:Size(38, 22)

    local OverlayFrameLeft = CreateFrame("Frame", nil, LeftIcon)
	OverlayFrameLeft:SetInside(LeftIcon, 1, 1)
	OverlayFrameLeft:SetTemplate()
	OverlayFrameLeft:CreateShadow()
	OverlayFrameLeft:SetShadowOverlay()

	local OverlayFrameRight = CreateFrame("Frame", nil, RightIcon)
	OverlayFrameRight:SetInside(RightIcon, 1, 1)
	OverlayFrameRight:SetTemplate()
	OverlayFrameRight:CreateShadow()
	OverlayFrameRight:SetShadowOverlay()

    -- Keep aspect ratio for the actual icon texture
    LeftIcon.Icon:ClearAllPoints()
    LeftIcon.Icon:SetInside(LeftIcon, 1, 1)

    RightIcon.Icon:ClearAllPoints()
    RightIcon.Icon:SetInside(RightIcon, 1, 1)

    UI:KeepAspectRatio(LeftIcon, LeftIcon.Icon)
    UI:KeepAspectRatio(RightIcon, RightIcon.Icon)

    Button.IsSkinned = true
end

function EW:Initialize()
    self:SkinIcons(CriticalEncounterWarnings)
    self:SkinIcons(MediumEncounterWarnings)
    self:SkinIcons(MinorEncounterWarnings)

	CriticalEncounterWarnings.View.Text:SetFontTemplate("Default", 26, 2, 2)
	MediumEncounterWarnings.View.Text:SetFontTemplate("Default", 18, 2, 2)
	MinorEncounterWarnings.View.Text:SetFontTemplate("Default", 14, 2, 2)
end