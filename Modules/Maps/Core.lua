local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Maps = UI:RegisterModule("Minimap")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local Minimap = _G.Minimap
local MapsCluster = _G.MinimapCluster
local MinimapBackdrop = _G.MinimapBackdrop
local QueueStatusButton = _G.QueueStatusButton
local MapsInstanceDifficulty = _G.MinimapCluster.InstanceDifficulty
local GameTimeFrame = _G.GameTimeFrame
local MinimapZoneText = _G.MinimapZoneText
local MinimapZoneTextButton = _G.MinimapZoneTextButton
local MapsZoomIn = _G.Minimap.ZoomIn
local MapsZoomOut = _G.Minimap.ZoomOut
local MinimapNorthTag = _G.MinimapNorthTag
local TimeManagerClockButton = _G.TimeManagerClockButton
local ExpansionMinimapButton = _G.ExpansionLandingPageMinimapButton

function Maps:GetLocTextColor()
	local GetZonePVPInfo = GetZonePVPInfo()

	if (GetZonePVPInfo == "friendly") then
		return 0.1, 1.0, 0.1
	elseif (GetZonePVPInfo == "hostile") then
		return 1.0, 0.1, 0.1
	elseif (GetZonePVPInfo == "contested") then
		return 1.0, 0.7, 0.0
	elseif (GetZonePVPInfo == "sanctuary") then
		return 0.41, 0.8, 0.94
	elseif (GetZonePVPInfo == "arena") then
		return 1.0, 0.1, 0.1
	else
		return 1, 0.82, 0
	end
end

function Maps:QueueStatusSetPoint(_, Anchor)
	if (Anchor ~= FeelUIQueueStatus) then
		self:ClearAllPoints()
		self:Point("CENTER", FeelUIQueueStatus)
	end

	self:SetScale(0.6)
end

function Maps:QueueStatusSetParent(Parent)
	if (Parent ~= FeelUIQueueStatus) then
		self:SetParent(FeelUIQueueStatus)
	end
end

function Maps:Style()
	local MinimapBG = CreateFrame("Frame", nil, Minimap)
	MinimapBG:SetFrameLevel(Minimap:GetFrameLevel() - 1)
	MinimapBG:Size(171, 171)
	MinimapBG:Point("TOPRIGHT", _G.UIParent, -6, -6)
	MinimapBG:CreateBackdrop()
	MinimapBG:CreateShadow()

	Minimap:SetMaskTexture(Media.Global.Blank)
	Minimap:Size(162, 162)
	Minimap:ClearAllPoints()
	Minimap:Point("CENTER", MinimapBG, 0, 0)
	Minimap:SetTemplate()
	Minimap:CreateShadow()
	Minimap:SetShadowOverlay()

	MapsCluster:ClearAllPoints()
	MapsCluster:SetAllPoints(Minimap)
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)

	local InvisFrame = CreateFrame("Frame", nil, Minimap)
	InvisFrame:SetFrameLevel(Minimap:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	Minimap.Location = InvisFrame:CreateFontString(nil, "OVERLAY")
	Minimap.Location:Size(162, 162)
	Minimap.Location:Point("TOP", Minimap, 0, 82)
	Minimap.Location:SetJustifyH("CENTER")
	Minimap.Location:SetJustifyV("MIDDLE")
	Minimap.Location:SetFontTemplate("Default", 12)

	if (QueueStatusButton) then
		local MapsQueueStatus = CreateFrame("Frame", "FeelUIQueueStatus", _G.UIParent)
		MapsQueueStatus:SetFrameLevel(10)
		MapsQueueStatus:Size(32)
		MapsQueueStatus:Point("BOTTOMLEFT", Minimap, 4, 2)

		hooksecurefunc(QueueStatusButton, "SetParent", Maps.QueueStatusSetParent)
		hooksecurefunc(QueueStatusButton, "SetPoint", Maps.QueueStatusSetPoint)
	end
 	
 	if (MapsInstanceDifficulty) then
		MapsInstanceDifficulty:ClearAllPoints()
		MapsInstanceDifficulty:Point("BOTTOM", Minimap, 0, 22)
	end

	if (MapsCluster.IndicatorFrame) then
		MapsCluster.IndicatorFrame:SetParent(Minimap)
		MapsCluster.IndicatorFrame:ClearAllPoints()
		MapsCluster.IndicatorFrame:Point("BOTTOMRIGHT", Minimap, -8, 8)
	end
end

function Maps:ScrollZoom(Zoom)
	self:EnableMouseWheel(true)

	if (Zoom > 0) then
		MapsZoomIn:Click()
	elseif (Zoom < 0) then
		MapsZoomOut:Click()
	end
end

function Maps:Disable()
	local HiddenFrames = {
		"MinimapBorder",
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MiniMapWorldMapButton",
		"MinimapBackdrop",
		"TimeManagerClockTicker",
	}

	local DisableFrames = {
        GameTimeFrame,
        MinimapZoneText,
        MapsCluster and MapsCluster.BorderTop,
        MapsZoomIn,
        MapsZoomOut,
        ExpansionMinimapButton,
        TimeManagerClockButton,
    }

    local DisableBG = {
        MapsInstanceDifficulty.Default,
        MapsInstanceDifficulty.ChallengeMode,
        MapsInstanceDifficulty.Guild,
    }

	for i, FrameName in pairs(HiddenFrames) do
		local Frame = _G[FrameName]
		
		if (Frame) then
			Frame:SetParent(UI.HiddenParent)
			
			if (Frame.UnregisterAllEvents) then
				Frame:UnregisterAllEvents()
			end
		end
	end

    for _, Frames in ipairs(DisableFrames) do
        if (Frames) then 
        	Frames:Kill() 
        end
    end

    for _, Frames in ipairs(DisableBG) do
        if (Frames) then
            if (Frames.Background) then 
            	Frames.Background:Hide()
            end

            if (Frames.Border) then 
            	Frames.Border:Hide() 
            end
        end
    end

    if (MapsCluster and MapsCluster.Tracking) then
        MapsCluster.Tracking:Hide()

        if (MapsCluster.Tracking.Button) then
            MapsCluster.Tracking.Button:Hide()
        end
    end

    if (MinimapZoneTextButton) then
        MinimapZoneTextButton:EnableMouse(false)
    end

    if (MapsCluster and MapsCluster.ZoneTextButton) then
        MapsCluster.ZoneTextButton:EnableMouse(false)
    end
    
    if (MinimapNorthTag) then
        MinimapNorthTag:SetTexture(nil)
    end
end

function Maps:OnEvent()
	Minimap.Location:SetText(GetMinimapZoneText())
	Minimap.Location:SetTextColor(Maps:GetLocTextColor())
end

function Maps:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("ZONE_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)
end

function Maps:EnableZoom()
	Minimap:SetScript("OnMouseWheel", self.ScrollZoom)
end

function Maps:Initialize()
	self:Disable()
	self:Style()
	self:RegisterEvents()
	self:EnableZoom()
end