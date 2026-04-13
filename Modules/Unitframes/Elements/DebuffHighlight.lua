local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

UF.DebuffIcons = {
    Magic = "RaidFrame-Icon-DebuffMagic",
    Curse = "RaidFrame-Icon-DebuffCurse",
    Disease = "RaidFrame-Icon-DebuffDisease",
    Poison = "RaidFrame-Icon-DebuffPoison",
    Bleed = "RaidFrame-Icon-DebuffBleed",
}

function UF:CreateDebuffHighlight(Frame)
    if (Frame.DebuffHighlight) then
        return
    end

    local DebuffHighlight = CreateFrame("Frame", nil, Frame)
    DebuffHighlight:SetInside(Frame, 1, 1)
    DebuffHighlight:CreateGlow(2.5, 3, 0, 0, 0, 0)

    Frame.DebuffHighlight = DebuffHighlight
end

function UF:CreateDebuffIcon(Frame)
    if (Frame.DebuffIcon) then
        return
    end

    local DebuffIcon = CreateFrame("Frame", nil, Frame.InvisFrameHigher)
    DebuffIcon:Hide()

    DebuffIcon.Texture = DebuffIcon:CreateTexture(nil, "OVERLAY")
    DebuffIcon.Texture:SetAllPoints()
    DebuffIcon.Texture:SetAtlas(UF.DebuffIcons)

    Frame.DebuffIcon = DebuffIcon
end