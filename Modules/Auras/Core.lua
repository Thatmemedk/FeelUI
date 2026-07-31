local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

function UI:BuildRuleDurationFormatter()
    if (not (C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and Enum.NumericRuleFormatRounding)) then
        return nil
    end

    local Formatter = C_StringUtil.CreateNumericRuleFormatter()
    local Down = Enum.NumericRuleFormatRounding.Down

    Formatter:SetBreakpoints({
        { threshold = 0, format = "%.1f", step = 0.1, rounding = Down },
        { threshold = 10, format = "%d", step = 1, rounding = Down },
        { threshold = 60, format = "%d:%02d", step = 1, rounding = Down, components = { { div = 60 }, { div = 1 } } },
        { threshold = 120, format = "%dm", step = 1, rounding = Down, components = { { div = 60 } } },
        { threshold = 3600, format = "%dh", step = 1, rounding = Down, components = { { div = 3600 } } },
        { threshold = 86400, format = "%dd", step = 1, rounding = Down, components = { { div = 86400 } } },
    })

    return Formatter
end

function UI:GetDurationFormatter()
    if (not UI.DurationFormatter) then
        UI.DurationFormatter = UI:BuildRuleDurationFormatter()
    end

    return UI.DurationFormatter
end

function UI:InitializeAuraButton(Button, Options)
    Button:Size(Options.Width, Options.Height)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- Icon
    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetInside()

    -- Setup Aspect Ratio
    UI:KeepAspectRatio(Button, Icon)

    -- Set Icon
    Button:SetIcon(Icon)

    -- Overlay
    local Overlay = CreateFrame("Frame", nil, Button)
    Overlay:SetFrameLevel(Button:GetFrameLevel() + 10)
    Overlay:SetInside()

    -- Cooldown
    if (Options.Cooldown) then
        local Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
        Cooldown:SetInside()
        Cooldown:SetDrawEdge(false)
        Cooldown:SetDrawBling(false)
        Cooldown:SetReverse(true)
        Cooldown:SetHideCountdownNumbers(true)

        Button:SetDurationCooldown(Cooldown)
    end

    -- Count
    if (Options.Count) then
        local Count = Overlay:CreateFontString(nil, "OVERLAY")
        Count:Point("TOPRIGHT", Button, Options.CountX or 2, Options.CountY or 2)
        Count:SetFontTemplate("Default")

        Button:SetApplicationCount(Count)
    end

    -- Duration
    if (Options.Duration) then
        local Time = Overlay:CreateFontString(nil, "OVERLAY")
        Time:Point("CENTER", Options.TimeX or 0, Options.TimeY or -8)
        Time:SetFontTemplate("Default")
        
        Button:SetDurationText(Time, {
			--binding = nil,
			textFormatter = UI:GetDurationFormatter(),
			--textFormat = nil,
			textColor = {
			    curve = UI.CooldownColorCurve,
			    property = Enum.DurationTextBindingProperty.RemainingDuration,
			},
		})
    end

    -- Debuff Border
    if (Options.Border) then
        local BorderStyle = {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
            showWhenHarmful = true,
            showWhenHelpful = false,
            showWithoutDispelType = true,
            customDispelColorMap = UI.Colors.Dispel,
        }

        local BorderTop = Overlay:CreateTexture(nil, "BORDER")
        BorderTop:Height(1)
        BorderTop:Point("TOPLEFT", Button, 0, 0)
        BorderTop:Point("TOPRIGHT", Button, 0, 0)
        BorderTop:SetTexture(Media.Global.Blank)

        local BorderBottom = Overlay:CreateTexture(nil, "BORDER")
        BorderBottom:Height(1)
        BorderBottom:Point("BOTTOMLEFT", 0, 0)
        BorderBottom:Point("BOTTOMRIGHT", 0, 0)
        BorderBottom:SetTexture(Media.Global.Blank)

        local BorderLeft = Overlay:CreateTexture(nil, "BORDER")
        BorderLeft:Width(1)
        BorderLeft:Point("TOPLEFT", Button, 0, 0)
        BorderLeft:Point("BOTTOMLEFT", Button, 0, 0)
        BorderLeft:SetTexture(Media.Global.Blank)

        local BorderRight = Overlay:CreateTexture(nil, "BORDER")
        BorderRight:Width(1)
        BorderRight:Point("TOPRIGHT", Button, 0, 0)
        BorderRight:Point("BOTTOMRIGHT", Button, 0, 0)
        BorderRight:SetTexture(Media.Global.Blank)

		Button.BorderThick = {}
	
		for i = 1, 8 do
			Button.BorderThick[i] = Overlay:CreateTexture(nil, "OVERLAY")
			Button.BorderThick[i]:Size(1, 1)
			Button.BorderThick[i]:SetColorTexture(0, 0, 0, 1)
		end
		
		Button.BorderThick[1]:Point("TOPLEFT", Button, "TOPLEFT", -1, 1)
		Button.BorderThick[1]:Point("TOPRIGHT", Button, "TOPRIGHT", 1, -1)

		Button.BorderThick[2]:Point("BOTTOMLEFT", Button, "BOTTOMLEFT", -1, -1)
		Button.BorderThick[2]:Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", 1, -1)

		Button.BorderThick[3]:Point("TOPLEFT", Button, "TOPLEFT", -1, 1)
		Button.BorderThick[3]:Point("BOTTOMLEFT", Button, "BOTTOMLEFT", 1, -1)

		Button.BorderThick[4]:Point("TOPRIGHT", Button, "TOPRIGHT", 1, 1)
		Button.BorderThick[4]:Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -1, -1)

		Button.BorderThick[5]:Point("TOPLEFT", Button, "TOPLEFT", 1, -1)
		Button.BorderThick[5]:Point("TOPRIGHT", Button, "TOPRIGHT", -1, 1)

		Button.BorderThick[6]:Point("BOTTOMLEFT", Button, "BOTTOMLEFT", 1, 1)
		Button.BorderThick[6]:Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -1, 1)

		Button.BorderThick[7]:Point("TOPLEFT", Button, "TOPLEFT", 1, -1)
		Button.BorderThick[7]:Point("BOTTOMLEFT", Button, "BOTTOMLEFT", -1, 1)

		Button.BorderThick[8]:Point("TOPRIGHT", Button, "TOPRIGHT", -1, -1)
		Button.BorderThick[8]:Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", 1, 1)

        Button:AddDispelTypeTexture(BorderTop, BorderStyle)
        Button:AddDispelTypeTexture(BorderBottom, BorderStyle)
        Button:AddDispelTypeTexture(BorderLeft, BorderStyle)
        Button:AddDispelTypeTexture(BorderRight, BorderStyle)

        Button.Shadow:SetOutside(Button, 3, 3)
    elseif (Options.Border == false) then
        Button.Shadow:SetOutside(Button, 2, 2)
    end

    -- Debuff Icon
    if (Options.DebuffIndicator) then
        local DispelIndicator = Overlay:CreateTexture(nil, "OVERLAY")
        DispelIndicator:Size(16, 16)
        DispelIndicator:Point("CENTER", Button, 0, 10)

        Button:AddDispelTypeTexture(DispelIndicator, {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
            showWhenHarmful = true,
            showWhenHelpful = false,
        })
    end

    Button:SetCancelAuraButtons("RightButtonUp, RightButtonDown")
end

function UI:AddAura(Container, Options)
    local InitializeAura = function(Button)
        UI:InitializeAuraButton(Button, Options)
    end

    if (Options.MaxAuras == 1) then
        Container:AddAuraSlot(Container:GetDebugName(), Options.Filter, {
            initializeFrame = InitializeAura,
        })
    else
        Container:AddAuraGroup(Container:GetDebugName(), Options.Filter, {
            maxFrameCount = Options.MaxAuras,
            initializeFrame = InitializeAura,

            layout = {
                elementSpacing = Options.Spacing or UI:Scale(3),
                lineSpacing = Options.LineSpacing or 0,
				groupSpacing = Options.GroupSpacing or 0,
				groupLineSpacing = Options.GroupLineSpacing or 0,
				forceNewLine = true,
				sortMethod = AuraContainerSortMethod.ExpirationOnly,
				sortDirection = AuraContainerSortDirection.Normal,
            },
        })
    end
end

function UI:CreateAuraContainer(Frame, Options)
    local Container = CreateFrame("AuraContainer", nil, Frame, "CustomAuraContainerTemplate")
    Container:Point(Options.Anchor, Frame, Options.RelativeAnchor or Options.Anchor, Options.X, Options.Y)
    Container:SetFlowLayoutAnchorPoint(Options.SetFlowLayoutAnchorPoint or "TOPLEFT")
    Container:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal)
    Container:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Down)
    --Container:SetFlowLayoutMaximumLineSize(255)
    Container:SetUnit(Frame.unit or Options.Unit)

    if (Options.Direction == "LEFT") then
        Container:SetFlowLayoutGrowthDirection(-1, 1)
    elseif (Options.Direction == "RIGHT") then
        Container:SetFlowLayoutGrowthDirection(1, 1)
    elseif (Options.Direction == "UP") then
        Container:SetFlowLayoutGrowthDirection(1, 1)
    elseif (Options.Direction == "DOWN") then
        Container:SetFlowLayoutGrowthDirection(1, -1)
    end

    self:AddAura(Container, Options)

    return Container
end

function UI:InitializeAuraHighlight(Button)
    local DispelGradient = Button:CreateTexture(nil, "OVERLAY")
    DispelGradient:SetInside()
    DispelGradient:SetAtlas("_RaidFrame-Dispel-Highlight-Horizontal", false, nil, nil, "REPEAT", "CLAMP")
    DispelGradient:SetTexCoord(0, 1, 0, 1)

    local DispelBorder = Button:CreateTexture(nil, "OVERLAY")
    DispelBorder:SetInside()
    DispelBorder:SetAtlas("RaidFrame-DispelHighlight")

    local DispelIcon = Button:CreateTexture(nil, "OVERLAY")
    DispelIcon:Size(24, 24)
    DispelIcon:Point("CENTER", Button, "TOPRIGHT", -1, -1)

    Button:AddDispelTypeTexture(DispelGradient, {
        style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
        customDispelColorMap = UI.Colors.Dispel,
    })

    Button:AddDispelTypeTexture(DispelBorder, {
        style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
        customDispelColorMap = UI.Colors.Dispel,
    })

    Button:AddDispelTypeTexture(DispelIcon, {
        style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
    })
end

function UI:AddAuraHighlight(Container, Options)
    local InitializeHighlight = function(Button)
        UI:InitializeAuraHighlight(Button)
    end

    Container:AddAuraSlot("Aura", Options.Filter, {
        initializeFrame = InitializeHighlight,
    })
end

function UI:CreateAuraHighlight(Frame, Options)
    local Container = CreateFrame("AuraContainer", nil, Frame, "CustomAuraContainerTemplate")
	Container:SetInside()
    Container:SetUnit(Frame.unit or Options.Unit)
    Container:EnableMouse(false)

    self:AddAuraHighlight(Container, Options)

    return Container
end