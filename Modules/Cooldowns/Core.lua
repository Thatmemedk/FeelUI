local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Cooldown = UI:RegisterModule("Cooldown")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local min, floor = math.min, math.floor

function Cooldown:GetFontScale(CD)
    if (not CD) then 
    	return 16 
    end

    local Width = CD:GetWidth() or 36
    local Height = CD:GetHeight() or 36
    local BaseSize = min(Width, Height)

    -- Base scale relative to standard 36px button
    local Scale = BaseSize / 36

    -- Smooth scaling for very small buttons
    if (Scale < 0.7) then
        Scale = 0.7  -- prevents ridiculously tiny fonts
    elseif (Scale > 1.6) then
        Scale = 1.6
    end

    -- Non-linear adjustment to make medium-small buttons more readable
    if (Scale < 1) then
        Scale = 0.8 + (Scale * 0.2)
    end

    -- Calculate final font size
    local FontSize = floor(Scale * 16 + 0.5)

    -- Minimum readable font
    if (FontSize < 10) then
        FontSize = 10
    end

    return FontSize
end

function Cooldown:IsActionBarParent(CD)
    local Parent = CD:GetParent()
    local Name = Parent and Parent:GetName() or ""

    return Name:match("ActionButton") or Name:match("MultiBar")
end

function Cooldown:UpdateCooldown(start, duration, enable, charges, maxcharges, forceShowdrawedge)
	local Enabled = GetCVar("countdownForCooldowns")

	if (Enabled and not self:IsForbidden()) then
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
                local FontSize = Cooldown:GetFontScale(self)
                Region:SetParent(self.InvisFrame)
                Region:ClearAllPoints()
                Region:SetFontTemplate("Default", FontSize)
                Region:SetTextColor(1, 0.82, 0)

                if (Cooldown:IsActionBarParent(self)) then
                    Region:Point("CENTER", InvisFrame, 0, 0)
                else
                	Region:Point("CENTER", InvisFrame, 0, -7)
                end
			end
		end

		self.CDTextModified = true
	end
end

function Cooldown:Initialize()
	hooksecurefunc("CooldownFrame_Set", self.UpdateCooldown)
end