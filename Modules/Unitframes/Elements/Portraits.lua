local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:CreatePortrait(Frame)
    if (Frame.Portrait) then
        return
    end
    
    if (not DB.Global.UnitFrames.Portraits) then 
        return
    end

    local Portrait = CreateFrame("PlayerModel", nil, Frame.Health)
    Portrait:SetFrameStrata(Frame:GetFrameStrata())
    Portrait:SetFrameLevel(Frame:GetFrameLevel() + 1)
    Portrait:SetInside(Frame.Health, 0, 0)
    Portrait:SetAlpha(0.20)

    Frame.Portrait = Portrait
end