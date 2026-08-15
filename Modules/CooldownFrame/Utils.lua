local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

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

function UI:UpdateCooldownText(CD, Parent, OffsetX, OffsetY, DynamicFontSize)
    if (not CD or CD.CooldownTextIsUpdated or CD:IsForbidden() or UI:IsSecretValue(CD)) then
        return
    end
    
    CD:SetCountdownFormatter(UI:BuildRuleDurationFormatter())

    for i = 1, CD:GetNumRegions() do
        local Region = select(i, CD:GetRegions())

        if (Region and Region.GetText) then
            local FontSize = DynamicFontSize and UI:GetCooldownFontScale(CD)

            Region:ClearAllPoints()
            Region:Point("CENTER", Parent, OffsetX or 0, OffsetY or 0)
            Region:SetFontTemplate("Default", FontSize or 12)
        end
    end

    CD.CooldownTextIsUpdated = true
end