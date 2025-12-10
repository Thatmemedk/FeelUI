-- CREDITS: Spyro

local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CooldownManager = UI:RegisterModule("CooldownManager")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local CooldownViewerSettings = _G.CooldownViewerSettings
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

-- Locals
local CooldownManagerFrames = { 
	EssentialCooldownViewer, 
	UtilityCooldownViewer, 
	BuffIconCooldownViewer,
}

function CooldownManager:SkinIcons(Button)
	if (Button:IsForbidden() or Button.CDMIsSkinned) then
		return
	end

	local Icon = Button.Icon or Button.icon or Button.Texture or Button.texture
	local Count = Button.Applications and Button.Applications.Applications
	local Charges = Button.ChargeCount and Button.ChargeCount.Current
	local Cooldown = Button.Cooldown
	local CooldownFlash = Button.CooldownFlash
	local Border = select(3, Button:GetRegions())
	local PandemIcon = Button.PandemicIcon or Button.pandemicIcon or Button.Pandemic or Button.pandemic

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

    if (Border) then
    	Border:Hide()
    end

	if (Icon) then
		Icon:ClearAllPoints()
		Icon:SetInside(Button, 1, 1)
	end

	if (Cooldown) then
		Cooldown:ClearAllPoints()
		Cooldown:SetInside(Button, 1, 1)
		Cooldown:SetReverse(true)
	end

	if (CooldownFlash) then
		CooldownFlash:ClearAllPoints()
		CooldownFlash:SetInside(Button, 1, 1)
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

    if (not PandemIcon) then
        for _, Frames in ipairs({ Button:GetChildren() }) do
            if (Frames:GetName() and Frames:GetName():find("Pandemic")) then
                PandemIcon = Frames
                break
            end
        end
    end

    if (PandemIcon and PandemIcon.ClearAllPoints) then
        PandemIcon:ClearAllPoints()
        PandemIcon:SetInside(Button, 1, 1)
    end

	Button.CDMIsSkinned = true
end

function CooldownManager:Update()
    if (self.Queued) then 
    	return
   	end

    self.Queued = true

	for _, Frames in ipairs(CooldownManagerFrames) do
		for _, Button in pairs({ Frames:GetChildren() }) do
			self:SkinIcons(Button)

	        if (Frames.GetNumChildren) then
	            local NumChild = Frames:GetNumChildren()

	            for i = 1, NumChild do
	                local Frame = select(i, Frames:GetChildren())

	                if (Frame and not Frame.IsHooked) then
	                    if (Frame.SetPoint) then hooksecurefunc(Frame, "SetPoint", function() CooldownManager:Update() end) end
	                    if (Frame.SetAllPoints) then hooksecurefunc(Frame, "SetAllPoints", function() CooldownManager:Update() end) end
	                    if (Frame.ClearAllPoints) then hooksecurefunc(Frame, "ClearAllPoints", function() CooldownManager:Update() end) end
	                    if (Frame.SetSize) then hooksecurefunc(Frame, "SetSize", function() CooldownManager:Update() end) end

	                   	Frame.IsHooked = true
	                end
	            end
	        end
	    end
	end

	self.Queued = false
end

function CooldownManager:UpdateSafe()
    if (not self.Queued) then
        self:Update()
    end
end

function CooldownManager:Initialize()
	if (not DB.Global.CooldownManager.Enable) then
		return
	end

	if not IsAddOnLoaded("Blizzard_CooldownViewer") then
		LoadAddOn("Blizzard_CooldownViewer")
	end

	self:UpdateSafe()
	--self:AddHooks()
end