local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateThreatHighlight(Frame)
    local Threat = CreateFrame("Frame", nil, Frame)
    Threat:SetInside(Frame, 1, 1)
    Threat:CreateGlow(2.5, 3, 0, 0, 0, 0)
    Threat:Hide()

    Threat.Animation = Threat:CreateAnimationGroup()
    Threat.Animation:SetLooping("BOUNCE")

    Threat.Animation.FadeOut = Threat.Animation:CreateAnimation("Alpha")
    Threat.Animation.FadeOut:SetFromAlpha(1)
    Threat.Animation.FadeOut:SetToAlpha(0.2)
    Threat.Animation.FadeOut:SetDuration(0.8)
    Threat.Animation.FadeOut:SetSmoothing("IN_OUT")

    Frame.Threat = Threat
end