local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Cooldown = UI:RegisterModule("CooldownFrame")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local min, floor = math.min, math.floor

function Cooldown:IsActionBarParent(CD)
    local Parent = CD:GetParent()
    local Name = Parent and Parent:GetName() or ""
    
    return Name:match("ActionButton") or Name:match("MultiBar")
end

function Cooldown:Initialize()
    if (not DB.Global.CooldownFrame.Enable) then
        return
    end

	hooksecurefunc("CooldownFrame_Set", function(self, Start, Duration, Enable, ForceShowDrawEdge, ModRate)
        if (not self or self.TextIsModified or UI:IsSecretValue(self)) then
            return
        end

        for i = 1, self:GetNumRegions() do
            local Region = select(i, self:GetRegions())

            if (Region and Region.GetText) then
                local InvisFrame = CreateFrame("Frame", nil, self)
                InvisFrame:SetFrameStrata("HIGH")
                InvisFrame:SetFrameLevel(self:GetFrameLevel() + 10)
                InvisFrame:SetInside()

                Region:SetParent(InvisFrame)
                Region:ClearAllPoints()

                if (Cooldown:IsActionBarParent(self)) then
                    Region:Point("CENTER", InvisFrame, 0, 0)
                else
                    Region:Point("CENTER", InvisFrame, 0, -6)
                end

                local FontSize = UI:GetCooldownFontScale(self)
                Region:SetFontTemplate("Default", FontSize)
                Region:SetTextColor(1, 0.82, 0)
            end
        end

        self.TextIsModified = true
    end)
end