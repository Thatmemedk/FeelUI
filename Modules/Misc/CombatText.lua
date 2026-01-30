local UI, DB, Media, Language = select(2, ...):Call()

local SCT = UI:RegisterModule("SCT")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function SCT:Create()
    local Frame = CreateFrame("Frame", "FeelUI_SCT", _G.UIParent)
    Frame:Size(26, 26)
    Frame:Point("CENTER", _G.UIParent, 0, 0)
    Frame:SetAlpha(0)

    -- TEXT
    local Text = Frame:CreateFontString(nil, "OVERLAY")
    Text:Point("CENTER", Frame, 0, 0)
    Text:SetFontTemplate("CombatText", 18)

    -- ANIMATION
    local Animation = Frame:CreateAnimationGroup()

    -- MOVE DOWN
    local Move = Animation:CreateAnimation("Translation")
    Move:SetOffset(0, 0)
    Move:SetDuration(1.5)
    Move:SetSmoothing("OUT")

    -- FADE IN
    local FadeIn = Animation:CreateAnimation("Alpha")
    FadeIn:SetFromAlpha(0)
    FadeIn:SetToAlpha(1)
    FadeIn:SetDuration(0.35)
    FadeIn:SetSmoothing("IN_OUT")

    -- FADE OUT
    local FadeOut = Animation:CreateAnimation("Alpha")
    FadeOut:SetFromAlpha(1)
    FadeOut:SetToAlpha(0)
    FadeOut:SetDuration(0.5)
    FadeOut:SetStartDelay(1)
    FadeOut:SetSmoothing("OUT_IN")

    -- ON PLAY
    Animation:SetScript("OnPlay", function()
        Frame:SetAlpha(0)
        Frame:Point("CENTER", _G.UIParent, 0, 0)

        local Direction = math.random(0, 1) == 1 and 62 or -62
        Move:SetOffset(0, Direction)
    end)

    -- CACHE
    self.Frame = Frame
    self.Text = Text
    self.Animation = Animation
end

function SCT:OnEvent(event)
    if (event == "PLAYER_REGEN_DISABLED") then
        self.Text:SetText("Entering Combat")
        self.Text:SetTextColor(1, 0.25, 0.25)

        self.Animation:Stop()
        self.Animation:Play()
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self.Text:SetText("Leaving Combat")
        self.Text:SetTextColor(0.25, 1, 0.25)

        self.Animation:Stop()
        self.Animation:Play()
    end
end

function SCT:RegisterEvents()
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:SetScript("OnEvent", function(_, event)
        self:OnEvent(event)
    end)
end

function SCT:Initialize()
    if (not DB.Global.ScrollingCombatText.Enable) then
        return
    end

    self:Create()
    self:RegisterEvents()
end