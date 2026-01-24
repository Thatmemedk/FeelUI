local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local DropDownMenu = UI:RegisterModule("DropDownMenu")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- WoW Globals
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn

-- Locals
DropDownMenu.Backdrops = {}

function DropDownMenu:SkinMenu(Frame)
    if (not Frame) then
        return
    end

    Frame:StripTexture()

    if (DropDownMenu.Backdrops[Frame]) then
        return
    end

    local BackdropNew = CreateFrame("Frame", nil, Frame, "LibBackdropTemplate")
    BackdropNew:SetInside()
    BackdropNew:SetBackdrop({
        edgeFile = Media.Global.Blank,
        bgFile   = Media.Global.Texture,
        edgeSize = UI:Scale(1),
    })
    BackdropNew:SetBackdropColor(unpack(DB.Global.General.BackdropColor))
    BackdropNew:SetBackdropBorderColor(unpack(DB.Global.General.BorderColor))
    BackdropNew:CreateShadow()

    DropDownMenu.Backdrops[Frame] = BackdropNew
end

function DropDownMenu:Update(Frame, Region, Menu, Anchor)
    local OpenMenu = Frame:GetOpenMenu()

    if (not OpenMenu) then
        return
    end

    self:SkinMenu(OpenMenu)

    if (Menu and Menu.AddMenuAcquiredCallback) then
        Menu:AddMenuAcquiredCallback(function(SubMenu)
            self:SkinMenu(SubMenu)
        end)
    end
end

function DropDownMenu:Skin()
    local MenuManager = _G.Menu.GetManager()

    if (MenuManager) then
        hooksecurefunc(MenuManager, "OpenMenu", function(Frame, Region, Menu, Anchor)
            self:Update(Frame, Region, Menu, Anchor)
        end)

        hooksecurefunc(MenuManager, "OpenContextMenu", function(Frame, Region, Menu, Anchor)
            self:Update(Frame, Region, Menu, Anchor)
        end)
    end
end

function DropDownMenu:Initialize()
	if (not DB.Global.Theme.Enable) then
		return
	end

    if (not IsAddOnLoaded("Blizzard_Menu")) then
        LoadAddOn("Blizzard_Menu")
    end

    self:Skin()
end