local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AF = UI:RegisterModule("AlertFrame")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function AF.AdjustQueuedAnchors(System, Frame)
    for Alert in System.alertFramePool:EnumerateActive() do
        Alert:ClearAllPoints()
        Alert:Point("TOP", Frame, "BOTTOM", 0, 0)

        Frame = Alert
    end

    return Frame
end

function AF.AdjustAnchors(System, Frame)
    local Alert = System.alertFrame

    if (Alert and Alert:IsShown()) then
        Alert:ClearAllPoints()
        Alert:Point("TOP", Frame, "BOTTOM", 0, 0)

        return Alert
    end

    return Frame
end

function AF.AdjustAnchorsNonAlert(System, Frame)
    local AnchorFrame = System.anchorFrame
    
    if (AnchorFrame and AnchorFrame:IsShown()) then
        AnchorFrame:ClearAllPoints()
        AnchorFrame:Point("TOP", Frame, "BOTTOM", 0, 0)

        return AnchorFrame
    end

    return Frame
end

function AF:AdjustPosition(System)
    if (System.alertFramePool) then
        System.AdjustAnchors = AF.AdjustQueuedAnchors
    elseif (not System.anchorFrame) then
        System.AdjustAnchors = AF.AdjustAnchors
    else
        System.AdjustAnchors = AF.AdjustAnchorsNonAlert
    end
end

function AF:Create()
    local Frame = CreateFrame("Frame", "FeelUI_AlertFrameHolder", _G.UIParent)
    Frame:Size(180, 20)
    Frame:Point("TOP", _G.UIParent, "TOP", 0, -52)

    self.Frame = Frame
end

function AF:AddHooks()
    _G.AlertFrame:ClearAllPoints()
    _G.AlertFrame:SetAllPoints(self.Frame)

    for _, System in ipairs(_G.AlertFrame.alertFrameSubSystems) do
        self:AdjustPosition(System)
    end

    hooksecurefunc(_G.AlertFrame, "AddAlertFrameSubSystem", function(_, System)
        self:AdjustPosition(System)
    end)
end

function AF:Initialize()
    self:Create()
    self:AddHooks()
end