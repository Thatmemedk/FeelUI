local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local AB = UI:CallModule("ActionBars")

-- Lib Globals
local _G = _G
local unpack = unpack

function AB:SafeHide(Frame)
    if (Frame) then
        Frame:Hide()

        if (Frame.SetAlpha) then 
            Frame:SetAlpha(0) 
        end
    end
end

function AB:StyleActionButton(Button, Icon, Name)
    if (not Button or Button.ActionBarButtonsIsSkinned) then 
        return 
    end

    local Normal = _G[Name.."NormalTexture"] or Button:GetNormalTexture()
    local Flash = _G[Name.."Flash"]
    local Border = _G[Name.."Border"]
    local Cooldown = _G[Name.."Cooldown"]
    local Count = _G[Name.."Count"]
    local HotKey = _G[Name.."HotKey"]
    local MacroName = _G[Name.."Name"]
    local KeybindTex = Button.QuickKeybindHighlightTexture
    local SpellHighlightTexture = Button.SpellHighlightTexture
    local IconMask = Button.IconMask
    local SlotArt = Button.SlotArt
    local SlotBG = Button.SlotBackground
    local Divider = Button.RightDivider
    local Shine = Button.AutoCastOverlay and Button.AutoCastOverlay.Shine
    local Corners = Button.AutoCastOverlay and Button.AutoCastOverlay.Corners
    local AutoCastOverlay = Button.AutoCastOverlay
    local AutoCastable = Button.AutoCastable
    local LossControlCD = Button.lossOfControlCooldown
    
    -- HIDE TEXTURES
    AB:SafeHide(Normal)
    AB:SafeHide(IconMask)
    AB:SafeHide(SlotArt)
    AB:SafeHide(SlotBG)
    AB:SafeHide(Divider)
    AB:SafeHide(Corners)
    AB:SafeHide(MacroName)

    if (SpellHighlightTexture) then
        SpellHighlightTexture:SetInside(Button, 1, 1)
        SpellHighlightTexture:SetTexture(Media.Global.Texture)
        SpellHighlightTexture:SetVertexColor(unpack(DB.Global.ActionBars.OverlayGlowColor))
    end

    if (KeybindTex) then
        KeybindTex:SetInside(Button, -1, -1)
        KeybindTex:SetVertexColor(unpack(DB.Global.ActionBars.OverlayGlowColor))
    end

    if (Flash) then
        Flash:SetInside(Button, 1, 1)
        Flash:SetTexture(Media.Global.Texture)
        Flash:SetVertexColor(0.55, 0, 0, 0.5)
    end

    if (Border) then
        Border:SetInside(Button, 1, 1)
        Border:SetTexture(Media.Global.Texture)
    end

    if (AutoCastOverlay) then
        AutoCastOverlay:ClearAllPoints()
        AutoCastOverlay:SetInside(Button, -3, -3)
    end

    if (Icon) then
        Icon:SetInside(Button, 1, 1)
        UI:KeepAspectRatio(Button, Icon)
    end

    if (Cooldown) then
        Cooldown:ClearAllPoints()
        Cooldown:SetInside()

        local NumRegions = Cooldown:GetNumRegions()

        for i = 1, NumRegions do
            local Region = select(i, Cooldown:GetRegions())

            if (Region.GetText) then
                local FontSize = UI:GetCooldownFontScale(Cooldown)

                Region:ClearAllPoints()
                Region:Point("CENTER", Button, 0, 0)
                Region:SetFontTemplate("Default", FontSize)
                Region:SetTextColor(1, 0.82, 0)
            end
        end
    end

    if (LossControlCD) then
        LossControlCD:ClearAllPoints()
        LossControlCD:SetInside()
    end

    if (Count) then
        Count:ClearAllPoints()
        Count:Point("BOTTOMRIGHT", -1, 3)
        Count:SetFontTemplate("Default")
    end

    if (HotKey) then
        if (DB.Global.ActionBars.HotKey) then
            HotKey:ClearAllPoints()
            HotKey:Point("TOPRIGHT", -2, -4)
            HotKey:SetFontTemplate("Default")
        else
            HotKey:SetText("")
            HotKey:SetAlpha(0)
        end
    end

    Button:CreateButtonPanel()
    Button:CreateButtonBackdrop()
    Button:CreateShadow()
    Button:StyleButton()
    Button:SetShadowOverlay()

    Button.ActionBarButtonsIsSkinned = true
end

function AB:SkinButton()
    local Name = self:GetName()
    local Icon = _G[Name.."Icon"]
    AB:StyleActionButton(self, Icon, Name)
end

function AB:SkinPetButtons()
    for i = 1, _G.NUM_PET_ACTION_SLOTS do
        local Button = _G["PetActionButton"..i]
        local Icon = Button.Icon or _G["PetActionButton"..i.."Icon"]
        AB:StyleActionButton(Button, Icon, Button:GetName())
    end
end

function AB:SkinStanceButtons()
    for i = 1, _G.NUM_STANCE_SLOTS or 10 do
        local Button = _G["StanceButton"..i]
        local Icon = Button.icon or _G["StanceButton"..i.."Icon"]
        AB:StyleActionButton(Button, Icon, Button:GetName())
    end
end