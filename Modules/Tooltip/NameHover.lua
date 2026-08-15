local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local TT = UI:CallModule("Tooltip")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitCanAttack = UnitCanAttack
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsTapDenied  = UnitIsTapDenied
local UnitReaction = UnitReaction
local GetMouseFocus = GetMouseFocus
local UnitExists = UnitExists
local GetCursorPosition = GetCursorPosition
local InCombatLockdown = InCombatLockdown
local UnitOnTaxi = UnitOnTaxi
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitName = UnitName

function TT:GetMouseOverColors()
	local UnitIsPlayer = UnitIsPlayer("mouseover")
	local _, Class = UnitClass("mouseover")
	local UnitCanAttack = UnitCanAttack("player", "mouseover")
	local UnitIsDead = UnitIsDead("mouseover")
	local UnitIsGhost = UnitIsGhost("mouseover")
	local UnitIsTapDenied = UnitIsTapDenied("mouseover")
	local UnitReaction = UnitReaction("mouseover", "player")

	if (UnitIsPlayer) then
		local Color = UI.Colors.Class[Class]
		return unpack(Color)
	elseif (UnitCanAttack) then
		if (UnitIsDead or UnitIsGhost or UnitIsTapDenied) then
			return 0.5, 0.5, 0.5
		else
			if (UnitReaction) then
				local Color = UI.Colors.Reaction[UnitReaction]
				return unpack(Color)
			end
		end
	else
		if (UnitReaction) then
			local Color = UI.Colors.Reaction[UnitReaction]
			return unpack(Color)
		end
	end

    return 1, 1, 1
end

function TT:NameHoverOnUpdate()
	local GMF = UI:GetMouseFocus()
	local UnitExists = UnitExists("mouseover")
	local X, Y = GetCursorPosition()
	
	if (GMF and GMF:IsForbidden()) then
		self.Frame:Hide()
		return
	end
	
	if (GMF and GMF:GetName() ~= "WorldFrame") then
		self.Frame:Hide()
		return
	end
	
	if not (UnitExists) then
		self.Frame:Hide()
		return
	end
	
	self.Text:Point("CENTER", _G.UIParent, "BOTTOMLEFT", X + 12, Y + 12)
end

function TT:NameHoverOnEvent()
	local GMF = UI:GetMouseFocus()
	local UnitName = UnitName("mouseover")

	if (GMF and GMF:IsForbidden()) then
		self.Frame:Hide()
		return
	end
	
	if (GMF and GMF:GetName() ~= "WorldFrame") then
		self.Frame:Hide()
		return
	end
	
	if InCombatLockdown() then
		self.Frame:Hide()
		return
	end
	
	if (UnitOnTaxi("player", "mouseover") or UnitIsAFK("player", "mouseover")) then
		self.Frame:Hide()
		return
	end
	
	self.Text:SetTextColor(self:GetMouseOverColors())
	
	if (UnitIsAFK("mouseover")) then
		self.Text:SetText("|CFF559655" .. CHAT_FLAG_AFK .. "|r " .. UnitName)
	elseif (UnitIsDND("mouseover")) then
		self.Text:SetText("|CFF559655" .. CHAT_FLAG_DND .. "|r " .. UnitName)
	else
		self.Text:SetText(UnitName)
	end
	
	self.Frame:Show()
end

function TT:CreateNameHover()
	local Frame = CreateFrame("Frame")
	Frame:SetFrameStrata("TOOLTIP")
	Frame:Hide()
	
	local Text = Frame:CreateFontString(nil, "OVERLAY")
	Text:SetFontTemplate("Default")
	
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:SetScript("OnEvent", self.NameHoverOnEvent)
	self:SetScript("OnUpdate", self.NameHoverOnUpdate)
	
	self.Frame = Frame
	self.Text = Text
end

function TT:EnableNameHover()
	if (not DB.Global.Tooltip.NameHoverTooltipMod) then
		return
	end
	
	TT:CreateNameHover()
end