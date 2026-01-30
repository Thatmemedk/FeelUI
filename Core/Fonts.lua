local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

local function SetFont(self, FontSize, FontStyle, ShadowOffsetX, ShadowOffsetY, R, G, B)
	if (not self or self:IsForbidden()) then 
		return 
	end

	if (not FontStyle) then
		FontStyle = ""
	end

	self:SetFont(Media.Global.Font, UI:Scale(FontSize), FontStyle)
	
	if (ShadowOffsetX and ShadowOffsetY) then
		self:SetShadowOffset(UI:Scale(ShadowOffsetX), -UI:Scale(ShadowOffsetY))
		self:SetShadowColor(0, 0, 0, 0.5)
	end

	if (R and G and B) then
		self:SetTextColor(R, G, B)
	end
	
	UI.Texts[self] = true
end

function UI:UpdateBlizzardFonts()
	local NORMALSIZE = 13
	local SMALLSIZE = 12

	_G.UNIT_NAME_FONT = Media.Global.Font
	_G.STANDARD_TEXT_FONT = Media.Global.Font
	_G.DAMAGE_TEXT_FONT = Media.Global.CombatFont

	-- Chat Bubble
	SetFont(_G.ChatBubbleFont,                     14, "THINOUTLINE", 1, 1)
	-- Game System Alerts Fonts	
	SetFont(_G.ZoneTextFont,                       38, "THINOUTLINE", 2, 2)
	SetFont(_G.SubZoneTextFont,                    28, "THINOUTLINE", 2, 2)
	SetFont(_G.PVPInfoTextFont,                    28, "THINOUTLINE", 2, 2)
	SetFont(_G.AutoFollowStatusText, 			   22, "THINOUTLINE", 2, 2) -- Follow Text
	SetFont(_G.ActionStatus.Text, 				   24, "THINOUTLINE", 2, 2) -- Action Status Text
	-- World Map
	SetFont(_G.SystemFont_OutlineThick_WTF,		   38, "THINOUTLINE", 2, 2) -- World Map
	SetFont(_G.SystemFont_Outline,				   28, "THINOUTLINE", 2, 2) -- World Map (Pet Level)
	-- Tooltip Fonts
	SetFont(_G.GameTooltipHeader,                  NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Tooltip_Med,                        SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Tooltip_Small,                      SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.FriendsFont_Large,                  15, "THINOUTLINE", 1, 1)	
	SetFont(_G.FriendsFont_Normal,                 SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.FriendsFont_Small,                  SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.FriendsFont_UserText,               SMALLSIZE, "THINOUTLINE", 1, 1)
	-- Game System Fonts
	SetFont(_G.SystemFont_Shadow_Huge1,            32, "THINOUTLINE", 2, 2) -- Raid Warning, Boss Emote etc.
	SetFont(_G.SystemFont_OutlineThick_Huge2,      22, "THICKOUTLINE")
	SetFont(_G.NumberFont_Outline_Huge,            30, "THICKOUTLINE")
	SetFont(_G.SystemFont_Shadow_Large,            NORMALSIZE)
	SetFont(_G.SystemFont_Large,                   NORMALSIZE)
	SetFont(_G.NumberFont_Outline_Large,           NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.SystemFont_Med1,                    SMALLSIZE)
	SetFont(_G.SystemFont_Med3,                    NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Med1,             SMALLSIZE)
	SetFont(_G.SystemFont_Shadow_Med3,             NORMALSIZE)
	SetFont(_G.NumberFont_Shadow_Med,              NORMALSIZE)
	SetFont(_G.NumberFont_Outline_Med,             NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.SystemFont_Small,                   SMALLSIZE)
	SetFont(_G.SystemFont_Outline_Small,           SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.SystemFont_Shadow_Small,            SMALLSIZE)
	SetFont(_G.NumberFont_Shadow_Small,            SMALLSIZE)
	SetFont(_G.NumberFont_OutlineThick_Mono_Small, SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.SystemFont_Tiny,                    SMALLSIZE)
	-- Game Fonts
	SetFont(_G.GameFontHighlightSmall,             SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontNormalSmall,                SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontDisableSmall,               SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontNormalHuge,                 20, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontNormalLarge,                NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontHighlight,                  SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontDisable,                    SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontNormal,                     SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontBlackMedium,                NORMALSIZE, "THINOUTLINE")
	SetFont(_G.GameFontHighlightMedium,            NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontHighlightSmallLeft,         SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontHighlightSmallRight,        SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontHighlightCenter,            NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontNormalMed3,                 NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontNormalSmall2,               SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.GameFontNormalMed2,                 NORMALSIZE, "THINOUTLINE", 1, 1)
	-- Number Fonts
	SetFont(_G.NumberFontNormalSmall,              SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.NumberFontNormal,                   NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.NumberFontNormalLarge,              NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.NumberFontNormalHuge,               30, "THINOUTLINE", 1, 1)
	-- Auction House
	SetFont(_G.Number11Font,                        SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number12Font,                        NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number15Font,                        NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.PriceFont,                           NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number12Font_o1,                     NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number13Font,                        NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number13FontGray,                    NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number13FontWhite,                   NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number13FontYellow,                  NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number14FontWhite,                  	NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number14FontGray,                  	NORMALSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.Number18Font,                        22, "THINOUTLINE", 1, 1)
	SetFont(_G.Number18FontWhite,                   22, "THINOUTLINE", 1, 1)
	-- Character Panel Texts
	SetFont(_G.CharacterLevelText,                            SMALLSIZE, "THINOUTLINE", 1, 1)
	SetFont(_G.CharacterFrameTitleText,                       NORMALSIZE, "THINOUTLINE", 1, 1, unpack(UI.GetClassColors))
	SetFont(_G.CharacterStatsPane.ItemLevelFrame.Value,       16, "THINOUTLINE", 1, 1)
	SetFont(_G.CharacterStatsPane.ItemLevelCategory.Title,    16, "THINOUTLINE", 1, 1)
	SetFont(_G.CharacterStatsPane.AttributesCategory.Title,   16, "THINOUTLINE", 1, 1)
	SetFont(_G.CharacterStatsPane.EnhancementsCategory.Title, 16, "THINOUTLINE", 1, 1)
	-- Banner Texts
	SetFont(_G.LevelUpDisplaySideLevel,                 		 32, "THINOUTLINE", 1, 1)
	SetFont(_G.LevelUpDisplayLevelFrameLevel,           		 32, "THINOUTLINE", 1, 1)
	SetFont(_G.LevelUpDisplayName,                      	     32, "THINOUTLINE", 1, 1)
	SetFont(_G.BossBanner.Title,    				    		 32, "THINOUTLINE", 1, 1)
	SetFont(_G.BossBanner.SubTitle,    				    		 14, "THINOUTLINE", 1, 1)
	SetFont(_G.BossBanner.SubTitle,    				    		 14, "THINOUTLINE", 1, 1)
	-- LFG
	SetFont(_G.LFGListFrame.CategorySelection.Label,	                    16, "THINOUTLINE", 1, 1)
	SetFont(_G.RaidFinderQueueFrameScrollFrameChildFrameTitle,    		    16, "THINOUTLINE", 1, 1)
	SetFont(_G.RaidFinderQueueFrameScrollFrameChildFrameDescription,        12, "THINOUTLINE", 1, 1)
	SetFont(_G.RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel,    	16, "THINOUTLINE", 1, 1)
	SetFont(_G.RaidFinderQueueFrameScrollFrameChildFrameRewardsDescription, 12, "THINOUTLINE", 1, 1)
	SetFont(_G.LFDQueueFrameRandomScrollFrameChildFrameTitle,    		    16, "THINOUTLINE", 1, 1)
	SetFont(_G.LFDQueueFrameRandomScrollFrameChildFrameXPLabel,				14, "THINOUTLINE", 1, 1)
	SetFont(_G.LFDQueueFrameRandomScrollFrameChildFrameDescription,         12, "THINOUTLINE", 1, 1)
	SetFont(_G.LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel,        16, "THINOUTLINE", 1, 1)
	SetFont(_G.LFDQueueFrameRandomScrollFrameChildFrameRewardsDescription,  12, "THINOUTLINE", 1, 1)
	-- Objective Tracker
	SetFont(_G.ObjectiveTrackerLineFont,       12, "THINOUTLINE", 1, 1)
	SetFont(_G.ObjectiveTrackerHeaderFont,     16, "THINOUTLINE", 1, 1)
end