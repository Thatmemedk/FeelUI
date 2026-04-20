local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local GameMenu = UI:RegisterModule("GameMenu")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Locals
local GameMenuFrame = _G.GameMenuFrame

function GameMenu:UpdateButtonState(Frame, State)
	if (not Frame.Backdrop) then
		return
	end

	local R, G, B

	if (State == "OnEnter") then
		R, G, B = unpack(UI.GetClassColors)

		UI:CreatePulse(Frame.PulseGlow)
		Frame.PulseGlow:SetBackdropBorderColor(R, G, B, 0.8)

		Frame.HighlightTexture:SetVertexColor(R, G, B, 0.25)
		Frame.HighlightTexture:Show()
	elseif (State == "OnLeave") then
		R, G, B = unpack(DB.Global.General.BorderColor)

		Frame.PulseGlow:SetScript("OnUpdate", nil)
		Frame.PulseGlow:SetBackdropBorderColor(0, 0, 0, 0)

		Frame.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		Frame.HighlightTexture:Hide()
	elseif (State == "OnDisable") then
		R, G, B = 0.3, 0.3, 0.3

		Frame.PulseGlow:SetScript("OnUpdate", nil)
		Frame.PulseGlow:SetBackdropBorderColor(0, 0, 0, 0)

		Frame.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		Frame.HighlightTexture:Hide()
	else
		R, G, B = unpack(DB.Global.General.BorderColor)

		Frame.PulseGlow:SetScript("OnUpdate", nil)
		Frame.PulseGlow:SetBackdropBorderColor(0, 0, 0, 0)

		Frame.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		Frame.HighlightTexture:Hide()
	end

	Frame.Backdrop:SetColorTemplate(R, G, B)
end

function GameMenu:OnButtonEnter()
	if (self.IsEnabled and self:IsEnabled()) then
		GameMenu:UpdateButtonState(self, "OnEnter")
	end
end

function GameMenu:OnButtonLeave()
	if (self.IsEnabled and self:IsEnabled()) then
		GameMenu:UpdateButtonState(self, "OnLeave")
	end
end

function GameMenu:OnButtonDisable()
	if (self.IsMouseOver and self:IsMouseOver()) then
		GameMenu:UpdateButtonState(self, "OnDisable")
	end
end

local function RegisterButtonHooks(Button, Script)
	if (Script == "OnEnter") then
		Button:HookScript("OnEnter", GameMenu.OnButtonEnter)
	elseif (Script == "OnLeave") then
		Button:HookScript("OnLeave", GameMenu.OnButtonLeave)
	elseif (Script == "OnDisable") then
		Button:HookScript("OnDisable", GameMenu.OnButtonDisable)
	end
end

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
	GameMenuFrameNew:Point("CENTER", GameMenuFrame, 0, -7)
	GameMenuFrameNew:CreateBackdrop()
	GameMenuFrameNew:CreateShadow()

	hooksecurefunc(_G.GameMenuFrame, "InitButtons", function(self)
		if (not self.buttonPool) then 
			return 
		end

		for Button in self.buttonPool:EnumerateActive() do
			if (not Button.IsSkinned) then
				Button:Size(144, 22)
				Button:HandleButton()
				Button.Backdrop:SetInside(Button, 1, 1)
				Button.BorderBackdrop:SetInside(Button, 1, 1)
				Button:GetFontString():SetFontTemplate("Default")
				Button:GetFontString():SetTextColor(1, 1, 1, 0.8)

				Button.IsSkinned = true
			end

			hooksecurefunc(Button, "SetScript", RegisterButtonHooks)
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