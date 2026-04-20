local UI, DB, Media = select(2, ...):Call()

-- Call Modules
local PA = UI:RegisterModule("PrivateAuras")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local MAX_PRIVATE_AURAS = 5
local AddPrivateAuraAnchor = _G.C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = _G.C_UnitAuras.RemovePrivateAuraAnchor

-- Locals
PA.Icons = {}

function PA:Create()
	local Frame = CreateFrame("Frame", "FeelUI_PrivateAuras", _G.UIParent)
	Frame:Size(200, 40)
	Frame:Point("CENTER", _G.UIParent, 0, 120)

	for i = 1, MAX_PRIVATE_AURAS do
		local IconFrame = CreateFrame("Frame", nil, Frame)
		IconFrame:Size(42, 42)

		if (i == 1) then
			IconFrame:Point("LEFT", Frame, "LEFT", 0, 0)
		else
			IconFrame:Point("LEFT", self.Icons[i - 1], "RIGHT", 6, 0)
		end

		self.Icons[i] = IconFrame
	end

	self.Frame = Frame
end

function PA:CreateAnchor(IconFrame, Index)
	local Anchor = {
		unitToken = "player",
		auraIndex = Index,
		parent = IconFrame,
		showCountdownFrame = true,
		showCountdownNumbers = true,

		iconInfo = {
			iconWidth = IconFrame:GetWidth(),
			iconHeight = IconFrame:GetHeight(),
			borderScale = 1,

			iconAnchor = {
				point = "CENTER",
				relativeTo = IconFrame,
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = 0,
			},
		},

		durationAnchor = {
			point = "CENTER",
			relativeTo = IconFrame,
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = -8,
		},
	}

	return AddPrivateAuraAnchor(Anchor)
end

function PA:CreateAnchors()
	for i = 1, MAX_PRIVATE_AURAS do
		local IconFrame = self.Icons[i]

		if (IconFrame.AnchorID) then
			RemovePrivateAuraAnchor(IconFrame.AnchorID)
		end

		IconFrame.AnchorID = self:CreateAnchor(IconFrame, i)
	end
end

function PA:RemoveAnchors()
	for i = 1, MAX_PRIVATE_AURAS do
		local IconFrame = self.Icons[i]

		if (IconFrame.AnchorID) then
			RemovePrivateAuraAnchor(IconFrame.AnchorID)
			IconFrame.AnchorID = nil
		end
	end
end

function PA:Update()
	self:RemoveAnchors()
	self:CreateAnchors()
end

function PA:Initialize()
	if (not DB.Global.PrivateAuras.Enable) then 
		return 
	end

	self:Create()
	self:Update()
end