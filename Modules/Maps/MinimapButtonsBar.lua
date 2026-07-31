local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local MinimapButtonBar = UI:RegisterModule("MinimapButtonBar")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local tostring = tostring
local lower = string.lower
local find = string.find
local strlower = strlower
local tinsert = tinsert

-- Locals
MinimapButtonBar.Childs = {}

local IgnoredBlizzard = {
	["BattlefieldMinimap"] = true,
	["ButtonCollectFrame"] = true,
	["FeedbackUIButton"] = true,
	["GameTimeFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["HelpOpenWebTicketButton"] = true,
	["MinimapBackdrop"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MiniMapLFGFrame"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapTracking"] = true,
	["MiniMapTrackingFrame"] = true,
	["MiniMapVoiceChatFrame"] = true,
	["MinimapZoneTextButton"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["QueueStatusMinimapButton"] = true,
	["TimeManagerClockButton"] = true,
	["ExpansionLandingPageMinimapButton"] = true,
}

local IgnoredAddOns = {
	"archy",
	"bookoftracksframe",
	"cartographernotespoi",
	"cork",
	"da_minimap",
	"dugisarrowminimappoint",
	"enhancedframeminimapbutton",
	"fishingextravaganzamini",
	"fwgminimappoi",
	"gatherarchnote",
	"gathermatepin",
	"gathernote",
	"gfw_trackmenuframe",
	"gfw_trackmenubutton",
	"gpsarrow",
	"guildmap3mini",
	"guildinstance",
	"handynotespin",
	"itemrack",
	"librockconfig-1.0_minimapbutton",
	"mininotepoi",
	"nauticusminiicon",
	"poiminimap",
	"premadefilter_minimapbutton",
	"questieframe",
	"questpointerpoi",
	"reciperadarminimapicon",
	"spy_mapnotelist_mini",
	"tdial_trackingicon",
	"tdial_trackButton",
	"westpointer",
	"zgvmarker",
}

local RemoveByID = {
	[136430] = true,
	[136467] = true,
	[136468] = true,
	[130924] = true,
}

local RemoveTextureFile = {
	["interface/minimap/minimap-trackingborder"] = true,
	["interface/minimap/ui-minimap-border"] = true,
	["interface/minimap/ui-minimap-background"] = true,
}

local IsIgnoredAddOn = function(Name)
	local AddonName = lower(Name)

	for i = 1, #IgnoredAddOns do
		if find(AddonName, IgnoredAddOns[i]) then
			return true
		end
	end
end

function MinimapButtonBar:SkinButtons()
	for _, Buttons in pairs({_G.Minimap:GetChildren()}) do
		local Name = Buttons:GetName()
		
		if (Name and not IgnoredBlizzard[Name] and not IsIgnoredAddOn(Name) and Buttons:IsShown()) then
			local Type = Buttons:GetObjectType()
			
			if (Buttons:HasScript("OnDragStart")) then
				Buttons:SetScript("OnDragStart", nil)
			end
			
			if (Buttons:HasScript("OnDragStop")) then
				Buttons:SetScript("OnDragStop", nil)
			end
			
			if (Type == "Button" or Type == "Frame") then			
				Buttons:Size(unpack(DB.Global.MinimapButtonBar.ButtonSize))			
				Buttons:StyleButton()
			end
			
			for i = 1, Buttons:GetNumRegions() do
				local Region = select(i, Buttons:GetRegions())
				
				if (Region:GetObjectType() == "Texture") then
					local Texture = Region.GetTextureFileID and Region:GetTextureFileID()
					
					if (RemoveByID[Texture]) then
						Region:SetTexture()
					else
						Texture = strlower(tostring(Region:GetTexture()))
					
						if (RemoveTextureFile[Texture] or strfind(Texture, "interface/characterframe") or (strfind(Texture, "interface/minimap") and not strfind(Texture, "interface/minimap/tracking")) or strfind(Texture, "border") or strfind(Texture, "background") or strfind(Texture, "alphamask") or strfind(Texture, "highlight")) then
							Region:SetTexture(nil)
							Region:SetAlpha(0)
						else
							Region:ClearAllPoints()
							Region:SetInside()
					
							Region.UpdateCoord = UI.Noop
							UI:KeepAspectRatio(Buttons, Region)
					
							if (not Buttons.MinimapButtonIsSkinned) then
								Buttons.IconOverlay = CreateFrame("Frame", nil, Buttons)
								Buttons.IconOverlay:SetInside(Region)
								Buttons.IconOverlay:SetTemplate()
								Buttons.IconOverlay:CreateShadow()
								Buttons.IconOverlay:SetShadowOverlay()
							
								Buttons.MinimapButtonIsSkinned = true
							end
							
							Buttons:HookScript("OnLeave", function() 
								UI:KeepAspectRatio(Buttons, Region)
							end)
						end
					end
				end
			end
			
			tinsert(self.Childs, Buttons)
		end
	end
end

function MinimapButtonBar:CreatePanel()
	local Frame = CreateFrame("Frame", nil, _G.UIParent)
	Frame:Point("TOPRIGHT", _G.Minimap, "BOTTOMRIGHT", 4, -8)
	Frame:CreateBackdrop()
	Frame:CreateShadow()
	
	self.Frame = Frame	
end

function MinimapButtonBar:Update()
	local ButtonWidth, ButtonHeight = unpack(DB.Global.MinimapButtonBar.ButtonSize)
	local Spacing = DB.Global.MinimapButtonBar.ButtonSpacing
	local ButtonsPerRow = DB.Global.MinimapButtonBar.ButtonsPerRow
	local Total = #self.Childs

	if (Total < ButtonsPerRow) then
		ButtonsPerRow = Total
	end

	local Columns = math.ceil(Total / ButtonsPerRow)

	if (Columns < 1) then
		Columns = 1
	end

	local Padding = 3
	local GridWidth = (ButtonWidth * ButtonsPerRow) + (Spacing * (ButtonsPerRow -1))
	local GridHeight = (ButtonHeight * Columns) + (Spacing * (Columns -1))

	self.Frame:Size(GridWidth + (Padding * 2), GridHeight + (Padding * 2))

	for i = 1, Total do
		local Row = math.floor((i - 1) / ButtonsPerRow)
		local Col = (i - 1) % ButtonsPerRow
		local Button = self.Childs[i]
		
		Button:SetParent(self.Frame)
		Button:ClearAllPoints()
		Button:Point("TOPLEFT", self.Frame, Padding + (Col * (ButtonWidth + Spacing)), -(Padding + (Row * (ButtonHeight + Spacing))))
	end
end

function MinimapButtonBar:Initialize()
	if (not DB.Global.MinimapButtonBar.Enable) then
		return
	end

	self:CreatePanel()
	self:SkinButtons()
	
	if (#self.Childs == 0) then
		self.Frame:Hide()
		return
	end
	
	self:Update()
end