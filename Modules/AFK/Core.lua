local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AFK = UI:RegisterModule("AFK")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local floor = math.floor
local format = format

-- WoW Globals
local GetTime = GetTime
local UnitClass = UnitClass
local UnitIsAFK = UnitIsAFK
local IsInGuild = IsInGuild
local GetGuildInfo = GetGuildInfo
local RequestTimePlayed = RequestTimePlayed
local ChatFrameTimeBreakDown = ChatFrame_TimeBreakDown

-- Locals
AFK.EventRequesting = false
AFK.Minutes = 0
AFK.Seconds = 0
AFK.Total = 0

-- Locals
local TotalPlayTime, LevelPlayTime, LevelPlayTimeOffset

function AFK:UpdateTime(Value)
    local Minutes, Seconds

    if (Value >= 60) then
        Minutes = floor(Value / 60)
        Seconds = Value - Minutes * 60
    else
        Minutes = 0
        Seconds = Value
    end

    if (self.Time) then
        self.Time:SetText("|cffffffff" .. format("%.2d", Minutes) .. ":" .. format("%.2d", Seconds))
    end

    self.Minutes = Minutes
    self.Seconds = Seconds
end

function AFK:OnUpdate(Elapsed)
    self.Update = (self.Update or 0) + Elapsed

    if (self.Update > 1) then
        self.Total = (self.Total or 0) + 1

        if (self.LocalDate) then
            self.LocalDate:SetFormattedText("%s", date("%A |cffffffff%B %d|r"))
        end

        if (self.LocalTime) then
            self.LocalTime:SetFormattedText("%s", date("|cffffffff%I:%M:%S|r %p"))
        end

        self:UpdateTime(self.Total)
        self.Update = 0
    end

    if (TotalPlayTime and LevelPlayTime) then
        local Days, Hours, Minutes, Seconds = ChatFrameTimeBreakDown(TotalPlayTime + (GetTime() - LevelPlayTimeOffset))

        if (self.TotalPlayedText) then
            self.TotalPlayedText:SetFormattedText("|cffffffff%02d|r Days |cffffffff%02d|r Hours |cffffffff%02d|r Mins |cffffffff%02d|r Secs", Days, Hours, Minutes, Seconds)
        end
    else
        if (self.Update > 2) and (not self.Requested) and (not self.EventRequesting) then
            self.Requested = true
            self.EventRequesting = true
            RequestTimePlayed()
        end
    end
end

function AFK:UpdateAFKState(State)
    if (State) then
        -- Fade In
        UI:UIFrameFadeIn(self.Frame, 1, self.Frame:GetAlpha(), 1)
        UI:UIFrameFadeOut(_G.UIParent, 1, _G.UIParent:GetAlpha(), 0)

        -- Hide
        _G.Minimap:Hide()

        if (IsInGuild()) then
            local GuildName, GuildRankName = GetGuildInfo("player")

            if (self.Guild) then
                self.Guild:SetFormattedText("|CFFFF66CC%s|r - |CFF00FF10%s|r", GuildName, GuildRankName)
            end
        else
            if (self.Guild) then
                self.Guild:SetText("")
            end
        end

        -- Update
        self.Frame:SetScript("OnUpdate", function(_, Elapsed)
            AFK:OnUpdate(Elapsed)
        end)

        -- Cache
        self.IsAFK = true
    elseif (self.IsAFK) then
        -- Fade Out
        UI:UIFrameFadeOut(self.Frame, 1, self.Frame:GetAlpha(), 0)
        UI:UIFrameFadeIn(_G.UIParent, 1, _G.UIParent:GetAlpha(), 1)
        
        -- Show
        _G.Minimap:Show()

        -- Update
        self.Frame:SetScript("OnUpdate", nil)

        -- Cache
        self.IsAFK = false
        self.Total = 0
    end
end

function AFK:Create()
    local R, G, B = unpack(UI.GetClassColors)

    local Frame = CreateFrame("Frame", nil)
    Frame:SetFrameLevel(5)
    Frame:SetScale(_G.UIParent:GetScale())
    Frame:SetInside(_G.UIParent)
    Frame:SetAlpha(0)
    Frame:Hide()
    
    local TopPanel = CreateFrame("Frame", nil, Frame)
    TopPanel:SetFrameLevel(Frame:GetFrameLevel() - 1)
    TopPanel:Size(_G.UIParent:GetWidth()+8, 42)
    TopPanel:Point("TOP", Frame, 0, 2)
    TopPanel:CreateBackdrop()
    TopPanel:CreateShadow()

    local BottomPanel = CreateFrame("Frame", nil, Frame)
    BottomPanel:SetFrameLevel(Frame:GetFrameLevel() - 1)
    BottomPanel:Size(_G.UIParent:GetWidth()+12, 84)
    BottomPanel:Point("BOTTOM", Frame, 0, -4)
    BottomPanel:CreateBackdrop()
    BottomPanel:CreateShadow()
    
    local InvisFrame = CreateFrame("Frame", nil, Frame)
    InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
    InvisFrame:SetInside()
    
    local LocalTime = InvisFrame:CreateFontString(nil, "OVERLAY")
    LocalTime:Point("RIGHT", TopPanel, -28, -2)
    LocalTime:SetFontTemplate("Default", 14, 2, 2)
    LocalTime:SetTextColor(R, G, B)

    local LocalDate = InvisFrame:CreateFontString(nil, "OVERLAY")
    LocalDate:Point("LEFT", TopPanel, 28, -2)
    LocalDate:SetFontTemplate("Default", 14, 2, 2)
    LocalDate:SetTextColor(R, G, B)
    
    local Time = InvisFrame:CreateFontString(nil, "OVERLAY")
    Time:Point("CENTER", TopPanel, 0, -2)
    Time:SetFontTemplate("Default", 16, 2, 2)
    Time:SetTextColor(R, G, B)

    --local Name = InvisFrame:CreateFontString(nil, "OVERLAY")
    --Name:Point("CENTER", BottomPanel, 0, 18)
    --Name:SetFontTemplate("Default", 34, 2, 2)
    --Name:SetTextColor(R, G, B)
    --Name:SetText("|CFF00AAFF" .. UI.Title .. "|r")

    local Name = InvisFrame:CreateTexture(nil, "OVERLAY")
    Name:Size(228, 228)
    Name:Point("CENTER", BottomPanel, 0, 28)
    Name:SetTexture(Media.Global.Logo)

    local Version = InvisFrame:CreateFontString(nil, "OVERLAY")  
    Version:Point("CENTER", BottomPanel, 0, -18)
    Version:SetFontTemplate("Default", 24, 2, 2)
    Version:SetText("Version |CFF4BEB2C" .. UI.Version)
    
    local Faction = InvisFrame:CreateTexture(nil, "OVERLAY")
    Faction:Size(142, 142)
    Faction:Point("LEFT", BottomPanel, 28, 18)
    Faction:SetTexture(format([[Interface\Timer\%s-Logo]], UI.MyFaction))
    
    local Guild = InvisFrame:CreateFontString(nil, "OVERLAY")
    Guild:Point("LEFT", BottomPanel, 152, 2)
    Guild:SetFontTemplate("Default", 18, 2, 2)
    Guild:SetText("")
    
    local TotalPlayedText = InvisFrame:CreateFontString(nil, "OVERLAY")
    TotalPlayedText:Point("RIGHT", BottomPanel, -28, -2)
    TotalPlayedText:SetFontTemplate("Default", 18, 2, 2)
    TotalPlayedText:SetTextColor(R, G, B)
    
    local PlayedThisLevelText = InvisFrame:CreateFontString(nil, "OVERLAY")
    PlayedThisLevelText:Point("RIGHT", BottomPanel, -28, -18)
    PlayedThisLevelText:SetFontTemplate("Default", 14, 2, 2)
    PlayedThisLevelText:SetTextColor(R, G, B)
    
    self.Frame = Frame
    self.TopPanel = TopPanel
    self.BottomPanel = BottomPanel
    self.LocalTime = LocalTime
    self.LocalDate = LocalDate
    self.Time = Time
    self.Name = Name
    self.Version = Version
    self.Faction = Faction
    self.Guild = Guild
    self.TotalPlayedText = TotalPlayedText
    self.PlayedThisLevelText = PlayedThisLevelText
end

function AFK:OnEvent(event, arg1)
    if (event == "TIME_PLAYED_MSG") then
        self.EventRequesting = false
        TotalPlayTime, LevelPlayTime = arg1
        LevelPlayTimeOffset = GetTime()
    elseif (event == "PLAYER_LEVEL_UP") then
        if (not LevelPlayTime) then
            self.EventRequesting = true
            RequestTimePlayed()
        else
            LevelPlayTimeOffset = GetTime()
        end
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self:UnregisterEvent(event)
    elseif (event == "UPDATE_BATTLEFIELD_STATUS" or event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW") then
        if (event ~= "UPDATE_BATTLEFIELD_STATUS" or (GetBattlefieldStatus(arg1) == "confirm")) then
            self:UpdateAFKState(false)
        end

        if (event == "PLAYER_REGEN_DISABLED") then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end

        return
    elseif (event == "PLAYER_FLAGS_CHANGED" and arg1 ~= "player") or InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown() then
        return
    end

    local IsAFK = UnitIsAFK("player")

    if (not UI:IsSecretValue(IsAFK)) then
        self:UpdateAFKState(IsAFK)
    end
end

function AFK:RegisterEvents()
    self:RegisterEvent("TIME_PLAYED_MSG")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("LFG_PROPOSAL_SHOW")
    self:RegisterEvent("PLAYER_FLAGS_CHANGED")
    self:SetScript("OnEvent", self.OnEvent)
end

function AFK:Initialize()
    if (not DB.Global.AFK.Enable) then 
        return 
    end

    self:Create()
    self:RegisterEvents()
end
