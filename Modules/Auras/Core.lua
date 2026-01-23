local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Auras = UI:RegisterModule("Auras")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex
local GetAuraApplicationDisplayCount = _G.C_UnitAuras.GetAuraApplicationDisplayCount

-- Locals
Auras.SortMethod = "TIME"
Auras.SortDirection = "+"
Auras.Headers = {}
Auras.HeadersName = ""

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
        self.Count:SetText(GetAuraApplicationDisplayCount(Unit, AuraData.auraInstanceID, AuraMinCount, AuraMaxCount))
   	end

   	if (self.Icon) then
		self.Icon:SetTexture(AuraData.icon)
		UI:KeepAspectRatio(self, self.Icon)
	end

	if (self.Cooldown) then
		if (C_StringUtil.TruncateWhenZero(AuraData.duration)) then
			self.Cooldown:SetCooldown(AuraData.duration, AuraData.expirationTime) 
			self.Cooldown:SetCooldownFromExpirationTime(AuraData.expirationTime, AuraData.duration)

			UI:RegisterCooldown(self.Cooldown, self.InvisFrame, 0, -8, false, true)
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

	self.Unit = Unit
	self.AuraInstanceID = AuraData.auraInstanceID
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

		self.TempEnchHighlight:Show()
	else
		self:SetAlpha(0)
		self.TempEnchHighlight:Hide()
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
	_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 6, -6)

	if (self:GetAttribute("index")) then
		_G.GameTooltip:SetUnitAuraByAuraInstanceID(self.Unit, self.AuraInstanceID)
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
	Count:Point("TOPRIGHT", self, 2, 2)
	Count:SetFontTemplate("Default")

	local Cooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
	Cooldown:SetInside()
	Cooldown:SetDrawEdge(false)
	Cooldown:SetSwipeColor(0, 0, 0, 0)

	local TempEnchHighlight = self:CreateTexture(nil, "OVERLAY")
	TempEnchHighlight:SetBlendMode("ADD")
	TempEnchHighlight:SetInside(self, 1, 1)
	TempEnchHighlight:SetTexture(Media.Global.Blank)
	TempEnchHighlight:SetVertexColor(0.64, 0.19, 0.79, 0.5)
	TempEnchHighlight:Hide()

	-- Style Buttons
	if (self:GetParent():GetAttribute("filter") == "HARMFUL") then
		self:SetTemplate(true)
	else
		self:SetTemplate()
	end

	self:CreateShadow()
	self:SetShadowOverlay()
	self:StyleButton()

	-- Set Scripts
	self:SetScript("OnAttributeChanged", Auras.OnAttributeChanged)
	self:SetScript("OnEnter", Auras.OnEnter)
	self:SetScript("OnLeave", Auras.OnLeave)

	-- Cache
	self.InvisFrame = InvisFrame
	self.Icon = Icon
	self.Duration = Duration
	self.Count = Count
	self.Cooldown = Cooldown
	self.TempEnchHighlight = TempEnchHighlight
	self.Filter = self:GetParent():GetAttribute("filter")
end

function Auras:UpdateHeader(Header)
	local ButtonWidth, ButtonHeight = unpack(DB.Global.Auras.ButtonSize)

	Header:SetAttribute("template", "FeelUIAuraTemplate")
	Header:SetAttribute("weaponTemplate", Header.Filter == "HELPFUL" and "FeelUIAuraTemplate" or nil)
	Header:SetAttribute("minHeight", UI:Scale(ButtonHeight))
	Header:SetAttribute("minWidth", UI:Scale(DB.Global.Auras.ButtonPerRow * ButtonWidth))
	Header:SetAttribute("xOffset", -UI:Scale(ButtonWidth + DB.Global.Auras.ButtonSpacing))
	Header:SetAttribute("yOffset", 0)
	Header:SetAttribute("wrapXOffset", 0)
	Header:SetAttribute("wrapYOffset", -UI:Scale(28))
	Header:SetAttribute("maxWraps", 3)
	Header:SetAttribute("wrapAfter", DB.Global.Auras.ButtonPerRow)
	Header:SetAttribute("sortMethod", Auras.SortMethod)
	Header:SetAttribute("sortDirection", Auras.SortDirection)
	Header:SetAttribute("point", "TOPRIGHT")
	Header:Show()
end

function Auras:CreateAuraHeader(Filter)
	local Name = Filter == "HELPFUL" and "FeelUIPlayerBuffs" or "FeelUIPlayerDebuffs"
	local ButtonWidth, ButtonHeight = unpack(DB.Global.Auras.ButtonSize)

	local Header = CreateFrame("Frame", Name, _G.UIParent, "SecureAuraHeaderTemplate")
	Header:UnregisterEvent("UNIT_AURA")
	Header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
	Header:SetAttribute("unit", "player")
	Header:SetAttribute("filter", Filter)
	Header.Filter = Filter

    Header:SetAttribute("config-width", UI:Scale(ButtonWidth))
    Header:SetAttribute("config-height", UI:Scale(ButtonHeight))
    Header:SetAttribute("initialConfigFunction", [[
        local button = self
        local width = button:GetParent():GetAttribute("config-width")
        local height = button:GetParent():GetAttribute("config-height")
        button:SetWidth(width)
        button:SetHeight(height)
    ]])

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
	self.BuffFrame:Point(unpack(DB.Global.Auras.AuraPoint))

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