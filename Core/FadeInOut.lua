local UI, DB, Media, Language = select(2, ...):Call()

local ActiveFades = {}
local FadeUpdater = CreateFrame("Frame")

function UI:EaseInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        local f = (2 * t) - 2
        return 0.5 * f * f * f + 1
    end
end

function UI:FadeOnUpdate(Delta)
    for Frame, Info in pairs(ActiveFades) do
        Info.Elapsed = (Info.Elapsed or 0) + Delta

        if (not Info.TimeToFade or Info.TimeToFade <= 0) then
            Info.TimeToFade = 0.000001
        end

        local Progress = math.min(Info.Elapsed / Info.TimeToFade, 1)
        local Ease = UI:EaseInOutCubic(Progress)

        if (Info.Mode == "IN") then
            Frame:SetAlpha(Info.StartAlpha + Info.DiffAlpha * Ease)
        else
            Frame:SetAlpha(Info.EndAlpha + Info.DiffAlpha * (1 - Ease))
        end

        if (Progress >= 1) then
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
        Info.DiffAlpha = Info.DiffAlpha or (Info.EndAlpha - Info.StartAlpha)

        if not Frame:IsProtected() then
            Frame:Show()
        end
    else
        Info.StartAlpha = Info.StartAlpha or 1
        Info.EndAlpha = Info.EndAlpha or 0
        Info.DiffAlpha = Info.DiffAlpha or (Info.StartAlpha - Info.EndAlpha)
    end

    Info.Elapsed = 0
    Frame:SetAlpha(Info.StartAlpha)

    if not ActiveFades[Frame] then
        ActiveFades[Frame] = Info
        FadeUpdater:SetScript("OnUpdate", UI.FadeOnUpdate)
    else
        ActiveFades[Frame] = Info
    end
end

function UI:UIFrameFadeIn(Frame, Duration, StartAlpha, TargetAlpha, HoldTime)
    if not Frame or Frame:IsForbidden() then 
        return 
    end

    local Info = {
        Mode = "IN",
        TimeToFade = Duration or 0.3,
        StartAlpha = StartAlpha or (Frame.GetAlpha and Frame:GetAlpha() or 0),
        EndAlpha = TargetAlpha or 1,
        DiffAlpha = (TargetAlpha or 1) - (StartAlpha or (Frame.GetAlpha and Frame:GetAlpha() or 0)),
        FadeHoldTime = HoldTime or 0,
        FinishedFunc = Frame.FadeCallback,
        FinishedArgs = Frame.FadeArgs
    }

    UI:UIFrameFade(Frame, Info)
end

function UI:UIFrameFadeOut(Frame, Duration, StartAlpha, TargetAlpha, HoldTime)
    if not Frame or Frame:IsForbidden() then 
        return 
    end

    local Info = {
        Mode = "OUT",
        TimeToFade = Duration or 0.3,
        StartAlpha = StartAlpha or (Frame.GetAlpha and Frame:GetAlpha() or 1),
        EndAlpha = TargetAlpha or 0,
        DiffAlpha = (StartAlpha or (Frame.GetAlpha and Frame:GetAlpha() or 1)) - (TargetAlpha or 0),
        FadeHoldTime = HoldTime or 0,
        FinishedFunc = Frame.FadeCallback,
        FinishedArgs = Frame.FadeArgs
    }

    UI:UIFrameFade(Frame, Info)
end

function UI:UIFrameFadeRemoveFrame(Frame)
    if Frame and ActiveFades[Frame] then
        if Frame.FadeObject then
            Frame.FadeObject.Elapsed = nil
        end

        ActiveFades[Frame] = nil
    end
end