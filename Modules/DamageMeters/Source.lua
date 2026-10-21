local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DM = UI:CallModule("DamageMeters")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select
local math_max = math.max
local math_min = math.min

-- HELPERS

function DM:Flush()
    DM.Pending = false

    local Frame = DM.SourceFrame

    if (Frame and Frame:IsShown()) then
        DM:RefreshSource()
    end
end

function DM:GetSpellDisplay(SpellID)
    if (not SpellID) then
        return nil, self.SourceFallBackIcon
    end

    return C_Spell.GetSpellName(SpellID), C_Spell.GetSpellTexture(SpellID) or self.SourceFallBackIcon
end

-- DATA

function DM:GetSourceSpells()
    local Source = self.SourceData

    if (not Source) then
        return nil
    end

    local MeterType = self.SourceMeterType

    if (self.SourceSessionID) then
        return C_DamageMeter.GetCombatSessionSourceFromID(self.SourceSessionID, MeterType, Source.sourceGUID, Source.sourceCreatureID)
    end

    if (self.SourceSessionType) then
        return C_DamageMeter.GetCombatSessionSourceFromType(self.SourceSessionType, MeterType, Source.sourceGUID, Source.sourceCreatureID)
    end
end

-- ROWS

function DM:ClearSourceRow(Row)
    Row.SpellID = nil
    Row.StatusBar:SetMinMaxValues(0, 1)
    Row.StatusBar:SetValue(0)
    Row.Text:SetText("")
    Row.Value:SetText("")
    Row:Hide()
end

function DM:ClearSourceRows()
    for Index = 1, self.SourceMaxRows do
        self:ClearSourceRow(self.SourceRows[Index])
    end
end

function DM:UpdateSourceRow(Row, Spell, MaxAmount, Color)
    Row.SpellID = Spell.spellID
    Row:Show()

    local Name, Icon = self:GetSpellDisplay(Spell.spellID)

    -- Icon
    Row.Icon:SetTexture(Icon)
    UI:KeepAspectRatio(Row.Icon, Row.Icon)

    -- Name
    Row.Text:SetText(Name or UNKNOWN)

    -- Bar
    if (Color) then
        Row.StatusBar:SetStatusBarColor(unpack(Color))
    else
        Row.StatusBar:SetStatusBarColor(1, 0.82, 0)
    end

    Row.StatusBar:SetMinMaxValues(0, MaxAmount, UI.SmoothBars)
    Row.StatusBar:SetValue(Spell.totalAmount, UI.SmoothBars)

    -- Value
    if (self.CountTypes[self.SourceMeterType]) then
        Row.Value:SetText(self:AbbreviateNumber(Spell.totalAmount))
    else
        Row.Value:SetFormattedText("%s (%s)", self:AbbreviateNumber(Spell.totalAmount), self:AbbreviateNumber(Spell.amountPerSecond))
    end
end

-- REFRESH

function DM:UpdateSourceHeader(Data)
    local Source = self.SourceData
    local Frame = self.SourceFrame

    if (not Source) then
        return
    end

    local Name = Source.name

    if (not UI:IsSecretValue(Name)) then
        Name = self:StripRealm(Name)
    end

    Frame.Title:SetText(Name or UNKNOWN)

    local Color = self:GetClassColor(Source.classFilename)

    if (Color) then
        Frame.Title:SetTextColor(unpack(Color))
    else
        Frame.Title:SetTextColor(1, 1, 1)
    end

    if (Data and Data.totalAmount) then
        Frame.Total:SetText(self:AbbreviateNumber(Data.totalAmount))
    else
        Frame.Total:SetText("")
    end
end

function DM:RefreshSource()
    local Frame = self.SourceFrame

    if (not Frame or not Frame:IsShown()) then
        return
    end

    local Data = self:GetSourceSpells()

    self:UpdateSourceHeader(Data)

    local Spells = Data and Data.combatSpells

    if (not Spells or not Spells[1]) then
        self:ClearSourceRows()
        self.SourceScrollOffset = 0
        self.SourceScrollMax = 0

        return
    end

    local MaxAmount = Data.maxAmount or Spells[1].totalAmount

    self.SourceScrollMax = math_max(0, #Spells - self.SourceMaxRows)
    self.SourceScrollOffset = math_max(0, math_min(self.SourceScrollOffset, self.SourceScrollMax))

    local Color = self:GetClassColor(self.SourceData.classFilename)

    for RowIndex = 1, self.SourceMaxRows do
        local Row = self.SourceRows[RowIndex]
        local Spell = Spells[self.SourceScrollOffset + RowIndex]

        if (Spell) then
            self:UpdateSourceRow(Row, Spell, MaxAmount, Color)
        else
            self:ClearSourceRow(Row)
        end
    end
end

-- TOGGLE

function DM:ToggleSourceWindow()
    if (not self.SourceFrame) then
        return
    end

    if (self.SourceFrame:IsShown()) then
        self.SourceFrame.FadeOut:Play()
    else
        self.SourceFrame:Show()
        self.SourceFrame.FadeIn:Play()
    end
end

-- OPEN

function DM:OpenSourceWindow(Source, MeterType, SessionType, SessionID)
    if (not Source) then
        return
    end

    if (InCombatLockdown()) then
        return
    end

    if (self:IsDeathSource(Source)) then
        if (OpenDeathRecapUI) then
            OpenDeathRecapUI(Source.deathRecapID)
        end

        return
    end

    if (not self.SourceFrame) then
        self:CreateSourceWindow()
    end

    self.SourceData = Source
    self.SourceMeterType = MeterType
    self.SourceSessionType = SessionType
    self.SourceSessionID = SessionID
    self.SourceScrollOffset = 0

    if (self.SourceFrame:IsShown()) then
        self:RefreshSource()
    else
        self:ToggleSourceWindow()
    end
end

-- CREATE

function DM:CreateSourceWindow()
    if (self.SourceFrame) then
        return
    end

    -- Main Frame
    local Frame = CreateFrame("Frame", "FeelUI_DamageMetersSource", _G.UIParent)
    Frame:SetFrameStrata("HIGH")
    Frame:Size(300, 28 + (self.SourceMaxRows * (DB.Global.DamageMeters.BarHeight + DB.Global.DamageMeters.BarSpacing)) + 4)
    Frame:Point("TOPRIGHT", self.Frame, "TOPRIGHT", 0, 212)
    Frame:CreateBackdrop()
    Frame:CreateShadow()
    Frame:SetAlpha(0)
    Frame:Hide()

    -- Animation
    Frame.Fade = UI:CreateAnimationGroup(Frame)

    Frame.FadeIn = UI:CreateAnimation(Frame.Fade, "Fade")
    Frame.FadeIn:SetDuration(1)
    Frame.FadeIn:SetChange(1)
    Frame.FadeIn:SetEasing("In-SineEase")

    Frame.FadeOut = UI:CreateAnimation(Frame.Fade, "Fade")
    Frame.FadeOut:SetDuration(1)
    Frame.FadeOut:SetChange(0)
    Frame.FadeOut:SetEasing("Out-SineEase")
    Frame.FadeOut:SetScript("OnFinished", function(self)
        self:GetParent():Hide()
    end)

    -- To be able to press "ESC"
    GameMenuFrame:HookScript("OnShow", function()
        if (Frame:IsShown()) then
            DM:ToggleSourceWindow()
        end
    end)

    -- Title & Total
    Frame.Title = Frame:CreateFontString(nil, "OVERLAY")
    Frame.Title:Point("TOPLEFT", Frame, 8, -8)
    Frame.Title:SetFontTemplate("Default")

    Frame.Total = Frame:CreateFontString(nil, "OVERLAY")
    Frame.Total:Point("TOPRIGHT", Frame, -28, -8)
    Frame.Total:SetFontTemplate("Default")

    -- Close
    Frame.Close = CreateFrame("Button", nil, Frame)
    Frame.Close:Size(18, 18)
    Frame.Close:Point("TOPRIGHT", Frame, -4, -4)
    Frame.Close:HandleCloseButton()

    Frame.Close:SetScript("OnClick", function()
        DM:ToggleSourceWindow()
    end)

    -- Content
    local Content = CreateFrame("Frame", nil, Frame)
    Content:Point("TOPLEFT", Frame, 8, -28)
    Content:Point("BOTTOMRIGHT", Frame, -8, 8)
    Content:EnableMouseWheel(true)

    -- Content OnMouseWheel
    Content:SetScript("OnMouseWheel", function(_, Delta)
        DM.SourceScrollOffset = math_max(0, math_min(DM.SourceScrollOffset - Delta, DM.SourceScrollMax))
        DM:RefreshSource()
    end)

    -- Create Rows
    for Index = 1, self.SourceMaxRows do
        local Row = CreateFrame("Button", nil, Content)
        Row:Height(DB.Global.DamageMeters.BarHeight)
        Row:Point("TOPLEFT", Content, "TOPLEFT", 0, -(Index - 1) * (DB.Global.DamageMeters.BarHeight + DB.Global.DamageMeters.BarSpacing))
        Row:Point("RIGHT", Content, "RIGHT")

        -- Invis Frame
        Row.InvisFrame = CreateFrame("Frame", nil, Row)
        Row.InvisFrame:SetFrameLevel(Row:GetFrameLevel() + 10)
        Row.InvisFrame:SetInside()

        -- StatusBar
        Row.StatusBar = CreateFrame("StatusBar", nil, Row)
        Row.StatusBar:SetInside()
        Row.StatusBar:SetMinMaxValues(0, 1)
        Row.StatusBar:SetValue(0)
        Row.StatusBar:SetStatusBarTexture(Media.Global.Texture)
        Row.StatusBar:CreateBackdrop()
        Row.StatusBar:CreateShadow()

        -- Highlight
        Row.HighlightTexture = Row.InvisFrame:CreateTexture(nil, "BACKGROUND")
        Row.HighlightTexture:SetInside(Row.StatusBar, 1, 1)
        Row.HighlightTexture:SetTexture(Media.Global.Texture)
        Row.HighlightTexture:SetVertexColor(unpack(DB.Global.ActionBars.HighlightColor))
        Row.HighlightTexture:Hide()

        -- Icon
        Row.Icon = Row.InvisFrame:CreateTexture(nil, "ARTWORK")
        Row.Icon:Size(unpack(DB.Global.DamageMeters.IconSize))
        Row.Icon:Point("LEFT", 0, 0)

        Row.IconOverlay = CreateFrame("Frame", nil, Row)
        Row.IconOverlay:SetFrameLevel(Row:GetFrameLevel() + 10)
        Row.IconOverlay:SetInside(Row.Icon)
        Row.IconOverlay:SetTemplate()
        Row.IconOverlay:CreateShadow()
        Row.IconOverlay:SetShadowOverlay()

        -- Spell Name
        Row.Text = Row.InvisFrame:CreateFontString(nil, "OVERLAY")
        Row.Text:Point("LEFT", Row.Icon, "RIGHT", 6, 0)
        Row.Text:SetFontTemplate("Default")

        -- Values
        Row.Value = Row.InvisFrame:CreateFontString(nil, "OVERLAY")
        Row.Value:Point("RIGHT", Row, "RIGHT", -6, 0)
        Row.Value:SetFontTemplate("Default")

        -- Tooltip + Highlight
        Row:SetScript("OnEnter", function(self)
            local SpellID = self.SpellID

            if (SpellID) then
                _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                _G.GameTooltip:SetSpellByID(SpellID)
                _G.GameTooltip:Show()
            end

            self.HighlightTexture:Show()
        end)

        Row:SetScript("OnLeave", function(self)
            _G.GameTooltip:Hide()
            self.HighlightTexture:Hide()
        end)

        self.SourceRows[Index] = Row
    end

    Frame:SetScript("OnEvent", function()
        if (DM.Pending) then
            return
        end

        DM.Pending = true
        C_Timer.After(DM.SourceThrottle, DM.Flush)
    end)

    Frame:SetScript("OnShow", function(self)
        self:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
        self:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
        self:RegisterEvent("DAMAGE_METER_RESET")

        DM:RefreshSource()
    end)

    Frame:SetScript("OnHide", function(self)
        self:UnregisterAllEvents()

        DM.SourceData = nil
        DM:ClearSourceRows()

        _G.GameTooltip:Hide()
    end)

    -- Cache
    self.SourceFrame = Frame
end