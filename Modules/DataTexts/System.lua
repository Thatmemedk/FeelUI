local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local System = UI:RegisterModule("DataTextSystem")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local unpack = unpack
local floor = math.floor

-- WoW Globals
local GetFramerate = GetFramerate
local GetNetStats = GetNetStats

-- Locals
local GradientColorPalet = {
	1, 0, 0,      -- Red
	1, 0.42, 0,   -- Orange
	1, 0.82, 0,   -- Yellow
    0, 1, 0       -- Green
}

local GradientColorPaletDown = { 
    0, 1, 0,     -- Green
    1, 0.82, 0,  -- Yellow
    1, 0.42, 0,  -- Orange
    1, 0, 0      -- Red
}

function System:Create()
    local Frame = CreateFrame("Frame", nil, _G.UIParent)
    Frame:Size(160, 50)
    Frame:Point("LEFT", Panels.DataTextHolder, 0, -2)

    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, -32, 0)
    Text:SetFontTemplate("Default", 12)
    Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

    self.Frame = Frame
    self.Text = Text
end

function System:Update(Elapsed)
    self.Init = (self.Init or 0) - Elapsed

    if (self.Init > 0) then 
    	return 
    end

    self.Init = 1

    local FrameRate = floor(GetFramerate())
	local _, _, HomeMS, WorldMS = GetNetStats() 
	local Latency = HomeMS and WorldMS

    local F, P, S = UI:ColorGradient(FrameRate, 60, unpack(GradientColorPalet))
    local HexFPS = UI:RGBToHex(F, P, S)

    local L, T, Y = UI:ColorGradient(Latency, 500, unpack(GradientColorPaletDown))
    local HexMS = UI:RGBToHex(L, T, Y)

    if (self.Text) then
    	self.Text:SetFormattedText("|cffffffffFPS|r: %s%d|r |cffffffffMS|r: %s%d|r", HexFPS, FrameRate, HexMS, Latency)
    end
end

function System:OnUpdate()
    self:SetScript("OnUpdate", self.Update)
end

function System:Initialize()
    if (not DB.Global.DataTexts.System) then 
        return 
    end

    self:Create()
    self:OnUpdate()
end