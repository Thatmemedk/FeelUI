local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local TotemBar = UI:RegisterModule("TotemBar")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local select = select
local unpack = unpack
local floor = math.floor

-- Locals
local Class = select(2, UnitClass("player"))

-- Locals
TotemBar.Buttons = {}

function TotemBar:CreateBar()
	for i = 1, _G.MAX_TOTEMS do
		local Totem = CreateFrame("Frame", nil, _G.UIParent)
		Totem:SetID(i)
		Totem:Size(36, 16)
		Totem:SetTemplate()
		Totem:CreateShadow()
		Totem:SetShadowOverlay()
		Totem:SetAlpha(0)
		
		if (i == 1) then
			Totem:Point(unpack(DB.Global.DataBars.TotemBarPoint))
		else
			Totem:Point("LEFT", self.Buttons[i-1], "RIGHT", 3, 0)
		end
		
		local Icon = Totem:CreateTexture(nil, "OVERLAY")
		Icon:SetInside()
		UI:KeepAspectRatio(Totem, Icon)
		
		local Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
		Cooldown:SetInside()
		Cooldown:SetReverse(false)
		Cooldown:SetDrawBling(false)
		Cooldown:SetDrawEdge(false)

		if (Class == "SHAMAN") then
			local Destroy = CreateFrame("Button", nil, Totem, "SecureUnitButtonTemplate")
			Destroy:SetFrameLevel(Totem:GetFrameLevel() + 5)
			Destroy:RegisterForClicks("RightButtonUp")
			Destroy:SetAllPoints(Totem)
			Destroy:SetID(i)
			Destroy:SetAttribute("type2", "destroytotem")
			Destroy:SetAttribute("*totem-slot*", i)
			Destroy:StyleButton()
		end
		
		self.Buttons[i] = Totem
		self.Buttons[i].Icon = Icon
		self.Buttons[i].Cooldown = Cooldown
	end
end

function TotemBar:OnEvent(event)
    for i = 1, _G.MAX_TOTEMS do
        local TotemBars = self.Buttons[i]
        local PlayerHaveTotem, Name, Start, Duration, Icon = GetTotemInfo(i)

        if (PlayerHaveTotem and Duration) then
            TotemBars.Icon:SetTexture(Icon)

            if (Duration and Start) then
                TotemBars.Cooldown:SetCooldown(Start, Duration)
            end

            UI:UIFrameFadeIn(TotemBars, 0.5, TotemBars:GetAlpha(), 1)
        else
            UI:UIFrameFadeOut(TotemBars, 0.5, TotemBars:GetAlpha(), 0)
      	end
    end
end

function TotemBar:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TOTEM_UPDATE")
	self:SetScript("OnEvent", self.OnEvent)
end

function TotemBar:Initialize()
	if (not DB.Global.DataBars.TotemBar) then
		return
	end

	--self:CreateBar()
	--self:RegisterEvents()
end