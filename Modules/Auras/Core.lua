local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Auras = UI:RegisterModule("Auras")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local DebuffTypeColor = DebuffTypeColor
local GetInventoryItemTexture = GetInventoryItemTexture
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

-- Locals
Auras.SortMethod = "TIME"
Auras.SortDirection = "+"
Auras.Headers = {}
Auras.HeadersName = ""

Auras.AttributeInitialConfig = [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("config-width"))
	self:SetHeight(header:GetAttribute("config-height"))
]]

function Auras:DisableBlizzardAuras()
	_G.BuffFrame:Kill()
	_G.BuffFrame.numHideableBuffs = 0

	if (_G.DebuffFrame) then
		_G.DebuffFrame:Kill()
	end
end

function Auras:OnUpdate(elapsed)
	local TimeLeft

	if (self.Enchant) then	
		local Expiration = select(self.Enchant, GetWeaponEnchantInfo())

		if (Expiration) then
			TimeLeft = Expiration / 1e3
		else
			TimeLeft = 0
		end
	else
		TimeLeft = self.TimeLeft - elapsed
	end

	self.TimeLeft = TimeLeft

	if (TimeLeft <= 0) then
		self.TimeLeft = nil
		self.Duration:SetText("")

		return self:SetScript("OnUpdate", nil)
	else		
		if (10 > self.TimeLeft) then
			self.Duration:SetVertexColor(unpack(DB.Global.CooldownFrame.ExpireColor))
		elseif (30 > self.TimeLeft) then	
			self.Duration:SetVertexColor(unpack(DB.Global.CooldownFrame.SecondsColor))
		elseif (60 > self.TimeLeft) then
			self.Duration:SetVertexColor(unpack(DB.Global.CooldownFrame.SecondsColor2))
		else 
			self.Duration:SetVertexColor(unpack(DB.Global.CooldownFrame.NormalColor))
		end
		
		local Text = UI:FormatTimeShort(self.TimeLeft)
		self.Duration:SetText(Text)
	end
end

function Auras:UpdateAura(Index)
	local Unit = self:GetParent():GetAttribute("unit")
	local AuraData = GetAuraDataByIndex(Unit, Index, self.Filter)
	
	if (not AuraData or not AuraData.name) then 
		return 
	end

    local AuraMinCount = 2
    local AuraMaxCount = 99

	if (self.Count) then
        self.Count:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(Unit, AuraData.auraInstanceID, AuraMinCount, AuraMaxCount))
   	end

   	if (self.Icon) then
		self.Icon:SetTexture(AuraData.icon)
		UI:KeepAspectRatio(self, self.Icon)
	end

	if (self.Cooldown) then
		if (C_StringUtil.TruncateWhenZero(AuraData.duration)) then
			self.Cooldown:SetCooldown(AuraData.duration, AuraData.expirationTime) 
			self.Cooldown:SetCooldownFromExpirationTime(AuraData.expirationTime, AuraData.duration)

			for i = 1, self.Cooldown:GetNumRegions() do
				local Region = select(i, self.Cooldown:GetRegions())

				if (Region and Region.GetText) then
					Region:ClearAllPoints()
					Region:Point("CENTER", self.InvisFrame, 0, -8)
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
		self.Cooldown:Hide()
	end

	if (self.Filter == "HARMFUL") then
		local Color = C_UnitAuras.GetAuraDispelTypeColor(Unit, AuraData.auraInstanceID, UI.DispelColorCurve)

		if (Color) then
			self:SetColorTemplate(Color.r, Color.g, Color.b)
		else
			self:SetColorTemplate(unpack(DB.Global.General.BorderColor))
		end
	end
end

function Auras:UpdateTempEnchant(Index)
	local Enchant = (Index == 16 and 2) or 6
	local Expiration = select(Enchant, GetWeaponEnchantInfo())
	local Icon = GetInventoryItemTexture("player", Index)

	if (Expiration) then
		self.Enchant = Enchant
		self:SetScript("OnUpdate", Auras.OnUpdate)
	else
		self.Enchant = nil
		self.TimeLeft = nil
		self:SetScript("OnUpdate", nil)
	end

	if (Icon) then
		self:SetAlpha(1)

		if (self.Icon) then
			self.Icon:SetTexture(Icon)
			UI:KeepAspectRatio(self, self.Icon)
		end

		self.TempEnchHighlight:SetVertexColor(0.64, 0.19, 0.79, 0.5)
	else
		self:SetAlpha(0)
		self.TempEnchHighlight:SetVertexColor(0, 0, 0, 0)
	end
end

function Auras:OnAttributeChanged(Attribute, Value)
	if (Attribute == "index") then
		Auras.UpdateAura(self, Value)
	elseif (Attribute == "target-slot") then
		Auras.UpdateTempEnchant(self, Value)
	end
end

function Auras:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 6, -6)

	if (self:GetAttribute("index")) then
		_G.GameTooltip:SetUnitAura(self:GetParent():GetAttribute("unit"), self:GetID(), self.Filter)
	elseif (self:GetAttribute("target-slot")) then
		_G.GameTooltip:SetInventoryItem("player", self:GetID())
	end
end

function Auras:OnLeave()
    _G.GameTooltip_Hide()
end

function Auras:Skin()
	local InvisFrame = CreateFrame("Frame", nil, self)
	InvisFrame:SetFrameLevel(self:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	local Icon = self:CreateTexture(nil, "BORDER")
	Icon:SetInside()

	local Duration = InvisFrame:CreateFontString(nil, "OVERLAY")
	Duration:Point("BOTTOM", self, 2, -4)
	Duration:SetFontTemplate("Default")

	local Count = InvisFrame:CreateFontString(nil, "OVERLAY")
	Count:Point("TOPRIGHT", self, 0, -4)
	Count:SetFontTemplate("Default")

	local Cooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
	Cooldown:SetInside()
	Cooldown:SetDrawEdge(false)
	Cooldown:SetReverse(true)
	Cooldown:SetSwipeColor(0, 0, 0, 0)

	local TempEnchHighlight = self:CreateTexture(nil, "OVERLAY")
	TempEnchHighlight:SetBlendMode("ADD")
	TempEnchHighlight:SetInside(self, 1, 1)
	TempEnchHighlight:SetTexture(Media.Global.Blank)
	TempEnchHighlight:SetVertexColor(0, 0, 0, 0)

	self:Size(unpack(DB.Global.Auras.ButtonSize))
	self:CreateShadow()
	self:StyleButton()
	self:SetShadowOverlay()

	self:SetScript("OnAttributeChanged", Auras.OnAttributeChanged)
	self:SetScript("OnEnter", Auras.OnEnter)
	self:SetScript("OnLeave", Auras.OnLeave)

	self.InvisFrame = InvisFrame
	self.Icon = Icon
	self.Duration = Duration
	self.Count = Count
	self.Cooldown = Cooldown
	self.TempEnchHighlight = TempEnchHighlight
	self.Filter = self:GetParent():GetAttribute("filter")

	if (self.Filter == "HARMFUL") then
		self:SetTemplate(true)
	else
		self:SetTemplate()
	end
end

function Auras:UpdateHeader(Header)
	local ButtonWidth, ButtonHeight = unpack(DB.Global.Auras.ButtonSize)

	Header:SetAttribute("template", "FeelUIAuraTemplate")
	Header:SetAttribute("weaponTemplate", Header.Filter == "HELPFUL" and "FeelUIAuraTemplate" or nil)
	Header:SetAttribute("config-width", UI:Scale(ButtonWidth))
	Header:SetAttribute("config-height", UI:Scale(ButtonHeight))
	Header:SetAttribute("minHeight", UI:Scale(ButtonHeight))
	Header:SetAttribute("minWidth", UI:Scale(DB.Global.Auras.ButtonPerRow * ButtonWidth))
	Header:SetAttribute("xOffset", -UI:Scale(ButtonWidth + DB.Global.Auras.ButtonSpacing))
	Header:SetAttribute("yOffset", 0)
	Header:SetAttribute("wrapXOffset", 0)
	Header:SetAttribute("wrapYOffset", -UI:Scale(42))
	Header:SetAttribute("maxWraps", 3)
	Header:SetAttribute("wrapAfter", DB.Global.Auras.ButtonPerRow)
	Header:SetAttribute("sortMethod", Auras.SortMethod)
	Header:SetAttribute("sortDirection", Auras.SortDirection)
	Header:SetAttribute("point", "TOPRIGHT")
	Header:SetAttribute("initialConfigFunction", Auras.AttributeInitialConfig)
	Header:Show()
end

function Auras:CreateAuraHeader(Filter)
	local Name = Filter == "HELPFUL" and "FeelUIPlayerBuffs" or "FeelUIPlayerDebuffs"

	local Header = CreateFrame("Frame", Name, _G.UIParent, "SecureAuraHeaderTemplate")
	Header:SetAttribute("unit", "player")
	Header:SetAttribute("filter", Filter)
	Header.Filter = Filter

	RegisterStateDriver(Header, "visibility", "[petbattle] hide; show")
	RegisterAttributeDriver(Header, "unit", "[vehicleui] vehicle; player")

	if (Filter == "HELPFUL") then
		Header:SetAttribute("consolidateDuration", -1)
		Header:SetAttribute("includeWeapons", 1)
	end

	-- Update Header
	self:UpdateHeader(Header)

	return Header
end

function Auras:CreateAuras()
	self.BuffFrame = self:CreateAuraHeader("HELPFUL")
	self.BuffFrame:Point("TOPRIGHT", _G.UIParent, -188, -6)

	self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
	self.DebuffFrame:Point("TOPRIGHT", self.BuffFrame, 0, -42*3)
end

function Auras:HeadersUpdate()
	for _, Header in next, Auras.Headers do
		local Child = Header:GetAttribute("child1")
		local i = 1

		while Child do
			Auras.UpdateAura(Child, Child:GetID())
			i = i + 1
			Child = Header:GetAttribute("child"..i)
		end
	end
end

function Auras:Initialize()
	if (not DB.Global.Auras.Enable) then 
		return 
	end

	self:DisableBlizzardAuras()
	self:CreateAuras()
	self:HeadersUpdate()
end