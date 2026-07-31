local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local select = select
local unpack = unpack
local next = next

-- Locals
UI.FadeFrames = {}
UI.FadeManager = {}
UI.FadeManager.Frame = CreateFrame("Frame")
UI.FadeManager.Delay = 0

function UI:UIFrameFadeOnUpdate(Elapsed)
    UI.FadeManager.Timer = (UI.FadeManager.Timer or 0) + Elapsed

    if (UI.FadeManager.Timer > UI.FadeManager.Delay) then
        UI.FadeManager.Timer = 0

        for Frame, Info in next, UI.FadeFrames do
            if (Frame:IsVisible()) then
                Info.FadeTimer = (Info.FadeTimer or 0) + (Elapsed + UI.FadeManager.Delay)
            else
                Info.FadeTimer = Info.TimeToFade + 1
            end

            if (Info.FadeTimer < Info.TimeToFade) then
                if (Info.Mode == "IN") then
                    Frame:SetAlpha((Info.FadeTimer / Info.TimeToFade) * Info.DiffAlpha + Info.StartAlpha)
                else
                    Frame:SetAlpha(((Info.TimeToFade - Info.FadeTimer) / Info.TimeToFade) * Info.DiffAlpha + Info.EndAlpha)
                end
            else
                Frame:SetAlpha(Info.EndAlpha)

                if (Info.FadeHoldTime and Info.FadeHoldTime > 0) then
                    Info.FadeHoldTime = Info.FadeHoldTime - Elapsed
                else
                    UI:UIFrameFadeRemoveFrame(Frame)

                    if (Info.FinishedFunc) then
                        if (Info.FinishedArgs) then
                            Info.FinishedFunc(unpack(Info.FinishedArgs))
                        else
                            Info.FinishedFunc(
                                Info.FinishedArg1,
                                Info.FinishedArg2,
                                Info.FinishedArg3,
                                Info.FinishedArg4,
                                Info.FinishedArg5
                            )
                        end

                        if (not Info.FinishedFuncKeep) then
                            Info.FinishedFunc = nil
                        end
                    end
                end
            end
        end

        if (not next(UI.FadeFrames)) then
            UI.FadeManager.Frame:SetScript("OnUpdate", nil)
        end
    end
end

function UI:UIFrameFade(Frame, Info)
    if (not Frame or Frame:IsForbidden()) then
        return
    end

    Frame.FadeInfo = Info
    Info.Mode = Info.Mode or "IN"

    if (Info.Mode == "IN") then
        Info.StartAlpha = Info.StartAlpha or 0
        Info.EndAlpha = Info.EndAlpha or 1
        Info.DiffAlpha = Info.DiffAlpha or Info.EndAlpha - Info.StartAlpha
    else
        Info.StartAlpha = Info.StartAlpha or 1
        Info.EndAlpha = Info.EndAlpha or 0
        Info.DiffAlpha = Info.DiffAlpha or Info.StartAlpha - Info.EndAlpha
    end

    Frame:SetAlpha(Info.StartAlpha)

    if (not Frame:IsProtected()) then
        Frame:Show()
    end

    UI.FadeFrames[Frame] = Info
    UI.FadeManager.Frame:SetScript("OnUpdate", UI.UIFrameFadeOnUpdate)
end

function UI:UIFrameFadeIn(Frame, TimeToFade, StartAlpha, EndAlpha)
    if (not Frame or Frame:IsForbidden()) then
        return
    end

    Frame.FadeObject = Frame.FadeObject or {}
    Frame.FadeObject.FadeTimer = nil

    Frame.FadeObject.Mode = "IN"
    Frame.FadeObject.TimeToFade = TimeToFade
    Frame.FadeObject.StartAlpha = StartAlpha
    Frame.FadeObject.EndAlpha = EndAlpha
    Frame.FadeObject.DiffAlpha = EndAlpha - StartAlpha

    UI:UIFrameFade(Frame, Frame.FadeObject)
end

function UI:UIFrameFadeOut(Frame, TimeToFade, StartAlpha, EndAlpha)
    if (not Frame or Frame:IsForbidden()) then
        return
    end

    Frame.FadeObject = Frame.FadeObject or {}
    Frame.FadeObject.FadeTimer = nil

    Frame.FadeObject.Mode = "OUT"
    Frame.FadeObject.TimeToFade = TimeToFade
    Frame.FadeObject.StartAlpha = StartAlpha
    Frame.FadeObject.EndAlpha = EndAlpha
    Frame.FadeObject.DiffAlpha = StartAlpha - EndAlpha

    UI:UIFrameFade(Frame, Frame.FadeObject)
end

function UI:UIFrameFadeRemoveFrame(Frame)
    if (Frame and UI.FadeFrames[Frame]) then
        if (Frame.FadeObject) then
            Frame.FadeObject.FadeTimer = nil
        end

        UI.FadeFrames[Frame] = nil
    end
end