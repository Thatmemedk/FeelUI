local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:SetupGroupFrame(Frame, type)
    if (Frame.UnitIsCreated) then 
        return 
    end

    if InCombatLockdown() then
        Frame.NeedsSetup = true

        return
    end

    Frame:RegisterForClicks("AnyUp")
    Frame:SetAttribute("type1", "target")
    Frame:SetAttribute("type2", "togglemenu")
    Frame:SetAttribute("toggleForVehicle", true)

    if (type == "party") then
        UF:CreateParty(Frame)
    else
        UF:CreateRaid(Frame)
    end

    -- REGISTER UNIT WATCH
    RegisterUnitWatch(Frame)

    Frame:HookScript("OnAttributeChanged", function(self, name, value)
        if (name ~= "unit") then
            return
        end

        self.unit = value

        -- HEALTH
        UF:UpdateHealth(self)
        -- HEALTH PRED
        UF:UpdateHealthPred(self)

        -- NAME
        if (type == "party") then
            UF:UpdateHealthTextCur(self)
            UF:UpdateHealthTextPer(self)
            UF:UpdatePower(self)

            UF:UpdateName(self, "Party")
        else
            UF:UpdateName(self, "Raid")
        end

        -- AURAS
        UF:UpdateAuras(self, self.unit, true)
        UF:UpdateAuras(self, self.unit, false)
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
        -- DEBUFF HIGHLIGHT
        --UF:UpdateDebuffHighlight(self, self.unit)
        -- RANGE
        UF:UpdateRange(self, self.unit)
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
        Header:SetAttribute("yOffset", -22)
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
    Header:SetScript("OnEvent", function(self, event)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end

        if (event == "PLAYER_REGEN_ENABLED") then
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

        local Index = 1

        while true do
            local Frame = self:GetAttribute("child" .. Index)

            if (not Frame) then
                break
            end

            UF:SetupGroupFrame(Frame, type)

            if (Frame.NeedsSetup) then
                Frame.NeedsSetup = nil

                UF:SetupGroupFrame(Frame, type)
            end

            Index = Index + 1
        end
    end)

    return Header
end