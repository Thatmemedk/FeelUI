local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Cooldown = UI:RegisterModule("Cooldown")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local min, floor = math.min, math.floor

function Cooldown:UpdateCooldown(Start, Duration, Enable, ForceShowDrawEdge, ModRate)
    if (self.CDTextModified) then
        return
    end

    if (not self.InvisFrame) then
        local InvisFrame = CreateFrame("Frame", nil, self)
        InvisFrame:SetFrameLevel(self:GetFrameLevel() + 10)
        InvisFrame:SetInside()

        self.InvisFrame = InvisFrame
    end

    local NumRegions = self:GetNumRegions()

    for i = 1, NumRegions do
        local Region = select(i, self:GetRegions())

        if (Region.GetText) then
            local FontSize = UI:GetCooldownFontScale(self)
            
            Region:SetParent(self.InvisFrame)
            Region:ClearAllPoints()
            Region:Point("CENTER", InvisFrame, 0, -7)
            Region:SetFontTemplate("Default", FontSize)
            Region:SetTextColor(1, 0.82, 0)
        end
    end

    self.CDTextModified = true
end

function Cooldown:Initialize()
	hooksecurefunc("CooldownFrame_Set", self.UpdateCooldown)
end