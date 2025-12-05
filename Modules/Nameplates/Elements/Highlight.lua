local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreatePanels(Frame)
    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() + 2)
    Panel:Size(Frame:GetWidth(), 14)
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
    Panel:Size(Frame:GetWidth(), 14)
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
    local TargetIndicatorLeft = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
    TargetIndicatorLeft:Size(14, 14)
    TargetIndicatorLeft:Point("LEFT", Frame.Health, -18, -12)
    TargetIndicatorLeft:SetTexture(Media.Global.PowerArrowRight)
    TargetIndicatorLeft:SetVertexColor(77/255, 179/255, 255/255)
    TargetIndicatorLeft:Hide()

    local TargetIndicatorRight = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
    TargetIndicatorRight:Size(14, 14)
    TargetIndicatorRight:Point("RIGHT", Frame.Health, 18, -12)
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