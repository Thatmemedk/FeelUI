local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ChatBubbles = UI:RegisterModule("ChatBubbles")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local pairs = pairs

-- WoW Globals
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

function ChatBubbles:SkinBubbles(Frame)
	if (self.IsSkinned) then
		return
	end

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

	self.IsSkinned = true
end

function ChatBubbles:OnUpdate(Elapsed)
	self.Init = (self.Init or -2) + Elapsed
	
	if (self.Init < 0.1) then
		return
	end

	for _, Frame in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		local Bubbles = Frame:GetChildren()

		if (Bubbles and not Bubbles:IsForbidden()) then
			self:SkinBubbles(Bubbles)
		end
	end

	self.Init = 0
end

function ChatBubbles:Initialize()
	self:SetScript("OnUpdate", self.OnUpdate)
end
