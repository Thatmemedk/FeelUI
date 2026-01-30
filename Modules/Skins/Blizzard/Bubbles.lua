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
	local Scale = _G.UIParent:GetScale()
	Frame:SetScale(Scale)
	Frame:CreateBackdrop()
	Frame:CreateShadow()
	Frame:DisableBackdrops()
	
	if (Frame.String) then
		Frame.String:SetFontTemplate("Default", 14)
	end

	Frame.IsSkinned = true
end

function ChatBubbles:OnUpdate(Elapsed)
	self.Init = (self.Init or -2) + Elapsed
	
	if (self.Init < 0.1) then
		return
	end

	for _, Frame in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		local Bubbles = Frame:GetChildren()

		if (Bubbles and not Bubbles:IsForbidden() and not Frame.IsSkinned) then
			self:SkinBubbles(Bubbles)
		end
	end

	self.Init = 0
end

function ChatBubbles:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end
	
	self:SetScript("OnUpdate", self.OnUpdate)
end