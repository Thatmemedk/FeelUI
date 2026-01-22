local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local GetAuraDuration = _G.C_UnitAuras.GetAuraDuration
local GetActionCooldownDuration = _G.C_ActionBar.GetActionCooldownDuration

function UI:GetCooldownFontScale(CD)
    if (not CD) then 
        return
    end

    local Width = CD:GetWidth() or 36
    local Height = CD:GetHeight() or 36
    local BaseSize = min(Width, Height)
    local Scale = BaseSize / 36

    if (Scale < 0.7) then
        Scale = 0.7
    elseif (Scale > 1.6) then
        Scale = 1.6
    end

    if (Scale < 1) then
        Scale = 0.8 + (Scale * 0.2)
    end

    local FontSize = floor(Scale * 15 + 0.6)

    if (FontSize < 10) then
        FontSize = 10
    end

    return FontSize
end

function UI:UpdateCooldownTextColor(CD, Elapsed, IsAura)
    if (not CD) then
        return
    end

    self.Elapsed = (self.Elapsed or 0) + Elapsed

    if (self.Elapsed < 0.1) then
        return
    end

    self.Elapsed = 0

    local Button = CD:GetParent()
    local Duration

    if (IsAura) then
        local AuraInstanceID = Button.AuraInstanceID
        local Unit = Button.Unit

        if (not Button or not Unit or not AuraInstanceID) then
            return
        end

        Duration = GetAuraDuration(Unit, AuraInstanceID)
    else
        local ActionID = Button.action

        if (not Button or not ActionID or issecretvalue(ActionID)) then
            return
        end

        Duration = GetActionCooldownDuration(ActionID)
    end

    if (not Duration) then
        return
    end

    local EvaluateDuration = Duration:EvaluateRemainingDuration(UI.CooldownColorCurve)

    if (not EvaluateDuration) then
        return
    end

    for i = 1, CD:GetNumRegions() do
        local Region = select(i, CD:GetRegions())

        if (Region and Region.GetText) then
            Region:SetVertexColor(EvaluateDuration:GetRGBA())
        end
    end
end

function UI:RegisterCooldown(CD, Aura, ActionBar)
    if (CD.IsRegisteredCooldown) then
        return
    end

    CD:HookScript("OnUpdate", function(self, Elapsed)
        if (Aura) then
            UI:UpdateCooldownTextColor(self, Elapsed, true)
        elseif (ActionBar) then
            UI:UpdateCooldownTextColor(self, Elapsed, false)
        end
    end)

    CD.IsRegisteredCooldown = true
end