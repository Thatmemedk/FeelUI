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

function Cooldown.UpdateCooldownFrameSet(CD, Start, Duration, Enable, ForceShowDrawEdge, ModRate)
    if (not CD) then
        return
    end

    local Success, Regions = pcall(function()
        return { CD:GetRegions() }
    end)

    if (not Success or not Regions) then
        return
    end

    for i = 1, #Regions do
        local Region = Regions[i]

        if (Region and Region.GetText) then
            local FontSize = UI:GetCooldownFontScale(CD)

            Region:ClearAllPoints()

            if (Cooldown:IsActionBarParent(CD)) then
                Region:Point("CENTER", CD, 0, 0)
            else
                Region:Point("CENTER", CD, 0, -6)
            end

            Region:SetFontTemplate("Default", FontSize)
            Region:SetTextColor(1, 0.82, 0)
        end
    end

    CD.CDTextIsModified = true
end

function Cooldown:Initialize()
    if (not DB.Global.CooldownFrame.Enable) then
        return
    end

	hooksecurefunc("CooldownFrame_Set", self.UpdateCooldownFrameSet)
end