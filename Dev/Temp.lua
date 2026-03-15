local UI, DB, Media = select(2, ...):Call()

-- Call Modules
local ET = UI:RegisterModule("EncounterTimeline")

-- WoW Globals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

function ET:Skin()
    if (self.IsSkinned) then
        return
    end

	EncounterTimeline.TrackView.Background:SetAlpha(0)
	EncounterTimeline.TrackView.LineStart:SetAlpha(0)
	EncounterTimeline.TrackView.LineEnd:SetAlpha(0)
	EncounterTimeline.TrackView.PipText:SetAlpha(0)
	EncounterTimeline.TrackView.PipIcon:SetAlpha(0)
	EncounterTimeline.TrackView.LongDivider:SetAlpha(0)
	EncounterTimeline.TrackView.QueueDivider:SetAlpha(0)

	--[[
	local EncounterTimelineFrameNew = CreateFrame("Frame", nil, EncounterTimeline)
	EncounterTimelineFrameNew:SetFrameLevel(EncounterTimeline:GetFrameLevel() -1)
	EncounterTimelineFrameNew:SetFrameStrata("LOW")
	EncounterTimelineFrameNew:Size(3, 420)
	EncounterTimelineFrameNew:Point("CENTER", EncounterTimeline, 0, 0)
	EncounterTimelineFrameNew:CreateBackdrop()
	EncounterTimelineFrameNew:CreateShadow()
	--]]

	self.IsSkinned = true
end

function ET:Initialize()
    if (not DB.Global.Theme.Enable) then 
        return
    end

	if (not IsAddOnLoaded("Blizzard_EncounterTimeline")) then
		LoadAddOn("Blizzard_EncounterTimeline")
	end

    self:Skin()
end