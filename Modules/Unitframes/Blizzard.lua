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

    local PetFrame = Frame.petFrame or Frame.PetFrame
    local TargetTargetFrame = Frame.totFrame
    local Health = Frame.healthBar or Frame.healthbar or Frame.HealthBar
    local Power = Frame.manabar or Frame.ManaBar
    local BuffFrame = Frame.BuffFrame
    local DebuffFrame = Frame.DebuffFrame
    local CCFrame = Frame.CcRemoverFrame
    local CastBar = Frame.castBar or Frame.spellbar or Frame.CastingBarFrame
    local AltPowerBar = Frame.powerBarAlt or Frame.PowerBarAlt
    local ClassPowerBar = Frame.classPowerBar

    if (PetFrame) then
        PetFrame:UnregisterAllEvents()
    end

    if (TargetTargetFrame) then
        TargetTargetFrame:UnregisterAllEvents()
    end

    if (Health) then
        Health:UnregisterAllEvents()
    end

    if (Power) then
        Power:UnregisterAllEvents()
    end

    if (BuffFrame) then
        BuffFrame:UnregisterAllEvents()
    end

    if (DebuffFrame) then
        DebuffFrame:UnregisterAllEvents()
    end

    if (CCFrame) then
        CCFrame:UnregisterAllEvents()
    end

    if (CastBar) then
        CastBar:UnregisterAllEvents()
    end

    if (AltPowerBar) then
        AltPowerBar:UnregisterAllEvents()
    end

    if (ClassPowerBar) then
        ClassPowerBar:UnregisterAllEvents()
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