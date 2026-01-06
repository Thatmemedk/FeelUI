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
local match = string.match
local floor = math.floor
local min = math.min
local max = math.max
local len = string.len
local byte = string.byte
local sub = string.sub

-- WoW Globals
local GetMouseFocus = GetMouseFocus
local GetMouseFoci = GetMouseFoci

-- HiddenParent
UI.HiddenParent = CreateFrame("Frame", nil, _G.UIParent)
UI.HiddenParent:SetAllPoints()
UI.HiddenParent:Hide()

-- Tables
UI.Texts = {}
UI.Commands = {}

-- Functions
UI.ClearTexture = UI.Retail and 0 or ""
UI.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
UI.Noop = function() return end

-- Blizzard Functions
UI.SmoothBars = Enum.StatusBarInterpolation.ExponentialEaseOut
UI.DirectionElapsed = Enum.StatusBarTimerDirection.ElapsedTime
UI.DirectionRemaining = Enum.StatusBarTimerDirection.RemainingTime
UI.CurvePercent = CurveConstants.ScaleTo100

-- UFT8
function UI:UTF8Sub(Text, Index, Dots)
    if not (Text) then 
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

-- Keep Aspect Ratio
function UI:KeepAspectRatio(Button, Icon)
	if (not Button or not Icon) then
		return
	end

	local BaseLeft, BaseRight, BaseTop, BaseBottom = unpack(UI.TexCoords)
	local Width, Height = Button:GetWidth(), Button:GetHeight()
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

-- CD Font Scaling
function UI:GetCooldownFontScale(CD)
    if (not CD) then 
    	return
    end

    local Width = CD:GetWidth() or 36
    local Height = CD:GetHeight() or 36
    local BaseSize = min(Width, Height)
    local Scale = BaseSize / 36

    if (Scale < 0.7) then
        Scale = 0.7
    elseif (Scale > 1.6) then
        Scale = 1.6
    end

    if (Scale < 1) then
        Scale = 0.8 + (Scale * 0.2)
    end

    local FontSize = floor(Scale * 15 + 0.6)

    if (FontSize < 10) then
        FontSize = 10
    end

    return FontSize
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

-- Update Fonts
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
	self:UpdateMedia()
	self:LoadCommands()
end