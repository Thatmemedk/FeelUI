local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreateCombatIcon(Frame)
    local CombatIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    CombatIcon:Size(24, 24)
    CombatIcon:Point("CENTER", Frame, 0, 0)
    CombatIcon:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
    CombatIcon:SetTexCoord(0.5, 1, 0, 0.49)
    CombatIcon:Hide()

    Frame.CombatIcon = CombatIcon
end
        
function UF:CreateRestingIcon(Frame)
    local RestingIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    RestingIcon:Size(24, 24)
    RestingIcon:Point("TOP", Frame, 0, 18)
    RestingIcon:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
    RestingIcon:SetTexCoord(0, 0.5, 0, 0.421875)
    RestingIcon:Hide()

    Frame.RestingIcon = RestingIcon
end

function UF:CreateRaidIcon(Frame)
    local RaidIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    RaidIcon:Size(32, 32)
    RaidIcon:Point("TOP", Frame, 0, 18)
    RaidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
    RaidIcon:Hide()
    
    Frame.RaidIcon = RaidIcon
end

function UF:CreateReadyCheckIcon(Frame)
    local ReadyCheckIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    ReadyCheckIcon:Size(24, 24)
    ReadyCheckIcon:Point("CENTER", Frame.Health, 0, 0)
    
    Frame.ReadyCheckIcon = ReadyCheckIcon
end

function UF:CreateResurrectIcon(Frame)
    local ResurrectIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    ResurrectIcon:Size(28, 28)
    ResurrectIcon:Point("CENTER", Frame.Health, 0, 0)

    Frame.ResurrectIcon = ResurrectIcon
end

function UF:CreateLeaderIcon(Frame)
    local LeaderIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    LeaderIconLeaderIcon:Size(11, 11)
    LeaderIcon:Point("TOPLEFT", Frame.Health, -4, 0)
    
    Frame.LeaderIcon = LeaderIcon
end

function UF:CreateAssistantIcon(Frame)
    local AssistantIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    AssistantIcon:Size(11, 11)
    AssistantIcon:Point("TOPLEFT", Frame.Health, -4, 0)
    
    Frame.AssistantIcon = AssistantIcon
end

function UF:CreateRoleIcon(Frame)
    local RoleIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    RoleIcon:Size(11, 11)
    RoleIcon:Point("TOP", Frame.Health, 0, 0)
    
    Frame.RoleIcon = RoleIcon
end

function UF:CreatePhaseIcon(Frame)
    local PhaseIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    PhaseIcon:Size(22, 22)
    PhaseIcon:Point("CENTER", Frame.Health, 0, 0)

    Frame.PhaseIcon = PhaseIcon
end

function UF:CreateSummonIcon(Frame)
    local SummonIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    SummonIcon:Size(32, 32)
    SummonIcon:Point("CENTER", Frame.Health, 0, 0)

    Frame.SummonIcon = SummonIcon
end