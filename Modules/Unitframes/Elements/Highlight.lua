local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:OnHide()
    if (not self:IsShown()) then
        self:SetAlpha(0)
    end

    UI:UIFrameFadeOut(self, UF.FadeInTime, self:GetAlpha(), 0)
end

function UF:OnShow()
    if (not self:IsShown()) then
        self:SetAlpha(0)
    end

    UI:UIFrameFadeIn(self, UF.FadeInTime, self:GetAlpha(), 1)
end

function UF:CreateFadeInOut(Frame)
    Frame:SetScript("OnShow", UF.OnShow)
    Frame:SetScript("OnHide", UF.OnHide)
end

function UF:CreateOnEnterLeave(Frame)
    Frame:SetScript("OnEnter", _G.UnitFrame_OnEnter)
    Frame:SetScript("OnLeave", _G.UnitFrame_OnLeave)
end

function UF:CreatePanels(Frame)
    if (Frame.Panel or Frame.InvisFrame or Frame.InvisFrameHigher) then
        return
    end

    local Panel = CreateFrame("Frame", nil, Frame)
    Panel:SetFrameLevel(Frame:GetFrameLevel() - 1)
    Panel:SetInside()
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

function UF:CreateHighlight(Frame)
    if (Frame.Highlight) then
        return
    end
    
    local Highlight = CreateFrame("StatusBar", nil, Frame)
    Highlight:SetInside()
    Highlight:SetStatusBarTexture(Media.Global.Texture)
    Highlight:SetStatusBarColor(1, 1, 1, 0.05)
    Highlight:Hide()
    
    -- On Enter / Leave
    Frame:HookScript("OnEnter", self.HighlightOnMouse)
    Frame:HookScript("OnLeave", self.HighlightOnMouse)
    
    Frame.Highlight = Highlight
end

function UF:CreateHighlightTarget(Frame)
    if (Frame.HighlightTarget) then
        return
    end

    local HighlightTarget = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
    HighlightTarget:SetBlendMode("ADD")
    HighlightTarget:SetInside()
    HighlightTarget:SetTexture(Media.Global.Glow)
    HighlightTarget:SetTexCoord(0, 1, 0.5, 1)
    HighlightTarget:SetVertexColor(1, 0.82, 0, 0.25)
    HighlightTarget:SetAlpha(0)

    Frame.HighlightTarget = HighlightTarget
end

function UF:HighlightOnMouse()
    local GMF = UI:GetMouseFocus()

    if (GMF == self and UnitExists(self.unit)) then
        self.Highlight:Show()
    else
        self.Highlight:Hide()
    end
end