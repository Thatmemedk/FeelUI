local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Time = UI:RegisterModule("DataTextTime")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Locals
Time.UpdateInterval = 1

function Time:Create()
	local Frame = CreateFrame("Frame", nil, _G.Minimap)
	Frame:Size(160, 50)
	Frame:Point("BOTTOM", _G.Minimap, 0, -12)

	local Text = Frame:CreateFontString(nil, "OVERLAY")
	Text:Point("CENTER", Frame, 0, 0)
	Text:SetFontTemplate("Default", 14) 
	Text:SetTextColor(unpack(DB.Global.DataTexts.TextColor))

	self.Frame = Frame
	self.Text = Text
end

function Time:Update(Elapsed)
    self.TimeElapsed = (self.TimeElapsed or 0) - Elapsed

    if (self.TimeElapsed > 0) then 
        return 
    end

    self.TimeElapsed = self.UpdateInterval

	-- Update Text
	self.Text:SetText(date("|CFFFFFFFF%I|r:|CFFFFFFFF%M|r"))
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