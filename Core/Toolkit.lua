local UI, DB, Media, Language = select(2, ...):Call()

-----------------------
-- Toolkit of FeelUI --
-----------------------

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local type = type
local assert = assert
local getmetatable = getmetatable
local pcall = pcall

-- WoW Globals
local CreateFrame = CreateFrame
local CreateTexture = CreateTexture

-- Locals
local FrameType = "Texture"

-------------------------------
-- Blizzard Frames & Regions --
-------------------------------

UI.BlizzardFrames = {
	"Inset",
	"inset",
	"InsetFrame",
	"LeftInset",
	"RightInset",
	"NineSlice",
	"BG",
	"border",
	"Border",
	"BorderFrame",
	"bottomInset",
	"BottomInset",
	"bgLeft",
	"bgRight",
	"FilligreeOverlay",
	"PortraitOverlay",
	"ArtOverlayFrame",
	"Portrait",
	"portrait",
	"ScrollFrameBorder",
	"ScrollUpBorder",
	"ScrollDownBorder",
}

UI.BlizzardRegions = {
	"Left",
	"Middle",
	"Right",
	"Mid",
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"TopMiddle",
	"MiddleLeft",
	"MiddleRight",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
	"Center",
}

UI.BlizzardNineSliceRegions = {
	"Center",
	"TopEdge", 
	"BottomEdge", 
	"LeftEdge", 
	"RightEdge",
	"TopLeftCorner", 
	"TopRightCorner",
	"BottomLeftCorner", 
	"BottomRightCorner",
}

----------
-- Kill --
----------

local function Kill(self)
	if (self.IsProtected) then
		if (self:IsProtected()) then
			error("Attempted to kill a protected object: <" .. self:GetName() .. ">")
		end
	end

	if (self.UnregisterAllEvents) then
		self:UnregisterAllEvents()
		self:SetParent(UI.HiddenParent)
	else
		self.Show = self.Hide
	end

	self:Hide()
end

local function ClearRegion(RegionType, Frame, Remove, Hide)
    if (Remove) then
        Frame:Kill()
    elseif (Hide) then
        Frame:SetAlpha(0)
    elseif (RegionType == FrameType) then
        Frame:SetTexture("")
        Frame:SetAtlas("")
    end
end

local function ProcessRegionType(RegionType, Frame, Remove, Hide)
    if (Frame:IsObjectType(RegionType)) then
        ClearRegion(RegionType, Frame, Remove, Hide)
    else
        if (RegionType == FrameType) then
            local FrameName = Frame.GetName and Frame:GetName()

            for _, RegionSub in ipairs(UI.BlizzardFrames) do
                local SubFrame = Frame[RegionSub] or (FrameName and _G[FrameName .. RegionSub])

                if (SubFrame and SubFrame.StripTextures) then
                    SubFrame:StripTextures(Remove, Hide)
                end
            end
        end

        if (Frame.GetNumRegions) then
            for _, Region in ipairs({ Frame:GetRegions() }) do

                if (Region and Region.IsObjectType and Region:IsObjectType(RegionType)) then
                    ClearRegion(RegionType, Region, Remove, Hide)
                end
            end
        end
    end
end

local function StripTexture(Frame, Remove, Hide)
    ProcessRegionType(FrameType, Frame, Remove, Hide)
end

--------------------
-- Font Templates --
--------------------

local function SetFontTemplate(self, FontTemplate, FontSize, ShadowOffsetX, ShadowOffsetY)
	if not (self) then
		return
	end

	if (FontTemplate == "Default") then
		self:SetFont(Media.Global.Font, UI:Scale(FontSize or 12), "THINOUTLINE")
	end

	self:SetShadowOffset(UI:Scale(ShadowOffsetX or 1), -UI:Scale(ShadowOffsetY or 1))
	self:SetShadowColor(0, 0, 0, 0.5)
	
	UI.Texts[self] = true
end

-------------------
-- Size & Points --
-------------------

local function WatchPixelSnap(self, Snap)
	if (self and not self:IsForbidden()) and self.PixelSnapDisabled and Snap then
		self.PixelSnapDisabled = nil
	end
end

local function DisablePixelSnap(self)
	if (self and not self:IsForbidden()) and not self.PixelSnapDisabled then
		if (self.SetSnapToPixelGrid) then
			self:SetSnapToPixelGrid(false)
			self:SetTexelSnappingBias(0)
		elseif (self.GetStatusBarTexture) then
			local Texture = self:GetStatusBarTexture()

			if (type(Texture) == "table" and Texture.SetSnapToPixelGrid) then
				Texture:SetSnapToPixelGrid(false)
				Texture:SetTexelSnappingBias(0)
			end
		end

		self.PixelSnapDisabled = true
	end
end

function UI:PointsRestricted(self)
	if self and not pcall(self.GetPoint, self) then
		return true
	end
end

local function Size(self, WidthSize, HeightSize)
	self:SetSize(UI:Scale(WidthSize), UI:Scale(HeightSize or WidthSize))
end

local function Width(self, WidthSize)
	self:SetWidth(UI:Scale(WidthSize))
end

local function Height(self, HeightSize)
	self:SetHeight(UI:Scale(HeightSize))
end

local function Point(self, Anchor, Parent, Anchor2, OffsetX, OffsetY)
    Parent = Parent or self:GetParent()

    local function ScaleIfNumber(Value)
        return (type(Value) == "number") and UI:Scale(Value) or Value
    end

    self:SetPoint(Anchor, Parent, Anchor2, ScaleIfNumber(OffsetX) or 0, ScaleIfNumber(OffsetY) or 0)
end

local function SetOutside(self, Anchor, OffsetX, OffsetY, Anchor2)
	OffsetX = OffsetX or 0
	OffsetY = OffsetY or 0
	Anchor = Anchor or self:GetParent()

	if UI:PointsRestricted(self) or self:GetPoint() then
		self:ClearAllPoints()
	end
	
	DisablePixelSnap(self)
	self:Point("TOPLEFT", Anchor, "TOPLEFT", -OffsetX, OffsetY)
	self:Point("BOTTOMRIGHT", Anchor2 or Anchor, "BOTTOMRIGHT", OffsetX, -OffsetY)
end

local function SetInside(self, Anchor, OffsetX, OffsetY, Anchor2)
	OffsetX = OffsetX or 0
	OffsetY = OffsetY or 0
	Anchor = Anchor or self:GetParent()

	if UI:PointsRestricted(self) or self:GetPoint() then
		self:ClearAllPoints()
	end

	DisablePixelSnap(self)
	self:Point("TOPLEFT", Anchor, "TOPLEFT", OffsetX, -OffsetY)
	self:Point("BOTTOMRIGHT", Anchor2 or Anchor, "BOTTOMRIGHT", -OffsetX, OffsetY)
end

------------------------
-- Borders & Backdrop --
------------------------

local function SetTemplate(self)
	if (self.BorderIsCreated) then
		return
	end
	
	local R, G, B, Alpha = unpack(DB.Global.General.BorderColor)
	
	self.FrameRaised = CreateFrame("Frame", nil, self)
	self.FrameRaised:SetFrameStrata(self:GetFrameStrata())
	self.FrameRaised:SetFrameLevel(self:GetFrameLevel() + 1)
	self.FrameRaised:SetAllPoints()	

	self.Border = {}
	
	for i = 1, 4 do
		self.Border[i] = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.Border[i]:Size(1, 1)
		self.Border[i]:SetColorTexture(R, G, B, Alpha)
	end
	
	self.Border[1]:Point("TOPLEFT", self, "TOPLEFT", 0, 0)
	self.Border[1]:Point("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	
	self.Border[2]:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
	self.Border[2]:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	self.Border[3]:Point("TOPLEFT", self, "TOPLEFT", 0, 0)
	self.Border[3]:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
	
	self.Border[4]:Point("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	self.Border[4]:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	self.BorderIsCreated = true
end

local function SetBackdropTemplate(self, InsetLeft, InsetRight, InsetTop, InsetBottom)
	if (self.BackdropIsCreated) then
		return
	end
	
	local R, G, B, Alpha = unpack(DB.Global.General.BackdropColor)
	
	self.BorderBackdrop = self:CreateTexture(nil, "BACKGROUND", nil, -8)
	self.BorderBackdrop:SetTexture(Media.Global.Texture)
	self.BorderBackdrop:SetVertexColor(R, G, B, Alpha)
	
	if (InsetLeft or InsetRight or InsetTop or InsetBottom) then
		self.BorderBackdrop:Point("TOPLEFT", self, "TOPLEFT", -InsetLeft or 0, InsetTop or 0)
		self.BorderBackdrop:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", InsetRight or 0, -InsetBottom or 0)
	else
		self.BorderBackdrop:Point("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.BorderBackdrop:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	end
	
	self.BackdropIsCreated = true
end

local function SetColorTemplate(self, R, G, B, Alpha)
	if (self and self.Border) then
		for i = 1, 4 do
			self.Border[i]:SetColorTexture(R, G, B, Alpha)
		end
	end
end

function SetBackdropColorTemplate(self, R, G, B, Alpha)
	if (self and self.BorderBackdrop) then
		self.BorderBackdrop:SetVertexColor(R, G, B, Alpha)
	end
end

local function CreateBackdrop(self)
	if (self.Backdrop) then
		return
	end
	
	self:SetBackdropTemplate()

	local Backdrop = CreateFrame("Frame", nil, self)
	Backdrop:SetOutside()
	Backdrop:SetTemplate()
	
	self.Backdrop = Backdrop
end

local function CreateShadow(self)
	if (self.Shadow) then
		return
	end

	local Shadow = CreateFrame("Frame", nil, self, "BackdropTemplate")

	if (self.FrameRaised) then
		Shadow:SetFrameStrata(self.FrameRaised:GetFrameStrata())
	end

	Shadow:SetFrameLevel(0)
	Shadow:SetOutside(self, 2, 2)
	Shadow:SetBackdrop({edgeFile = Media.Global.Shadow, edgeSize = UI:Scale(3)})
	Shadow:SetBackdropColor(0, 0, 0, 0)
	Shadow:SetBackdropBorderColor(unpack(DB.Global.General.ShadowColor))

	self.Shadow = Shadow
end

local function CreateGlow(self, Scale, EdgeSize, R, G, B, Alpha)
	if (self.Glow) then
		return
	end

	local Glow = CreateFrame("Frame", nil, self, "BackdropTemplate")

	if (self.FrameRaised) then
		Glow:SetFrameStrata(self.FrameRaised:GetFrameStrata())
	end

	Glow:SetFrameLevel(0)
	Glow:SetScale(UI:Scale(Scale))
	Glow:SetOutside(self, 3, 3)
	Glow:SetBackdrop({edgeFile = Media.Global.Shadow, edgeSize = UI:Scale(EdgeSize)})
	Glow:SetBackdropBorderColor(R, G, B, Alpha)

	self.Glow = Glow
end

----------------------
-- ActionBars Style --
----------------------

local function CreateButtonPanel(self, ExtraShadowBorders)
	if (self.ButtonPanel) then
		return
	end

	local ButtonPanel = CreateFrame("Frame", nil, self)
	ButtonPanel:SetFrameLevel(self:GetFrameLevel() + 1)
	ButtonPanel:SetInside()
	ButtonPanel:SetTemplate(ExtraShadowBorders)

	self.ButtonPanel = ButtonPanel
end

local function CreateButtonBackdrop(self)
	if (self.ButtonBG) then
		return
	end

	local ButtonBG = CreateFrame("Button", nil, self)
	ButtonBG:SetFrameLevel(self:GetFrameLevel() - 1)
	ButtonBG:Size(self:GetSize())
	ButtonBG:Point("CENTER", self, 0, 0)
	
	ButtonBG:SetNormalTexture(4701874)
	UI:KeepAspectRatio(ButtonBG, ButtonBG:GetNormalTexture())
	ButtonBG:GetNormalTexture():SetInside()
	
	self.ButtonBG = ButtonBG
end

local function StyleButton(self, NoHover, NoPushed, NoChecked)
	if (self.SetHighlightTexture and self.CreateTexture and not self.Highlight and not NoHover) then
		self:SetHighlightTexture(Media.Global.Texture)

		local Highlight = self:GetHighlightTexture()
		Highlight:SetInside(self, 1, 1)
		Highlight:SetBlendMode("ADD")
		Highlight:SetColorTexture(unpack(DB.Global.ActionBars.HighlightColor))
		self.Highlight = Highlight
	end

	if (self.SetPushedTexture and self.CreateTexture and not self.Pushed and not NoPushed) then
		self:SetPushedTexture(Media.Global.Texture)

		local Pushed = self:GetPushedTexture()
		Pushed:SetInside(self, 1, 1)
		Pushed:SetBlendMode("ADD")
		Pushed:SetColorTexture(unpack(DB.Global.ActionBars.PushedColor))
		self.Pushed = Pushed
	end

	if (self.SetCheckedTexture and self.CreateTexture and not self.Checked and not NoChecked) then
		self:SetCheckedTexture(Media.Global.Texture)

		local Checked = self:GetCheckedTexture()
		Checked:SetInside(self, 1, 1)
		Checked:SetBlendMode("ADD")
		Checked:SetColorTexture(unpack(DB.Global.ActionBars.CheckedColor))
		self.Checked = Checked
	end
	
	if (self.Cooldown) then
		self.Cooldown:SetInside()
		self.Cooldown:SetDrawEdge(true)
	end
end

local function StyleButtonHighlight(self, X, Y)
	if self:GetHighlightTexture() then
		self:GetHighlightTexture():SetInside(self, X or 0, Y or 0)
		self:GetHighlightTexture():SetColorTexture(unpack(DB.Global.ActionBars.HighlightColor))
	end
end

local function SetShadowOverlay(self, ShadowOverlayAlpha)
	if (self.ShadowOverlay) then
		return
	end

	local ShadowOverlay = self:CreateTexture(nil, "OVERLAY", nil, 7)
	ShadowOverlay:SetInside()
	ShadowOverlay:SetTexture(Media.Global.Overlay)
	ShadowOverlay:SetVertexColor(1, 1, 1, ShadowOverlayAlpha or 0.5)

	self.ShadowOverlay = ShadowOverlay
end

----------
-- Misc --
----------

local function CreateSpark(self, R, G, B, A)
	if (self.Spark) then
		return
	end

	local Spark = self:CreateTexture(nil, "OVERLAY", nil, 7)
	Spark:Size(3, self:GetHeight())
	Spark:Point("CENTER", self:GetStatusBarTexture(), "RIGHT")
	Spark:SetTexture(Media.Global.Highlight)
	Spark:SetVertexColor(R or 0, G or 0.66, B or 1, A or 0.80)
	Spark:SetBlendMode("DISABLE")
	
	self.Spark = Spark
end

--------------
-- Skinning --
--------------

local function ClearFrameRegions(Frame, Remove)
    if not (Frame) then 
    	return 
    end

    local Prefix = Frame.GetName and Frame:GetName() or nil

    for _, RegionSuffix in ipairs(UI.BlizzardRegions) do
        local Region = Frame[RegionSuffix] or (Prefix and _G[Prefix .. RegionSuffix])

        if (Region) then
            if (Remove) then
                Region:Kill()
            else
                Region:SetAlpha(0)
            end
        end
    end
end

local function DisableBackdrops(self)
    for _, RegionKey in ipairs(UI.BlizzardRegions) do
        local Frame = self[RegionKey]

        if (Frame) then
            Frame:Hide()
        end
    end

    if (self.BackdropFrame) then
        self.BackdropFrame:Kill()
    end

    if (self.NineSlice) then
        for _, RegionKeyNS in ipairs(UI.BlizzardNineSliceRegions) do
            local Frame = self.NineSlice[RegionKeyNS]

            if (Frame) then
                Frame:Hide()
            end
        end
    end
end

local function HandleButton(self, Strip, Pulse)
	if (self.HandleButtonIsSkinned) then
		return 
	end

	local ButtonName = self.GetName and self:GetName()

	if self.SetNormalTexture then self:SetNormalTexture(UI.ClearTexture) end
	if self.SetHighlightTexture then self:SetHighlightTexture(UI.ClearTexture) end
	if self.SetPushedTexture then self:SetPushedTexture(UI.ClearTexture) end
	if self.SetDisabledTexture then self:SetDisabledTexture(UI.ClearTexture) end

	if Strip then 
		self:StripTexture() 
	end
	
	self:ClearFrameRegions()
	self:CreateBackdrop()
	self:CreateShadow()
	self:SetBackdropColorTemplate(0.25, 0.25, 0.25, 0.70)
	
	local R, G, B = unpack(UI.GetClassColors)
	
	self.HighlightTexture = self:CreateTexture(nil, "BACKGROUND")
	self.HighlightTexture:SetInside()
	self.HighlightTexture:SetTexture(Media.Global.Texture)
	self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
	self.HighlightTexture:Hide()
	
	self.PulseGlow = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.PulseGlow:SetFrameStrata(self:GetFrameStrata())
	self.PulseGlow:SetFrameLevel(self:GetFrameLevel() + 1)
	self.PulseGlow:SetScale(UI:Scale(2))
	self.PulseGlow:SetOutside(self, 3, 3)
	self.PulseGlow:SetBackdrop({edgeFile = Media.Global.Shadow, edgeSize = UI:Scale(3)})
	self.PulseGlow:SetBackdropBorderColor(0, 0, 0, 0)
	
	self:HookScript("OnEnter", function() 
		self.HighlightTexture:SetVertexColor(R, G, B, 0.25)
		self.HighlightTexture:Show()
		
		UI:CreatePulse(self.PulseGlow)
		self.PulseGlow:SetBackdropBorderColor(R, G, B, 0.8)
		
		self.Backdrop:SetColorTemplate(R, G, B)
	end)
	
	self:HookScript("OnLeave", function() 
		self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		self.HighlightTexture:Hide()
		
		self.PulseGlow:SetScript("OnUpdate", nil)
		self.PulseGlow:SetBackdropBorderColor(0, 0, 0, 0)
		
		self.Backdrop:SetColorTemplate(unpack(DB.Global.General.BorderColor))
	end)
	
	self.HandleButtonIsSkinned = true
end

local function HandleCloseButton(self, OffsetX, OffsetY, CloseSize)
	if (self.HandleCloseButtonIsSkinned) then 
		return 
	end
	
	self:StripTexture()

	self.Texture = self:CreateTexture(nil, "OVERLAY")
	self.Texture:Point("CENTER", OffsetX or 0, OffsetY or 0)
	self.Texture:Size(CloseSize or 12)
	self.Texture:SetTexture(Media.Global.CloseTexture)
	self.Texture:SetVertexColor(0.8, 0.8, 0.8, 1)
	
	self:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	self:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(0.8, 0.8, 0.8, 1) end)
	
	self.HandleCloseButtonIsSkinned = true
end

local function HandleSplitButton(self, Width, Height)
	if (self.HandleSplitButtonIsSkinned) then 
		return 
	end
	
	local Tex = Media.Global.Texture
	local R, G, B = unpack(UI.GetClassColors)
	local Normal = self:GetNormalTexture()
	local Pushed = self:GetPushedTexture()
	local Disabled = self:GetDisabledTexture()

	self:StripTexture()
	self:Size(Width or 18, Height or 18)
	self:SetTemplate()
	self:CreateShadow()

	self:SetNormalTexture(Tex)
	self:SetPushedTexture(Tex)
	self:SetDisabledTexture(Tex)
	self:SetHighlightTexture("")
	
	if (Normal) then
		Normal:SetVertexColor(R, G, B, 0.8)
		Normal:SetInside()
	end
	
	if (Pushed) then
		Pushed:SetVertexColor(unpack(DB.Global.ActionBars.HighlightColor))
		Pushed:SetInside()
	end
	
	if (Disabled) then
		Disabled:SetVertexColor(0.3, 0.3, 0.3, 0.8)
		Disabled:SetInside()
	end
	
	self.HighlightTexture = self:CreateTexture(nil, "OVERLAY")
	self.HighlightTexture:SetInside()
	self.HighlightTexture:SetTexture(Tex)
	self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
	self.HighlightTexture:Hide()
	
	self:HookScript("OnEnter", function(self) 
		self.HighlightTexture:SetVertexColor(unpack(DB.Global.ActionBars.HighlightColor))
		self.HighlightTexture:Show()
	end)
	
	self:HookScript("OnLeave", function(self) 
		self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		self.HighlightTexture:Hide()
	end)
	
	self.HandleSplitButtonIsSkinned = true
end

--------------------------------
-- Merge our API with WoW API --
--------------------------------

local function AddAPI(object)
	local mt = getmetatable(object).__index

	-- Pixel Stuff
	if not object.DisabledPixelSnap and (mt.SetSnapToPixelGrid or mt.SetStatusBarTexture or mt.SetColorTexture or mt.SetVertexColor or mt.CreateTexture or mt.SetTexCoord or mt.SetTexture) then
		if mt.SetSnapToPixelGrid then hooksecurefunc(mt, "SetSnapToPixelGrid", WatchPixelSnap) end
		if mt.SetStatusBarTexture then hooksecurefunc(mt, "SetStatusBarTexture", DisablePixelSnap) end
		if mt.SetColorTexture then hooksecurefunc(mt, "SetColorTexture", DisablePixelSnap) end
		if mt.SetVertexColor then hooksecurefunc(mt, "SetVertexColor", DisablePixelSnap) end
		if mt.CreateTexture then hooksecurefunc(mt, "CreateTexture", DisablePixelSnap) end
		if mt.SetTexture then hooksecurefunc(mt, "SetTexture", DisablePixelSnap) end
		if mt.SetTexCoord then hooksecurefunc(mt, "SetTexCoord", DisablePixelSnap) end

		mt.DisabledPixelSnap = true
	end

	-- Kill
	if not object.Kill then mt.Kill = Kill end
	if not object.StripTexture then mt.StripTexture = StripTexture end
	-- Font
	if not object.SetFontTemplate then mt.SetFontTemplate = SetFontTemplate end
	-- Size & Point
	if not object.Size then mt.Size = Size end
	if not object.Width then mt.Width = Width end
	if not object.Height then mt.Height = Height end
	if not object.Point then mt.Point = Point end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	-- Borders & Backdrop
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.SetBackdropTemplate then mt.SetBackdropTemplate = SetBackdropTemplate end
	if not object.SetColorTemplate then mt.SetColorTemplate = SetColorTemplate end
	if not object.SetBackdropColorTemplate then mt.SetBackdropColorTemplate = SetBackdropColorTemplate end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.CreateGlow then mt.CreateGlow = CreateGlow end
	if not object.CreateButtonPanel then mt.CreateButtonPanel = CreateButtonPanel end
	if not object.CreateButtonBackdrop then mt.CreateButtonBackdrop = CreateButtonBackdrop end
	if not object.CreateButtonHighlight then mt.CreateButtonHighlight = CreateButtonHighlight end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.StyleButtonHighlight then mt.StyleButtonHighlight = StyleButtonHighlight end
	if not object.SetShadowOverlay then mt.SetShadowOverlay = SetShadowOverlay end
	if not object.CreateSpark then mt.CreateSpark = CreateSpark end
	-- Skining
	if not object.ClearFrameRegions then mt.ClearFrameRegions = ClearFrameRegions end
	if not object.DisableBackdrops then mt.DisableBackdrops = DisableBackdrops end
	if not object.HandleButton then mt.HandleButton = HandleButton end
	if not object.HandleCloseButton then mt.HandleCloseButton = HandleCloseButton end
	if not object.HandleSplitButton then mt.HandleSplitButton = HandleSplitButton end
end

local Handled = {["Frame"] = true}

local Object = CreateFrame("Frame")
AddAPI(Object)
AddAPI(Object:CreateTexture())
AddAPI(Object:CreateFontString())
AddAPI(Object:CreateMaskTexture())

Object = EnumerateFrames()

while Object do
	if not Object:IsForbidden() and not Handled[Object:GetObjectType()] then
		AddAPI(Object)
		Handled[Object:GetObjectType()] = true
	end
	
	Object = EnumerateFrames(Object)
end