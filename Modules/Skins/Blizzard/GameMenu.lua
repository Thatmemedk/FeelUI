local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local GameMenu = UI:RegisterModule("GameMenu")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- Locals
local GameMenuFrame = _G.GameMenuFrame

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function GameMenu:Skin()
	if (self.IsSkinned) then
		return
	end

	GameMenuFrame:ClearAllPoints()
	GameMenuFrame:Point("CENTER", _G.UIParent, 0, 52)

	if (GameMenuFrame.Header) then
		GameMenuFrame.Header:SetAlpha(0)
	end

	if (GameMenuFrame.Border) then
		GameMenuFrame.Border:StripTexture()
	end

	if (GameMenuFrame.NewOptionsFrame) then
		GameMenuFrame.NewOptionsFrame.Label:Hide()
		GameMenuFrame.NewOptionsFrame.BGLabel:Hide()
		GameMenuFrame.NewOptionsFrame.Glow:Hide()
	end

	local GameMenuFrameNew = CreateFrame("Frame", nil, GameMenuFrame)
	GameMenuFrameNew:Size(162, 296)
	GameMenuFrameNew:Point("CENTER", GameMenuFrame, 0, -6)
	GameMenuFrameNew:CreateBackdrop()
	GameMenuFrameNew:CreateShadow()

	hooksecurefunc(_G.GameMenuFrame, "InitButtons", function(self)
		if not (self.buttonPool) then 
			return 
		end

		for Button in self.buttonPool:EnumerateActive() do
			Button:Size(144, 22)
			Button:HandleButton()
			Button.Backdrop:SetInside(Button, 1, 1)
			Button.BorderBackdrop:SetInside(Button, 1, 1)

			Button:GetFontString():SetFontTemplate("Default")
			Button:GetFontString():SetTextColor(0.8, 0.8, 0.8)
		end
	end)

	self.IsSkinned = true
end

function GameMenu:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end

	self:Skin()
end