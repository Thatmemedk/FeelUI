local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ChatBubbles = UI:RegisterModule("ChatBubbles")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local pairs = pairs

function ChatBubbles:SkinBubbles(Bubbles)
	local Frame = Bubbles:GetChildren()

	if Frame and not Frame:IsForbidden() then
		local Scale = _G.UIParent:GetScale()
		Frame:SetScale(Scale)
		Frame:CreateBackdrop()
		Frame:CreateShadow()

		Frame.Center:Hide()
		Frame.TopEdge:Hide()
		Frame.BottomEdge:Hide()
		Frame.LeftEdge:Hide()
		Frame.RightEdge:Hide()
		Frame.TopLeftCorner:Hide()
		Frame.TopRightCorner:Hide()
		Frame.BottomLeftCorner:Hide()
		Frame.BottomRightCorner:Hide()
		Frame.Tail:Hide()
		
		Frame.String:SetFontTemplate("Default", 14)
	end
	
	Bubbles.AllChatBubblesIsSkinned = true
end

function ChatBubbles:OnUpdate(Elapsed)
	self.Init = (self.Init or -2) + Elapsed
	
	if (self.Init < 0.1) then
		return
	end

	local C_ChatBubbles_GetAllChatBubbles = _G.C_ChatBubbles and _G.C_ChatBubbles.GetAllChatBubbles

	for _, Bubbles in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		if not (Bubbles.AllChatBubblesIsSkinned) then
			self:SkinBubbles(Bubbles)
		end
	end

	self.Init = 0
end

function ChatBubbles:Initialize()
	--self:SetScript("OnUpdate", self.OnUpdate) -- Disable for now seems to give taints.
end
