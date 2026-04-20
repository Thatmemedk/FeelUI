local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:SetupGroupFrame(Frame, Type)
    if (Frame.UnitIsCreated) then 
        return 
    end

    if (InCombatLockdown()) then
        Frame.NeedsSetup = true
        
        return
    end

    Frame:RegisterForClicks("AnyUp")
    Frame:SetAttribute("type1", "target")
    Frame:SetAttribute("type2", "togglemenu")
    Frame:SetAttribute("toggleForVehicle", true)

    -- TYPE
    Frame.IsParty = (Type == "party")
    Frame.IsRaid  = (Type == "raid")

    if (Type == "party") then
        UF:CreateParty(Frame)
    else
        UF:CreateRaid(Frame)
    end

    -- REGISTER UNIT WATCH
    RegisterUnitWatch(Frame)

    -- ON ATTRIBUTE CHANGED
    Frame:HookScript("OnAttributeChanged", function(self, name, value)
        if (name ~= "unit") then
            return
        end

        self.unit = value

        if (value) then
            UF:RefreshGroup(self, value)
        end
    end)

    Frame.UnitIsCreated = true
end

function UF:SpawnGroupHeader(Type)
    local Name = (Type == "party") and "FeelUI_Party" or "FeelUI_Raid"
    local Header = CreateFrame("Frame", Name, UF.SecureFrame, "SecureGroupHeaderTemplate")

    Header:SetAttribute("template", "SecureUnitButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate, PingableUnitFrameTemplate")
    Header:SetAttribute("initialConfigFunction", [[
        self:SetWidth(self:GetParent():GetAttribute("initial-width"))
        self:SetHeight(self:GetParent():GetAttribute("initial-height"))
    ]])

    if (Type == "party") then
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
    Header:SetScript("OnEvent", function(self, event)
        if (InCombatLockdown()) then
            self.NeedsRefresh = true

            return
        end

        local Index = 1

        while true do
            local Frame = self:GetAttribute("child" .. Index)

            if (not Frame) then
                break
            end

            if (not Frame.UnitIsCreated) then
                UF:SetupGroupFrame(Frame, Type)
            end

            Index = Index + 1
        end

        if (event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD") then
            UI:Delay("RefreshGroups", 0.05, function()
                UF:FullRefreshGroup()
            end)
        end

        if (event == "PLAYER_REGEN_ENABLED" and self.NeedsRefresh) then
            self.NeedsRefresh = nil

            UI:Delay("RefreshGroups", 0.05, function()
                UF:FullRefreshGroup()
            end)
        end 
    end)

    return Header
end