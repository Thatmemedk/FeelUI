local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

--- HIDE BLIZZARD NP

function NP:DisableBlizzard()
    hooksecurefunc(_G.NamePlateDriverFrame, "OnNamePlateAdded", function(_, Unit)
        local BlizzNP = C_NamePlate.GetNamePlateForUnit(Unit, issecure())

        if (not BlizzNP and Unit) then
            return
        end

        BlizzNP.UnitFrame:UnregisterAllEvents()
        BlizzNP.UnitFrame:SetAlpha(0)

        if (BlizzNP.UnitFrame.castBar) then
            BlizzNP.UnitFrame.castBar:UnregisterAllEvents()
        end

        hooksecurefunc(BlizzNP.UnitFrame, "SetAlpha", function(Frame)
            if Frame:IsForbidden() or Frame:GetAlpha() == 0 then
                return
            end

            Frame:SetAlpha(0)
        end)

        if (BlizzNP.UnitFrame.WidgetContainer) then
            BlizzNP.UnitFrame.WidgetContainer:SetParent(BlizzNP)
        end

        NP.Hooked[Unit] = BlizzNP.UnitFrame
    end)

    hooksecurefunc(_G.NamePlateDriverFrame, "OnNamePlateRemoved", function(_, Unit)
        local BlizzNP = NP.Hooked[Unit]

        if (not BlizzNP and Unit) then
            return
        end

        if (BlizzNP.WidgetContainer) then
            BlizzNP.WidgetContainer:SetParent(BlizzNP)
        end

        NP.Hooked[Unit] = nil
    end)
end