local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreatePanels(Frame, EnableGlow, GlowScale, GlowSize)
    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() - 1)
    Panel:SetInside()
    Panel:CreateShadow()
    
    if (EnableGlow) then
        Panel:CreateGlow(GlowScale or 2.5, GlowSize or 3, 0, 0, 0, 0)
    end
    
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

function UF:NPCreatePanels(Frame)
    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() + 2)
    Panel:Size(Frame:GetWidth(), 14)
    Panel:Point("CENTER", Frame, 0, -12)
    Panel:CreateShadow()
    --Panel:CreateGlow(3, 3, 0, 0, 0, 0)
    
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

function UF:HighlightOnMouse()
    local GMF = UI:GetMouseFocus()

    if GMF == self and UnitExists(self.unit) then
        self.Highlight:Show()
        self.Highlight:SetStatusBarColor(1, 1, 1, 0.05)
    else
        self.Highlight:Hide()
        self.Highlight:SetStatusBarColor(0, 0, 0, 0)
    end
end

function UF:CreateHightlight(Frame)
    local Highlight = CreateFrame("StatusBar", nil, Frame)
    Highlight:SetFrameLevel(Frame:GetFrameLevel() + 10)
    Highlight:SetInside()
    Highlight:SetStatusBarTexture(Media.Global.Texture)
    Highlight:Hide()
    
    Frame:HookScript("OnEnter", self.HighlightOnMouse)
    Frame:HookScript("OnLeave", self.HighlightOnMouse)
    
    Frame.Highlight = Highlight
end

function UF:CreateOnEnterLeave(Frame)
    Frame:SetScript("OnEnter", _G.UnitFrame_OnEnter)
    Frame:SetScript("OnLeave", _G.UnitFrame_OnLeave)
end

function UF:NPCreateTargetIndicator(Frame, Unit)
    local TargetIndLeft = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
    TargetIndLeft:Size(14, 14)
    TargetIndLeft:Point("LEFT", Frame.Health, -18, -12)
    TargetIndLeft:SetTexture(Media.Global.PowerArrowRight)
    TargetIndLeft:SetVertexColor(77/255, 179/255, 255/255)
    TargetIndLeft:Hide()

    local TargetIndRight = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
    TargetIndRight:Size(14, 14)
    TargetIndRight:Point("RIGHT", Frame.Health, 18, -12)
    TargetIndRight:SetTexture(Media.Global.PowerArrowLeft)
    TargetIndRight:SetVertexColor(77/255, 179/255, 255/255)
    TargetIndRight:Hide()

    Frame.TargetIndLeft = TargetIndLeft
    Frame.TargetIndRight = TargetIndRight
end

function UF:NPHighlightOnNameplateTarget(Frame, Unit)
    if UnitIsUnit("target", Unit) then
        Frame.TargetIndLeft:Show()
        Frame.TargetIndRight:Show()
    else
        Frame.TargetIndLeft:Hide()
        Frame.TargetIndRight:Hide()
    end
end