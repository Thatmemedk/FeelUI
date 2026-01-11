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
        Totem:Size(36, 12)
        Totem:SetTemplate()
        Totem:CreateShadow()
        Totem:SetShadowOverlay()
        Totem:SetAlpha(0)

        if (i == 1) then
            Totem:Point("CENTER", _G.UIParent, -353, -246)
        else
            Totem:Point("LEFT", self.Buttons[i-1], "RIGHT", 2, 0)
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
        local Button = self.Buttons[i]
        local PlayerHaveTotem, Name, Start, Duration, Icon = GetTotemInfo(i)

        if (Icon and Icon ~= "") then
            UI:UIFrameFadeIn(Button, 0.25, Button:GetAlpha(), 1)

            if (Icon) then
                Button.Icon:SetTexture(Icon)
            end

            if (Duration and Start) then
                Button.Cooldown:SetCooldown(Start, Duration)

                for i = 1, Button.Cooldown:GetNumRegions() do
                    local Region = select(i, Button.Cooldown:GetRegions())

                    if (Region and Region.GetText) then
                        local FontSize = UI:GetCooldownFontScale(Button.Cooldown)

                        Region:ClearAllPoints()
                        Region:Point("CENTER", Button.Overlay, 0, -6)
                        Region:SetFontTemplate("Default", FontSize)
                        Region:SetTextColor(1, 0.82, 0)
                    end
                end
            end
      	else
            UI:UIFrameFadeOut(Button, 0.25, Button:GetAlpha(), 0)
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

	self:CreateBar()
	self:RegisterEvents()
end