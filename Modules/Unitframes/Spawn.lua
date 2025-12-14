local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

--- HIDE BLIZZARD UF

function UF:SafeHide(Frame, SkipParent)
    if (not Frame or UF.HiddenFrames[Frame]) then 
        return 
    end

    Frame:UnregisterAllEvents()
    Frame:Hide()

    if (not SkipParent and UI.HiddenParent and not InCombatLockdown()) then
        Frame:SetParent(UI.HiddenParent)
    end

    UF.HiddenFrames[Frame] = true
end

function UF:HideBlizzardFrames()
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

-- SPAWN THE UNITFRAMES

function UF:Spawn(Unit, Width, Height, Orientation)
    if (not Unit) then 
        return 
    end

    local Frame = CreateFrame("Button", "FeelUI_" .. Unit, UF.SecureFrame, "SecureUnitButtonTemplate, PingableUnitFrameTemplate")
    Frame.unit = Unit

    Frame:Size(Width or 228, Height or 36)
    Frame:SetAttribute("unit", Unit)

    if (not Frame.UnitWatchRegistered) then
        RegisterUnitWatch(Frame)
        
        Frame.UnitWatchRegistered = true
    end

    Frame:RegisterForClicks("AnyUp")
    Frame:SetAttribute("type1", "target")
    Frame:SetAttribute("type2", "togglemenu")
    Frame:SetAttribute("toggleForVehicle", true)

    -- STORE IN CACHE
    self.Frames[Unit] = Frame

    -- CREATE ELEMENTS
    self:CreateOnEnterLeave(Frame)
    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateFadeInOut(Frame)
    -- HEALTH
    self:CreateHealth(Frame, Height, Orientation)
    -- ICONS
    self:CreateRaidIcon(Frame)

    if (Unit == "player") then
        -- TEXTS
        self:CreatePlayerTexts(Frame)
        -- HEALTH PRED
        self:CreateHealthPrediction(Frame)
        -- ICONS
        self:CreateCombatIcon(Frame)
        self:CreateRestingIcon(Frame)
        self:CreateResurrectIcon(Frame)
        self:CreateLeaderIcon(Frame)
        self:CreateAssistantIcon(Frame)
        self:CreateSummonIcon(Frame)
        -- CASTBAR
        self:CreatePlayerCastbar(Frame)
        -- PORTRAITS
        self:CreatePortrait(Frame)
        -- ADDITIONAL POWER
        self:CreateAdditionalPower(Frame)
    elseif (Unit == "target") then
        -- TEXTS
        self:CreateTargetTexts(Frame)
        -- ICONS
        self:CreateSummonIcon(Frame)
        self:CreatePhaseIcon(Frame)
        -- CASTBARS
        self:CreateTargetCastbar(Frame)
        -- PORTRAITS
        self:CreatePortrait(Frame)
        -- HEALTH PRED
        self:CreateHealthPrediction(Frame)
        -- AURAS
        self:CreateBuffs(Frame)
        self:CreateDebuffs(Frame)
        -- THREAT
        self:CreateThreatHighlight(Frame)
    elseif (Unit == "targettarget") then
        -- TEXT
        self:CreateNameTextCenter(Frame)
        -- THREAT
        self:CreateThreatHighlight(Frame)
    elseif (Unit == "pet") then
        -- TEXT
        self:CreateNameTextCenter(Frame)
        -- THREAT
        self:CreateThreatHighlight(Frame)
        -- CASTBAR
        self:CreatePetCastbar(Frame)
    elseif (Unit == "focus") then
        -- TEXT
        self:CreateNameTextCenter(Frame)
        -- THREAT
        self:CreateThreatHighlight(Frame)
        -- CASTBAR
        self:CreateFocusCastbar(Frame)
    elseif (Unit:match("^boss%d$")) then
        -- TEXT
        self:CreateTargetTexts(Frame)
        -- THREAT
        self:CreateThreatHighlight(Frame)
        -- CASTBAR
        self:CreateBossCastbar(Frame)
    end

    return Frame
end

--- CREATE UNITFRAMES

function UF:CreateUF()
    -- PLAYER
    local Player = UF:Spawn("player", 228, 36)
    Player:Point(unpack(DB.Global.UnitFrames.PlayerPoint))

    -- TARGET
    local Target = UF:Spawn("target", 228, 36)
    Target:Point(unpack(DB.Global.UnitFrames.TargetPoint))

    -- TARGET OF TARGET
    local TargetTarget = UF:Spawn("targettarget", 114, 28)
    TargetTarget:Point("BOTTOMRIGHT", Target, 0, -58)

    -- FOCUS
    local Focus = UF:Spawn("focus", 114, 28)
    Focus:Point("BOTTOMRIGHT", TargetTarget, 0, -42)

    -- PET
    local Pet = UF:Spawn("pet", 114, 28)
    Pet:Point("BOTTOMLEFT", Player, 0, -58)

    -- BOSS FRAMES
    for i = 1, 5 do
        local Boss = UF:Spawn("boss"..i, 204, 36)

        if (i == 1) then
            Boss:Point(unpack(DB.Global.UnitFrames.BossPoint))
        else
            Boss:Point("BOTTOM", self.Frames["boss"..(i-1)], "TOP", 0, 28)
        end
    end

    -- PARTY FRAMES
    if (DB.Global.UnitFrames.PartyFrames) then
        local Party = UF:SpawnGroupHeader("party")
        Party:Point(unpack(DB.Global.UnitFrames.PartyPoint))

        self.Frames.Party = Party
    end

    -- RAID FRAMES
    if (DB.Global.UnitFrames.RaidFrames) then
        local Raid = UF:SpawnGroupHeader("raid")
        Raid:Point(unpack(DB.Global.UnitFrames.RaidPoint))

        self.Frames.Raid = Raid
    end

    -- CACHE REFERENCES
    self.Frames.Player = Player
    self.Frames.Target = Target
    self.Frames.TargetTarget = TargetTarget
    self.Frames.Focus = Focus
    self.Frames.Pet = Pet
end