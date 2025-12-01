local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreatePortrait(Frame)
    local Portrait = CreateFrame("PlayerModel", nil, Frame)
    Portrait:SetFrameStrata(Frame:GetFrameStrata())
    Portrait:SetFrameLevel(Frame:GetFrameLevel() + 1)
    Portrait:SetInside(Frame, 1, 1)
    Portrait:SetAlpha(0.20)
    Portrait:SetCamDistanceScale(2.5)
    Portrait:SetPortraitZoom(1)
    Portrait:SetPosition(0, 0, 0)

    Frame.Portrait = Portrait
end