local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Cooldown = UI:RegisterModule("CooldownFrame")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local min, floor = math.min, math.floor

function Cooldown:IsActionBarParent(CD)
    local Parent = CD:GetParent()
    local Name = Parent and Parent:GetName() or ""

    return Name:match("ActionButton") or Name:match("MultiBar")
end

function Cooldown:UpdateCooldown(Start, Duration, Enable, ForceShowDrawEdge, ModRate)
    if (not DB.Global.CooldownFrame.Enable or self.CDTextModified) then
        return
    end

    for i = 1, self:GetNumRegions() do
        local Region = select(i, self:GetRegions())

        if (Region and Region.GetText) then
            local FontSize = UI:GetCooldownFontScale(self)

            Region:ClearAllPoints()

            if (Cooldown:IsActionBarParent(self)) then
                Region:Point("CENTER", self, 0, 0)
            else
                Region:Point("CENTER", self, 0, -6)
            end

            Region:SetFontTemplate("Default", FontSize)
            Region:SetTextColor(1, 0.82, 0)
        end
    end

    self.CDTextModified = true
end

function Cooldown:Initialize()
	hooksecurefunc("CooldownFrame_Set", self.UpdateCooldown)
end