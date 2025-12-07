local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreatePanels(Frame)
    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() + 2)
    Panel:Size(Frame:GetWidth() + 18, 16)
    Panel:Point("CENTER", Frame, 0, -4)
    Panel:CreateShadow()
    
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

function NP:CreatePanelsFriendly(Frame)
    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() + 2)
    Panel:Size(Frame:GetWidth() + 18, 16)
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
    local TargetIndicatorLeft = Frame:CreateTexture(nil, "OVERLAY")
    TargetIndicatorLeft:Size(16, 16)
    TargetIndicatorLeft:Point("LEFT", Frame, -30, -4)
    TargetIndicatorLeft:SetTexture(Media.Global.PowerArrowRight)
    TargetIndicatorLeft:SetVertexColor(77/255, 179/255, 255/255)
    TargetIndicatorLeft:Hide()

    local TargetIndicatorRight = Frame:CreateTexture(nil, "OVERLAY")
    TargetIndicatorRight:Size(16, 16)
    TargetIndicatorRight:Point("RIGHT", Frame, 30, -4)
    TargetIndicatorRight:SetTexture(Media.Global.PowerArrowLeft)
    TargetIndicatorRight:SetVertexColor(77/255, 179/255, 255/255)
    TargetIndicatorRight:Hide()

    Frame.TargetIndicatorLeft = TargetIndicatorLeft
    Frame.TargetIndicatorRight = TargetIndicatorRight
end

function NP:HighlightOnNameplateTarget(Frame, Unit)
    if UnitIsUnit("target", Unit) then
        Frame.TargetIndicatorLeft:Show()
        Frame.TargetIndicatorRight:Show()
    else
        Frame.TargetIndicatorLeft:Hide()
        Frame.TargetIndicatorRight:Hide()
    end
end