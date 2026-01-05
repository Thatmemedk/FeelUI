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

-- WoW Globals
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

function Auras:Skin(Frame, ExtraBorder, AuraData, IsDebuff)
	if (Frame.isAuraAnchor or not Frame.Icon or not AuraData) then
		return
	end

	if (not Frame.AurasIsSkinned) then
		Frame:Size(unpack(DB.Global.Auras.ButtonSize))
		Frame:SetTemplate(ExtraBorder)
		Frame:CreateShadow()
		Frame:StyleButton()
		Frame:SetShadowOverlay()

		Frame.InvisFrame = CreateFrame("Frame", nil, Frame)
		Frame.InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
		Frame.InvisFrame:SetInside()

		Frame.Cooldown = CreateFrame("Cooldown", nil, Frame, "CooldownFrameTemplate")
		Frame.Cooldown:SetInside()
		Frame.Cooldown:SetDrawEdge(false)
		Frame.Cooldown:SetReverse(true)
		Frame.Cooldown:SetSwipeColor(0, 0, 0, 0)

		if (Frame.Duration) then
			Frame.Duration:SetAlpha(0)
		end

		if (Frame.Count) then
			Frame.Count:SetParent(Frame.InvisFrame)
			Frame.Count:ClearAllPoints()
			Frame.Count:Point("TOPRIGHT", Frame, 2, 2)
			Frame.Count:SetFontTemplate("Default")
		end

		if (Frame.Icon) then
			Frame.Icon:SetInside()
			UI:KeepAspectRatio(Frame, Frame.Icon)
		end

		if (Frame.TempEnchantBorder) then
			Frame.TempEnchantBorder:SetInside()
			Frame.TempEnchantBorder:SetTexture(Media.Global.Blank)
			Frame.TempEnchantBorder:SetVertexColor(0.64, 0.19, 0.79, 0.5)
		end

		if (Frame.DebuffBorder) then
			Frame.DebuffBorder:SetAlpha(0)
		end

		Frame.AurasIsSkinned = true
	end

	if (IsDebuff) then
		local Color = C_UnitAuras.GetAuraDispelTypeColor("player", AuraData.auraInstanceID, UI.DispelColorCurve)

		if (Color) then
			Frame:SetColorTemplate(Color.r, Color.g, Color.b)
		else
			Frame:SetColorTemplate(unpack(DB.Global.General.BorderColor))
		end
	end

	if (Frame.Cooldown) then
		if (C_StringUtil.TruncateWhenZero(AuraData.duration)) then
			Frame.Cooldown:SetCooldown(AuraData.duration, AuraData.expirationTime) 
			Frame.Cooldown:SetCooldownFromExpirationTime(AuraData.expirationTime, AuraData.duration)

			for i = 1, Frame.Cooldown:GetNumRegions() do
				local Region = select(i, Frame.Cooldown:GetRegions())

				if (Region and Region.GetText) then
					Region:ClearAllPoints()
					Region:Point("CENTER", Frame.InvisFrame, 0, -8)
					Region:SetFontTemplate("Default")

					local Curve = C_CurveUtil.CreateColorCurve()
					Curve:SetType(Enum.LuaCurveType.Step)
					Curve:AddPoint(0,  CreateColor(unpack(DB.Global.CooldownFrame.ExpireColor)))
					Curve:AddPoint(9,  CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor)))
					Curve:AddPoint(29, CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor2)))
					Curve:AddPoint(59, CreateColor(unpack(DB.Global.CooldownFrame.NormalColor)))

					local AuraDuration = C_UnitAuras.GetAuraDuration("player", AuraData.auraInstanceID)
					local EvaluateDuration = AuraDuration:EvaluateRemainingDuration(Curve)
					Region:SetVertexColor(EvaluateDuration:GetRGBA())
				end
			end
		end
	else
		Frame.Cooldown:Hide()
	end
end

function Auras:UpdateBuffs(Frame, Index)
	local Previous

	if (Frame.isAuraAnchor or not Frame.Icon) then
		return
	end

	Frame:ClearAllPoints()

	if (Index == 1) then
		Frame:Point("TOPRIGHT", self.AuraHolder, "TOPRIGHT", 0, -12)
	elseif (Index - 1) % DB.Global.Auras.ButtonPerRow == 0 then
		Frame:Point("TOPRIGHT", BuffFrameAuraFrames[Index - DB.Global.Auras.ButtonPerRow], "BOTTOMRIGHT", 0, -DB.Global.Auras.ButtonRowSpacing)
	else
		Frame:Point("RIGHT", BuffFrameAuraFrames[Index - 1], "LEFT", -DB.Global.Auras.ButtonSpacing, 0)
	end

	local AuraData = GetAuraDataByIndex("player", Index, "HELPFUL")
	self:Skin(Frame, nil, AuraData, false)

	Previous = Frame
end

function Auras:UpdateDebuffs(Frame, Index)
	local Previous

	if (Frame.isAuraAnchor or not Frame.Icon) then
		return
	end

	Frame:ClearAllPoints()

	if (Index == 1) then
		Frame:Point("TOPRIGHT", self.AuraHolder, "TOPRIGHT", 0, -12)
	elseif (Index - 1) % DB.Global.Auras.ButtonPerRow == 0 then
		Frame:Point("TOPRIGHT", BuffFrameAuraFrames[Index - DB.Global.Auras.ButtonPerRow], "BOTTOMRIGHT", 0, -DB.Global.Auras.ButtonRowSpacing)
	else
		Frame:Point("RIGHT", BuffFrameAuraFrames[Index - 1], "LEFT", -DB.Global.Auras.ButtonSpacing, 0)
	end

	local AuraData = GetAuraDataByIndex("player", Index, "HARMFUL")
	self:Skin(Frame, true, AuraData, true)

	Previous = Frame
end

function Auras:StyleBuffs()
	if (not BuffFrameAuraFrames) then 
		return 
	end

	for Index, Frame in ipairs(BuffFrameAuraFrames) do
		Auras:UpdateBuffs(Frame, Index)
	end
end

function Auras:StyleDebuffs()
	if (not DebuffFrameAuraFrames) then 
		return 
	end

	for Index, Frame in ipairs(DebuffFrameAuraFrames) do
		Auras:UpdateDebuffs(Frame, Index)
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

	for _, func in ipairs(EditModeFuncs) do
		if (type(EditModeManager[func]) == "function") then
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