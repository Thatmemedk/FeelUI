local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CH = UI:RegisterModule("Chat")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local type = type
local gsub = gsub
local format = format
local strsub = strsub

-- WoW Globals
local ChatFrame1Tab = _G.ChatFrame1Tab
local ChatMenu = _G.ChatMenu
local ChatFrameMenuButton = _G.ChatFrameMenuButton
local ChatConfigFrameDefaultButton = _G.ChatConfigFrameDefaultButton

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function CH:AddMessage(msg, ...)
	msg = format("%s %s", date"|CFF909090[%H:%M:%S]|r", msg) -- Time Stamps
	
	self.OldAddMessage(self, msg, ...)
end

function CH:StyleFrames(Frame)
	if (Frame.ChatIsSkinned) then
		return
	end

	local FrameName = Frame:GetName()
	local ID = Frame:GetID()
	local Chat = _G[FrameName]
	local Tab = _G[FrameName.."Tab"]
	local EditBox = _G[FrameName.."EditBox"]
	local EditBoxHeader = _G[FrameName.."EditBoxHeader"]
	local TabText = _G[FrameName.."Tab"].Text or _G[FrameName.."TabText"]
	local Scroll = Frame.ScrollBar
	local ScrollBottom = Frame.ScrollToBottomButton
	local MinimizeButton = _G[FrameName.."ButtonFrameMinimizeButton"]

	Chat:SetClampRectInsets(0, 0, 0, 0)
	Chat:SetClampedToScreen(false)
	
	EditBox:Size(Panels.ChatPanelLeft:GetWidth(), 22)
	EditBox:ClearAllPoints()
	EditBox:Point("TOPLEFT", Panels.ChatPanelLeft, 0, 26)
	EditBox:CreateBackdrop()
	EditBox:SetBackdropColorTemplate(0.1, 0.1, 0.1, 0.90)
	EditBox:CreateShadow()

	Chat:SetFontTemplate("Default")
	EditBox:SetFontTemplate("Default")
	EditBoxHeader:SetFontTemplate("Default")
	TabText:SetFontTemplate("Default")

	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[FrameName..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end

	Chat:StripTexture()
	Tab:StripTexture()
	
	_G[format("ChatFrame%sButtonFrame", ID)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusLeft", ID)]:SetAlpha(0)
	_G[format("ChatFrame%sEditBoxFocusMid", ID)]:SetAlpha(0)
	_G[format("ChatFrame%sEditBoxFocusRight", ID)]:SetAlpha(0)
	_G[format("ChatFrame%sEditBoxLeft", ID)]:SetAlpha(0)
	_G[format("ChatFrame%sEditBoxMid", ID)]:SetAlpha(0)
	_G[format("ChatFrame%sEditBoxRight", ID)]:SetAlpha(0)

	if (Scroll) then Scroll:Kill() end
	if (ScrollBottom) then ScrollBottom:Kill() end
	if (MinimizeButton) then MinimizeButton:Kill() end

	if (i ~= 2) then
		Frame.OldAddMessage = Frame.AddMessage
		Frame.AddMessage = CH.AddMessage
	end

	Frame.ChatIsSkinned = true
end

function CH:StyleTempFrame()
	local Frame = FCF_GetCurrentChatFrame()

	if (Frame.ChatIsSkinned) then
		return
	end

	CH:StyleFrames(Frame)
end

function CH:UpdateTabColors(Selected)
	if (Selected) then
		self:GetFontString():SetTextColor(R, G, B)
	else
		self:GetFontString():SetTextColor(1, 1, 1)
	end
end

function CH:AddChatMenu()
	ChatFrame1Tab:RegisterForClicks("AnyUp")
	ChatFrame1Tab:HookScript("OnClick", function(self, Button)
		if (Button == "MiddleButton") then
			ChatMenu:Show()
		end
	end)
end

function CH:SetChatFrame1Position()
	self:SetPointBase("BOTTOMLEFT", Panels.ChatPanelLeft, 3, 4)
end

function CH:SetChatFramePosition()
	local ID = self:GetID()

	if (ID == 1) then
		self:SetUserPlaced(true)
		self:ClearAllPoints()
		self:Size(408, 158)
		self:Point("BOTTOMLEFT", Panels.ChatPanelLeft, 3, 4)

		hooksecurefunc(self, "SetPoint", CH.SetChatFrame1Position)
	end
end

function CH:AddHooks()
	hooksecurefunc("FCF_OpenTemporaryWindow", self.StyleTempFrame)
	hooksecurefunc("FCFTab_UpdateColors", self.UpdateTabColors)
	hooksecurefunc("FCF_RestorePositionAndDimensions", self.SetChatFramePosition)
end

function CH:SetupChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		self:StyleFrames(Frame)
		
		if not (Frame.isLocked) then
			FCF_SetLocked(Frame, 1)
		end

		self.SetChatFramePosition(Frame)
	end
end

function CH:HideButtons()
	ChatFrameMenuButton:Kill()
	ChatConfigFrameDefaultButton:Kill()
	QuickJoinToastButton:Kill()
end

function CH:Initialize()
	if (not DB.Global.Chat.Enable) then
		return
	end

	self:HideButtons()
	self:SetupChat()
	self:AddChatMenu()
	self:AddHooks()
	self:StyleCombatLog()
	self:EnableURL()
	self:CreateCopyButton()
end