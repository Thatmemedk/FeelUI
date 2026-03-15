local UI, DB, Media, Language = select(2, ...):Call()

-- Call Module
local NP = UI:CallModule("NamePlates")

--- HIDE BLIZZARD NP

  local BlizzFrames = {
    "name",
    "castBar",
    "SoftTargetFrame",
    "HealthBarsContainer",
    "RaidTargetFrame",
    "ClassificationFrame",
    "PlayerLevelDiffFrame",
    "aggroHighlight",
    "aggroHighlightBase",
    "aggroHighlightAdditive",
  }

function NP:DisableBlizzard()
    hooksecurefunc(_G.NamePlateDriverFrame, "OnNamePlateAdded", function(_, Unit)
        if (Unit == "preview") then
            return
        end

        local BlizzNP = C_NamePlate.GetNamePlateForUnit(Unit, issecure())

        if (not BlizzNP and Unit) then
            return
        end

        if (not NP.Hooked[BlizzNP.UnitFrame]) then
            NP.Hooked[BlizzNP.UnitFrame] = true

            local NPLocked = true
            hooksecurefunc(BlizzNP.UnitFrame, "SetAlpha", function(Frame)
                if (NPLocked or Frame:IsForbidden()) then
                    return
                end

                NPLocked = true
                Frame:SetAlpha(0)
                NPLocked = false
            end)
        end

        BlizzNP.UnitFrame:SetAlpha(0)
        BlizzNP.UnitFrame:UnregisterAllEvents()

        if (BlizzNP.UnitFrame.castBar) then
            BlizzNP.UnitFrame.castBar:UnregisterAllEvents()
        end

        if (BlizzNP.UnitFrame.WidgetContainer) then
            BlizzNP.UnitFrame.WidgetContainer:SetParent(BlizzNP)
        end

        NP.Modified[Unit] = BlizzNP.UnitFrame
    end)

    hooksecurefunc(_G.NamePlateDriverFrame, "OnNamePlateRemoved", function(_, Unit)
        local BlizzNP = NP.Modified[Unit]

        if (BlizzNP) then
            BlizzNP:UnregisterEvent("UNIT_AURA")

            if (BlizzNP.WidgetContainer) then
                BlizzNP.WidgetContainer:SetParent(BlizzNP)
            end

            NP.Modified[Unit] = nil
        end
    end)
end