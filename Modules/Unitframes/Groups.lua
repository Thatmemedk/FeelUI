local UI, DB, Media, Language = select(2, ...):Call() 

-- Call Modules
local UF = UI:CallModule("UnitFrames")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UF:SetupGroupFrame(Frame, Type, Unit)
    if (Frame.UnitIsCreated) then
        return
    end

    -- SET UNIT
    Frame.unit = Unit
    Frame:SetAttribute("unit", Unit)

    -- SET ATTRIBUTES
    Frame:RegisterForClicks("AnyUp")
    Frame:SetAttribute("type1", "target")
    Frame:SetAttribute("type2", "togglemenu")
    Frame:SetAttribute("toggleForVehicle", true)

    -- REGISTER UNIT WATCH
    RegisterUnitWatch(Frame)

    -- TYPE
    Frame.IsParty = (Type == "party")
    Frame.IsRaid  = (Type == "raid")

    if (Type == "party") then
        UF:CreateParty(Frame)
    else
        UF:CreateRaid(Frame)
    end

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
        local Index = 1

        while true do
            local Frame = self:GetAttribute("child" .. Index)

            if (not Frame) then
                break
            end

            if (not Frame.UnitIsCreated) then
                UF:SetupGroupFrame(Frame, Type, Frame:GetAttribute("unit"))
            end

            Index = Index + 1
        end

        UF:FullRefreshGroup()
    end)

    return Header
end