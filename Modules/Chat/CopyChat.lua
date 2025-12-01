local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local CH = UI:CallModule("Chat")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function CH:OnTextCopied()
	self:SetTextCopyable(false)
	self:EnableMouse(false)
	self:SetOnTextCopiedCallback(nil)
	self.IsCopyEnabled = false
	
	Panels.CopyHighlight:SetStatusBarColor(0, 0, 0, 0)
end

function CH:EnterSelectMode(Frame)
	local Frame = Frame or SELECTED_CHAT_FRAME
	Frame:SetTextCopyable(true)
	Frame:EnableMouse(true)
	Frame:SetOnTextCopiedCallback(self.OnTextCopied)
end

function CH:OnMouseUp()
	local Frame = self.ChatFrame
	
	if Frame.IsCopyEnabled then
		Frame:SetTextCopyable(false)
		Frame:EnableMouse(false)
		Frame:SetOnTextCopiedCallback(nil)
		Frame.IsCopyEnabled = false
		
		Panels.CopyHighlight:SetStatusBarColor(0, 0, 0, 0)
		
		return
	else
		Frame.IsCopyEnabled = true
	end
	
	if Frame.isDocked then
		Panels.CopyHighlight:SetStatusBarColor(1, 1, 1, 0.05)
	end
	
	CH:EnterSelectMode(Frame)
end

function CH:OnEnter()
	UI:UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
end

function CH:OnLeave()
	UI:UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
end

function CH:CreateCopyButton()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]

		local Button = CreateFrame("Button", nil, Frame)
		Button:Size(22, 22)
		Button:Point("TOPRIGHT", Frame, -1, 2)
		Button:SetAlpha(0.25)
		Button:CreateBackdrop()
		Button:CreateShadow()
		
		local ButtonTexture = Button:CreateTexture(nil, "OVERLAY")
		ButtonTexture:SetInside(Button, 2, 2)
		ButtonTexture:SetTexture(Media.Global.ChatCopy)
		ButtonTexture:SetVertexColor(0.55, 0.55, 0.55)

		Button:SetScript("OnMouseUp", self.OnMouseUp)
		Button:SetScript("OnEnter", self.OnEnter)
		Button:SetScript("OnLeave", self.OnLeave)
		
		Button.ChatFrame = Frame
	end
end