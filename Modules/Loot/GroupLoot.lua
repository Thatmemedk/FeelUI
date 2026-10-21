local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local GroupLoot = UI:RegisterModule("GroupLoot")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local pairs = pairs
local ipairs = ipairs
local math_random = math.random

-- WoW Globals
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local NUM_GROUP_LOOT_FRAMES = 4

-- Locals
GroupLoot.PreviousFrame = {}

function GroupLoot:GetQualityColor(Quality)
	local ColorData = _G.ColorManager and _G.ColorManager.GetColorDataForItemQuality(Quality)
	return ColorData or ITEM_QUALITY_COLORS[Quality]
end

function GroupLoot:TestGroupLootFrames()
	local OriginalGetLootRollItemInfo = _G.GetLootRollItemInfo
	local OriginalGetLootRollTimeLeft = _G.GetLootRollTimeLeft

	_G.GetLootRollItemInfo = function(RollID)
		if (RollID > NUM_GROUP_LOOT_FRAMES) then
			return OriginalGetLootRollItemInfo(RollID)
		end

		local Texture = 135226
		local Name = "Atiesh, Greatstaff of the Guardian"
		local Count = RollID
		local Quality = RollID + 1
		local BindOnPickUp = math_random(0, 1) > 0.5
		local CanNeed = true
		local CanGreed = true
		local CanDisenchant = false
		local ReasonNeed = 0
		local ReasonGreed = 0
		local ReasonDisenchant = 0
		local DeSkillRequired = 0
		local CanTransmog = RollID % 2 == 0 -- show both Greed and Transmog variants

		return Texture, Name, Count, Quality, BindOnPickUp, CanNeed, CanGreed, CanDisenchant, ReasonNeed, ReasonGreed, ReasonDisenchant, DeSkillRequired, CanTransmog
	end

	_G.GetLootRollTimeLeft = function(RollID)
		if (RollID > NUM_GROUP_LOOT_FRAMES) then
			return OriginalGetLootRollTimeLeft(RollID)
		end

		return RollID * 60000
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		_G.GroupLootContainer_AddRoll(i, 300000)
	end
end

function GroupLoot:SkinGroupLoot(Frame)
	if (Frame.LootGroupIsSkinned) then
		return
	end

	local ButtonContainer = Frame.LootButtonContainer

	Frame:StripTexture()
	Frame:Size(242, 84)

	if (Frame.Border) then
		Frame.Border:Kill()
	end

	if (Frame.Timer.Background) then
		Frame.Timer.Background:Kill()
	end

	if (_G[Frame:GetName().."NameFrame"]) then
		_G[Frame:GetName().."NameFrame"]:Kill()
	end

	if (_G[Frame:GetName().."Corner"]) then
		_G[Frame:GetName().."Corner"]:Kill()
	end

	if (Frame.IconFrame.Border and Frame.IconFrame.Border.GetObjectType) then
		Frame.IconFrame.Border:Kill()
	end

	Frame.OverlayContrainerFrame = CreateFrame("Frame", nil, Frame)
	Frame.OverlayContrainerFrame:SetFrameLevel(Frame:GetFrameLevel() -1)
	Frame.OverlayContrainerFrame:Size(242, 28)
	Frame.OverlayContrainerFrame:Point("CENTER", Frame, 0, 0)

	Frame.InvisFrame = CreateFrame("Frame", nil, Frame.OverlayContrainerFrame)
	Frame.InvisFrame:SetFrameLevel(Frame.OverlayContrainerFrame:GetFrameLevel() + 10)
	Frame.InvisFrame:SetInside()

	Frame.IconFrame:SetTemplate()
	Frame.IconFrame:CreateShadow()
	Frame.IconFrame:SetShadowOverlay()
	Frame.IconFrame:Size(38, 28)
	Frame.IconFrame:ClearAllPoints()
	Frame.IconFrame:Point("RIGHT", Frame.OverlayContrainerFrame, "LEFT", -4, 0)

	Frame.IconFrame.Icon:SetInside()
	UI:KeepAspectRatio(Frame.IconFrame, Frame.IconFrame.Icon)

	-- Buttons now live in Frame.LootButtonContainer (Frame.NeedButton etc. no longer exist).
	-- The container is a layout frame, stop it from re-anchoring the buttons behind our back.
	if (ButtonContainer.Layout) then
		ButtonContainer.Layout = function() end
	end

	local PassButton = ButtonContainer.PassButton
	local GreedButton = ButtonContainer.GreedButton
	local TransmogButton = ButtonContainer.TransmogButton
	local NeedButton = ButtonContainer.NeedButton

    PassButton:SetFrameLevel(Frame.OverlayContrainerFrame:GetFrameLevel() + 10)
    PassButton:Size(24, 24)
    PassButton:ClearAllPoints()
    PassButton:Point("RIGHT", Frame.InvisFrame, -6, -12)

    GreedButton:SetFrameLevel(Frame.OverlayContrainerFrame:GetFrameLevel() + 10)
    GreedButton:Size(24, 24)
    GreedButton:ClearAllPoints()
    GreedButton:Point("LEFT", PassButton, -32, 0)

    TransmogButton:SetFrameLevel(Frame.OverlayContrainerFrame:GetFrameLevel() + 10)
    TransmogButton:Size(24, 24)
    TransmogButton:ClearAllPoints()
    TransmogButton:Point("LEFT", PassButton, -32, 0)

    NeedButton:SetFrameLevel(Frame.OverlayContrainerFrame:GetFrameLevel() + 10)
    NeedButton:Size(24, 24)
    NeedButton:ClearAllPoints()
    NeedButton:Point("LEFT", GreedButton, -32, 0)

	Frame.Name:SetParent(Frame.InvisFrame)
	Frame.Name:ClearAllPoints()
	Frame.Name:Point("TOP", Frame.OverlayContrainerFrame, 6, 16)
	Frame.Name:SetFontTemplate("Default")
	Frame.Name:SetNonSpaceWrap(true)
	Frame.Name:Width(242)

	Frame.IconFrame.Count:ClearAllPoints()
	Frame.IconFrame.Count:Point("BOTTOMRIGHT", -2, 4)
	Frame.IconFrame.Count:SetFontTemplate("Default")

	Frame.Timer:StripTexture(true)
	Frame.Timer:SetStatusBarTexture(Media.Global.Texture)
	Frame.Timer:ClearAllPoints()
	Frame.Timer:Size(Frame.OverlayContrainerFrame:GetWidth(), 28)
	Frame.Timer:Point("BOTTOM", Frame.OverlayContrainerFrame, 0, 0)
	Frame.Timer:CreateSpark()

	Frame.Timer.OverlayTimerFrame = CreateFrame("Frame", nil, Frame.Timer)
	Frame.Timer.OverlayTimerFrame:SetInside()
	Frame.Timer.OverlayTimerFrame:CreateBackdrop()
	Frame.Timer.OverlayTimerFrame:CreateShadow()

	if (type(Frame.IconFrame.Border) == "table" and not Frame.IconFrame.Border.SetAtlas) then
		Frame.IconFrame.Border.SetAtlas = function() end
	end

	Frame.LootGroupIsSkinned = true
end

function GroupLoot:GroupLootFrameOnShow()
	if (not self.rollID) then
		return
	end

	local Texture, Name, Count, Quality = GetLootRollItemInfo(self.rollID)

	if (not Name) then
		return
	end

	local Color = GroupLoot:GetQualityColor(Quality)

	if (self.SetBackdrop) then
		self:SetBackdrop(nil)
	end

	if (Color) then
		self.Timer:SetStatusBarColor(Color.r, Color.g, Color.b, 0.7)
	end

	self.Name:SetText(UI:UTF8Sub(Name, 36, true))
end

function GroupLoot:UpdateGroupLootContainer()
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local Frame = _G["GroupLootFrame"..i]
		Frame:ClearAllPoints()

		if (i == 1) then
			Frame:Point("CENTER", _G.UIParent, 0, -42)
		else
			Frame:Point("BOTTOM", GroupLoot.PreviousFrame, "TOP", 0, -28)
		end

		GroupLoot.PreviousFrame = Frame
	end
end

function GroupLoot:SkinFrames()
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local Frame = _G["GroupLootFrame"..i]
		self:SkinGroupLoot(Frame)
	end
end

function GroupLoot:AddHooks()
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local Frame = _G["GroupLootFrame"..i]
		Frame:HookScript("OnShow", self.GroupLootFrameOnShow)
	end

	if (_G.UIPARENT_MANAGED_FRAME_POSITIONS) then
		_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	end

	hooksecurefunc("GroupLootContainer_Update", self.UpdateGroupLootContainer)
end

function GroupLoot:Initialize()
	self:SkinFrames()
	self:AddHooks()
	--self:TestGroupLootFrames()
end