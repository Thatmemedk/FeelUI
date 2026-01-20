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
    RestingIcon:Size(30, 30)
    RestingIcon:Point("TOP", Frame, 12, 22)
    RestingIcon:SetAtlas("UI-HUD-UnitFrame-Player-Rest-Flipbook")
    RestingIcon:SetAlpha(0)

    RestingIcon.Animation = RestingIcon:CreateAnimationGroup()
    RestingIcon.Animation:SetLooping("REPEAT")
    RestingIcon.Animation:SetToFinalAlpha(true)

    RestingIcon.AnimationFrame = RestingIcon.Animation:CreateAnimation("FlipBook")
    RestingIcon.AnimationFrame:SetTarget(RestingIcon)
    RestingIcon.AnimationFrame:SetDuration(2)
    RestingIcon.AnimationFrame:SetFlipBookRows(7)
    RestingIcon.AnimationFrame:SetFlipBookColumns(6)
    RestingIcon.AnimationFrame:SetFlipBookFrames(42)
    RestingIcon.AnimationFrame:SetSmoothing("NONE")

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

    ReadyCheckIcon.Animation = ReadyCheckIcon:CreateAnimationGroup()

    ReadyCheckIcon.AnimationFrame = ReadyCheckIcon.Animation:CreateAnimation("Alpha")
    ReadyCheckIcon.AnimationFrame:SetFromAlpha(1)
    ReadyCheckIcon.AnimationFrame:SetToAlpha(0)
    ReadyCheckIcon.AnimationFrame:SetDuration(2)
    ReadyCheckIcon.AnimationFrame:SetStartDelay(10)

    ReadyCheckIcon.Animation:SetScript("OnFinished", function()
        ReadyCheckIcon:Hide()
    end)

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