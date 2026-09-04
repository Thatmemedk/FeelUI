local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- Locals
local DropdownWidth = 222
local DropdownRowHeight = 18
local DropdownPadding = 4

-- Locals
local R, G, B = unpack(UI.GetClassColors)

-- DROPDOWN

function UI:CreateDropdown(Width, Owner, X, Y)
    Width = Width or DropdownWidth

    local ClickCatcher = CreateFrame("Button", nil, _G.UIParent)
    ClickCatcher:SetFrameStrata("DIALOG")
    ClickCatcher:SetFrameLevel(99)
    ClickCatcher:EnableMouse(true)
    ClickCatcher:SetClampedToScreen(true)
    ClickCatcher:SetAllPoints(_G.UIParent)
    ClickCatcher:Hide()

    local Dropdown = CreateFrame("Frame", nil, _G.UIParent, "LibBackdropTemplate")
    Dropdown:SetFrameStrata("DIALOG")
    Dropdown:SetFrameLevel(100)
    Dropdown:SetClampedToScreen(true)
    Dropdown:EnableMouse(true)
    Dropdown:Width(Width)
    Dropdown:CreateBackdrop()
    Dropdown:CreateShadow()
    Dropdown:Hide()

    Dropdown.ClickCatcher = ClickCatcher
    Dropdown.Buttons = {}
    Dropdown.Count = 0

    -- Methods
    function Dropdown:AddDropdownButton(...)
        return UI:AddDropdownButton(self, ...)
    end

    function Dropdown:HideDropdown()
        return UI:HideDropdown(self)
    end

    function Dropdown:ClearDropdownButtons()
        return UI:ClearDropdownButtons(self)
    end

    ClickCatcher:SetScript("OnClick", function()
        Dropdown:HideDropdown()
    end)

    if (Owner) then
        Dropdown:Point("BOTTOMLEFT", Owner, "TOPLEFT", X or 0, Y or 0)
        Dropdown:Show()
        Dropdown:Raise()
        ClickCatcher:Show()
    end

    return Dropdown
end

function UI:AddDropdownButton(Dropdown, Text, Checked, OnClick)
    Dropdown.Count = Dropdown.Count + 1

    local Index = Dropdown.Count
    local Button = Dropdown.Buttons[Index]

    if (not Button) then
        Button = CreateFrame("Button", nil, Dropdown)
        Button:Height(DropdownRowHeight)

        -- Text
        Button.Text = Button:CreateFontString(nil, "OVERLAY")
        Button.Text:Point("LEFT", Button, "LEFT", 6, 0)
        Button.Text:Point("RIGHT", Button, "RIGHT", -26, 0)
        Button.Text:SetJustifyH("LEFT")
        Button.Text:SetWordWrap(false)
        Button.Text:SetFontTemplate("Default")

        -- Checkbox
        Button.Check = CreateFrame("StatusBar", nil, Button)
        Button.Check:Size(14, 14)
        Button.Check:Point("RIGHT", Button, "RIGHT", -6, 0)
        Button.Check:SetStatusBarTexture(Media.Global.Texture)

        Button.CheckOverlay = CreateFrame("Frame", nil, Button)
        Button.CheckOverlay:SetFrameLevel(Button.Check:GetFrameLevel() - 1)
        Button.CheckOverlay:SetInside(Button.Check)
        Button.CheckOverlay:CreateBackdrop()
        Button.CheckOverlay:CreateShadow()

        Button.CheckHighlight = Button.Check:CreateTexture(nil, "OVERLAY")
        Button.CheckHighlight:SetInside(Button.Check, 1, 1)
        Button.CheckHighlight:SetTexture(Media.Global.Texture)
        Button.CheckHighlight:SetVertexColor(1, 1, 1, 0.25)
        Button.CheckHighlight:Hide()

        -- Highlight
        Button.Highlight = Button:CreateTexture(nil, "BACKGROUND")
        Button.Highlight:SetInside(Button, 1, 1)
        Button.Highlight:SetTexture(Media.Global.Highlight)
        Button.Highlight:SetVertexColor(R, G, B, 0.50)
        Button.Highlight:Hide()

        Button:SetScript("OnEnter", function(self)
            self.Highlight:Show()
            self.CheckHighlight:Show()
        end)

        Button:SetScript("OnLeave", function(self)
            self.Highlight:Hide()
            self.CheckHighlight:Hide()
        end)

        Dropdown.Buttons[Index] = Button
    end

    Button.Text:SetText(Text)

    if (Checked == true) then
        Button.Check:SetStatusBarColor(R, G, B, 1)
    else
        Button.Check:SetStatusBarColor(0.25, 0.25, 0.25, 0.5)
    end

    Button:SetScript("OnClick", function()
        Dropdown:HideDropdown()

        if (OnClick) then
            OnClick()
        end
    end)

    Button:ClearAllPoints()
    Button:Width(Dropdown:GetWidth() - DropdownPadding * 2)
    Button:Point("TOPLEFT", Dropdown, "TOPLEFT", DropdownPadding, -DropdownPadding - ((Index - 1) * DropdownRowHeight))
    Button:Show()

    Dropdown:Height((Dropdown.Count * DropdownRowHeight) + (DropdownPadding * 2))
end

function UI:HideDropdown(Dropdown)
    Dropdown:Hide()
    Dropdown.ClickCatcher:Hide()
end

function UI:ClearDropdownButtons(Dropdown)
    Dropdown.Count = 0

    for _, Button in ipairs(Dropdown.Buttons) do
        Button:Hide()
    end

    Dropdown:Height(DropdownPadding * 2)
end