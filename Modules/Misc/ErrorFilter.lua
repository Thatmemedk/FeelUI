local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ErrorFilter = UI:RegisterModule("ErrorFilter")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Global
local UIErrorsFrame = _G.UIErrorsFrame

function ErrorFilter:UpdateErros()
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	UIErrorsFrame:ClearAllPoints()
	UIErrorsFrame:Point("TOP", _G.UIParent, 0, -222)
	UIErrorsFrame:SetFontTemplate("Default", 16)
	UIErrorsFrame:SetTimeVisible(1)
	UIErrorsFrame:SetFadeDuration(0.8)
end

function ErrorFilter:RegisterEvents()
	self:RegisterEvent("UI_ERROR_MESSAGE")
	self:SetScript("OnEvent", function(_, _, _, Message)
		UIErrorsFrame:AddMessage(Message, unpack(DB.Global.ErrorsFrame.TextColor))
	end)
end

function ErrorFilter:Initialize()
	if (not DB.Global.ErrorsFrame.Enable) then
		return
	end

	self:UpdateErros()
	self:RegisterEvents()
end