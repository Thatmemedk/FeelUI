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

    -- MOVE
    local Move = Animation:CreateAnimation("Translation")
    Move:SetDuration(2)
    Move:SetSmoothing("OUT")

    -- FADE IN
    local FadeIn = Animation:CreateAnimation("Alpha")
    FadeIn:SetFromAlpha(0)
    FadeIn:SetToAlpha(1)
    FadeIn:SetDuration(0.25)

    -- FADE OUT
    local FadeOut = Animation:CreateAnimation("Alpha")
    FadeOut:SetFromAlpha(1)
    FadeOut:SetToAlpha(0)
    FadeOut:SetStartDelay(1)
    FadeOut:SetDuration(0.5)
    FadeOut:SetSmoothing("OUT")

    -- ON PLAY
    Animation:SetScript("OnPlay", function()
        self.LastDirection = -self.LastDirection

        local X = math.random(25, 45) * self.LastDirection
        local Y = math.random(70, 95)

        Move:SetOffset(X, Y)
        Move:SetDuration(math.random(120,150) / 100)
    end)

    -- CACHE
    self.Frame = Frame
    self.Text = Text
    self.Animation = Animation
    self.LastDirection = 1
end

function SCT:EnteringCombat()
    self.Text:SetText(_G.ENTERING_COMBAT)
    self.Text:SetTextColor(1, 0.25, 0.25)
    self.Animation:Stop()
    self.Animation:Play()
end

function SCT:LeavingCombat()
    self.Text:SetText(_G.LEAVING_COMBAT)
    self.Text:SetTextColor(0.25, 1, 0.25)
    self.Animation:Stop()
    self.Animation:Play()
end

function SCT:OnEvent(event)
    if (event == "PLAYER_REGEN_DISABLED") then
        self:EnteringCombat()
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self:LeavingCombat()
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