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
        if (not self or self.CooldownTextIsUpdated or self:IsForbidden() or UI:IsSecretValue(self)) then
            return
        end

        self:SetCountdownFormatter(UI:BuildRuleDurationFormatter())

        for i = 1, self:GetNumRegions() do
            local Region = select(i, self:GetRegions())

            if (Region and Region.GetText) then
                Region:ClearAllPoints()

                if (Cooldown:IsActionBarParent(self)) then
                    Region:Point("CENTER", self, 0, 0)
                else
                    Region:Point("CENTER", self, 0, -6)
                end

                local FontSize = UI:GetCooldownFontScale(self)
                Region:SetFontTemplate("Default", FontSize)
            end
        end

        self.CooldownTextIsUpdated = true
    end)
end