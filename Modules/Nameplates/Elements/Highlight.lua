local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreatePanels(Frame)
    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() + 2)
    Panel:Size(192, 16)
    Panel:Point("CENTER", Frame, 0, -4)
    
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

function NP:CreateTargetIndicator(Frame)
    local Indicator = CreateFrame("Frame", nil, Frame)
    Indicator:Size(192, 16)
    Indicator:Point("CENTER", Frame, 0, -4)

    local Left = Indicator:CreateTexture(nil, "OVERLAY")
    Left:Size(16, 16)
    Left:Point("LEFT", Indicator, -20, 0)
    Left:SetTexture(Media.Global.PowerArrowRight)
    Left:SetVertexColor(unpack(DB.Global.Nameplates.TargetIndicatorColor))
    Left:Hide()

    local Right = Indicator:CreateTexture(nil, "OVERLAY")
    Right:Size(16, 16)
    Right:Point("RIGHT", Indicator, 20, 0)
    Right:SetTexture(Media.Global.PowerArrowLeft)
    Right:SetVertexColor(unpack(DB.Global.Nameplates.TargetIndicatorColor))
    Right:Hide()

    Frame.TargetIndicator = Indicator
    Frame.TargetIndicator.Left = Left
    Frame.TargetIndicator.Right = Right
end

function NP:HighlightOnNameplateTarget(Frame, Unit)
    if UnitIsUnit("target", Unit) then
        Frame.TargetIndicator.Left:Show()
        Frame.TargetIndicator.Right:Show()
    else
        Frame.TargetIndicator.Left:Hide()
        Frame.TargetIndicator.Right:Hide()
    end
end