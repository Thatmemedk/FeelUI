local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CDM = UI:RegisterModule("CooldownManager")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

-- Locals
CDM.Anchors = {}

function CDM:ForceLayout(Viewer)
	if (not Viewer or not Viewer.layoutFrame) then
		return
	end

	if InCombatLockdown() then
		return
	end

	Viewer.layoutFrame:MarkDirty()

	if (Viewer.layoutFrame.Layout) then
		Viewer.layoutFrame:Layout()
	end
end

function CDM:ApplyAnchors(Viewer)
    if (not Viewer or not self.Anchors[Viewer]) then
        return
    end

    if InCombatLockdown() then
        return
    end

    local AnchorData = self.Anchors[Viewer]
    local AnchorFrame = AnchorData.Frame

    if (not AnchorFrame) then
        return
    end

    local Container = Viewer.viewerFrame or Viewer
    local Icons = {}

    for _, Child in ipairs({ Container:GetChildren() }) do
        if Child:IsShown() then
            Icons[#Icons + 1] = Child
        end
    end

    if (#Icons == 0) then
        return
    end

    local First = Icons[1]
    local Width = First:GetWidth()
    local Spacing = AnchorData.IconSpacing
    local TotalWidth = (#Icons * Width) + ((#Icons - 1) * Spacing)
    local StartX = -TotalWidth / 2 + Width / 2

    for i, Icon in ipairs(Icons) do
        Icon:ClearAllPoints()
        Icon:Point("CENTER", AnchorFrame, "CENTER", StartX + (i - 1) * (Width + Spacing), 0)
    end
end

function CDM:CreateAnchor(Viewer, Point, Anchor, X, Y, IconSpacing)
    if (not Viewer) then 
        return 
    end

    local AnchorFrame = CreateFrame("Frame", nil, _G.UIParent)
    AnchorFrame:Point(Point, Anchor, X or 0, Y or 0)
    AnchorFrame:Size(unpack(DB.Global.CooldownManager.ButtonSize))

    Viewer:SetParent(AnchorFrame)
    Viewer:ClearAllPoints()
    Viewer:Point("CENTER", AnchorFrame, "CENTER", 0, 0)

    self.Anchors[Viewer] = {
        Frame = AnchorFrame,
        IconSpacing = IconSpacing
    }

    -- Always Apply Anchors
    self:ApplyAnchors(Viewer)
    self:ForceLayout(Viewer)

    return AnchorFrame
end

function CDM:SkinIcons(Button)
	if (Button.CDMIsSkinned) then
		return
	end

	local Icon = Button.Icon or Button.icon or Button.Texture or Button.texture
	local Count = Button.Applications and Button.Applications.Applications
	local Charges = Button.ChargeCount and Button.ChargeCount.Current
	local Cooldown = Button.Cooldown
	local OutOfRange = Button.OutOfRange
	local CooldownFlash = Button.CooldownFlash
	local Border = Button.DebuffBorder
	local BorderTex = select(3, Button:GetRegions())
	--local PandemIcon = Button.PandemicIcon or Button.pandemicIcon or Button.Pandemic or Button.pandemic

	if (not Button and not Icon) then
		return
	end

	-- Button Size
	Button:Size(unpack(DB.Global.CooldownManager.ButtonSize))

	-- Keep Aspect Ratio
	UI:KeepAspectRatio(Button, Icon)

	local OverlayFrame = CreateFrame("Frame", nil, Button)
	OverlayFrame:SetInside(Button, 1, 1)
	OverlayFrame:SetTemplate()
	OverlayFrame:CreateShadow()
	OverlayFrame:SetShadowOverlay()

	local InvisFrame = CreateFrame("Frame", nil, Button)
	InvisFrame:SetFrameLevel(Button:GetFrameLevel() + 10)
	InvisFrame:SetInside()

    if (BorderTex) then
    	BorderTex:SetAlpha(0)
    end

   	if (Border) then
		Border:SetAlpha(0)

		--[[
		local Index = 10
		local AuraData = GetAuraDataByIndex("Target", Index, "HARMFUL")

	    if (AuraData) then
			local Color = C_UnitAuras.GetAuraDispelTypeColor("Target", AuraData.auraInstanceID, UI.DispelColorCurve)
			    
		    if (Color) then
		        OverlayFrame:SetColorTemplate(Color.r, Color.g, Color.b)
		    else
		   	    OverlayFrame:SetColorTemplate(unpack(DB.Global.General.BorderColor))
		    end
		end
		--]]
	end

	if (Icon) then
		Icon:ClearAllPoints()
		Icon:SetInside(OverlayFrame, 1, 1)
	end

	if (Cooldown) then
		Cooldown:ClearAllPoints()
		Cooldown:SetInside(OverlayFrame, 1, 1)
		Cooldown:SetReverse(true)
		Cooldown:SetSwipeTexture(Media.Global.Blank)
	end

	if (CooldownFlash) then
		CooldownFlash:ClearAllPoints()
		CooldownFlash:SetInside(OverlayFrame, 1, 1)
	end

	if (OutOfRange) then
		OutOfRange:ClearAllPoints()
		OutOfRange:SetInside(OverlayFrame, 1, 1)
	end
 
	if (Charges) then
    	Charges:ClearAllPoints()
    	Charges:Point("TOPRIGHT", Button, -1, -1)
    	Charges:SetFontTemplate("Default", 12)
	end

	if (Count) then
		Count:SetParent(InvisFrame)
    	Count:ClearAllPoints()
    	Count:Point("TOP", Button, 0, 6)
    	Count:SetFontTemplate("Default", 14)
    end

	Button.CDMIsSkinned = true
end

function CDM:UpdateAnchors()
    for Frame in pairs(self.Anchors) do
        self:ApplyAnchors(Frame)
        self:ForceLayout(Frame)
    end
end

function CDM:UpdateAcquireItemsFrame(Frames)
	CDM:SkinIcons(Frames)
	CDM:ApplyAnchors(Frames)
end

function CDM:UpdateIcons(Elements)
	hooksecurefunc(Elements, "OnAcquireItemFrame", CDM.UpdateAcquireItemsFrame)

	for Frames in Elements.itemFramePool:EnumerateActive() do
		CDM:SkinIcons(Frames)
		CDM:ApplyAnchors(Frames)
	end
end

function CDM:Update()
	self:UpdateIcons(UtilityCooldownViewer)
	self:UpdateIcons(BuffIconCooldownViewer)
	self:UpdateIcons(EssentialCooldownViewer)
end

function CDM:CreateAnchors()
    local EssentialContainer = self:CreateAnchor(EssentialCooldownViewer, "CENTER", _G.UIParent, 0, -142, 0)
    local BuffContainer = self:CreateAnchor(BuffIconCooldownViewer, "BOTTOM", EssentialContainer, 0, -24, 0)
    local UtilityContainer = self:CreateAnchor(UtilityCooldownViewer, "BOTTOM", BuffContainer, 0, -24, 0)
end

function CDM:Register()
	EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
	    CDM:UpdateAnchors()
	end)

    EventRegistry:RegisterCallback("EditMode.Exit", function()
        CDM:UpdateAnchors()
    end)
end

function CDM:Initialize()
	if (not DB.Global.CooldownManager.Enable) then
		return
	end

	if not IsAddOnLoaded("Blizzard_CooldownViewer") then
		LoadAddOn("Blizzard_CooldownViewer")
	end

	self:Update()
	self:CreateAnchors()
	self:UpdateAnchors()
	self:Register()
end