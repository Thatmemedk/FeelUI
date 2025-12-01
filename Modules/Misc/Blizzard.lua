local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Blizzard = UI:RegisterModule("Blizzard")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local NewPlayerExperience = _G.NewPlayerExperience
local HelpTip = _G.HelpTip

function Blizzard:DisableTips()
    if (HelpTip and HelpTip.framePool) then
        for Frames in HelpTip.framePool:EnumerateActive() do
            Frames:Acknowledge()
        end

        local OriginalShow = HelpTip.Show
        HelpTip.Show = function(...) end
    end

    if (NewPlayerExperience) then
        if (NewPlayerExperience:GetIsActive()) then
            NewPlayerExperience:Shutdown()
        end

        if (NewPlayerExperience.SetEnabled) then
            NewPlayerExperience:SetEnabled(false)
        end
    end
end

function Blizzard:Initialize()
	self:DisableTips()
end