local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Toasts = UI:RegisterModule("Toasts")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local EventToastManagerFrame = _G.EventToastManagerFrame

-- Locals
local R, G, B = unpack(UI.GetClassColors)

function Toasts:DisplayToasts()
    local Current = self:IsCurrentlyToasting()

    if (not self.IsSkinned) then
        self.GLine:Kill()
        self.GLine2:Kill()

        if (Current) then
            local StatusLineTop = CreateFrame("StatusBar", nil, self)
            StatusLineTop:Size(402, 2)
            StatusLineTop:Point("TOP", self, 0, -7)
            StatusLineTop:SetStatusBarTexture(Media.Global.Highlight)
            StatusLineTop:SetStatusBarColor(R, G, B, 0.7)

            local StatusLineBottom = CreateFrame("StatusBar", nil, self)
            StatusLineBottom:Size(402, 2)
            StatusLineBottom:Point("BOTTOM", self, 0, -2)
            StatusLineBottom:SetStatusBarTexture(Media.Global.Highlight)
            StatusLineBottom:SetStatusBarColor(R, G, B, 0.7)
        end

        if (Current.Title) then
            Current.Title:SetFontTemplate("Default", 28, 2, 2)
        end

        if (Current.SubTitle) then 
            Current.SubTitle:SetFontTemplate("Default", 18, 2, 2)
        end

        self.IsSkinned = true
    end
end

function Toasts:Update()
    hooksecurefunc(EventToastManagerFrame, "DisplayToast", self.DisplayToasts)
end

function Toasts:Initialize()
    self:Update()
end