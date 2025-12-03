local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local GhostFrameBlizz = UI:RegisterModule("GhostFrame")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GhostFrame = _G.GhostFrame
local Text = _G.GhostFrameContentsFrameText
local Icon = _G.GhostFrameContentsFrameIcon

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function GhostFrameBlizz:Skin()
	if (self.IsSkinned) then
		return
	end

	GhostFrame:StripTexture(true)
	GhostFrame:ClearAllPoints()
	GhostFrame:Point("CENTER", _G.UIParent, 0, 162)
	
	Text:ClearAllPoints()
	Text:Point("BOTTOM", GhostFrame, 0, 2)
	Text:SetFontTemplate("Default", 16)
	
	Icon:ClearAllPoints()
	Icon:Point("TOP", GhostFrame, -2, -2)
	Icon:Size(48, 22)
	UI:KeepAspectRatio(Icon, Icon)

	GhostFrame.IconOverlay = CreateFrame("Frame", nil, GhostFrame)
	GhostFrame.IconOverlay:SetInside(Icon)
	GhostFrame.IconOverlay:SetTemplate()
	GhostFrame.IconOverlay:CreateShadow()
	GhostFrame.IconOverlay:SetShadowOverlay()
	
	GhostFrame.PulseGlow = CreateFrame("Frame", nil, GhostFrame, "BackdropTemplate")
	GhostFrame.PulseGlow:SetFrameStrata(GhostFrame:GetFrameStrata())
	GhostFrame.PulseGlow:SetFrameLevel(GhostFrame:GetFrameLevel() + 1)
	GhostFrame.PulseGlow:SetScale(UI:Scale(3.5))
	GhostFrame.PulseGlow:SetOutside(Icon, 3, 3)
	GhostFrame.PulseGlow:SetBackdrop({edgeFile = Media.Global.Shadow, edgeSize = UI:Scale(3)})
	GhostFrame.PulseGlow:SetBackdropBorderColor(0, 0, 0, 0)
	
	GhostFrame:HookScript("OnEnter", function() 		
		UI:CreatePulse(GhostFrame.PulseGlow)
		GhostFrame.PulseGlow:SetBackdropBorderColor(R, G, B, 0.8)
		
		GhostFrame.IconOverlay:SetColorTemplate(R, G, B)
	end)
	
	GhostFrame:HookScript("OnLeave", function()
		GhostFrame.PulseGlow:SetScript("OnUpdate", nil)
		GhostFrame.PulseGlow:SetBackdropBorderColor(0, 0, 0, 0)
		
		GhostFrame.IconOverlay:SetColorTemplate(unpack(DB.Global.General.BorderColor))
	end)

	self.IsSkinned = true
end

function GhostFrameBlizz:Initialize()
	if (not DB.Global.Theme.Enable) then 
		return
	end
	
	--self:Skin()
end