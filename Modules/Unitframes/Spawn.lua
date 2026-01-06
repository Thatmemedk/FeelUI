local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- SPAWN THE UNITFRAMES

function UF:Spawn(Unit, Width, Height, Orientation)
    if (not Unit) then 
        return 
    end

    -- CHECK IF FRAME ALREADY EXISTS
    if (self.Frames[Unit]) then
        return self.Frames[Unit]
    end

    local Frame = CreateFrame("Button", "FeelUI_"..Unit, UF.SecureFrame, "SecureUnitButtonTemplate, PingableUnitFrameTemplate")
    Frame.unit = Unit

    Frame:Size(Width or 228, Height or 36)
    Frame:SetAttribute("unit", Unit)

    Frame:RegisterForClicks("AnyUp")
    Frame:SetAttribute("type1", "target")
    Frame:SetAttribute("type2", "togglemenu")

    -- REGISTER
    RegisterUnitWatch(Frame)

    -- STORE IN CACHE
    self.Frames[Unit] = Frame

    if (Unit == "player") then
        UF:CreatePlayer(Frame, Height, Orientation)
    elseif (Unit == "target") then
        UF:CreateTarget(Frame, Height, Orientation)
    elseif (Unit == "targettarget") then
        UF:CreateTargetTarget(Frame, Height, Orientation)
    elseif (Unit == "pet") then
        UF:CreatePet(Frame, Height, Orientation)
    elseif (Unit == "focus") then
        UF:CreateFocus(Frame, Height, Orientation)
    elseif (Unit:match("^boss%d$")) then
        UF:CreateBoss(Frame, Height, Orientation)
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