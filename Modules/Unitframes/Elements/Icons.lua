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
    RestingIcon:SetAlpha(0)

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

function UF:CreateResurrectIcon(Frame)
    local ResurrectIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    ResurrectIcon:Size(28, 28)
    ResurrectIcon:Point("CENTER", Frame.Health, 0, 0)
    ResurrectIcon:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
    ResurrectIcon:Hide()

    Frame.ResurrectIcon = ResurrectIcon
end

function UF:CreateLeaderIcon(Frame)
    local LeaderIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    LeaderIcon:Size(11, 11)
    LeaderIcon:Point("TOPLEFT", Frame.Health, -4, 0)
    LeaderIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
    LeaderIcon:SetTexCoord(0, 1, 0, 1)
    LeaderIcon:Hide()
    
    Frame.LeaderIcon = LeaderIcon
end

function UF:CreateAssistantIcon(Frame)
    local AssistantIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    AssistantIcon:Size(11, 11)
    AssistantIcon:Point("TOPLEFT", Frame.Health, -4, 0)
    AssistantIcon:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
    AssistantIcon:Hide()
    
    Frame.AssistantIcon = AssistantIcon
end

function UF:CreateReadyCheckIcon(Frame)
    local ReadyCheckIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    ReadyCheckIcon:Size(24, 24)
    ReadyCheckIcon:Point("CENTER", Frame.Health, 0, 0)
    ReadyCheckIcon:Hide()

    local Animation = ReadyCheckIcon:CreateAnimationGroup()

    local Fade = Animation:CreateAnimation("Alpha")
    Fade:SetFromAlpha(1)
    Fade:SetToAlpha(0)
    Fade:SetDuration(1.5)
    Fade:SetStartDelay(10)

    Animation:SetScript("OnFinished", function()
        ReadyCheckIcon:Hide()
    end)

    Frame.Animation = Animation
    Frame.ReadyCheckIcon = ReadyCheckIcon
end

function UF:CreateSummonIcon(Frame)
    local SummonIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    SummonIcon:Size(32, 32)
    SummonIcon:Point("CENTER", Frame.Health, 0, 0)
    SummonIcon:Hide()

    Frame.SummonIcon = SummonIcon
end

function UF:CreatePhaseIcon(Frame)
    local PhaseIcon = Frame.InvisFrameHigher:CreateTexture(nil, "OVERLAY", nil, 7)
    PhaseIcon:Size(22, 22)
    PhaseIcon:Point("CENTER", Frame.Health, 0, 0)
    PhaseIcon:SetTexture([[Interface\TargetingFrame\UI-PhasingIcon]])
    PhaseIcon:Hide()

    Frame.PhaseIcon = PhaseIcon
end