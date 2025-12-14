local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:SetupGroupFrame(Frame, type)
    if (Frame.UnitIsCreated) then 
        return 
    end

    Frame:SetAttribute("*type1", "target")
    Frame:SetAttribute("*type2", "togglemenu")

    -- REGISTER
    RegisterUnitWatch(Frame)

    -- PANELS
    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateFadeInOut(Frame)

    -- HEALTH
    if (type == "party") then
        self:CreateHealth(Frame)
        self:CreatePartyTexts(Frame)
        self:CreatePartyDebuffs(Frame)
    else
        self:CreateHealth(Frame, 42, "VERTICAL")
        self:CreateRaidTexts(Frame)
        self:CreateRaidDebuffs(Frame)
    end

    -- HEALTH PRED
    self:CreateHealthPrediction(Frame)
    -- ICONS
    self:CreateRaidIcon(Frame)
    self:CreateResurrectIcon(Frame)
    self:CreateLeaderIcon(Frame)
    self:CreateAssistantIcon(Frame)
    self:CreateSummonIcon(Frame)
    self:CreatePhaseIcon(Frame)
    self:CreateReadyCheckIcon(Frame)
    -- THREAT
    self:CreateThreatHighlightRaid(Frame)

    Frame:HookScript("OnAttributeChanged", function(self, name, value)
        if (name == "unit" and value) then
            self.unit = value

            -- HEALTH
            UF:UpdateHealth(self)
            -- HEALTH PRED
            UF:UpdateHealthPred(self)

            if (type == "party") then
                UF:UpdateNameParty(self)
                UF:UpdateHealthTextCur(self)
                UF:UpdateHealthTextPer(self)
                UF:UpdatePower(self)
            else
                UF:UpdateNameRaid(self)
            end

            -- AURAS
            UF:UpdateAuras(self, value, true)
            -- ICONS
            UF:UpdateRaidIcon(self)
            UF:UpdateResurrectionIcon(self)
            UF:UpdateLeaderIcon(self)
            UF:UpdateAssistantIcon(self)
            UF:UpdateSummonIcon(self)
            UF:UpdatePhaseIcon(self)
            UF:UpdateReadyCheckIcon(self)
            -- THREAT
            UF:UpdateThreatHighlightRaid(self)

            -- CACHE
            if (type == "party") then
                UF.Frames.Party[value] = self
            else
                UF.Frames.Raid[value] = self
            end
        end
    end)

    Frame.UnitIsCreated = true
end

function UF:SpawnGroupHeader(type)
    local Name = (type == "party") and "FeelUI_Party" or "FeelUI_Raid"
    local Header = CreateFrame("Frame", Name, UF.SecureFrame, "SecureGroupHeaderTemplate")

    Header:SetAttribute("template", "SecureUnitButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate, PingableUnitFrameTemplate")
    Header:SetAttribute("initialConfigFunction", [[
        self:SetWidth(self:GetParent():GetAttribute("initial-width"))
        self:SetHeight(self:GetParent():GetAttribute("initial-height"))
    ]])

    if (type == "party") then
        -- PARTY SETTINGS
        Header:SetAttribute("showPlayer", false)
        Header:SetAttribute("showParty", true)
        Header:SetAttribute("showRaid", true)
        Header:SetAttribute("initial-width", 202)
        Header:SetAttribute("initial-height", 36)
        Header:SetAttribute("point", "TOP")
        Header:SetAttribute("yOffset", -18)
        Header:SetAttribute("columnAnchorPoint", "BOTTOM")
    else
        -- RAID SETTINGS
        Header:SetAttribute("showRaid", true)
        Header:SetAttribute("showParty", true)
        Header:SetAttribute("showPlayer", true)
        Header:SetAttribute("initial-width", 79)
        Header:SetAttribute("initial-height", 42)
        Header:SetAttribute("point", "LEFT")
        Header:SetAttribute("xOffset", 4)
        Header:SetAttribute("yOffset", -4)
        Header:SetAttribute("columnAnchorPoint", "TOP")
        Header:SetAttribute("unitsPerColumn", 5)
        Header:SetAttribute("maxColumns", 8)
        Header:SetAttribute("columnSpacing", 4)
    end

    -- GENERAL SETTINGS
    Header:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
    Header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
    Header:SetAttribute("groupBy", "GROUP")
    Header:SetAttribute("sortMethod", "INDEX")

    -- REGISTER DRIVER
    RegisterAttributeDriver(Header, "state-visibility", "show")

    -- EVENTS
    Header:RegisterEvent("PLAYER_ENTERING_WORLD")
    Header:RegisterEvent("GROUP_ROSTER_UPDATE")
    Header:RegisterEvent("UPDATE_INSTANCE_INFO")
    Header:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    Header:SetScript("OnEvent", function(self)
        local Index = 1
        
        while true do
            local Frame = self:GetAttribute("child"..Index)

            if (not Frame) then 
                break 
            end

            UF:SetupGroupFrame(Frame, type)

            Index = Index + 1
        end
    end)

    return Header
end