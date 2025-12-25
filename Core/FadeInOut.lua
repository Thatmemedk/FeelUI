local UI, DB, Media, Language = select(2, ...):Call()

UI.FadeUpdater = CreateFrame("Frame")
UI.ActiveFades = {}
UI.TickDelay = 0

function UI:EaseInOutCubic(Time)
    if (Time < 0.5) then
        return 4 * Time * Time * Time
    else
        local AdjustedTime = (2 * Time) - 2
        return 0.5 * AdjustedTime * AdjustedTime * AdjustedTime + 1
    end
end

function UI:FadeOnUpdate(Elapsed)
    UI.FadeUpdater.Timer = (UI.FadeUpdater.Timer or 0) + Elapsed

    if (UI.FadeUpdater.Timer > UI.TickDelay) then
        UI.FadeUpdater.Timer = 0

        for Frame, Data in next, UI.ActiveFades do
            if (Frame:IsVisible()) then
                Data.FadeTimer = (Data.FadeTimer or 0) + (Elapsed + UI.TickDelay)
            else
                Data.FadeTimer = (Data.TimeToFade or 0.3) + 1
            end

            local Progress = math.min((Data.FadeTimer or 0) / (Data.TimeToFade or 0.3), 1)
            local Ease = UI:EaseInOutCubic(Progress)

            if (Progress < 1) then
                if (Data.Mode == "IN") then
                    Frame:SetAlpha(Data.StartAlpha + Data.DiffAlpha * Ease)
                else
                    Frame:SetAlpha(Data.EndAlpha + Data.DiffAlpha * (1 - Ease))
                end
            else
                Frame:SetAlpha(Data.EndAlpha)
                UI:UIFrameFadeRemove(Frame)
            end
        end

        if (not next(UI.ActiveFades)) then
            UI.FadeUpdater:SetScript("OnUpdate", nil)
        end
    end
end

function UI:UIFrameFade(Frame, Data)
    if (not Frame or Frame:IsForbidden()) then
        return
    end

    Frame.Fader = Data

    if (not Data.Mode) then
        Data.Mode = "IN"
    end

    if (Data.Mode == "IN") then
        Data.StartAlpha = (Data.StartAlpha == nil and 0 or Data.StartAlpha)
        Data.EndAlpha = (Data.EndAlpha == nil and 1 or Data.EndAlpha)
        Data.DiffAlpha = (Data.DiffAlpha == nil and (Data.EndAlpha - Data.StartAlpha) or Data.DiffAlpha)
    else
        Data.StartAlpha = (Data.StartAlpha == nil and 1 or Data.StartAlpha)
        Data.EndAlpha = (Data.EndAlpha == nil and 0 or Data.EndAlpha)
        Data.DiffAlpha = (Data.DiffAlpha == nil and (Data.StartAlpha - Data.EndAlpha) or Data.DiffAlpha)
    end

    Frame:SetAlpha(Data.StartAlpha)

    if (not Frame:IsProtected()) then
        Frame:Show()
    end

    if (not UI.ActiveFades[Frame]) then
        UI.ActiveFades[Frame] = Data
        UI.FadeUpdater:SetScript("OnUpdate", UI.FadeOnUpdate)
    else
        UI.ActiveFades[Frame] = Data
    end
end

function UI:UIFrameFadeIn(Frame, TimeToFade, StartAlpha, EndAlpha)
    if (not Frame or Frame:IsForbidden()) then
        return
    end

    if (Frame.Fader) then
        Frame.Fader.FadeTimer = nil
    else
        Frame.Fader = {}
    end

    Frame.Fader.Mode = "IN"
    Frame.Fader.TimeToFade = TimeToFade
    Frame.Fader.StartAlpha = StartAlpha
    Frame.Fader.EndAlpha = EndAlpha
    Frame.Fader.DiffAlpha = EndAlpha - StartAlpha

    UI:UIFrameFade(Frame, Frame.Fader)
end

function UI:UIFrameFadeOut(Frame, TimeToFade, StartAlpha, EndAlpha)
    if (not Frame or Frame:IsForbidden()) then
        return
    end

    if (Frame.Fader) then
        Frame.Fader.FadeTimer = nil
    else
        Frame.Fader = {}
    end

    Frame.Fader.Mode = "OUT"
    Frame.Fader.TimeToFade = TimeToFade
    Frame.Fader.StartAlpha = StartAlpha
    Frame.Fader.EndAlpha = EndAlpha
    Frame.Fader.DiffAlpha = StartAlpha - EndAlpha

    UI:UIFrameFade(Frame, Frame.Fader)
end

function UI:UIFrameFadeRemove(Frame)
    if (Frame and UI.ActiveFades[Frame]) then
        if (Frame.Fader) then
            Frame.Fader.FadeTimer = nil
        end

        UI.ActiveFades[Frame] = nil
    end
end