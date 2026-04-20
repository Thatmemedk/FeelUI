local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local System = UI:RegisterModule("DataTextSystem")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
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

-- Locals
local UpdateTime = 1

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
    self.TimeElapsed = (self.TimeElapsed or 0) - Elapsed

    if (self.TimeElapsed > 0) then 
        return 
    end

    self.TimeElapsed = UpdateTime

    -- Locals
    local FrameRate = GetFramerate()
    local _, _, _, WorldMS = GetNetStats()

    -- Color Gradient
    local F, P, S = UI:ColorGradient(FrameRate, 60, unpack(GradientColorPalet))
    local L, T, Y = UI:ColorGradient(WorldMS, 500, unpack(GradientColorPaletDown))

    -- Convert to Hex
    local HexFPS = UI:RGBToHex(F, P, S)
    local HexMS = UI:RGBToHex(L, T, Y)

    -- Update Text
    self.Text:SetFormattedText("|cffffffffFPS|r: %s%d|r |cffffffffMS|r: %s%d|r", HexFPS, FrameRate, HexMS, WorldMS)
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