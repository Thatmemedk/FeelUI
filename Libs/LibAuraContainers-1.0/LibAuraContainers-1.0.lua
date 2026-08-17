local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

---------------------------
-- LibAuraContainers 1.0 --
---------------------------

--[[
"HELPFUL"; Include only helpful auras (buffs)
"HELPFUL|PLAYER"; Include only auras that were cast by the player, or by the player's pet or vehicle
"HELPFUL|RAID"; Include only auras the player can apply
"HELPFUL|PLAYER|RAID_IN_COMBAT; Include only auras flagged to show on raid frames in combat. Combine with HELPFUL & PLAYER to return self-cast HoTs
"HELPFUL|RAID_PLAYER_DISPELLABLE"; Include only auras someone in the player's raid can purge/steal
"HELPFUL|EXTERNAL_DEFENSIVE"; Include only auras that are external defensives
"HELPFUL|BIG_DEFENSIVE"; Include only auras that are big defensives

"HARMFUL"; Include only harmful auras (debuffs)
"HARMFUL|PLAYER"; Include only auras that were cast by the player, or by the player's pet or vehicle
"HARMFUL|RAID"; Include only auras the player can dispel
"HARMFUL|RAID_PLAYER_DISPELLABLE"; Include only auras someone in the player's raid can dispel
"HARMFUL|DISPELLABLE; Include only auras that are dispellable/purgeable/stealable, regardless of whether the player or someone in the player's raid can
"HARMFUL|CROWD_CONTROL"; Include only auras that have a crowd control effect (stun, fear, silence, slow, etc.)
--]]

-- Tables
UI.AuraContainerData = {}
UI.AuraContainerIndex = 0

-- FORMATTER

function UI:BuildRuleDurationFormatter()
    local Formatter = C_StringUtil.CreateNumericRuleFormatter()
    local Down = Enum.NumericRuleFormatRounding.Down
    local ExpireColor = CreateColor(unpack(DB.Global.CooldownFrame.ExpireColor))
    local SecondsColor = CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor))
    local SecondsColor2 = CreateColor(unpack(DB.Global.CooldownFrame.SecondsColor2))
    local NormalColor = CreateColor(unpack(DB.Global.CooldownFrame.NormalColor))

    Formatter:SetBreakpoints({
        { threshold = 0, format = ExpireColor:WrapTextInColorCode("%.1f"), step = 0.1, rounding = Down },
        { threshold = 10, format = SecondsColor:WrapTextInColorCode("%d"), step = 1, rounding = Down },
        { threshold = 30, format = SecondsColor2:WrapTextInColorCode("%d"), step = 1, rounding = Down },
        { threshold = 60, format = NormalColor:WrapTextInColorCode("%d:%02d"), step = 1, rounding = Down, components = {{ div = 60 }, { div = 1, mod = 60 }} },
        { threshold = 120, format = NormalColor:WrapTextInColorCode("%dm"), step = 1, rounding = Down, components = {{ div = 60 }} },
        { threshold = 3600, format = NormalColor:WrapTextInColorCode("%dh"), step = 1, rounding = Down, components = {{ div = 3600 }} },
        { threshold = 86400, format = NormalColor:WrapTextInColorCode("%dd"), step = 1, rounding = Down, components = {{ div = 86400 }} },
    })

    return Formatter
end

-- AURA BUTTONS

function UI:InitializeAuraButton(Button, Options)
    if (not Button) then
        return
    end

    Button:SetFrameLevel(Button:GetParent():GetFrameLevel() + 10)
    Button:Size(Options.Width, Options.Height)
    Button:SetTemplate()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    -- Cancel Aura
    Button:SetCancelAuraButtons("RightButtonUp, RightButtonDown")

    -- Tooltip
    Button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, -6)
    Button:SetHideTooltipInCombat(false or Options.HideTooltipInCombat)

    -- Icon
    local Icon = Button:CreateTexture(nil, "OVERLAY")
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
        Count:SetFontTemplate("Default", Options.CountSize or 12)

        Button:SetApplicationCount(Count)
    end

    -- Duration
    if (Options.Duration) then
        local Time = Overlay:CreateFontString(nil, "OVERLAY")
        Time:Point("CENTER", Options.TimeX or 0, Options.TimeY or -8)
        Time:SetFontTemplate("Default", Options.TimeSize or 12)
        
        Button:SetDurationText(Time, {
            textFormatter = UI:BuildRuleDurationFormatter(),
        })
    end

    -- Debuff Border
    if (Options.Border) then
        local BorderStyle = {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
            showWhenHarmful = true,
            showWhenHelpful = false,
            showWithoutDispelType = true,
            showStealable = true,
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

-- TEMP AURA BUTTONS

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
    local TempEnchHighlight = Overlay:CreateTexture(nil, "OVERLAY")
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

-- ADD AURA

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

    Data.GroupIndex = (Data.GroupIndex or 0) + 1
    local GroupKey = "AuraGroup" .. Data.GroupIndex

    Container:AddAuraGroup(GroupKey, Options.Filter, {
        maxFrameCount = Options.MaxAuras,
        initializeFrame = InitializeAura,
        candidateFilters = Options.CandidateFilters,

        layout = {
            elementSpacing = Options.Spacing or UI:Scale(3),
            lineSpacing = Options.LineSpacing or UI:Scale(8),
            groupSpacing = Options.GroupSpacing or UI:Scale(3),
            groupLineSpacing = Options.GroupLineSpacing or UI:Scale(8),
            sortMethod = AuraContainerSortMethod.ExpirationOnly,
            sortDirection = AuraContainerSortDirection.Normal,
        },
    })

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

function UI:AddAuraNP(Container, Options)
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

    Data.GroupIndex = (Data.GroupIndex or 0) + 1
    local GroupKey = "AuraGroup" .. Data.GroupIndex

    Container:AddAuraGroup(GroupKey, Options.Filter, {
        maxFrameCount = Options.MaxAuras,
        initializeFrame = InitializeAura,
        candidateFilters = Options.CandidateFilters,

        layout = {
            elementSpacing = Options.Spacing or 3,
            lineSpacing = Options.LineSpacing or 8,
            groupSpacing = Options.GroupSpacing or 3,
            groupLineSpacing = Options.GroupLineSpacing or 8,
            sortMethod = AuraContainerSortMethod.ExpirationOnly,
            sortDirection = AuraContainerSortDirection.Normal,
        },
    })
end

-- CREATE CONTAINER

function UI:CreateAuraContainer(Frame, Options)
    if (not Frame) then
        return
    end

    local Data = UI.AuraContainerData[Frame]

    if (not Data) then
        Data = {
            Containers = {},
            Registry = {},
        }

        UI.AuraContainerData[Frame] = Data
    end

    -- Increment The Global Index So Container IDs Are Never Reused.
    UI.AuraContainerIndex = UI.AuraContainerIndex + 1

    local Container = CreateFrame("AuraContainer", "FeelUI_AuraContainer".. UI.AuraContainerIndex, Frame, "CustomAuraContainerTemplate")

    -- Store The Container Reference For This Frame.
    Data.Containers[#Data.Containers + 1] = Container

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
    Container:SetFlowLayoutMaximumLineSize(Options.AurasPerRow or 550)

    -- Set Unit
    local Unit = Frame.unit or Options.Unit

    if (not Unit) then
        return
    end

    if (Container:GetUnit() ~= Unit) then
        Container:SetUnit(Unit)
    end

    -- Set Policy
    if (Options.Policy) then
        Container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.ProcessAura, Options.Policy)
    end

    -- Add Aura
    self:AddAura(Container, Options)

    return Container
end

function UI:CreateAuraContainerNP(Frame, Options)
    if (not Frame) then
        return
    end

    local Data = UI.AuraContainerData[Frame]

    if (not Data) then
        Data = {
            Containers = {},
            Registry = {},
        }

        UI.AuraContainerData[Frame] = Data
    end

    -- Increment The Global Index So Container IDs Are Never Reused.
    UI.AuraContainerIndex = UI.AuraContainerIndex + 1

    local Container = CreateFrame("AuraContainer", "FeelUI_AuraContainerNP".. UI.AuraContainerIndex, Frame, "CustomAuraContainerTemplate")

    -- Store The Container Reference For This Frame.
    Data.Containers[#Data.Containers + 1] = Container

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
    Container:SetFlowLayoutMaximumLineSize(Options.AurasPerRow or 550)

    -- Set Policy
    if (Options.Policy) then
        Container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.ProcessAura, Options.Policy)
    end

    -- Add Aura
    self:AddAuraNP(Container, Options)

    return Container
end

-- AURA HIGHLIGHT

function UI:InitializeAuraHighlight(Button)
    if (not Button) then
        return
    end

    -- Button
    Button:SetFrameLevel(Button:GetFrameLevel() +6)
    Button:SetInside()
    Button:EnableMouse(false)

    -- Overlay
    local OverlayGradient = CreateFrame("Frame", nil, Button)
    OverlayGradient:SetFrameLevel(Button:GetFrameLevel() -1)
    OverlayGradient:SetInside()
    OverlayGradient:SetAlpha(0.5)

    local OverlayBorder = CreateFrame("Frame", nil, Button)
    OverlayBorder:SetFrameLevel(Button:GetFrameLevel() -1)
    OverlayBorder:SetInside()
    OverlayBorder:SetAlpha(0.25)

    -- Gradient Border
    local DispelGradient = OverlayGradient:CreateTexture(nil, "OVERLAY")
    DispelGradient:SetInside()
    DispelGradient:SetAtlas("_RaidFrame-Dispel-Highlight-Horizontal", false, nil, nil, "REPEAT", "CLAMP")
    DispelGradient:SetTexCoord(0, 1, 0, 1)

    -- Border
    local DispelBorder = OverlayBorder:CreateTexture(nil, "OVERLAY")
    DispelBorder:SetInside(Button, -1, -1)
    DispelBorder:SetAtlas("RaidFrame-DispelHighlight")

    -- Icon
    local DispelIcon = Button:CreateTexture(nil, "OVERLAY")
    DispelIcon:Size(18, 18)
    DispelIcon:Point("CENTER", Button, 0, 22)

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

    local Container = CreateFrame("AuraContainer", "FeelUI_AuraHighlightContainer", Frame, "CustomAuraContainerTemplate")
    Container:SetInside()

    -- Set Unit
    local Unit = Frame.unit or Options.Unit

    if (not Unit) then
        return
    end

    if (Container:GetUnit() ~= Unit) then
        Container:SetUnit(Unit)
    end

    -- Add Aura
    self:AddAuraHighlight(Container, Options)

    return Container
end