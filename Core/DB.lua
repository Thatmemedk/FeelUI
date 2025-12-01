local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local pairs = pairs
local tonumber = tonumber
local type = type
local format = string.format
local gsub = string.gsub
local split = string.split

-- Locals
local MyVersion = UI.Version
local MyClass = UI.MyClass
local MyRegion = UI.MyRegion
local Name = UI.MyName
local Realm = UI.MyRealm

-- DB
function UI:LoadDB()
	if not (FeelDB) then
		FeelDB = {}
	end

	if not (FeelDB[Realm]) then
		FeelDB[Realm] = {}
	end

	if not (FeelDB[Realm][Name]) then
		FeelDB[Realm][Name] = {}
	end
	
	if not (FeelDB[Realm][Name].Install) then
		FeelDB[Realm][Name].Install = {}
	end
end

function UI:ResetDB()
	if not (FeelDB) then
		return
	end

	FeelDB = nil
	FeelDB = {}
	FeelDB[Realm] = {}
	FeelDB[Realm][Name] = {}
end

-- STORAGE DB
function UI:LoadStorageDB()
	local Storage = FeelDB[Realm][Name]

	for Group, Options in pairs(Storage) do
		if (DB[Group]) then
			local Count = 0

			for Option, Value in pairs(Options) do
				if (DB[Group][Option] ~= nil) then
					if (DB[Group][Option] == Value) then
						Storage[Group][Option] = nil
					else
						Count = Count + 1

						if (type(DB[Group][Option]) == "table") then
							if (DB[Group][Option][Options]) then
								DB[Group][Option][Value] = Value
							else
								DB[Group][Option] = Value
							end
						else
							DB[Group][Option] = Value
						end
					end
				end
			end
		else
			Storage[Group] = nil
		end
	end
end

-- STORAGE CHARACTER DB
function UI:LoadCharacterStorageDB()
	local Storage = FeelDB[Realm][Name]

	for Option, Value in pairs(DB) do
		if (type(Value) ~= "table") then
			if (Storage[Option] == nil) then
				Storage[Option] = Value
			end
		else
			if (Storage[Option] == nil) then
				Storage[Option] = {}
			end

			for List, Key in pairs(Value) do
				if (Storage[Option][List] == nil) then
					Storage[Option][List] = Key
				end
			end
		end
	end
end

-- EXPORT STORAGE
function UI:ExportStorageDB(EditBox)
	local Data = FeelDB[Realm][Name]
	local String = "FeelUI_Export:" .. UIVersion .. ":" .. MyRegion .. ":" .. MyClass

	for OptionCategroy, OptionTable in pairs(Data) do
		if (type(OptionTable) == "table") then
			for Setting, Value in pairs(OptionTable) do
				if (type(Value) ~= "table") then

					if (Data[OptionCategroy][Setting] == false) then
						UI.ValueText = "false"
					elseif (Data[OptionCategroy][Setting] == true) then
						UI.ValueText = "true"
					else
						UI.ValueText = Data[OptionCategroy][Setting]
					end

					String = String .. "^" .. OptionCategroy .. "~" .. Setting .. "~" .. UI.ValueText
				else
					String = String .. "^" .. OptionCategroy .. "~" .. Setting .. "~" .. Data[OptionCategroy][Setting][1] .. "~" .. Data[OptionCategroy][Setting][2] .. "~" .. Data[OptionCategroy][Setting][3] .. "~" .. Data[OptionCategroy][Setting][4]
				end
			end
		else

		end
	end

	EditBox:SetText(String)
	EditBox:HighlightText()
end

-- IMPORT STORAGE
function UI:ImportStorageDB(String)
	local Data = FeelDB[Realm][Name]
	local Lines = { split("^", String) }
	local UIName, Version, Locale, Class = split(":", Lines[1])
	local SameVersion, SameLocale, SameClass

	if (UIName ~= "FeelUI_Export") then
		UI:Print("STATIC_POPUP_PROFILE_IMPORT_INCORRECT_IMPORT_STRING")
	else
		UI:Print("STATIC_POPUP_PROFILE_IMPORT_CORRECT_IMPORT_STRING")

		local ImportString = ""

		if (Version ~= MyVersion) then
			ImportString = ImportString .. format("\nImport Version %s(Current Version %s)", Version, MyVersion)
		else
			SameVersion = true
		end

		if (Locale ~= MyRegion) then
			ImportString = ImportString .. format("\nGame Client %s(Current Client %s)", Locale, MyRegion)
		else
			SameLocale = true
		end

		if (Class ~= MyClass) then
			ImportString = ImportString .. format("\nClass %s(Current Class %s)", Class, MyClass)
		else
			SameClass = true
		end

		if not (SameVersion and SameLocale and SameClass) then
			ImportString = ImportString .. "\nMay not import completely."
		end

		for Index, Key in pairs(Lines) do
			if (Index ~= 1) then
				local OptionCategroy, Setting, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9 = split("~", Key)
				local Count = select(2, gsub(Key, "~", "~")) + 1

				if (Count == 3) then
					if (Data[OptionCategroy][Setting] ~= nil) then
						if (Arg1 == "true") then
							Data[OptionCategroy][Setting] = true
						elseif (Arg1 == "false") then
							Data[OptionCategroy][Setting] = false
						elseif (tonumber(Arg1)) then
							Data[OptionCategroy][Setting] = tonumber(Arg1)
						else
							Data[OptionCategroy][Setting] = Arg1
						end
					end
				else
					if (OptionCategroy == "Colors") then
						Data[OptionCategroy][Setting] = {}
						Data[OptionCategroy][Setting] = {
							tonumber(Arg1),
							tonumber(Arg2),
							tonumber(Arg3),
							tonumber(Arg4)
						}
					end
				end
			end
		end
	end
end