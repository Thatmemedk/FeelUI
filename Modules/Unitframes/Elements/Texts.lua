local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local select = select
local unpack = unpack

function UF:CreatePlayerTexts(Frame)
    local HealthTextCur = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthTextCur:Point("RIGHT", Frame, -8, 0)
    HealthTextCur:SetFontTemplate("Default")
    
    local HealthTextPer = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthTextPer:Point("RIGHT", Frame, -4, 20)
    HealthTextPer:SetFontTemplate("Default", 16)
    
    local PowerText = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    PowerText:Point("LEFT", Frame, 8, 0)
    PowerText:SetFontTemplate("Default")
    
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Point("LEFT", Frame, 4, 20)
    Name:SetFontTemplate("Default", 14)

    Frame.HealthTextCur = HealthTextCur
    Frame.HealthTextPer = HealthTextPer
    Frame.PowerText = PowerText
    Frame.Name = Name
end

function UF:CreateTargetTexts(Frame)
    local HealthTextCur = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthTextCur:Point("LEFT", Frame, 8, 0)
    HealthTextCur:SetFontTemplate("Default")
    
    local HealthTextPer = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthTextPer:Point("LEFT", Frame, 4, 20)
    HealthTextPer:SetFontTemplate("Default", 16)
    
    local PowerText = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    PowerText:Point("RIGHT", Frame, -8, 0)
    PowerText:SetFontTemplate("Default")
    
    local NameLevel = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    NameLevel:Point("RIGHT", Frame, -4, 20)
    NameLevel:SetFontTemplate("Default", 14)

    Frame.HealthTextCur = HealthTextCur
    Frame.HealthTextPer = HealthTextPer
    Frame.PowerText = PowerText
    Frame.NameLevel = NameLevel
end

function UF:CreateNameTextCenter(Frame)
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Point("CENTER", Frame, 0, 0)
    Name:SetFontTemplate("Default", 12)

    Frame.Name = Name
end

function UF:NPCreateHealthText(Frame)
    local HealthText = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthText:Point("LEFT", Frame.Health, 4, 10)
    HealthText:SetFontTemplate("Default", 14)

    Frame.HealthText = HealthText
end

function UF:NPCreateName(Frame, Unit)
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Point("RIGHT", Frame.Health, -4, 10)
    Name:SetFontTemplate("Default", 14)

    Frame.Name = Name
end