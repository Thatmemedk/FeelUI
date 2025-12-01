local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local TimeTrackers = UI:RegisterModule("TimeTrackers")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local TimerTracker = _G.TimerTracker

function TimeTrackers:UpdateBar(Bar)
	if not (Bar) then 
		return 
	end

	for i = 1, Bar:GetNumRegions() do
		local Region = select(i, Bar:GetRegions())

		if (Region and Region.GetObjectType) then
			local Type = Region:GetObjectType()

			if (Type == "Texture") then
				Region:SetTexture(nil)
			elseif (Type == "FontString") then
				Region:ClearAllPoints()
				Region:Point("CENTER", Bar, 0, 1)
				Region:SetFontTemplate("Default", 14)
			end
		end
	end

	Bar:StripTexture()
	Bar:Size(302, 24)
	Bar:ClearAllPoints()
	Bar:Point("TOP", _G.UIParent, 0, -192)
	Bar:SetStatusBarTexture(Media.Global.Texture)
	Bar:SetStatusBarColor(170 / 255, 10 / 255, 10 / 255)
	Bar:CreateBackdrop()
	Bar:CreateShadow()
end

function TimeTrackers:Update()
	if not (TimerTracker and TimerTracker.timerList) then
		return
	end

	for _, Data in pairs(TimerTracker.timerList) do
		local Bar = Data and Data["bar"]

		if (Bar and not Bar.TimeTrackersIsSkinned) then
			self:UpdateBar(Bar)

			Bar.TimeTrackersIsSkinned = true
		end
	end
end

function TimeTrackers:RegisterEvents()
	self:RegisterEvent("START_TIMER")
	self:SetScript("OnEvent", self.Update)
end

function TimeTrackers:Initialize()
	self:RegisterEvents()
end