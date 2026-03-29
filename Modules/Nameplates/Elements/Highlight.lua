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
    local Highlight = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
    Highlight:SetBlendMode("ADD")
    Highlight:SetInside(Frame, 0, 0)
    Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
    Highlight:SetTexCoord(0, 1, 0.5, 1)
    Highlight:SetVertexColor(1, 0.82, 1, 0.5)
    Highlight:Hide()

    Frame.Highlight = Highlight
end

function NP:CreateTargetIndicator(Frame)
    local Indicator = CreateFrame("Frame", nil, Frame)
    Indicator:SetInside()
    Indicator:Hide()

    local Left = Indicator:CreateTexture(nil, "OVERLAY")
    Left:Size(16, 16)
    Left:Point("LEFT", Indicator, -18, 0)
    Left:SetTexture(Media.Global.ArrowRight)
    Left:SetVertexColor(unpack(DB.Global.Nameplates.TargetIndicatorColor))

    local Right = Indicator:CreateTexture(nil, "OVERLAY")
    Right:Size(16, 16)
    Right:Point("RIGHT", Indicator, 18, 0)
    Right:SetTexture(Media.Global.ArrowLeft)
    Right:SetVertexColor(unpack(DB.Global.Nameplates.TargetIndicatorColor))

    Frame.TargetIndicator = Indicator
end