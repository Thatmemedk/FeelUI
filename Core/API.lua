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
local select = select
local unpack = unpack
local print = print
local type = type
local match, floor = string.match, math.floor
local min, max = math.min, math.max

-- WoW Globals
local GetPhysicalScreenSize = GetPhysicalScreenSize
local Resolution = select(1, GetPhysicalScreenSize()).."x"..select(2, GetPhysicalScreenSize())
local PixelPerfectScale = 768 / match(Resolution, "%d+x(%d+)")

-- WoW Globals
local GetMouseFocus = GetMouseFocus
local GetMouseFoci = GetMouseFoci

-- HiddenParent
UI.HiddenParent = CreateFrame("Frame", nil, _G.UIParent)
UI.HiddenParent:SetAllPoints()
UI.HiddenParent:Hide()

-- Functions
UI.Texts = {}
UI.ClearTexture = UI.Retail and 0 or ""
UI.Noop = function() return end
UI.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
UI.SmoothBars = Enum.StatusBarInterpolation.ExponentialEaseOut

-- Print
function UI:Print(...)
	print("|CFF00AAFF" .. "FeelUI" .. "|r:", ...)
end

-- Chat Commands
UI.Commands = {}

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
				--UI:Print(Language.Help.Website)
			elseif (Func == "Options") then
				local Options = UI:CallModule("Options")
				
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
	if not SlashCmdList[Name] then
		SlashCmdList[Name] = Func

		if type(Keys) == "table" then
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
	UI:AddCommand("RELOADUI", {"/rl"}, _G.ReloadUI)
	UI:AddCommand("DEVCON", "/devcon", function()
		if (_G.DeveloperConsole) then
			_G.DeveloperConsole:Toggle()
		end
	end)

	UI:RegisterChatCommand("feelui", "Options")
	UI:RegisterChatCommand("fhelp", "Help")
	UI:RegisterChatCommand("fstatus", "Status")
	UI:RegisterChatCommand("freset", "ResetUI")
	UI:RegisterChatCommand("fgrid", "Grid")
end

-- Pixel Perfect
function FeelUI:SetUIScale()
	self:RegisterEvent("PLAYER_LOGIN")
	self:SetScript("OnEvent", function(self, event)
		if (event ~= "PLAYER_LOGIN") then 
			return 
		end

		if (DB.Global.General.UseUIScale) then
			local Scale = max(DB.Global.General.UIScaleMin, min(1.15, DB.Global.General.UIScaleMax))
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", Scale)
		end
	end)
end

function UI:Scale(x)
	local Mult = PixelPerfectScale / GetCVar("uiScale")
	return Mult * floor(x / Mult + 0.5)
end

-- Keep Aspect Ratio
function UI:KeepAspectRatio(Button, Icon)
	if (not Button or not Icon) then
		return
	end

	local BaseLeft, BaseRight, BaseTop, BaseBottom = unpack(UI.TexCoords)
	local Width, Height = Button:GetWidth(), Button:GetHeight()

	if (not Width or not Height or Height == 0) then
		return
	end

	local Aspect = Width / Height
	local Trim = 0

	if (Aspect > 1) then
		Trim = (1 - (1 / Aspect)) * 0.5
		BaseTop = BaseTop + Trim
		BaseBottom = BaseBottom - Trim
	elseif (Aspect < 1) then
		Trim = (1 - Aspect) * 0.5
		BaseLeft = BaseLeft + Trim
		BaseRight = BaseRight - Trim
	end

	Icon:SetTexCoord(BaseLeft, BaseRight, BaseTop, BaseBottom)
end

-- Pulse Function
function UI:CreatePulse(Frame)
	if not (Frame) then
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

-- Update Update Media
function FeelUI:UpdateMedia()
	UI:UpdateBlizzardFonts()
end

-- Update LibSharedMedia
do
	local function LSMCallback() FeelUI:UpdateMedia() end
	LSM.RegisterCallback(UI, "LibSharedMedia_Registered", LSMCallback)
end

-- Initialize The Core
function FeelUI:Initialize()
	self:SetUIScale()
	self:UpdateMedia()
	self:LoadCommands()
end