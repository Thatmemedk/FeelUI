local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local StackSplit = UI:RegisterModule("StackSplit")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local StackSplitFrame = _G.StackSplitFrame

function StackSplit:Skin()
	if (self.IsSkinned) then
		return
	end

	StackSplitFrame:StripTexture()
	StackSplitFrame:CreateBackdrop()
	StackSplitFrame:CreateShadow()

	StackSplitFrame.Background = CreateFrame("Frame", nil, StackSplitFrame)
	StackSplitFrame.Background:SetFrameLevel(StackSplitFrame:GetFrameLevel() - 1)
	StackSplitFrame.Background:Point("TOPLEFT", StackSplitFrame, 12, -14)
	StackSplitFrame.Background:Point("BOTTOMRIGHT", StackSplitFrame, -12, 56)
	StackSplitFrame.Background:CreateBackdrop()
	StackSplitFrame.Background:CreateShadow()
	
	StackSplitFrame.LeftButton:ClearAllPoints()
	StackSplitFrame.LeftButton:Point("LEFT", StackSplitFrame.Background, 6, 0)
	StackSplitFrame.LeftButton:HandleSplitButton()
	
	StackSplitFrame.RightButton:ClearAllPoints()
	StackSplitFrame.RightButton:Point("RIGHT", StackSplitFrame.Background, -6, 0)
	StackSplitFrame.RightButton:HandleSplitButton()

	StackSplitFrame.OkayButton:HandleButton()
	StackSplitFrame.CancelButton:HandleButton()
		
	self.IsSkinned = true
end

function StackSplit:Initialize()
	if not (DB.Global.Theme.Enable) then 
		return
	end

	self:Skin()
end