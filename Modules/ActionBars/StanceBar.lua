local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")

-- Lib Globals
local _G = _G
local unpack = unpack

-- WoW Globals
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS or 10
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local StanceBar = _G.StanceBar or _G.StanceBarFrame or _G.ShapeshiftBarFrame

function AB:StanceBarUpdateState()
    local Bar = AB.StanceBar
    local NumForms = GetNumShapeshiftForms()
    local Width, Height  = unpack(DB.Global.ActionBars.StanceButtonSize)
    local Spacing = DB.Global.ActionBars.ButtonSpacing
    local Padding = 4

    if (NumForms < 1) then
        Bar.Backdrop:Hide()

        for i = 1, NUM_STANCE_SLOTS do
            local Button = _G["StanceButton"..i]

            if (Button) then 
            	Button:SetAlpha(0) 
            end
        end

        return
    end

    Bar.Backdrop:Size((NumForms * Width) + ((NumForms - 1) * Spacing) + (Padding * 2), Height + (Padding * 2))
    Bar.Backdrop:ClearAllPoints()
    Bar.Backdrop:Point("LEFT", _G.StanceButton1, "LEFT", -Padding, 0)
    Bar.Backdrop:Show()

    for i = 1, NUM_STANCE_SLOTS do
        local Button = _G["StanceButton"..i]
		local Icon = Button.icon

        if (i <= NumForms) then
            local Texture, IsActive, IsCastable = GetShapeshiftFormInfo(i)

            if (not Texture) then 
            	Texture = 136116 
            end

			Icon:SetInside() 
			Icon:SetTexture(Texture)

            Button:SetChecked(IsActive)
            Button:SetAlpha(1)

            if (IsCastable) then
                Button.icon:SetVertexColor(1, 1, 1)
            else
                Button.icon:SetVertexColor(0.4, 0.4, 0.4)
            end
        else
            Button:SetAlpha(0)
        end
    end
end

function AB:UpdateStanceBar(event)
	local NumForms = GetNumShapeshiftForms()

	if (NumForms == 0) then
		AB.StanceBar:SetAlpha(0)
	else
		AB.StanceBar:SetAlpha(1)
	end
end

function AB:CreateBarStance()
	local Bar = AB.StanceBar
	local Spacing = DB.Global.ActionBars.ButtonSpacing

	if (StanceBar) then
		StanceBar.ignoreFramePositionManager = true
		StanceBar:StripTexture()
		StanceBar:EnableMouse(false)
		StanceBar:UnregisterAllEvents()
	end

	for i = 1, NUM_STANCE_SLOTS do
		local Button = _G["StanceButton"..i]
		Button:Size(unpack(DB.Global.ActionBars.StanceButtonSize))
		Button:SetParent(Bar)
		Button:ClearAllPoints()

		if (i == 1) then
			Button:Point("LEFT", Bar, "LEFT", Spacing, 0)
		else
			Button:Point("LEFT", _G["StanceButton"..(i - 1)], "RIGHT", Spacing, 0)
		end
	end

	Bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	Bar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	Bar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	Bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	Bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
	Bar:SetScript("OnEvent", function(_, event)
		AB:StanceBarUpdateState()
		AB:UpdateStanceBar(event)
	end)

	self:StanceBarUpdateState()
	self:SkinStanceButtons()

	if (DB.Global.ActionBars.StanceBar) then
		RegisterStateDriver(Bar, "visibility", "[vehicleui][petbattle][overridebar] hide; show")
	else
		UnregisterStateDriver(Bar, "visibility")
	end
end