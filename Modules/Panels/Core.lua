local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Panels = UI:RegisterModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local CreateFrame = CreateFrame

function Panels:Initialize()
	-- ChatPanelLeft
	local ChatPanelLeft = CreateFrame("Frame", nil, _G.UIParent)
	ChatPanelLeft:SetFrameStrata("BACKGROUND")
	ChatPanelLeft:SetFrameLevel(10)
	ChatPanelLeft:Size(414, 168)
	ChatPanelLeft:Point("BOTTOMLEFT", _G.UIParent, 6, 6)
	ChatPanelLeft:CreateBackdrop()
	ChatPanelLeft:CreateShadow()

	-- ChatPanelRight
	local ChatPanelRight = CreateFrame("Frame", nil, _G.UIParent)
	ChatPanelRight:SetFrameStrata("BACKGROUND")
	ChatPanelRight:SetFrameLevel(10)
	ChatPanelRight:Size(414, 168)
	ChatPanelRight:Point("BOTTOMRIGHT", _G.UIParent, -6, 6)
	ChatPanelRight:CreateBackdrop()
	ChatPanelRight:CreateShadow()
	
	-- CopyChat Highlight
	local CopyHighlight = CreateFrame("StatusBar", nil, ChatPanelLeft)
	CopyHighlight:SetFrameLevel(ChatPanelLeft:GetFrameLevel() + 5)
	CopyHighlight:SetInside()
	CopyHighlight:SetStatusBarTexture(Media.Global.Texture)
	CopyHighlight:SetStatusBarColor(0, 0, 0, 0)
	
	-- DataTextHolder
	local DataTextHolder = CreateFrame("Frame", nil, _G.UIParent)
	DataTextHolder:Size(392, 22)
	DataTextHolder:Point("BOTTOM", _G.UIParent, 0, 6)

	-- DataBarHolder
	local DataBarHolder = CreateFrame("Frame", nil, _G.UIParent)
	DataBarHolder:Size(222, 78)
	DataBarHolder:Point("BOTTOM", _G.UIParent, 0, 166)
	
	-- Bottom Panel
	local BottomPanel = CreateFrame("Frame", nil, _G.UIParent)
	BottomPanel:SetFrameStrata("BACKGROUND")
	BottomPanel:SetFrameLevel(5)
	BottomPanel:Size(_G.UIParent:GetWidth()+12, 22)
	BottomPanel:Point("BOTTOM", _G.UIParent, 0, -6)
	BottomPanel:CreateBackdrop()
	BottomPanel:CreateShadow()

	-- Register Panels
	self.ChatPanelLeft = ChatPanelLeft
	self.ChatPanelRight = ChatPanelRight
	self.CopyHighlight = CopyHighlight
	self.DataTextHolder = DataTextHolder
	self.DataBarHolder = DataBarHolder
	self.BottomPanel = BottomPanel
end