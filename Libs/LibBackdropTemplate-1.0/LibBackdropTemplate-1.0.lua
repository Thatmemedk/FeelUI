-----------------------------
-- LibBackdropTemplate 1.0 --
-----------------------------

LibBackdropTemplateMixin = {}

-- Locals
local CoordStart = 0.0625
local CoordEnd = 1 - CoordStart
local DefaultEdgeSize = 39

-- Tables
local TextureUVs = {
    TopLeftCorner = { SetWidth = true, SetHeight = true, ULx = 0.5078125, ULy = CoordStart, LLx = 0.5078125, LLy = CoordEnd, URx = 0.6171875, URy = CoordStart, LRx = 0.6171875, LRy = CoordEnd },
    TopRightCorner = { SetWidth = true, SetHeight = true, ULx = 0.6328125, ULy = CoordStart, LLx = 0.6328125, LLy = CoordEnd, URx = 0.7421875, URy = CoordStart, LRx = 0.7421875, LRy = CoordEnd },
    BottomLeftCorner = { SetWidth = true, SetHeight = true, ULx = 0.7578125, ULy = CoordStart, LLx = 0.7578125, LLy = CoordEnd, URx = 0.8671875, URy = CoordStart, LRx = 0.8671875, LRy = CoordEnd },
    BottomRightCorner = { SetWidth = true, SetHeight = true, ULx = 0.8828125, ULy = CoordStart, LLx = 0.8828125, LLy = CoordEnd, URx = 0.9921875, URy = CoordStart, LRx = 0.9921875, LRy = CoordEnd },
    TopEdge = { SetHeight = true, ULx = 0.2578125, ULy = "repeatX", LLx = 0.3671875, LLy = "repeatX", URx = 0.2578125, URy = CoordStart, LRx = 0.3671875, LRy = CoordStart },
    BottomEdge = { SetHeight = true, ULx = 0.3828125, ULy = "repeatX", LLx = 0.4921875, LLy = "repeatX", URx = 0.3828125, URy = CoordStart, LRx = 0.4921875, LRy = CoordStart },
    LeftEdge = { SetWidth = true,  ULx = 0.0078125, ULy = CoordStart, LLx = 0.0078125, LLy = "repeatY", URx = 0.1171875, URy = CoordStart, LRx = 0.1171875, LRy = "repeatY" },
    RightEdge = { SetWidth = true,  ULx = 0.1328125, ULy = CoordStart, LLx = 0.1328125, LLy = "repeatY", URx = 0.2421875, URy = CoordStart, LRx = 0.2421875, LRy = "repeatY" },
    Center = { ULx = 0, ULy = 0, LLx = 0, LLy = "repeatY", URx = "repeatX", URy = 0, LRx = "repeatX", LRy = "repeatY" },
}

function LibBackdropTemplateMixin:OnBackdropLoaded()
    if (self.backdropInfo) then
        if (not self.backdropInfo.edgeFile and not self.backdropInfo.bgFile) then
            self.backdropInfo = nil
            return
        end

        self:ApplyBackdrop()

        do
            local R, G, B = 1, 1, 1

            if (self.backdropColor) then
                R, G, B = self.backdropColor:GetRGB()
            end

            self:SetBackdropColor(R, G, B, self.backdropColorAlpha or 1)
        end

        do
            local R, G, B = 1, 1, 1

            if (self.backdropBorderColor) then
                R, G, B = self.backdropBorderColor:GetRGB()
            end

            self:SetBackdropBorderColor(R, G, B, self.backdropBorderColorAlpha or 1)
        end

        if (self.backdropBorderBlendMode) then
            self:SetBorderBlendMode(self.backdropBorderBlendMode)
        end
    end
end

function LibBackdropTemplateMixin:OnBackdropSizeChanged()
    if (self.backdropInfo) then
        self:SetupTextureCoordinates()
    end
end

function LibBackdropTemplateMixin:GetEdgeSize()
    if (self.backdropInfo.edgeSize and self.backdropInfo.edgeSize > 0) then
        return self.backdropInfo.edgeSize
    end

    return DefaultEdgeSize
end

local function GetBackdropCoordValue(Coord, PieceSetup, RepeatX, RepeatY)
    local Value = PieceSetup[Coord]

    if (Value == "repeatX") then
        return RepeatX
    elseif (Value == "repeatY") then
        return RepeatY
    end

    return Value
end

local function SetupBackdropTextureCoordinates(Region, PieceSetup, RepeatX, RepeatY)
    Region:SetTexCoord(
        GetBackdropCoordValue("ULx", PieceSetup, RepeatX, RepeatY),
        GetBackdropCoordValue("ULy", PieceSetup, RepeatX, RepeatY),
        GetBackdropCoordValue("LLx", PieceSetup, RepeatX, RepeatY),
        GetBackdropCoordValue("LLy", PieceSetup, RepeatX, RepeatY),
        GetBackdropCoordValue("URx", PieceSetup, RepeatX, RepeatY),
        GetBackdropCoordValue("URy", PieceSetup, RepeatX, RepeatY),
        GetBackdropCoordValue("LRx", PieceSetup, RepeatX, RepeatY),
        GetBackdropCoordValue("LRy", PieceSetup, RepeatX, RepeatY)
    )
end

function LibBackdropTemplateMixin:SetupTextureCoordinates()
    local Width = self:GetWidth()
    local Height = self:GetHeight()
    local EffectiveScale = self:GetEffectiveScale()
    local EdgeSize = self:GetEdgeSize()

    if (issecretvalue(Width) or issecretvalue(Height) or issecretvalue(EffectiveScale) or issecretvalue(EdgeSize)) then
        return
    end

    local EdgeRepeatX = max(0, (Width / EdgeSize) * EffectiveScale -2 - CoordStart)
    local EdgeRepeatY = max(0, (Height / EdgeSize) * EffectiveScale -2 - CoordStart)

    for PieceName, PieceSetup in pairs(TextureUVs) do
        local Region = self[PieceName]

        if (Region) then
            if (PieceName == "Center") then
                local RepeatX, RepeatY = 1, 1

                if (self.backdropInfo.tile) then
                    local Divisor = self.backdropInfo.tileSize

                    if (not Divisor or Divisor == 0) then
                        Divisor = EdgeSize
                    end

                    if (Divisor ~= 0) then
                        RepeatX = (Width / Divisor) * EffectiveScale
                        RepeatY = (Height / Divisor) * EffectiveScale
                    end
                end

                SetupBackdropTextureCoordinates(Region, PieceSetup, RepeatX, RepeatY)
            else
                SetupBackdropTextureCoordinates(Region, PieceSetup, EdgeRepeatX, EdgeRepeatY)
            end
        end
    end
end

function LibBackdropTemplateMixin:SetupPieceVisuals(Piece, SetupInfo)
    local TextureInfo = TextureUVs[SetupInfo.pieceName]
    local TileVerts = false
    local File

    if (SetupInfo.pieceName == "Center") then
        File = self.backdropInfo.bgFile
        TileVerts = self.backdropInfo.tile
    else
        File = self.backdropInfo.edgeFile
        TileVerts = self.backdropInfo.tileEdge ~= false
    end

    Piece:SetTexture(File, TileVerts, TileVerts)

    local CornerWidth = TextureInfo.SetWidth and self:GetEdgeSize() or 0
    local CornerHeight = TextureInfo.SetHeight and self:GetEdgeSize() or 0

    Piece:SetSize(CornerWidth, CornerHeight)
end

function LibBackdropTemplateMixin:SetBorderBlendMode(BlendMode)
    if (not self.backdropInfo) then
        return
    end

    for PieceName in pairs(TextureUVs) do
        local Region = self[PieceName]

        if (Region and PieceName ~= "Center") then
            Region:SetBlendMode(BlendMode)
        end
    end
end

function LibBackdropTemplateMixin:HasBackdropInfo(BackdropInfo)
    return self.backdropInfo == BackdropInfo
end

function LibBackdropTemplateMixin:ClearBackdrop()
    if (self.backdropInfo) then
        for PieceName in pairs(TextureUVs) do
            local Region = self[PieceName]

            if (Region) then
                Region:SetTexture(nil);
            end
        end

        self.backdropInfo = nil
    end
end

function LibBackdropTemplateMixin:ApplyBackdrop()
    local X, Y, X1, Y1 = 0, 0, 0, 0

    if (self.backdropInfo.bgFile) then
        local EdgeSize = self:GetEdgeSize()

        X = -EdgeSize
        Y = EdgeSize
        X1 = EdgeSize
        Y1 = -EdgeSize

        local Insets = self.backdropInfo.insets

        if (Insets) then
            X  = X  + (Insets.left or 0)
            Y  = Y  - (Insets.top or 0)
            X1 = X1 - (Insets.right or 0)
            Y1 = Y1 + (Insets.bottom or 0)
        end
    end

    NineSliceUtil.ApplyLayout(self, {
        TopLeftCorner = {},
        TopRightCorner = {},
        BottomLeftCorner = {},
        BottomRightCorner = {},
        TopEdge = {},
        BottomEdge = {},
        LeftEdge = {},
        RightEdge = {},
        Center = { layer = "BACKGROUND", x = X, y = Y, x1 = X1, y1 = Y1 },
        setupPieceVisualsFunction = LibBackdropTemplateMixin.SetupPieceVisuals,
    })

    self:SetBackdropColor(1, 1, 1, 1)
    self:SetBackdropBorderColor(1, 1, 1, 1)
    self:SetupTextureCoordinates()
end

function LibBackdropTemplateMixin:SetBackdrop(BackdropInfo)
    if (BackdropInfo) then
        if (self:HasBackdropInfo(BackdropInfo)) then
            return
        end

        if (not BackdropInfo.edgeFile and not BackdropInfo.bgFile) then
            self:ClearBackdrop()
            return
        end

        self.backdropInfo = BackdropInfo
        self:ApplyBackdrop()
    else
        self:ClearBackdrop()
    end
end

function LibBackdropTemplateMixin:GetBackdrop()
    if (not self.backdropInfo) then
        return nil
    end

    local BackdropInfo = CopyTable(self.backdropInfo)

    BackdropInfo.bgFile = BackdropInfo.bgFile or ""
    BackdropInfo.edgeFile = BackdropInfo.edgeFile or ""
    BackdropInfo.tile = BackdropInfo.tile or false
    BackdropInfo.tileSize = BackdropInfo.tileSize or 0
    BackdropInfo.tileEdge = BackdropInfo.tileEdge ~= false
    BackdropInfo.edgeSize = BackdropInfo.edgeSize or self:GetEdgeSize()

    BackdropInfo.insets = BackdropInfo.insets or {}
    BackdropInfo.insets.left = BackdropInfo.insets.left or 0
    BackdropInfo.insets.right = BackdropInfo.insets.right or 0
    BackdropInfo.insets.top = BackdropInfo.insets.top or 0
    BackdropInfo.insets.bottom = BackdropInfo.insets.bottom or 0

    return BackdropInfo
end

function LibBackdropTemplateMixin:GetBackdropColor()
    if (not self.backdropInfo) then
        return
    end

    if (self.Center) then
        return self.Center:GetVertexColor()
    end
end

function LibBackdropTemplateMixin:SetBackdropColor(R, G, B, A)
    if (not self.backdropInfo) then
        return
    end

    if (self.Center) then
        self.Center:SetVertexColor(R, G, B, A or 1)
    end
end

function LibBackdropTemplateMixin:GetBackdropBorderColor()
    if (not self.backdropInfo) then
        return
    end

    for PieceName in pairs(TextureUVs) do
        local Region = self[PieceName]

        if (Region and PieceName ~= "Center") then
            return Region:GetVertexColor()
        end
    end
end

function LibBackdropTemplateMixin:SetBackdropBorderColor(R, G, B, A)
    if (not self.backdropInfo) then
        return
    end

    for PieceName in pairs(TextureUVs) do
        local Region = self[PieceName]

        if (Region and PieceName ~= "Center") then
            Region:SetVertexColor(R, G, B, A or 1)
        end
    end
end