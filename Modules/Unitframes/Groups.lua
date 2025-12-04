local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

function UF:SetupPartyFrames(Frame)
    if (Frame.UnitIsCreated) then 
        return 
    end

    Frame:SetAttribute("*type1", "target")
    Frame:SetAttribute("*type2", "togglemenu")
    Frame:RegisterForClicks("AnyUp")

    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateFadeInOut(Frame)
    self:CreateHealth(Frame)
    self:CreatePartyTexts(Frame)
    self:CreateRaidIcon(Frame)
    self:CreatePartyDebuffs(Frame)
    self:CreateThreatHighlightRaid(Frame)

    Frame:HookScript("OnAttributeChanged", function(self, name, value)
        if (name == "unit" and value) then
            self.unit = value

            UF:UpdateHealth(self)
            UF:UpdateRaidIcon(self)
            UF:UpdateHealthTextCur(self)
            UF:UpdateHealthTextPer(self)
            UF:UpdatePower(self)
            UF:UpdateNameParty(self)
            UF:UpdateThreatHighlightRaid(self)
            --UF:UpdateAuras(self, value, false)
            UF:UpdateAuras(self, value, true)
        end
    end)

    Frame.UnitIsCreated = true
end

function UF:SetupRaidFrames(Frame)
    if (Frame.UnitIsCreated) then 
        return 
    end

    Frame:SetAttribute("*type1", "target")
    Frame:SetAttribute("*type2", "togglemenu")
    Frame:RegisterForClicks("AnyUp")

    self:CreatePanels(Frame)
    self:CreateHightlight(Frame)
    self:CreateFadeInOut(Frame)
    self:CreateHealth(Frame, 42, "VERTICAL")
    self:CreateRaidTexts(Frame)
    self:CreateRaidIcon(Frame)
    self:CreateThreatHighlightRaid(Frame)

    Frame:HookScript("OnAttributeChanged", function(self, name, value)
        if (name == "unit" and value) then
            self.unit = value

            UF:UpdateHealth(self)
            UF:UpdateRaidIcon(self)
            UF:UpdateHealthTextCur(self)
            UF:UpdateHealthTextPer(self)
            UF:UpdatePower(self)
            UF:UpdateNameRaid(self)
            UF:UpdateThreatHighlightRaid(self)
            --UF:UpdateAuras(self, value, true)
        end
    end)

    Frame.UnitIsCreated = true
end

function UF:SpawnPartyHeader()
    local Header = CreateFrame("Frame", "FeelUI_Party", _G.UIParent, "SecureGroupHeaderTemplate")
    Header:SetAttribute("template", "SecureUnitButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate, PingableUnitFrameTemplate")
    Header:SetAttribute("initialConfigFunction", [[
        self:SetWidth(self:GetParent():GetAttribute("initial-width"))
        self:SetHeight(self:GetParent():GetAttribute("initial-height"))
    ]])
    Header:SetAttribute("showPlayer", false)
    Header:SetAttribute("showParty", true)
    Header:SetAttribute("showRaid", true)
    Header:SetAttribute("showSolo", false)
    Header:SetAttribute("initial-width", 202)
    Header:SetAttribute("initial-height", 36)
    Header:SetAttribute("point", "TOP")
    Header:SetAttribute("yOffset", -18)
    Header:SetAttribute("columnAnchorPoint", "BOTTOM")
    Header:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
    Header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
    Header:SetAttribute("groupBy", "GROUP")
    Header:SetAttribute("sortMethod", "INDEX")

    RegisterAttributeDriver(Header, "state-visibility", "show")

    Header:RegisterEvent("PLAYER_ENTERING_WORLD")
    Header:RegisterEvent("GROUP_ROSTER_UPDATE")
    Header:SetScript("OnEvent", function(self)
        local Index = 1

        while true do
            local Frames = self:GetAttribute("child"..Index)

            if (not Frames) then 
                break 
            end

            UF:SetupPartyFrames(Frames)

            Index = Index + 1
        end
    end)

    return Header
end

function UF:SpawnRaidHeader()
    local Header = CreateFrame("Frame", "FeelUI_Raid", _G.UIParent, "SecureGroupHeaderTemplate")
    Header:SetAttribute("template", "SecureUnitButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate, PingableUnitFrameTemplate")
    Header:SetAttribute("initialConfigFunction", [[
        self:SetWidth(self:GetParent():GetAttribute("initial-width"))
        self:SetHeight(self:GetParent():GetAttribute("initial-height"))
    ]])
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
    Header:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
    Header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
    Header:SetAttribute("groupBy", "GROUP")
    Header:SetAttribute("sortMethod", "INDEX")

    RegisterAttributeDriver(Header, "state-visibility", "show")

    Header:RegisterEvent("PLAYER_ENTERING_WORLD")
    Header:RegisterEvent("GROUP_ROSTER_UPDATE")
    Header:SetScript("OnEvent", function(self)
        local Index = 1

        while true do
            local Frames = self:GetAttribute("child"..Index)

            if (not Frames) then 
                break 
            end

            UF:SetupRaidFrames(Frames)

            Index = Index + 1
        end
    end)

    return Header
end