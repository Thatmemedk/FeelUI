local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local MirrorTimers = UI:RegisterModule("MirrorTimers")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local MirrorTimerContainer = _G.MirrorTimerContainer

function MirrorTimers:Update(Timer)
	local Bar = self:GetAvailableTimer(Timer)
	
	if not (Bar) then 
		return 
	end

	if not (Bar.AtlasHolder) then
		Bar.AtlasHolder = CreateFrame("Frame", nil, Bar)
		Bar.AtlasHolder:SetClipsChildren(true)
		Bar.AtlasHolder:SetInside(Bar, 1, 1)

		Bar.StatusBar:SetParent(Bar.AtlasHolder)
		Bar.StatusBar:ClearAllPoints()
		Bar.StatusBar:Size(302, 28)
		Bar.StatusBar:Point("TOP", 0, 2)
		Bar.StatusBar:CreateSpark(1, 0.82, 0, 0.8) 

		Bar.Text:ClearAllPoints()
		Bar.Text:SetParent(Bar.StatusBar)
		Bar.Text:Point("CENTER", Bar.StatusBar, 0, 0)
		Bar.Text:SetFontTemplate("Default", 16)

		Bar:StripTexture()
		Bar:Size(302, 28)

		if not (Bar.MirrorTimerIsSkinned) then
			local BarOverlay = CreateFrame("Frame", nil, Bar)
			BarOverlay:SetFrameLevel(Bar:GetFrameLevel() - 1)
			BarOverlay:SetInside(Bar, 1, 1)
			BarOverlay:CreateBackdrop()
			BarOverlay:CreateShadow()

			Bar.MirrorTimerIsSkinned = true
		end
	end
end

function MirrorTimers:Initialize()
	hooksecurefunc(MirrorTimerContainer, "SetupTimer", self.Update)
end