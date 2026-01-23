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

function UI:GetCooldownDuration(Button, IsAura)
    if (IsAura) then
        local Unit, AuraInstanceID = Button.Unit, Button.AuraInstanceID

        if (Unit and AuraInstanceID) then
            return GetAuraDuration(Unit, AuraInstanceID)
        end
    else
        local ActionID = Button.action

        if (ActionID and not issecretvalue(ActionID)) then
            return GetActionCooldownDuration(ActionID)
        end
    end
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

    if (not Button) then 
        return 
    end

    local Duration = UI:GetCooldownDuration(Button, IsAura)

    if (not Duration) then 
        return 
    end

    local Evaluated = Duration:EvaluateRemainingDuration(UI.CooldownColorCurve)
    
    if (not Evaluated) then 
        return 
    end

    for i = 1, CD:GetNumRegions() do
        local Region = select(i, CD:GetRegions())

        if (Region and Region.GetText) then
            Region:SetVertexColor(Evaluated:GetRGBA())
        end
    end
end

function UI:RegisterCooldown(CD, Parent, OffsetX, OffsetY, DynamicFontSize, IsAura)
    if (CD.IsRegisteredCooldown) then
        return
    end

    for i = 1, CD:GetNumRegions() do
        local Region = select(i, CD:GetRegions())

        if (Region and Region.GetText) then
            local FontSize = DynamicFontSize and UI:GetCooldownFontScale(CD)

            Region:ClearAllPoints()
            Region:Point("CENTER", Parent, OffsetX or 0, OffsetY or 0)
            Region:SetFontTemplate("Default", FontSize or 12)
        end
    end

    CD:HookScript("OnUpdate", function(self, Elapsed)
        UI:UpdateCooldownTextColor(self, Elapsed, IsAura)
    end)

    CD.IsRegisteredCooldown = true
end