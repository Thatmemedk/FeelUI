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
	GameMenuFrame:ClearAllPoints()
	GameMenuFrame:Point("CENTER", _G.UIParent, 0, 52)

	if not (GameMenuFrame.IsSkinned) then
		GameMenuFrame.Border:StripTexture()
		GameMenuFrame.NewOptionsFrame.Label:Hide()
		GameMenuFrame.NewOptionsFrame.BGLabel:Hide()
		GameMenuFrame.NewOptionsFrame.Glow:Hide()

		local GameMenuFrameNew = CreateFrame("Frame", nil, GameMenuFrame)
		GameMenuFrameNew:Size(162, 282)
		GameMenuFrameNew:Point("CENTER", GameMenuFrame, 0, -6)
		GameMenuFrameNew:CreateBackdrop()
		GameMenuFrameNew:CreateShadow()

		local InvisFrame = CreateFrame("Frame", nil, GameMenuFrame)
		InvisFrame:SetFrameLevel(GameMenuFrame:GetFrameLevel() + 10)
		InvisFrame:SetInside()
		
		GameMenuFrame.Header:StripTexture()
		GameMenuFrame.Header:ClearAllPoints()
		GameMenuFrame.Header:SetParent(InvisFrame)
		GameMenuFrame.Header:Point("TOP", InvisFrame, 0, -10)
		GameMenuFrame.Header.Text:SetFontTemplate("Default", 18, 2, 2)
		GameMenuFrame.Header.Text:SetTextColor(R, G, B)

		GameMenuFrame.IsSkinned = true
	end

	hooksecurefunc(_G.GameMenuFrame, "InitButtons", function(self)
		if not (self.buttonPool) then 
			return 
		end

		for Button in self.buttonPool:EnumerateActive() do
			Button:Size(144, 22)
			Button:HandleButton()
			Button.Backdrop:SetInside(Button, 1, 1)
			Button.BorderBackdrop:SetInside(Button, 1, 1)

			local Font = Button.GetFontString and Button:GetFontString()

			if (Font) then
				Font:SetFontTemplate("Default", 12)
				Font:SetTextColor(0.85, 0.85, 0.85)
			end
		end
	end)
end

function GameMenu:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end

	self:Skin()
end