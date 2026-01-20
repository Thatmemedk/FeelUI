local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreatePanels(Frame)
    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() + 2)
    Panel:SetInside()
    
    local InvisFrame = CreateFrame("Frame", nil, Frame)
    InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 8)
    InvisFrame:SetInside()
    
    local InvisFrameHigher = CreateFrame("Frame", nil, Frame)
    InvisFrameHigher:SetFrameLevel(Frame:GetFrameLevel() + 10)
    InvisFrameHigher:SetInside()
    
    Frame.Panel = Panel
    Frame.InvisFrame = InvisFrame
    Frame.InvisFrameHigher = InvisFrameHigher
end

function NP:CreateHighlight(Frame)
    local Highlight = CreateFrame("StatusBar", nil, Frame)
    Highlight:SetFrameLevel(Frame:GetFrameLevel() + 10)
    Highlight:SetInside()
    Highlight:SetStatusBarTexture(Media.Global.Texture)
    Highlight:SetStatusBarColor(1, 1, 1, 0.05)
    Highlight:Hide()
    
    Frame.Highlight = Highlight
end

function NP:CreateTargetIndicator(Frame)
    local Indicator = CreateFrame("Frame", nil, Frame)
    Indicator:SetInside()
    Indicator:Hide()

    local Left = Indicator:CreateTexture(nil, "OVERLAY")
    Left:Size(14, 14)
    Left:Point("LEFT", Indicator, -16, 0)
    Left:SetTexture(Media.Global.ArrowRight)
    Left:SetVertexColor(unpack(DB.Global.Nameplates.TargetIndicatorColor))

    local Right = Indicator:CreateTexture(nil, "OVERLAY")
    Right:Size(14, 14)
    Right:Point("RIGHT", Indicator, 16, 0)
    Right:SetTexture(Media.Global.ArrowLeft)
    Right:SetVertexColor(unpack(DB.Global.Nameplates.TargetIndicatorColor))

    Frame.TargetIndicator = Indicator
end