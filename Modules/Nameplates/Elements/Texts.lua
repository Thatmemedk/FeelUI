local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local NP = UI:CallModule("NamePlates")

-- Lib Globals
local select = select
local unpack = unpack

function NP:CreateHealthText(Frame)
    local HealthText = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthText:Point("LEFT", Frame.Health, 4, 10)
    HealthText:SetFontTemplate("Default", 14)

    Frame.HealthText = HealthText
end

function NP:CreateName(Frame)
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Point("RIGHT", Frame.Health, -4, 10)
    Name:SetFontTemplate("Default", 14)

    Frame.Name = Name
end

function NP:CreateNameMiddle(Frame)
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Point("CENTER", Frame.Panel, 0, 0)
    Name:SetFontTemplate("Default", 14)

    Frame.Name = Name
end