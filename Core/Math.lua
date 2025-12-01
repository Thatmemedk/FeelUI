local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local unpack = unpack
local select = select
local modf = math.modf
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local format = string.format
local strmatch = string.match
local huge = math.huge
local tonumber = tonumber

-- Colors
-- cffffffff (White)
-- cffff3333 (Red)
-- cff4beb2c (Green)

-- FeelUI
-- cff00aaff (Dark Blue) - (0, 0.66, 1)

-- ElvUI/Tukui
-- cffaf5050 (Light Red)

-- AftermathhUI
-- cff99ccff (Light Blue) - (0.65, 0.84, 1)
-- cffffd200 (Yellow) - (1, 0.82, 0)

-- AsphyxiaUI
-- cffad2424 (Red)
-- cff817fc9 (Lila)
-- cffd38d01 (Yellow)
-- cffff63d3 (Pink)
-- cff1daa1d (Green)
-- cffcccccc (Grey)
-- cffc5b358 (Gold)
-- cff049ffe (Blue)

-- Colors
function UI:RGBToHex(R, G, B, Header, Ending)
	R = R <= 1 and R >= 0 and R or 1
	G = G <= 1 and G >= 0 and G or 1
	B = B <= 1 and B >= 0 and B or 1
	return format("%s%02x%02x%02x%s", Header or "|cff", R*255, G*255, B*255, Ending or "")
end

function UI:HexToRGB(Hex)
	local Alpha, R, G, B = strmatch(Hex, "^|?c?(%x%x)(%x%x)(%x%x)(%x?%x?)|?r?$")
	
	if not (Alpha) then 
		return 0, 0, 0, 0 
	end
	
	if (B == "") then 
		R, G, B, Alpha = Alpha, R, G, "ff"
	end

	return tonumber(R, 16), tonumber(G, 16), tonumber(B, 16), tonumber(Alpha, 16)
end

function UI:ColorGradient(Min, Max, ...)
	local Percent

	if (Max == 0) then
		Percent = 0
	else
		Percent = Min/Max
	end

	if (Percent >= 1) then
		local R, G, B = select(select("#", ...) - 2, ...)
		return R, G, B
	elseif Percent <= 0 then
		local R, G, B = ...
		return R, G, B
	end

	local Num = (select("#", ...) / 3)
	local Segment, RelPercent = modf(Percent * (Num - 1))
	local R1, G1, B1, R2, G2, B2 = select((Segment * 3) + 1, ...)

	return R1 + (R2 - R1) * RelPercent, G1 + (G2 - G1) * RelPercent, B1 + (B2 - B1) * RelPercent
end

function UI:ColorGradientText(Perc, ...)
	local Value = select("#", ...)

	if (Perc >= 1) then
		return select(Value - 2, ...)
	elseif Perc <= 0 then
		return ...
	end

	local Num = Value / 3
	local Segment, RelPerc = modf(Perc*(Num-1))
	local R1, G1, B1, R2, G2, B2 = select((Segment*3)+1, ...)

	return R1+(R2-R1)*RelPerc, G1+(G2-G1)*RelPerc, B1+(B2-B1)*RelPerc
end

-- Round Numbers
function UI:Round(Number, Decimals)
	if not (Decimals) then
		Decimals = 0
	end
	return format(format("%%.%df", Decimals), Number)
end

-- Short Numbers
function UI:FormVal(Value)
	if (Value > 1024) then
		return format("%.2f MB", Value/1024)
	else
		return format("%.2f KB", Value)
	end
end

function UI:ShortNumbers(Value)
	if (Value >= 1e6) then
		return format("%.1fm", Value / 1e6)
	elseif (Value >= 1e3) then
		return format("%.1fk", Value / 1e3)
	else
		return format("%d", Value)
	end
end

function UI:FormatTimeShort(Seconds)
	if (Seconds == mathhuge) then
		return
	end

	local Day, Hour, Minute = 86400, 3600, 60

	if (Seconds >= Day) then
		return format("%dd", ceil(Seconds / Day))
	elseif (Seconds >= Hour) then
		return format("%dh", ceil(Seconds / Hour))
	elseif (Seconds >= Minute) then
		return format("%dm", ceil(Seconds / Minute))
	elseif (Seconds < 10) then
		return format("%.1f", Seconds)
	else
		return format("%d", Seconds)
	end
end

-- Full Numbers
function UI:FormatTime(Seconds)
	local Day, Hour, Minutes = 0, 0, 0
	
	if (Seconds >= 86400) then
		Day = Seconds / 86400
		Seconds = Seconds % 86400
	end

	if (Seconds >= 3600) then
		Hour = Seconds / 3600
		Seconds = Seconds % 3600
	end
	
	if (Seconds >= 60) then
		Minutes = Seconds / 60
		Seconds = Seconds % 60
	end
	
	if (Day > 0) then
		return format("%.2d|CFF00AAFF:|r%.2d", Day, Hour)
	elseif (Hour > 0) then
		return format("%.2d|CFF00AAFF:|r%.2d", Hour, Minutes)
	elseif (Minutes > 0) then
		return format("%.1d|CFF00AAFF:|r%.2d", Minutes, Seconds)
	elseif (Seconds < 10) then
		return format("%.1f", Seconds) 
	else
		return format("%d", Seconds)
	end
end

-- Money Formats
function UI:FormatMoney(Value, TextOnly)
    local Amount = abs(Value)
    local GOLD = floor(Amount / 10000)
    local SILVER = floor(mod(Amount / 100, 100))
    local COPPER = floor(mod(Amount, 100))

    local COLOR_GOLD, COLOR_SILVER, COLOR_COPPER = "|cffffd700", "|cffc7c7cf", "|cffeda55f"
    local ICON_GOLD   = TextOnly and COLOR_GOLD .. "g|r" or "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12|t"
    local ICON_SILVER = TextOnly and COLOR_SILVER .. "s|r" or "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12|t"
    local ICON_COPPER = TextOnly and COLOR_COPPER .. "c|r" or "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12|t"

    if (GOLD > 0) then
        return format("%s%sg|r %s%ss|r %s%02dc|r", COLOR_GOLD, BreakUpLargeNumbers(GOLD), COLOR_SILVER, SILVER, COLOR_COPPER, COPPER)
    elseif (SILVER > 0) then
        return format("%s%ds|r %s%02dc|r", COLOR_SILVER, SILVER, COLOR_COPPER, COPPER)
    else
        return format("%s%dc|r", COLOR_COPPER, COPPER)
    end
end