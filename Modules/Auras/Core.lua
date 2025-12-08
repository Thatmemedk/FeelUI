-- CREDITS: Unhalted

local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Auras = UI:RegisterModule("Auras")

-- Lib Globals
local _G = _G
local unpack = unpack

-- WoW Globals
local BuffFrame = _G.BuffFrame
local DebuffFrame = _G.DebuffFrame
local BuffFrameAuraFrames = _G.BuffFrame.auraFrames
local DebuffFrameAuraFrames = _G.DebuffFrame.auraFrames
local BuffCollapseAndExpandButton = _G.BuffFrame.CollapseAndExpandButton
local EditModeManager = _G.EditModeManager

function Auras:Skin(Frame)
	if (Frame.isAuraAnchor or not Frame.Icon) then
		return 
	end

	if (Frame.AurasIsSkinned) then
		return
	end

	Frame:Size(unpack(DB.Global.Auras.ButtonSize))
	Frame:SetTemplate()
	Frame:CreateShadow()
	Frame:StyleButton()
	Frame:SetShadowOverlay()
	Frame:CreateGlow(4, 3, 0, 0, 0, 0)
	
	Frame.InvisFrame = CreateFrame("Frame", nil, Frame)
	Frame.InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
	Frame.InvisFrame:SetInside()

	if (Frame.Duration) then
		Frame.Duration:SetParent(Frame.InvisFrame)
		Frame.Duration:ClearAllPoints()
		Frame.Duration:Point("BOTTOM", Frame, 2, -6)
		Frame.Duration:SetFontTemplate("Default")
	end
	
	if (Frame.Count) then
		Frame.Count:SetParent(Frame.InvisFrame)
		Frame.Count:ClearAllPoints()
		Frame.Count:Point("TOPRIGHT", Frame, 0, -2)
		Frame.Count:SetFontTemplate("Default")
	end
	
	--if (Frame.Icon) then
		--Frame.Icon:SetInside()
		--UI:KeepAspectRatio(Frame, Frame.Icon)
	--end

	if (Frame.TempEnchantBorder) then
		Frame.TempEnchantBorder:ClearAllPoints()
		Frame.TempEnchantBorder:SetInside()
		Frame.TempEnchantBorder:SetTexture(Media.Global.Blank)
		Frame.TempEnchantBorder:SetVertexColor(0.64, 0.19, 0.79, 0.5)
	end

	if (Frame.DebuffBorder) then
		Frame.DebuffBorder:SetAlpha(0)
	end

	Frame.AurasIsSkinned = true
end

function Auras:AnchorBuffs(Frame, Index)
	local Previous

	if (Frame.isAuraAnchor or not Frame.Icon) then
		return
	end

	-- Update ButtonSize here too.
	Frame:Size(unpack(DB.Global.Auras.ButtonSize))
	Frame:ClearAllPoints()

	if (Index == 1) then
		Frame:Point("TOPRIGHT", self.AuraHolder, "TOPRIGHT", 0, -12)
	elseif (Index - 1) % DB.Global.Auras.ButtonPerRow == 0 then
		Frame:Point("TOPRIGHT", BuffFrameAuraFrames[Index - DB.Global.Auras.ButtonPerRow], "BOTTOMRIGHT", 0, -DB.Global.Auras.ButtonRowSpacing)
	else
		Frame:Point("RIGHT", BuffFrameAuraFrames[Index - 1], "LEFT", -DB.Global.Auras.ButtonSpacing, 0)
	end

	-- Update Duration and Count here too.
	if (Frame.Duration) then
		Frame.Duration:SetParent(Frame.InvisFrame)
		Frame.Duration:ClearAllPoints()
		Frame.Duration:Point("BOTTOM", Frame, 2, -6)
		Frame.Duration:SetFontTemplate("Default")
	end
	
	if (Frame.Count) then
		Frame.Count:SetParent(Frame.InvisFrame)
		Frame.Count:ClearAllPoints()
		Frame.Count:Point("TOPRIGHT", Frame, 0, -2)
		Frame.Count:SetFontTemplate("Default")
	end

	-- Update KeepAspectRatio here too.
	if (Frame.Icon) then
		Frame.Icon:SetInside()
		UI:KeepAspectRatio(Frame, Frame.Icon)
	end

	Previous = Frame
end

function Auras:AnchorDebuffs(Frame, Index)
	local Previous

	if (Frame.isAuraAnchor or not Frame.Icon) then
		return
	end

	-- Update ButtonSize here too.
	Frame:Size(unpack(DB.Global.Auras.ButtonSize))
	Frame:ClearAllPoints()

	if (Index == 1) then
		Frame:Point("TOPRIGHT", self.AuraHolder, "TOPRIGHT", 0, -158)
	elseif (Index - 1) % DB.Global.Auras.ButtonPerRow == 0 then
		Frame:Point("TOPRIGHT", DebuffFrameAuraFrames[Index - DB.Global.Auras.ButtonPerRow], "BOTTOMRIGHT", 0, -DB.Global.Auras.ButtonRowSpacing)
	else
		Frame:Point("RIGHT", DebuffFrameAuraFrames[Index - 1], "LEFT", -DB.Global.Auras.ButtonSpacing, 0)
	end

	-- Update Duration and Count here too.
	if (Frame.Duration) then
		Frame.Duration:SetParent(Frame.InvisFrame)
		Frame.Duration:ClearAllPoints()
		Frame.Duration:Point("BOTTOM", Frame, 2, -6)
		Frame.Duration:SetFontTemplate("Default")
	end
	
	if (Frame.Count) then
		Frame.Count:SetParent(Frame.InvisFrame)
		Frame.Count:ClearAllPoints()
		Frame.Count:Point("TOPRIGHT", Frame, 0, -2)
		Frame.Count:SetFontTemplate("Default")
	end

	-- Update KeepAspectRatio here too.
	if (Frame.Icon) then
		Frame.Icon:SetInside()
		UI:KeepAspectRatio(Frame, Frame.Icon)
	end

	-- Update Debuff Border
	if (Frame.DebuffBorder) then
		Frame.DebuffBorder:SetAlpha(0)

		local R, G, B = Frame.DebuffBorder:GetVertexColor()
		Frame:SetColorTemplate(R, G, B)
		Frame.Glow:SetBackdropBorderColor(R, G, B, 0.8)
	else
		Frame:SetColorTemplate(unpack(DB.Global.General.BorderColor))
		Frame.Glow:SetBackdropBorderColor(0, 0, 0, 0)
	end

	Previous = Frame
end

function Auras:StyleBuffs()
	if not BuffFrameAuraFrames then 
		return 
	end

	for Index, Frame in ipairs(BuffFrameAuraFrames) do
		Auras:Skin(Frame)
		Auras:AnchorBuffs(Frame, Index)
	end
end

function Auras:StyleDebuffs()
	if not DebuffFrameAuraFrames then 
		return 
	end

	for Index, Frame in ipairs(DebuffFrameAuraFrames) do
		Auras:Skin(Frame)
		Auras:AnchorDebuffs(Frame, Index)
	end
end

function Auras:UpdateAuras()
	hooksecurefunc(BuffFrame, "Update", function()
		self:StyleBuffs()
	end)

	hooksecurefunc(DebuffFrame, "Update", function()
		self:StyleDebuffs()
	end)
end

function Auras:UpdateEditMode()
	self:StyleBuffs()
	self:StyleDebuffs()
end

function Auras:RegisterEditMode()
	if not (EditModeManager) then
		self:RegisterEvent("PLAYER_LOGIN")
		self:SetScript("OnEvent", function()
			self:UnregisterEvent("PLAYER_LOGIN")
			self:UpdateEditMode()
		end)

		return
	end

	if (EditModeManager.OnEditModeEnter) then
		hooksecurefunc(EM, "OnEditModeEnter", function()
			self:UpdateEditMode()
		end)
	end

	if (EditModeManager.OnEditModeExit) then
		hooksecurefunc(EM, "OnEditModeExit", function()
			self:UpdateEditMode()
		end)
	end

	local EditModeFuncs = { 
		"Refresh", 
		"RefreshAll", 
		"RefreshEditMode", 
		"OnEditModeStateChanged" 
	}

	for _, func in ipairs(tryFuncs) do
		if (type(EditModeManager[EditModeFuncs]) == "function") then
			hooksecurefunc(EditModeManager, func, function()
				self:UpdateEditMode()
			end)
		end
	end

	if (EditModeManager.RegisterCallback) then
		pcall(function()
			EditModeManager:RegisterCallback("EditMode.Enter", function() 
				self:UpdateEditMode() 
			end)

			EditModeManager:RegisterCallback("EditMode.Exit", function() 
				self:UpdateEditMode() 
			end)
		end)
	end
end

function Auras:CreateContainer()
	local AuraHolder = CreateFrame("Frame", "FeelUI_AuraContainer", _G.UIParent)
	AuraHolder:Size(200, 200)
	AuraHolder:Point(unpack(DB.Global.Auras.AuraPoint))

	self.AuraHolder = AuraHolder
end

function Auras:ExpandButtonHide()
	BuffCollapseAndExpandButton:SetAlpha(0)
	BuffCollapseAndExpandButton:SetScript("OnClick", nil)
end

function Auras:Initialize()
	if (not DB.Global.Auras.Enable) then
		return
	end

	self:CreateContainer()
	self:UpdateAuras()
	self:ExpandButtonHide()
	self:UpdateEditMode()
	self:RegisterEditMode()
end
