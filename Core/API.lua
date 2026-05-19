local UI, DB, Media, Language = select(2, ...):Call()

--------------------
-- Core of FeelUI --
--------------------

-- Call Modules
local FeelUI = UI:RegisterModule("FeelUI")

-- Call Libs
local LSM = UI.Libs.LSM

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local pcall = pcall
local print = print
local type = type
local match = string.match
local floor = math.floor
local min = math.min
local max = math.max
local len = string.len
local byte = string.byte
local sub = string.sub

-- WoW Globals
local issecretvalue = issecretvalue
local issecrettable = issecrettable
local canaccessvalue = canaccessvalue
local hasanysecretvalues = hasanysecretvalues
local UnitSecret = C_Secrets.ShouldUnitIdentityBeSecret

-- WoW Globals
local GetMouseFocus = GetMouseFocus
local GetMouseFoci = GetMouseFoci
local GameMenuFrame = _G.GameMenuFrame

-- WoW Globals
local C_TimerAfter = C_Timer.After

-- HiddenParent
UI.HiddenParent = CreateFrame("Frame", nil, _G.UIParent)
UI.HiddenParent:SetAllPoints()
UI.HiddenParent:Hide()

-- Tables
UI.Texts = {}
UI.Commands = {}
UI.DelayedTimers = {}

-- Functions
UI.ClearTexture = 0
UI.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
UI.Noop = function() return end

-- Blizzard Functions
UI.SmoothBars = Enum.StatusBarInterpolation.ExponentialEaseOut
UI.DirectionElapsed = Enum.StatusBarTimerDirection.ElapsedTime
UI.DirectionRemaining = Enum.StatusBarTimerDirection.RemainingTime
UI.CurvePercent = CurveConstants.ScaleTo100

-- Secret Values
function UI:IsSecretUnit(Unit)
	local Pass, Value = pcall(UnitSecret, Unit)

	if (Pass) then
		return Value
	end
end

function UI:NotSecretUnit(Unit)
	return not UI:IsSecretUnit(Unit)
end

function UI:IsSecretValue(Value)
	return issecretvalue and issecretvalue(Value)
end

function UI:HasAnySecretValues(...)
	return hasanysecretvalues and hasanysecretvalues(...)
end

function UI:NotSecretValue(Value)
	return not UI:IsSecretValue(Value)
end

function UI:IsSecretTable(Table)
	return issecrettable and issecrettable(Table)
end

function UI:NotSecretTable(Table)
	return not UI:IsSecretTable(Table)
end

function UI:CanAccessValue(Value)
	return not canaccessvalue or canaccessvalue(Value)
end

function UI:CanNotAccessValue(Value)
	return not UI:CanAccessValue(Value)
end

function UI:HasSecretValues(Value)
	return Value.HasSecretValues and Value:HasSecretValues()
end

function UI:NoSecretValues(Value)
	return not UI:HasSecretValues(Value)
end

-- UFT8
function UI:UTF8Sub(Text, Index, Dots)
    if (not (Text) or UI:IsSecretValue(Text))  then 
        return 
    end
    
    local Bytes = Text:len()

    if (Bytes <= Index) then
        return Text
    else
        local Len, Pos = 0, 1
        
        while (Pos <= Bytes) do
            Len = Len + 1
            local LeadByte = Text:byte(Pos)

            if (LeadByte > 0 and LeadByte <= 127) then
                Pos = Pos + 1
            elseif (LeadByte >= 192 and LeadByte <= 223) then
                Pos = Pos + 2
            elseif (LeadByte >= 224 and LeadByte <= 239) then
                Pos = Pos + 3
            elseif (LeadByte >= 240 and LeadByte <= 247) then
                Pos = Pos + 4
            end

            if (Len == Index) then 
            	break 
            end
        end

        if (Len == Index and Pos <= Bytes) then
            return Text:sub(1, Pos - 1) .. (Dots and "..." or "")
        else
            return Text
        end
    end
end

-- NameAbbrev
function UI:NameAbbrev(Text)
    local Letters, LastWord = "", strmatch(Text, ".+%s(.+)$")
    
    if (LastWord) then
        for Words in gmatch(Text, ".-%s") do
            local FirstLetter = strsub(gsub(Words, "^[%s%p]*", ""), 1, 1)
            
            if (FirstLetter ~= strlower(FirstLetter)) then
                Letters = format("%s%s. ", Letters, FirstLetter)
            end
        end
        
        Text = format("%s%s", Letters, LastWord)
    end
    
    return Text
end

-- Delay
function UI:Delay(Key, Delay, Func)
    if (type(Delay) ~= "number" or type(Func) ~= "function") then
        return false
    end

    if (self.DelayedTimers[Key]) then
        return false
    end

    self.DelayedTimers[Key] = true

    Delay = Delay < 0.01 and 0.01 or Delay

    C_TimerAfter(Delay, function()
        self.DelayedTimers[Key] = nil
        Func()
    end)

    return true
end

-- Print
function UI:Print(...)
	print("|CFF00AAFF" .. "FeelUI" .. "|r:", ...)
end

-- Register Commands
function UI:RegisterChatCommand(Command, Func)
	local Name = Command:upper()
	
	if (type(Func) == "string") then
		SlashCmdList[Name] = function()
			if (Func == "Help") then
				UI:Print(Language.Help.Commands)
				UI:Print(Language.Help.Options)
				--UI:Print(Language.Help.Move)
				UI:Print(Language.Help.Install)
				UI:Print(Language.Help.Status)
				UI:Print(Language.Help.Grid)
				UI:Print(Language.Help.Discord)
				UI:Print(Language.Help.CDM)
				--UI:Print(Language.Help.Website)
			elseif (Func == "Options") then
				local Options = UI:CallModule("OptionsUI")
				
				if (Options) then
					Options:Toggle()
				else
					UI:Print("|CFF00AAFFFeelUI|r_Options is |CFFFF3333Disabled|r")
				end
			elseif (Func == "Move") then
				--local Move = UI:CallModule("Move")
				-- TO BE WORKED ON.
			elseif (Func == "Status") then
				local Status = UI:CallModule("Status")
				Status:Toggle()
			elseif (Func == "ResetUI") then
				local Install = UI:CallModule("Install")
				Install:Toggle()
			elseif (Func == "Grid") then
				local Align = UI:CallModule("Align")
				Align:Toggle()
			end
		end
	end

	_G["SLASH_"..Name.."1"] = "/"..Command:lower()
	
	UI.Commands[Command] = Name
end

function UI:AddCommand(Name, Keys, Func)
	if (not SlashCmdList[Name]) then
		SlashCmdList[Name] = Func

		if (type(Keys) == "table") then
			for i, Key in next, Keys do
				_G["SLASH_"..Name..i] = Key
			end
		else
			_G["SLASH_"..Name.."1"] = Keys
		end
	end
end

-- Load Commands
function FeelUI:LoadCommands()
	-- Dev Console
	UI:AddCommand("DEVCON", "/devcon", function()
		if (_G.DeveloperConsole) then
			_G.DeveloperConsole:Toggle()
		end
	end)

	-- Reload UI
	UI:AddCommand("RELOADUI", "/rl", _G.ReloadUI)

	-- Pull
	UI:AddCommand("PULL", "/pull", "/countdown", function(msg)
		local Number = gsub(msg, "(%s*)(%d+)", "%2")
		local ToNumber = tonumber(Number)

		if (ToNumber and ToNumber <= Constants.PartyCountdownConstants.MaxCountdownSeconds) then
			C_PartyInfo.DoCountdown(ToNumber)
		end
	end)

	-- ReadyCheck
	UI:AddCommand("READYCHECK", "/rc", "/readycheck", function(msg)
		if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") and not InCombatLockdown()) then
			DoReadyCheck()
		end
	end)

	-- Cooldown Manager
	UI:AddCommand("CDMUI", "/cdm", function()
		if InCombatLockdown() or not _G.CooldownViewerSettings then
			UI:Print("You can't access |CFF00AAFFCooldown Manager|r while in combat.")
			return
		end

		_G.CooldownViewerSettings:ShowUIPanel()
	end)

	-- FeelUI Commands
	UI:RegisterChatCommand("feelui", "Options")
	UI:RegisterChatCommand("fhelp", "Help")
	UI:RegisterChatCommand("fstatus", "Status")
	UI:RegisterChatCommand("freset", "ResetUI")
	UI:RegisterChatCommand("fgrid", "Grid")
end

-- Keep Aspect Ratio
function UI:KeepAspectRatio(Button, Icon, Zoom)
	if (not Button or not Icon) then
		return
	end

	local BaseLeft, BaseRight, BaseTop, BaseBottom = unpack(UI.TexCoords)
	local Width, Height = Button:GetWidth(), Button:GetHeight()
	local Aspect = Width / Height
	local Left, Right = BaseLeft, BaseRight
	local Top, Bottom = BaseTop, BaseBottom
	local Trim = 0

	if (Aspect > 1) then
		Trim = (1 - (1 / Aspect)) * 0.5
		Top = Top + Trim
		Bottom = Bottom - Trim
	elseif (Aspect < 1) then
		Trim = (1 - Aspect) * 0.5
		Left = Left + Trim
		Right = Right - Trim
	end

	Zoom = Zoom or 0.20

	if (Zoom > 0) then
		local HorizontalZoom = (Right - Left) * Zoom * 0.5
		local VerticalZoom = (Bottom - Top) * Zoom * 0.5

		Left = Left + HorizontalZoom
		Right = Right - HorizontalZoom
		Top = Top + VerticalZoom
		Bottom = Bottom - VerticalZoom
	end

	Icon:SetTexCoord(Left, Right, Top, Bottom)
end

-- Pulse Function
function UI:CreatePulse(Frame)
	if (not Frame) then
		return
	end

	local Speed = 0.05
	local Mult = 1
	local Alpha = 0.8
	local Last = 0
	
	Frame:SetScript("OnUpdate", function(self, Elapsed)
		Last = Last + Elapsed
	
		if (Last > Speed) then
			Last = 0
			self:SetAlpha(max(0, min(1, Alpha)))
		end
		
		Alpha = Alpha - Elapsed * Mult
		
		if (Alpha < 0 and Mult > 0) then
			Mult = Mult * -1
			Alpha = 0
		elseif (Alpha > 1 and Mult < 0) then
			Mult = Mult * -1
		end
	end)
end

-- GetMouseFocus
function UI:GetMouseFocus()
	if (GetMouseFoci) then
		local GMF = GetMouseFoci()
		return GMF and GMF[1]
	else
		return GetMouseFocus()
	end
end

-- Update Fonts
function FeelUI:UpdateMedia()
	UI:UpdateBlizzardFonts()
end

-- Update LibSharedMedia
do
	local function LSMCallback() 
		FeelUI:UpdateMedia() 
	end

	LSM.RegisterCallback(UI, "LibSharedMedia_Registered", LSMCallback)
end

-- FeelUI GameMenu
function FeelUI:CreateGameMenu()
	if (self.FeelUIGameMenuIsCreated) then
		return
	end

	if (not GameMenuFrame) then
		return
	end

	-- FRAME
	local Frame = CreateFrame("Frame", "FeelUI_MenuFrame", _G.UIParent)
	Frame:SetFrameStrata("HIGH")
    Frame:SetFrameLevel(GameMenuFrame:GetFrameLevel() - 1)
	Frame:SetAllPoints()
	Frame:CreateBackdrop()
	Frame:CreateShadow()
	Frame:SetAlpha(0)
	Frame:Hide()

	Frame.InvisFrame = CreateFrame("Frame", nil, Frame)
	Frame.InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
	Frame.InvisFrame:SetInside()

	-- CREATE ANIMATIONS
	Frame.Fade = UI:CreateAnimationGroup(Frame)

	Frame.FadeIn = UI:CreateAnimation(Frame.Fade, "Fade")
	Frame.FadeIn:SetDuration(1)
	Frame.FadeIn:SetChange(1)
	Frame.FadeIn:SetEasing("In-SineEase")

	Frame.FadeOut = UI:CreateAnimation(Frame.Fade, "Fade")
	Frame.FadeOut:SetDuration(1)
	Frame.FadeOut:SetChange(0)
	Frame.FadeOut:SetEasing("Out-SineEase")
	Frame.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	-- FEELUI LOGO
	Frame.Logo = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
	Frame.Logo:Size(228, 228)
	Frame.Logo:Point("TOP", GameMenuFrame, 0, 182)
	Frame.Logo:SetTexture(Media.Global.Logo)

	-- TEXT
    Frame.FeedbackText = Frame.InvisFrame:CreateFontString(nil, "OVERLAY")
    Frame.FeedbackText:Point("TOP", GameMenuFrame, 0, 32)
    Frame.FeedbackText:SetFontTemplate("Default", 16)
    Frame.FeedbackText:SetText("Need help or info? Join the |cff00aaffFeelUI|r Discord!")

	Frame.DiscordLogo = Frame.InvisFrame:CreateTexture(nil, "OVERLAY")
	Frame.DiscordLogo:Size(28, 28)
    Frame.DiscordLogo:Point("LEFT", Frame.FeedbackText, 44, -32)
    Frame.DiscordLogo:SetTexture(Media.Global.LogoDiscord)

    Frame.DiscordText = Frame.InvisFrame:CreateFontString(nil, "OVERLAY")
    Frame.DiscordText:Point("LEFT", Frame.DiscordLogo, 34, 0)
    Frame.DiscordText:SetFontTemplate("Default", 12)
    Frame.DiscordText:SetText("discord.gg/Q2mkRme3Yv")

    -- HOOKS
	GameMenuFrame:HookScript("OnShow", function()
		if Frame:IsShown() then
			Frame.FadeOut:Play()
		else
			Frame:Show()
			Frame.FadeIn:Play()
		end
	end)
	
	GameMenuFrame:HookScript("OnHide", function()
		if Frame:IsShown() then
			Frame.FadeOut:Play()
		end
	end)
	
	self.FeelUIGameMenuIsCreated = true
end

-- Initialize The Core
function FeelUI:Initialize()
	self:UpdateMedia()
	self:LoadCommands()
	self:CreateGameMenu()
end