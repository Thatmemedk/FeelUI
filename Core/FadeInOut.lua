local UI, DB, Media, Language = select(2, ...):Call()

local ActiveFades = {}
local FadeUpdater = CreateFrame("Frame")

function UI:FadeOnUpdate(Delta)
    for Frame, Info in pairs(ActiveFades) do
        if Frame:IsVisible() then
            Info.FadeTimer = (Info.FadeTimer or 0) + Delta
        else
            Info.FadeTimer = (Info.TimeToFade or 0) + 1
        end

        if (Info.FadeTimer < Info.TimeToFade or 0.3) then
            if (Info.Mode == "IN") then
                Frame:SetAlpha((Info.FadeTimer / Info.TimeToFade) * Info.DiffAlpha + Info.StartAlpha)
            else
                Frame:SetAlpha(((Info.TimeToFade - Info.FadeTimer) / Info.TimeToFade) * Info.DiffAlpha + Info.EndAlpha)
            end
        else
            Frame:SetAlpha(Info.EndAlpha)

            if (Info.FadeHoldTime and Info.FadeHoldTime > 0) then
                Info.FadeHoldTime = Info.FadeHoldTime - Delta
            else
                UI:UIFrameFadeRemoveFrame(Frame)

                if (Info.FinishedFunc) then
                    if (Info.FinishedArgs) then
                        Info.FinishedFunc(unpack(Info.FinishedArgs))
                    else
                        Info.FinishedFunc()
                    end

                    if (not Info.FinishedFuncKeep) then
                        Info.FinishedFunc = nil
                    end
                end
            end
        end
    end

    if not next(ActiveFades) then
        FadeUpdater:SetScript("OnUpdate", nil)
    end
end

function UI:UIFrameFade(Frame, Info)
    if not Frame or Frame:IsForbidden() then 
        return 
    end

    Frame.FadeObject = Info
    Info.Mode = Info.Mode or "IN"

    if (Info.Mode == "IN") then
        Info.StartAlpha = Info.StartAlpha or 0
        Info.EndAlpha = Info.EndAlpha or 1
        Info.DiffAlpha = Info.EndAlpha - Info.StartAlpha
    else
        Info.StartAlpha = Info.StartAlpha or 1
        Info.EndAlpha = Info.EndAlpha or 0
        Info.DiffAlpha = Info.StartAlpha - Info.EndAlpha
    end

    Frame:SetAlpha(Info.StartAlpha)

    if not Frame:IsProtected() then
        Frame:Show()
    end

    if not ActiveFades[Frame] then
        ActiveFades[Frame] = Info
        FadeUpdater:SetScript("OnUpdate", UI.FadeOnUpdate)
    else
        ActiveFades[Frame] = Info
    end
end

function UI:UIFrameFadeIn(Frame, TimeToFade, StartAlpha, EndAlpha)
    if not Frame or Frame:IsForbidden() then 
        return 
    end

    if (Frame.FadeObject) then
        Frame.FadeObject.FadeTimer = nil
    else
        Frame.FadeObject = {}
    end

    Frame.FadeObject.Mode = "IN"
    Frame.FadeObject.TimeToFade = TimeToFade or 0.3
    Frame.FadeObject.StartAlpha = StartAlpha or (Frame.GetAlpha and Frame:GetAlpha() or 0)
    Frame.FadeObject.EndAlpha = EndAlpha or 1
    Frame.FadeObject.DiffAlpha = (Frame.FadeObject.EndAlpha or 1) - (Frame.FadeObject.StartAlpha or 0)

    UI:UIFrameFade(Frame, Frame.FadeObject)
end

function UI:UIFrameFadeOut(Frame, TimeToFade, StartAlpha, EndAlpha)
    if not Frame or Frame:IsForbidden() then 
        return 
    end

    if (Frame.FadeObject) then
        Frame.FadeObject.FadeTimer = nil
    else
        Frame.FadeObject = {}
    end

    Frame.FadeObject.Mode = "OUT"
    Frame.FadeObject.TimeToFade = TimeToFade or 0.3
    Frame.FadeObject.StartAlpha = StartAlpha or (Frame.GetAlpha and Frame:GetAlpha() or 1)
    Frame.FadeObject.EndAlpha = EndAlpha or 0
    Frame.FadeObject.DiffAlpha = (Frame.FadeObject.StartAlpha or 1) - (Frame.FadeObject.EndAlpha or 0)

    UI:UIFrameFade(Frame, Frame.FadeObject)
end

function UI:UIFrameFadeRemoveFrame(Frame)
    if (Frame and ActiveFades[Frame]) then
        if (Frame.FadeObject) then
            Frame.FadeObject.FadeTimer = nil
        end

        ActiveFades[Frame] = nil
    end
end