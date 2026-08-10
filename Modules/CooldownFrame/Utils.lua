local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local GetAuraDuration = _G.C_UnitAuras.GetAuraDuration
local GetActionCooldownDuration = _G.C_ActionBar.GetActionCooldownDuration

function UI:GetCooldownFontScale(CD)
    if (not CD) then
        return
    end

    local Width = CD:GetWidth()
    local Height = CD:GetHeight()

    if (UI:IsSecretValue(Width) or UI:IsSecretValue(Height)) then
        return 12
    end

    Width = Width or 36
    Height = Height or 36

    local BaseSize = math.min(Width, Height)
    local Scale = BaseSize / 36

    if (Scale < 0.7) then
        Scale = 0.7
    elseif (Scale > 1.6) then
        Scale = 1.6
    end

    if (Scale < 1) then
        Scale = 0.8 + (Scale * 0.2)
    end

    local FontSize = math.floor(Scale * 15 + 0.6)

    if (FontSize < 10) then
        FontSize = 10
    end

    return FontSize
end

function UI:UpdateCooldownTextColor(CD, Elapsed)
    if (not CD) then
        return
    end

    local Button = CD:GetParent()

    if (not Button) then
        return
    end

    CD.Elapsed = (CD.Elapsed or 0) + Elapsed

    if (CD.Elapsed < 0.1) then
        return
    end

    CD.Elapsed = 0

    local ActionID = Button.action

    if (ActionID and not UI:IsSecretValue(ActionID)) then
        local Duration = GetActionCooldownDuration(ActionID)

        if (Duration) then
            local Evaluated = Duration:EvaluateRemainingDuration(UI.CooldownColorCurve)
        
            if (Evaluated) then
                for i = 1, CD:GetNumRegions() do
                    local Region = select(i, CD:GetRegions())

                    if (Region and Region.GetText) then
                        Region:SetVertexColor(Evaluated:GetRGBA())
                    end
                end
            end
        end
    end
end

function UI:UpdateABCooldownText(CD, Parent, OffsetX, OffsetY, DynamicFontSize)
    if (not CD or CD.IsRegisteredCooldown or UI:IsSecretValue(CD)) then
        return
    end
    
    for i = 1, CD:GetNumRegions() do
        local Region = select(i, CD:GetRegions())

        if (Region and Region.GetText) then
            local FontSize = DynamicFontSize and UI:GetCooldownFontScale(CD)

            Region:ClearAllPoints()
            Region:Point("CENTER", Parent, OffsetX or 0, OffsetY or 0)
            Region:SetFontTemplate("Default", FontSize or 12)
            Region:SetTextColor(1, 0.82, 0)
        end
    end

    CD:HookScript("OnUpdate", function(self, Elapsed)
        UI:UpdateCooldownTextColor(self, Elapsed, IsAura)
    end)

    CD.IsRegisteredCooldown = true
end

function UI:UpdateCooldownText(CD, Parent, OffsetX, OffsetY, DynamicFontSize)
    if (not CD or CD.CooldownTextIsUpdated or UI:IsSecretValue(CD)) then
        return
    end
    
    for i = 1, CD:GetNumRegions() do
        local Region = select(i, CD:GetRegions())

        if (Region and Region.GetText) then
            local FontSize = DynamicFontSize and UI:GetCooldownFontScale(CD)

            Region:ClearAllPoints()
            Region:Point("CENTER", Parent, OffsetX or 0, OffsetY or 0)
            Region:SetFontTemplate("Default", FontSize or 12)
            Region:SetTextColor(1, 0.82, 0)
        end
    end

    CD.CooldownTextIsUpdated = true
end