local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:OnHide()
    if not self:IsShown() then
        UI:UIFrameFadeOut(self, UF.FadeInTime, self:GetAlpha(), 0)
    end

    UI:UIFrameFadeOut(self, UF.FadeInTime, self:GetAlpha(), 0)
end

function UF:OnShow()
    if not self:IsShown() then
        UI:UIFrameFadeOut(self, UF.FadeInTime, self:GetAlpha(), 0)
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