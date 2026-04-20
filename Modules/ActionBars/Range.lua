local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")
	
-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange
local ActionHasRange = ActionHasRange

function AB:CreateRange()
	hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, ChecksRange, InRange)
		local Icon = self.icon
		local ID = self.action

		if (not Icon or not ID) then 
			return 
		end

		local IsUsable, NotEnoughMana = IsUsableAction(ID)
		local HasRange = ActionHasRange(ID)
		local InRange = IsActionInRange(ID)

		if (IsUsable) then
			if (HasRange and InRange == false) then
				Icon:SetVertexColor(0.82, 0.22, 0.22, 1)
			else
				Icon:SetVertexColor(1, 1, 1, 1)
			end
		elseif (NotEnoughMana) then
			Icon:SetVertexColor(0.22, 0.22, 0.82, 1)
		else
			Icon:SetVertexColor(0.82, 0.82, 0.82, 1)
		end
	end)
end