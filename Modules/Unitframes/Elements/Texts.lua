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
    NameLevel:Width(155)
    NameLevel:Point("RIGHT", Frame, -4, 20)
    NameLevel:SetJustifyH("RIGHT")
    NameLevel:SetJustifyV("MIDDLE")
    NameLevel:SetWordWrap(false)
    NameLevel:SetNonSpaceWrap(false)
    NameLevel:SetMaxLines(1)
    NameLevel:SetFontTemplate("Default", 14)

    Frame.HealthTextCur = HealthTextCur
    Frame.HealthTextPer = HealthTextPer
    Frame.PowerText = PowerText
    Frame.NameLevel = NameLevel
end

function UF:CreatePartyTexts(Frame)
    local HealthTextCur = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthTextCur:Point("LEFT", Frame, 8, 0)
    HealthTextCur:SetFontTemplate("Default")
    
    local HealthTextPer = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    HealthTextPer:Point("LEFT", Frame, 4, 20)
    HealthTextPer:SetFontTemplate("Default", 16)
    
    local PowerText = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    PowerText:Point("RIGHT", Frame, -8, 0)
    PowerText:SetFontTemplate("Default")
    
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Point("RIGHT", Frame, -4, 20)
    Name:SetFontTemplate("Default", 14)
    
    Frame.HealthTextCur = HealthTextCur
    Frame.HealthTextPer = HealthTextPer
    Frame.PowerText = PowerText
    Frame.Name = Name
end

function UF:CreateRaidTexts(Frame)
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Point("CENTER", Frame.Health, 2, 2)
    Name:SetFontTemplate("Default")
    
    Frame.Name = Name
end

function UF:CreateNameTextCenter(Frame)
    local Name = Frame.InvisFrame:CreateFontString(nil, "OVERLAY", nil, 7)
    Name:Width(110)
    Name:Point("CENTER", Frame, 0, 0)
    Name:SetFontTemplate("Default", 12)
    Name:SetJustifyH("CENTER")
    Name:SetJustifyV("MIDDLE")
    Name:SetWordWrap(false)
    Name:SetNonSpaceWrap(false)
    Name:SetMaxLines(1)

    Frame.Name = Name
end