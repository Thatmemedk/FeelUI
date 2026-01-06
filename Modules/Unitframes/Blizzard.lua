local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

--- HIDE BLIZZARD UF

function UF:SafeHide(Frame, SkipParent)
    if (not Frame or UF.Frames.Hidden[Frame]) then 
        return 
    end

    Frame:UnregisterAllEvents()
    Frame:Hide()

    if (not SkipParent and UI.HiddenParent and not InCombatLockdown()) then
        Frame:SetParent(UI.HiddenParent)
    end

    UF.Frames.Hidden[Frame] = true
end

function UF:DisableBlizzard()
    UF:SafeHide(_G.PlayerFrame)
    UF:SafeHide(_G.TargetFrame)
    UF:SafeHide(_G.FocusFrame)
    UF:SafeHide(_G.TargetFrameToT)
    UF:SafeHide(_G.PetFrame)

    if (_G.PlayerCastingBarFrame) then
        UF:SafeHide(_G.PlayerCastingBarFrame)
    end

    if (_G.PetCastingBarFrame) then
        UF:SafeHide(_G.PetCastingBarFrame)
    end

    if (_G.TargetFrameSpellBar) then
        UF:SafeHide(_G.TargetFrameSpellBar)
    end

    if (_G.FocusFrameSpellBar) then
        UF:SafeHide(_G.FocusFrameSpellBar)
    end

    for i = 1, 5 do
        UF:SafeHide(_G["Boss" .. i .. "TargetFrameSpellBar"])
        UF:SafeHide(_G["Boss"..i.."TargetFrame"])
    end

    UF:SafeHide(_G.PartyFrame)

    for Frames in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        UF:SafeHide(Frames)
    end

    for i = 1, _G.MEMBERS_PER_RAID_GROUP do
        UF:SafeHide(_G["CompactPartyFrameMember"..i])
    end

    if (_G.CompactRaidFrameManager) then
        UF:SafeHide(_G.CompactRaidFrameManager)
    end

    if (CompactRaidFrameManager_SetSetting) then
        CompactRaidFrameManager_SetSetting("IsShown", "0")
    end
end