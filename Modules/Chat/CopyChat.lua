local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local CH = UI:CallModule("Chat")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack

function CH:CreateChatCopyFrame()
	local CopyFrame = CreateFrame("Frame", "FeelUI_CopyChatFrame", _G.UIParent)
	CopyFrame:Size(692, 392)
	CopyFrame:Point("CENTER", _G.UIParent, 0, 42)
	CopyFrame:SetFrameStrata("DIALOG")
	CopyFrame:CreateBackdrop()
	CopyFrame:CreateShadow()
	CopyFrame:Hide()

	local ScrollFrame = CreateFrame("ScrollFrame", nil, CopyFrame, "UIPanelScrollFrameTemplate")
	ScrollFrame:Point("TOPLEFT", CopyFrame, "TOPLEFT", 6, -30)
	ScrollFrame:Point("BOTTOMRIGHT", CopyFrame, "BOTTOMRIGHT", -30, 6)

	local CopyEditBox = CreateFrame("EditBox", nil, ScrollFrame)
	CopyEditBox:Width(640)
	CopyEditBox:SetFontTemplate("Default")
	CopyEditBox:SetMultiLine(true)
	CopyEditBox:EnableMouse(true)
	CopyEditBox:SetAutoFocus(false)
	CopyEditBox:SetScript("OnEscapePressed", function()
		CopyFrame:Hide()
	end)

	ScrollFrame:SetScrollChild(CopyEditBox)
	ScrollFrame.ScrollBar:HandleScrollBar()

	local Close = CreateFrame("Button", "FeelUI_CopyChatFrameCloseButton", CopyFrame, "UIPanelCloseButton")
	Close:Point("TOPRIGHT", CopyFrame, -6, 0)
	Close:EnableMouse(true)
	Close:HandleCloseButton()

	self.CopyFrame = CopyFrame
	self.CopyEditBox = CopyEditBox
end

function CH:ShowCopyText(Text)
	self.CopyFrame:Show()
	self.CopyEditBox:SetText(Text or "")
	self.CopyEditBox:HighlightText()
	self.CopyEditBox:SetFocus()
end

function CH:OnMouseUp()
	local Frame = self.ChatFrame

	if (not Frame) then
		return
	end

	local Text = ""

	for i = 1, Frame:GetNumMessages() do
		local msg = Frame:GetMessageInfo(i)

		if msg then
			Text = Text .. msg .. "\n"
		end
	end

	CH:ShowCopyText(Text)
end

function CH:OnEnter()
	UI:UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
end

function CH:OnLeave()
	UI:UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
end

function CH:CreateChatCopyButton()
	for i = 1, _G.NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]

		local Button = CreateFrame("Button", nil, Frame)
		Button:Size(22, 22)
		Button:Point("TOPRIGHT", Frame, -1, 2)
		Button:SetAlpha(0.25)
		Button:CreateBackdrop()
		Button:CreateShadow()

		local Texture = Button:CreateTexture(nil, "OVERLAY")
		Texture:SetInside(Button, 2, 2)
		Texture:SetTexture(Media.Global.ChatCopy)
		Texture:SetVertexColor(0.55, 0.55, 0.55)

		Button:SetScript("OnMouseUp", self.OnMouseUp)
		Button:SetScript("OnEnter", self.OnEnter)
		Button:SetScript("OnLeave", self.OnLeave)

		Button.ChatFrame = Frame
	end
end

function CH:CreateChatCopy()
	self:CreateChatCopyButton()
	self:CreateChatCopyFrame()
end