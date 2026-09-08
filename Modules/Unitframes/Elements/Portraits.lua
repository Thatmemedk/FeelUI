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

    if (DB.Global.UnitFrames.PortraitStyle == "3D") then
        local Portrait = CreateFrame("PlayerModel", nil, Frame.Health)
        Portrait:SetFrameStrata(Frame:GetFrameStrata())
        Portrait:SetFrameLevel(Frame:GetFrameLevel() + 1)
        Portrait:SetInside(Frame.Health, 0, 0)
        Portrait:SetAlpha(0.20)

        Frame.Portrait = Portrait
    elseif (DB.Global.UnitFrames.PortraitStyle == "2D") then
        local PortraitFrame = CreateFrame("Frame", nil, Frame.Health)
        PortraitFrame:SetFrameStrata(Frame:GetFrameStrata())
        PortraitFrame:SetFrameLevel(Frame:GetFrameLevel() + 1)
        PortraitFrame:Size(36, 36)
        PortraitFrame:SetTemplate()
        PortraitFrame:CreateShadow()
        PortraitFrame:SetShadowOverlay()

        if (Frame.unit == "target") then
            PortraitFrame:Point("RIGHT", Frame.Health, "RIGHT", 36, 0)
        else
            PortraitFrame:Point("LEFT", Frame.Health, "LEFT", -36, 0)
        end

        local Portrait = PortraitFrame:CreateTexture(nil, "ARTWORK")
        Portrait:SetAllPoints(PortraitFrame)
        UI:KeepPortraitAspectRatio(Portrait)

        Frame.Portrait = Portrait
        Frame.PortraitFrame = PortraitFrame
    end
end