local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local TT = UI:RegisterModule("Tooltip")
local Panels = UI:CallModule("Panels")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local pairs = pairs
local gsub = string.gsub
local find = string.find
local sub = string.sub
local issecretvalue = issecretvalue

-- WoW Globals
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar
local AddTooltipPostCall = TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall

-- WoW Globals
local UnitRace = UnitRace
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification
local UnitRealmRelationship = UnitRealmRelationship
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local IsInGuild = IsInGuild
local GetGuildInfo = GetGuildInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitExists = UnitExists
local UnitIsConnected = UnitIsConnected

-- WoW Globals
local BOSS = _G.BOSS
local ELITE = _G.ELITE
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL
local INTERACTIVE_SERVER_LABEL = _G.INTERACTIVE_SERVER_LABEL
local LE_REALM_RELATION_COALESCED = _G.LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL

-- WoW Globals
local LEVEL1 = strlower(_G.TOOLTIP_UNIT_LEVEL:gsub("%s?%%s%s?%-?",""))
local LEVEL2 = strlower((_G.TOOLTIP_UNIT_LEVEL_RACE or _G.TOOLTIP_UNIT_LEVEL_CLASS):gsub("^%%2$s%s?(.-)%s?%%1$s","%1"):gsub("^%-?г?о?%s?",""):gsub("%s?%%s%s?%-?",""))

-- Locals
local ClassificationText = {
	worldboss = "|CFFFF0000" .. BOSS .. "|r ",
	rareelite = "|CFFFF66CCRare|r |cffFFFF00" .. ELITE .. "|r ",
	elite = "|CFFFFFF00" .. ELITE .. "|r ",
	rare = "|CFFFF66CCRare|r ",
}

function TT:GetColor(Unit)
    if (not Unit) then
        return
    end

    local Color

    if UnitIsPlayer(Unit) and not UnitHasVehicleUI(Unit) then
        local Class = select(2, UnitClass(Unit))
        Color = UI.Colors.Class[Class]
    else
        local Reaction = UnitReaction(Unit, "player")
        Color = UI.Colors.Reaction[Reaction]
    end

    if (not Color) then
        return
    end

    return UI:RGBToHex(Color.r, Color.g, Color.b), Color.r, Color.g, Color.b
end

function TT:ApplyStatusBarColor(Tooltip, Unit, ClassFile, Reaction)
    if (not Tooltip or Tooltip:IsForbidden() or not Unit) then
        return
    end

    local R, G, B

    if not (GameTooltipStatusBar) then
        return
    end

    if not UnitIsConnected(Unit) or UnitIsTapDenied(Unit) or UnitIsGhost(Unit) then
        R, G, B = 0.5, 0.5, 0.5
    elseif UnitIsDead(Unit) then
        R, G, B = 0.5, 0, 0
    elseif UnitIsPlayer(Unit) then
        local Color = UI.Colors.Class[ClassFile]
        R, G, B = Color.r, Color.g, Color.b
    else
        local Color = UI.Colors.Reaction[Reaction]
        R, G, B = Color.r, Color.g, Color.b
    end

    GameTooltipStatusBar:SetStatusBarColor(R, G, B)
   	GameTooltipStatusBar:SetBackdropColorTemplate(R * 0.5, G * 0.5, B * 0.5, 0.7)
end

function TT:FormatUnitName(Unit)
    local Name, Realm = UnitName(Unit)
    local Title = UnitPVPName(Unit)
    local Relationship = UnitRealmRelationship(Unit)
    local Color = TT:GetColor(Unit) or "|CFFFFFFFF"
    local StatusText = ""

    if (Title) then
        Name = Title
    end

    if (Realm and Realm ~= "") then
        if IsShiftKeyDown() then
            Name = Name .. "-" .. Realm
        elseif (Relationship == LE_REALM_RELATION_COALESCED) then
            Name = Name .. FOREIGN_SERVER_LABEL
        elseif (Relationship == LE_REALM_RELATION_VIRTUAL) then
            Name = Name .. INTERACTIVE_SERVER_LABEL
        end
    end

    if UnitIsAFK(Unit) then
        StatusText = " |CFF559655" .. CHAT_FLAG_AFK .. "|r"
    elseif UnitIsDND(Unit) then
        StatusText = " |CFF559655" .. CHAT_FLAG_DND .. "|r"
    end

	_G.GameTooltipTextLeft1:SetFormattedText("%s%s%s%s", Color, Name, "|r", StatusText) 
end

function TT:FormatGuildInfo(Unit)
    local GuildName, GuildRankName = GetGuildInfo(Unit)

    if (not GuildName) then 
    	return 
    end

    local SameGuild = IsInGuild() and GetGuildInfo("player") == GuildName
    local Color = SameGuild and "|CFFFF66CC[%s]|r |CFF00FF10[%s]|r" or "|CFFFFFFFF[%s]|r |CFF00FF10[%s]|r"

    _G.GameTooltipTextLeft2:SetFormattedText(Color, GuildName, GuildRankName)
end

function TT:ProcessTooltipLines(Unit, NumLines, Player, ClassName, ClassFile, Race, CreatureType, ClassificationUnit, Level)
    local ClassColor = UI.Colors.Class[ClassFile]
    local DiffColor = GetQuestDifficultyColor(Level)
    local LevelColor

    if (Level == -1 or ClassificationUnit == "worldboss") then
        LevelColor = { r = 1, g = 0, b = 0 }
    else
        LevelColor = DiffColor
    end

    for i = 2, NumLines do
        local Line = _G["GameTooltipTextLeft" .. i]
        local Text = Line and Line:GetText()
        local LowerText = Text:lower()

        if (not Text) then 
        	break 
        end

        if (Player and ClassName and LowerText:find(ClassName:lower()) and not LowerText:find("alliance") and not LowerText:find("horde")) then
            local SpecText = Text:gsub(ClassName, ""):trim()
            Line:SetFormattedText("|cFFFFFFFF%s |cff%02x%02x%02x%s|r", SpecText, ClassColor[1]*255, ClassColor[2]*255, ClassColor[3]*255, ClassName)
        end

        if (LowerText:find(LEVEL1) or LowerText:find(LEVEL2)) then
            if (Player) then
                Line:SetFormattedText("Level |cff%02x%02x%02x%s|r %s", DiffColor.r * 255, DiffColor.g * 255, DiffColor.b * 255, Level > 0 and Level or "??", Race or "")
            else
                local ClassText = ClassificationText[ClassificationUnit] or ""
                Line:SetFormattedText("Level |cff%02x%02x%02x%s|r %s%s", LevelColor.r * 255, LevelColor.g * 255, LevelColor.b * 255, Level > 0 and Level or "??", ClassText, CreatureType or "")
            end
        end

        if (Text == CreatureType or Text == _G.FACTION_HORDE or Text == _G.FACTION_ALLIANCE or Text == _G.PVP) then
            Line:SetText("")
            Line:Hide()
        end
    end
end

function TT:OnTooltipSetUnit()
    if (self ~= GameTooltip or self:IsForbidden()) then
        return
    end

    local Unit = select(2, self:GetUnit())

    if (not Unit) then
        local GMF = UI:GetMouseFocus()
        local FocusUnit = GMF and GMF.GetAttribute and GMF:GetAttribute("unit")

        if (FocusUnit) then
            Unit = FocusUnit
        end
    end

    if (not Unit or issecretvalue(Unit) or not UnitExists(Unit)) then
        return
    end

    local NumLines = self:NumLines()
    local Player = UnitIsPlayer(Unit)
    local ClassName, ClassFile = UnitClass(Unit)
    local Race = UnitRace(Unit)
    local Level = (UI.Retail and UnitEffectiveLevel or UnitLevel)(Unit)
    local CreatureType = UnitCreatureType(Unit)
    local ClassificationUnit = UnitClassification(Unit)
    local Reaction = UnitReaction(Unit, "player")

   	TT:FormatUnitName(Unit)
    TT:FormatGuildInfo(Unit)
    TT:ProcessTooltipLines(Unit, NumLines, Player, ClassName, ClassFile, Race, CreatureType, ClassificationUnit, Level)
    TT:ApplyStatusBarColor(self, Unit, ClassFile, Reaction)
end

function TT:StyleHealthBar()
	GameTooltipStatusBar:Height(6)
    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, -2)
    GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, 2)
	GameTooltipStatusBar:SetStatusBarTexture(Media.Global.Texture)
	GameTooltipStatusBar:CreateBackdrop()
	GameTooltipStatusBar:CreateShadow()
    GameTooltipStatusBar:SetScript("OnValueChanged", nil)
end

function TT:SetBackdropStyle(tt)
	if (not tt or not tt.NineSlice or tt:IsForbidden() or tt.IsSkinned) then 
		return 
	end

    if (tt.NineSlice) then 
        tt.NineSlice:SetAlpha(0) 
    end

    if not issecretvalue or not issecretvalue(tt:GetWidth()) then
        local Frame = CreateFrame("Frame", nil, tt)
        Frame:SetFrameLevel(tt:GetFrameLevel() -1)
        Frame:SetInside(tt, 2, 2)
        Frame:CreateBackdrop()
        Frame:CreateShadow()
    end

    tt.IsSkinned = true
end

function TT:StyleTooltips()
    local TTList = {
        _G.GameTooltip,
        _G.GameSmallHeaderTooltip,
        _G.ItemRefTooltip,
        _G.ItemRefShoppingTooltip1,
        _G.ItemRefShoppingTooltip2,
        _G.FriendsTooltip,
        _G.ShoppingTooltip1,
        _G.ShoppingTooltip2,
        _G.ReputationParagonTooltip,
        _G.EmbeddedItemTooltip,
        _G.WarCampaignTooltip,
        _G.QuestScrollFrame.StoryTooltip,
        _G.QuestScrollFrame.CampaignTooltip,
        _G.QuickKeybindTooltip,
        _G.LibDBIconTooltip,
    }

    for _, Tooltips in pairs(TTList) do
        if (Tooltips) then
            TT:SetBackdropStyle(Tooltips)

            if (Tooltips.CompareHeader) then
                Tooltips.CompareHeader:StripTexture()
            end
        end
    end

    --hooksecurefunc("SharedTooltip_SetBackdropStyle", self.SetBackdropStyle) 
end

function TT:StyleCloseButton()
	_G.ItemRefTooltip.CloseButton:HandleCloseButton(-6, -6)
end

function TT:CreateAnchor()	
	local Anchor = CreateFrame("Frame", "FeelUI_TooltipAnchor", _G.UIParent)
    Anchor:SetFrameStrata("TOOLTIP")
    Anchor:SetFrameLevel(20)
    Anchor:SetClampedToScreen(true)
	Anchor:Size(200, Panels.ChatPanelRight:GetHeight() - 4)
	Anchor:Point("BOTTOMRIGHT", Panels.ChatPanelRight, 0, 0)
	Anchor:SetMovable(true)

	self.Anchor = Anchor
end

function TT:TooltipAnchorUpdate(tt, Parent)
	local Anchor = TT.Anchor

	if (DB.Global.Tooltip.TooltipOnMouseOver) then
		if (Parent ~= _G.UIParent) then
			self:SetOwner(Anchor)
			self:SetAnchorType("ANCHOR_TOPRIGHT", 0, 18)
		else
			self:SetOwner(parent, "ANCHOR_CURSOR")
		end
	else
		self:SetOwner(Anchor)
		self:SetAnchorType("ANCHOR_TOPRIGHT", 0, 18)
	end
end

function TT:SetTooltipAnchor()
	hooksecurefunc("GameTooltip_SetDefaultAnchor", self.TooltipAnchorUpdate)
end
	
function TT:SetTooltipSetUnitUpdate()
	if (AddTooltipPostCall) then
		AddTooltipPostCall(Enum.TooltipDataType.Unit, self.OnTooltipSetUnit)
	end   
end

function TT:Initialize()
	if (not DB.Global.Tooltip.Enable) then
		return
	end

	self:CreateAnchor()
	self:SetTooltipAnchor()
	self:StyleHealthBar()
	self:StyleTooltips()
	self:StyleCloseButton()
	self:SetTooltipSetUnitUpdate()
end