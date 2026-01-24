local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Time = UI:RegisterModule("DataTextTime")

-- Lib Globals
local unpack = unpack
local select = select

function Time:Create()
	local Frame = CreateFrame("Frame", nil, _G.Minimap)
	Frame:Size(160, 50)
	Frame:Point("BOTTOM", _G.Minimap, 0, -12)

	local Text = Frame:CreateFontString(nil, "OVERLAY")
	Text:Point("CENTER", Frame, 0, 0)
	Text:SetFontTemplate("Default", 16, 2, 2) 
	Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

	self.Frame = Frame
	self.Text = Text
end

function Time:Update(Elapsed)
    self.Init = (self.Init or 0) - Elapsed

    if (self.Init > 0) then 
    	return 
    end

    self.Init = 1

    if (self.Text) then
		self.Text:SetFormattedText("%s", date( "|CFFFFFFFF%I|r:|CFFFFFFFF%M|r"))
	end
end

function Time:OnUpdate()
	self:SetScript("OnUpdate", self.Update)
end

function Time:Initialize()
	if (not DB.Global.DataTexts.Time) then 
		return 
	end
	
	self:Create()
	self:OnUpdate()
end