local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local ReadyCheck = UI:RegisterModule("ReadyCheck")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local ReadyCheckFrame = _G.ReadyCheckFrame
local ReadyCheckFrameNoButton = _G.ReadyCheckFrameNoButton
local ReadyCheckFrameYesButton = _G.ReadyCheckFrameYesButton
local ReadyCheckListenerFrame = _G.ReadyCheckListenerFrame
local ReadyCheckFrameText = _G.ReadyCheckFrameText
local ReadyCheckPortrait = _G.ReadyCheckPortrait

local function HidePlayerRC(Frame)
	if (Frame.initiator and UnitIsUnit("player", Frame.initiator)) then
		Frame:Hide()
	end
end

function ReadyCheck:Skin()
	if (self.IsSkinned) then
		return
	end

	-- HIDE
	ReadyCheckListenerFrame:StripTexture()
	ReadyCheckListenerFrame.NineSlice:SetAlpha(0)

	-- TITLE
	ReadyCheckListenerFrame.TitleContainer.TitleText:Hide()

	-- TEXT
	ReadyCheckFrameText:Hide()

	-- PORTRAIT
	ReadyCheckPortrait:Kill()

	-- BUTTONS
	ReadyCheckFrameNoButton:Size(142, 32)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameNoButton:Point("TOPLEFT", ReadyCheckFrame, "CENTER", 2, -6)
	ReadyCheckFrameNoButton:HandleButton()

	ReadyCheckFrameYesButton:Size(142, 32)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameYesButton:Point("TOPRIGHT", ReadyCheckFrame, "CENTER", -2, -6)
	ReadyCheckFrameYesButton:HandleButton()
	
	-- SKIN
	ReadyCheckFrame.Background = CreateFrame("Frame", nil, ReadyCheckFrame)
	ReadyCheckFrame.Background:SetFrameLevel(StackSplitFrame:GetFrameLevel() - 1)
	ReadyCheckFrame.Background:Size(306, 48)
	ReadyCheckFrame.Background:Point("CENTER", ReadyCheckFrame, 0, -22)
	ReadyCheckFrame.Background:CreateBackdrop()
	ReadyCheckFrame.Background:CreateShadow()

	-- HOOK
	ReadyCheckFrame:HookScript("OnShow", HidePlayerRC)

	self.IsSkinned = true
end

function ReadyCheck:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end

	self:Skin()
end