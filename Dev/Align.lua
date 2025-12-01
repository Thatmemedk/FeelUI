--[[
## Based on Align by Akeru ** 
## http://www.wowinterface.com/downloads/info6153-Align.html **
-]]

local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Align = UI:RegisterModule("Align")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local floor = math.floor

-- Locals
Align.Enable = false
Align.BoxSize = 32

function Align:Toggle(msg)
	msg = msg and tonumber(msg)
	
	if type(msg) == "number" and (msg <= 256 and msg >= 4) then
		Frame.BoxSize = msg
		Align:Show()
	elseif self.Frame and self.Frame:IsShown() then
		Align:Hide()
	else
		Align:Show()
	end
end

function Align:Show()
	if not (self.Frame) then
		Align:Create()
	elseif (self.Frame.BoxSize ~= Align.BoxSize) then
		self.Frame:Hide()
		Align:Create()
	else
		self.Frame:Show()
	end
end

function Align:Hide()
	if self.Frame then
		self.Frame:Hide()
	end
end

function Align:Create() 
	Frame = CreateFrame("Frame", nil, _G.UIParent)	
	Frame:SetFrameStrata("FULLSCREEN")
	Frame:SetAllPoints(_G.UIParent)
	
	Frame.BoxSize = Align.BoxSize

	local Size = 1
	local Width = GetScreenWidth()
	local Ratio = Width / GetScreenHeight()
	local Height = GetScreenHeight() * Ratio
	local WidthStep = Width / Align.BoxSize
	local HeightStep = Height / Align.BoxSize
	local R, G, B = unpack(UI.GetClassColors)
	
	for i = 0, Align.BoxSize do 
		local TextureFrame = Frame:CreateTexture(nil, "OVERLAY")
		TextureFrame:SetColorTexture(0, 0, 0, 1)
		
		if (i == Align.BoxSize / 2) then
			TextureFrame:SetColorTexture(R, G, B)
		else
			TextureFrame:SetColorTexture(0, 0, 0, 1)
		end
		
		TextureFrame:Point("TOPLEFT", Frame, "TOPLEFT", i*WidthStep - (Size/2), 0) 
		TextureFrame:Point("BOTTOMRIGHT", Frame, "BOTTOMLEFT", i*WidthStep + (Size/2), 0) 
	end

	Height = GetScreenHeight()

	do
		local TextureFrame = Frame:CreateTexture(nil, "OVERLAY")
		TextureFrame:Point("TOPLEFT", Frame, "TOPLEFT", 0, -(Height/2) + (Size/2))
		TextureFrame:Point("BOTTOMRIGHT", Frame, "TOPRIGHT", 0, -(Height/2 + Size/2))
		TextureFrame:SetColorTexture(R, G, B)
	end

	for i = 1, floor((Height/2)/HeightStep) do
		local TextureFrame = Frame:CreateTexture(nil, "OVERLAY")
		TextureFrame:Point("TOPLEFT", Frame, "TOPLEFT", 0, -(Height/2+i*HeightStep) + (Size/2))
		TextureFrame:Point("BOTTOMRIGHT", Frame, "TOPRIGHT", 0, -(Height/2+i*HeightStep + Size/2))
		TextureFrame:SetColorTexture(0, 0, 0, 1)
		
		local TextureFrame = Frame:CreateTexture(nil, "OVERLAY")
		TextureFrame:Point("TOPLEFT", Frame, "TOPLEFT", 0, -(Height/2-i*HeightStep) + (Size/2))
		TextureFrame:Point("BOTTOMRIGHT", Frame, "TOPRIGHT", 0, -(Height/2-i*HeightStep + Size/2))
		TextureFrame:SetColorTexture(0, 0, 0, 1)
	end

	self.Frame = Frame
end