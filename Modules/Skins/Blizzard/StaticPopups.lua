local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local StaticPopups = UI:RegisterModule("StaticPopups")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack

-- Locals
local R, G, B = unpack(UI.GetClassColors)

StaticPopups.Popups = {
    _G.StaticPopup1,
    _G.StaticPopup2,
    _G.StaticPopup3,
    _G.StaticPopup4,
}

function StaticPopups:Update()
    if (self.IsSkinned) then
        return
    end
    
    local Name = self:GetName()

    if (_G[Name].BG) then 
        _G[Name].BG:SetAlpha(0) 
    end

    if (not _G[Name].NewBackdrop) then
        _G[Name].NewBackdrop = CreateFrame("Frame", nil, _G[Name])
        _G[Name].NewBackdrop:SetFrameLevel(_G[Name]:GetFrameLevel())
        _G[Name].NewBackdrop:SetInside(_G[Name], 2, 2)
        _G[Name].NewBackdrop:CreateBackdrop()
        _G[Name].NewBackdrop:CreateShadow()
    end

    _G[Name.."Button1"]:HandleButton()
    _G[Name.."Button2"]:HandleButton()
    _G[Name.."Button3"]:HandleButton()
    _G[Name.."Button4"]:HandleButton()
    
    _G[Name.."Button1"].Flash:SetTexture(Media.Global.Texture)
    _G[Name.."Button1"].Flash:SetInside(_G[Name.."Button1"])
    _G[Name.."Button1"].Flash:SetColorTexture(R, G, B, 0.25)

    _G[Name.."CloseButton"]:HandleCloseButton()
    _G[Name.."CloseButton"].SetNormalTexture = function() end
    _G[Name.."CloseButton"].SetPushedTexture = function() end

    self.IsSkinned = true
end

function StaticPopups:Skin()
    for _, Frame in pairs(StaticPopups.Popups) do
        self.Update(Frame)
    end
end

function StaticPopups:Initialize()
    if (not DB.Global.Theme.Enable) then 
        return
    end

    self:Skin()
end