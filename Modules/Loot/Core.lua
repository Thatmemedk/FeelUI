local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Loot = UI:RegisterModule("Loot")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local LootFrame = _G.LootFrame

function Loot:SetQualityBackdrop(Button)
    if (not Button.NewBackdrop) then
        return
    end

    local Quality = Enum.ItemQuality.Common

    if (Button.GetQuality) then
        Quality = Button:GetQuality()
    end

    local Color = ITEM_QUALITY_COLORS[Quality or Enum.ItemQuality.Common]

    if (Color) then
        Button.NewBackdrop:SetBackdropColorTemplate(Color.r * 0.25, Color.g * 0.25, Color.b * 0.25, 0.7)
    end
end

function Loot:UpdateButtons(Button)
	if (Button.IsSkinned) then 
		return
	end

	local Items = Button.Item
	local SlotType = Button.GetItemSlotType and Button:GetItemSlotType()

	if (Items) then
		Items:Size(36, 22)
	    Items:ClearAllPoints()
	    Items:Point("LEFT", Button, 0, 0)

		Items:SetTemplate()
		Items:CreateShadow()
		Items:StyleButton()
		Items:SetShadowOverlay()

		if (Items.icon) then
			Items.icon:SetInside()
			UI:KeepAspectRatio(Items.icon, Items.icon)
		end

		if (Items.Count) then
			Items.Count:ClearAllPoints()
			Items.Count:Point("TOPRIGHT", Items, 0, -2)
			Items.Count:SetFontTemplate("Default")
		end

		if (Items.IconBorder) then
			Items.IconBorder:SetAlpha(0) 
		end

		if (Items.NormalTexture) then
			Items.NormalTexture:SetAlpha(0) 
		end
	end

	if (not Button.NewBackdrop) then
		Button.NewBackdrop = CreateFrame("Frame", nil, Button)
    	Button.NewBackdrop:SetFrameLevel(Button:GetFrameLevel() -1)
    	Button.NewBackdrop:CreateBackdrop()
    	Button.NewBackdrop:CreateShadow()
    end

    Button.NewBackdrop:ClearAllPoints()
    Button.NewBackdrop:Point("LEFT", Items, "RIGHT", 6, 0)
    Button.NewBackdrop:Point("RIGHT", Button, "RIGHT", -6, 0)
    Button.NewBackdrop:Point("TOP", Items, "TOP", 0, 0)
    Button.NewBackdrop:Point("BOTTOM", Items, "BOTTOM", 0, 0)

    Loot:SetQualityBackdrop(Button)

	if (Button.Text and Button.Text.SetFont) then
	    Button.Text:SetFontTemplate("Default")
	    Button.Text:ClearAllPoints()

	    if (SlotType == Enum.LootSlotType.Money) then
        	Button.Text:Point("LEFT", Button, 46, 0)
    	else
	    	Button.Text:Point("RIGHT", Button, -6, -9)
	    end

	    Button.Text:SetWidth(148)
	    Button.Text:SetJustifyH("LEFT")
	    Button.Text:SetWordWrap(false)
	    Button.Text:SetNonSpaceWrap(false)
	    Button.Text:SetMaxLines(1)
	end

	if (Button.QualityText and Button.QualityText.SetFont) then
	    Button.QualityText:SetFontTemplate("Default", 11)
	    Button.QualityText:ClearAllPoints()
	    Button.QualityText:Point("TOPRIGHT", Button.NameFrame, -6, 4)
	end

	if (Button.QualityStripe) then
		Button.QualityStripe:Point("TOPRIGHT", Button.NameFrame, -6, 1)
		Button.QualityStripe:SetAlpha(0.7)
	end

	if (Button.NameFrame) then
		Button.NameFrame:SetAlpha(0)
	end

	if (Button.BorderFrame) then
		Button.BorderFrame:SetAlpha(0)
	end
	
	if (Button.HighlightNameFrame) then
		Button.HighlightNameFrame:SetAlpha(0)
	end

	if (Button.PushedNameFrame) then
		Button.PushedNameFrame:SetAlpha(0)
	end

	if (Button.IconQuestTexture) then
		Button.IconQuestTexture:SetAlpha(0)
	end

	Button.IsSkinned = true
end

function Loot:UpdateScrollBox(Frame)
	Frame:ForEachFrame(function(Button)
		self:UpdateButtons(Button)
	end)
end

function Loot:Update()
	hooksecurefunc(LootFrame.ScrollBox, "Update", function(Frame)
		self:UpdateScrollBox(Frame)
	end)
end

function Loot:Skin()
	if (self.IsSkinned) then 
		return
	end

	if (LootFrame) then
		if (not LootFrame.NewBackdrop) then
			LootFrame.NewBackdrop = CreateFrame("Frame", nil, LootFrame)
        	LootFrame.NewBackdrop:SetFrameLevel(LootFrame:GetFrameLevel() -1)
        	LootFrame.NewBackdrop:SetInside()
        	LootFrame.NewBackdrop:CreateBackdrop()
        	LootFrame.NewBackdrop:CreateShadow()
        end

		LootFrame:StripTexture()

		if (LootFrame.ScrollBar) then
			LootFrame.ScrollBar:HandleScrollBar()
		end

		if (LootFrame.ClosePanelButton) then
			LootFrame.ClosePanelButton:HandleCloseButton()
		end

		if (_G.LootFrameBg) then
		 	_G.LootFrameBg:SetAlpha(0)
		end

		if (_G.LootFrameTitleText) then
			LootFrameTitleText:SetAlpha(0)
		end

		if (LootFrame.NineSlice) then
		 	LootFrame.NineSlice:Hide()
		end

		if (LootFrame.Backdrop) then
			LootFrame.Backdrop:Hide()
		end

		if (LootFrame.ScrollBox.Shadows) then
			LootFrame.ScrollBox.Shadows:Hide()
		end
	end

	self.IsSkinned = true
end

function Loot:Initialize()
	if (not DB.Global.Loot.Enable) then 
		return 
	end

	self:Skin()
	self:Update()
end