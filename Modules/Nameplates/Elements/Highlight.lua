local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreateStackingBounds(Frame)
    if (Frame.StackingBound) then
        return
    end

    local StackingBound = CreateFrame("Frame", nil, Frame)
    StackingBound:SetAllPoints()

    local Texture = StackingBound:CreateTexture()
    Texture:SetColorTexture(1, 0, 0, 0)
    Texture:SetAllPoints(StackingBound)

    local Plate = Frame:GetParent()

    if (Plate and Plate.SetStackingBoundsFrame) then
        Plate:SetStackingBoundsFrame(StackingBound)
    end

    Frame.StackingBound = StackingBound
end

function NP:CreatePanels(Frame)
    if (Frame.Panel or Frame.InvisFrame or Frame.InvisFrameHigher) then
        return
    end

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
    if (Frame.Highlight) then
        return
    end

    local Highlight = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
    Highlight:SetBlendMode("ADD")
    Highlight:SetInside()
    Highlight:SetTexture(Media.Global.Glow)
    Highlight:SetTexCoord(0, 1, 0.5, 1)
    Highlight:SetVertexColor(1, 0.82, 0, 0.5)
    Highlight:Hide()

    Frame.Highlight = Highlight
end

function NP:CreateHighlightMouseOver(Frame)
    if (Frame.HighlightMouseOver) then
        return
    end

    local HighlightMouseOver = CreateFrame("StatusBar", nil, Frame)
    HighlightMouseOver:SetFrameLevel(Frame:GetFrameLevel() + 1)
    HighlightMouseOver:SetInside(Frame, 1, 1)
    HighlightMouseOver:SetStatusBarTexture(Media.Global.Texture)
    HighlightMouseOver:SetStatusBarColor(1, 1, 1, 0.25)
    HighlightMouseOver:Hide()

    -- On Update
    Frame:SetScript("OnUpdate", function(self, Elapsed)
        self.Elapsed = (self.Elapsed or 0) + Elapsed

        if (self.Elapsed > 0.1) then
            if (not UnitIsUnit("mouseover", self.unit)) then
                self.HighlightMouseOver:Hide()
            end

            self.Elapsed = 0
        end
    end)

    -- On Hide
    Frame:HookScript("OnHide", self.HighlightOnHide)

    Frame.HighlightMouseOver = HighlightMouseOver
end

function NP:HighlightOnHide()
    self.HighlightMouseOver:Hide()
end

function NP:CreateTargetIndicator(Frame)
    if (Frame.TargetIndicator) then
        return
    end
    
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