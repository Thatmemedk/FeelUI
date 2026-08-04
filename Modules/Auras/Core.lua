local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Tables
UI.AuraContainerData = {}

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

function UI:InitializeAuraButton(Button, Options)
    if (not Button) then
        return
    end

    Button:Size(Options.Width, Options.Height)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- Cancel Aura
    Button:SetCancelAuraButtons("RightButtonUp, RightButtonDown")

    -- Tooltip
    Button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, -6)
    Button:SetHideTooltipInCombat(true)

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
			textFormatter = UI:BuildRuleDurationFormatter(),
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
        BorderTop:Point("TOPLEFT", Button, "TOPLEFT", 0, 0)
        BorderTop:Point("TOPRIGHT", Button, "TOPRIGHT", 0, 0)
        BorderTop:SetTexture(Media.Global.Blank)

        local BorderBottom = Overlay:CreateTexture(nil, "BORDER")
        BorderBottom:Height(1)
        BorderBottom:Point("BOTTOMLEFT", Button, "BOTTOMLEFT", 0, 0)
        BorderBottom:Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", 0, 0)
        BorderBottom:SetTexture(Media.Global.Blank)

        local BorderLeft = Overlay:CreateTexture(nil, "BORDER")
        BorderLeft:Width(1)
        BorderLeft:Point("TOPLEFT", Button, "TOPLEFT", 0, 0)
        BorderLeft:Point("BOTTOMLEFT", Button, "BOTTOMLEFT", 0, 0)
        BorderLeft:SetTexture(Media.Global.Blank)

        local BorderRight = Overlay:CreateTexture(nil, "BORDER")
        BorderRight:Width(1)
        BorderRight:Point("TOPRIGHT", Button, "TOPRIGHT", 0, 0)
        BorderRight:Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", 0, 0)
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
end

function UI:InitializeTempAuraButton(Button, Options)
    if (not Button) then
        return
    end

    Button:Size(Options.Width, Options.Height)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- Cancel Aura
    Button:SetCancelAuraButtons("RightButtonUp, RightButtonDown")

    -- Tooltip
    Button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, -6)
    Button:SetHideTooltipInCombat(true)

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

    -- Temp Aura Highlight
    local TempEnchHighlight = Button:CreateTexture(nil, "OVERLAY")
    TempEnchHighlight:SetBlendMode("ADD")
    TempEnchHighlight:SetInside(Button, 1, 1)
    TempEnchHighlight:SetTexture(Media.Global.Blank)
    TempEnchHighlight:SetVertexColor(0.64, 0.19, 0.79, 0.5)

    -- Duration
    if (Options.Duration) then
        local Time = Overlay:CreateFontString(nil, "OVERLAY")
        Time:Point("CENTER", Options.TimeX or 0, Options.TimeY or -8)
        Time:SetFontTemplate("Default")
        
        Button:SetDurationText(Time, {
            --binding = nil,
            textFormatter = UI:BuildRuleDurationFormatter(),
            --textFormat = nil,
            textColor = {
                curve = UI.CooldownColorCurve,
                property = Enum.DurationTextBindingProperty.RemainingDuration,
            },
        })
    end
end

function UI:AddAura(Container, Options)
    if (not Container) then
        return
    end

    local Owner = Container:GetParent()
    local Data = UI.AuraContainerData[Owner]

    if (not Data) then
        return
    end

    local InitializeAura = function(Button)
        UI:InitializeAuraButton(Button, Options)
    end

    local InitializeTempAura = function(Button)
        UI:InitializeTempAuraButton(Button, Options)
    end

    if (Options.MaxAuras == 1) then
        Data.SlotIndex = (Data.SlotIndex or 0) + 1
        local SlotKey = "AuraSlot" .. Data.SlotIndex

        Container:AddAuraSlot(SlotKey, Options.Filter, {
            initializeFrame = InitializeAura,
        })
    else
        Data.GroupIndex = (Data.GroupIndex or 0) + 1
        local GroupKey = "AuraGroup" .. Data.GroupIndex

        Container:AddAuraGroup(GroupKey, Options.Filter, {
            maxFrameCount = Options.MaxAuras,
            initializeFrame = InitializeAura,

            layout = {
                elementSpacing = Options.Spacing or UI:Scale(3),
                lineSpacing = Options.LineSpacing or UI:Scale(8),
                groupSpacing = Options.GroupSpacing or UI:Scale(3),
                groupLineSpacing = Options.GroupLineSpacing or UI:Scale(8),
                sortMethod = AuraContainerSortMethod.ExpirationOnly,
                sortDirection = AuraContainerSortDirection.Normal,
            },
        })
    end

    if (Options.ShowTempItemEnchantment) then
        Container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.MainHand, {
            initializeFrame = InitializeTempAura,
            hidePermanent = true,
        })

        Container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.OffHand, {
            initializeFrame = InitializeTempAura,
            hidePermanent = true,
        })

        Container:SetItemEnchantmentLayout({
            placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups,
        })

        Container:SetItemEnchantmentSortMethod(
            AuraContainerItemEnchantmentSortMethod.Slot,
            AuraContainerSortDirection.Normal
        )
    end
end

function UI:CreateAuraContainer(Frame, Options)
    if (not Frame) then
        return
    end

    local Data = UI.AuraContainerData[Frame]

    if (not Data) then
        Data = {
            Index = 1,
            Containers = {},
            Registry = {},
        }

        UI.AuraContainerData[Frame] = Data
    end

    local Container = CreateFrame("AuraContainer", "FeelUI_AuraContainer".. Data.Index, Frame, "CustomAuraContainerTemplate")

    -- Store The Container Reference By Index.
    Data.Containers[Data.Index] = Container

    -- Increment The Index So The Container Is Unique.
    Data.Index = Data.Index + 1

    -- Keep A Reverse Reference From Container.
    Data.Registry[Container] = Frame

    -- Set The Anchors
    local GrowthDirection = ({
        LEFT = AnchorUtil.FlowDirection.Left,
        RIGHT = AnchorUtil.FlowDirection.Right,
        UP = AnchorUtil.FlowDirection.Up,
        DOWN = AnchorUtil.FlowDirection.Down,
    }) [Options.GrowthDirection] or AnchorUtil.FlowDirection.Right

    local VerticalGrowthDirection = ({
        UP = AnchorUtil.FlowDirection.Up,
        DOWN = AnchorUtil.FlowDirection.Down,
    }) [Options.VerticalGrowthDirection] or AnchorUtil.FlowDirection.Down

    Container:Point(Options.Anchor, Frame, Options.X, Options.Y)
    Container:SetFlowLayoutAnchorPoint(Options.Anchor or "TOPLEFT")
    Container:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal)
    Container:SetFlowLayoutGrowthDirection(GrowthDirection, VerticalGrowthDirection)
    Container:SetFlowLayoutMaximumLineSize(Options.AurasPerRow or 600)

    -- Set Unit
    local Unit = Frame.unit or Options.Unit

    if (type(Unit) == "string") then
        Container:SetUnit(Unit)
    end

    -- Set Policy
    if (Options.Policy) then
        Container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.ProcessAura, Options.Policy)
    end

    -- Add Options
    self:AddAura(Container, Options)

    return Container
end

function UI:InitializeAuraHighlight(Button)
    if (not Button) then
        return
    end

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
    if (not Container) then
        return
    end

    local InitializeHighlight = function(Button)
        UI:InitializeAuraHighlight(Button)
    end

    Container:AddAuraSlot("Aura", Options.Filter, {
        initializeFrame = InitializeHighlight,
    })
end

function UI:CreateAuraHighlight(Frame, Options)
    if (not Frame) then
        return
    end

    local Container = CreateFrame("AuraContainer", nil, Frame, "CustomAuraContainerTemplate")
	Container:SetInside()
    Container:SetUnit(Frame.unit or Options.Unit)
    Container:EnableMouse(false)

    self:AddAuraHighlight(Container, Options)

    return Container
end