require "ISUI/ISCollapsableWindow"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

-------------------------------------------------------------------
-- DT_ManualUI_ImageModal
-- A resizable modal overlay that displays a manual-page image.
-- The image scales dynamically to fill the window while keeping
-- its original aspect ratio.  Press the X button or Escape to close.
-------------------------------------------------------------------

DT_ManualUI_ImageModal = ISCollapsableWindow:derive("DT_ManualUI_ImageModal")
DT_ManualUI_ImageModal.instance = nil

function DT_ManualUI_ImageModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle(self.caption or "Image Preview")
    self:setResizable(true)
end

function DT_ManualUI_ImageModal:createChildren()
    ISCollapsableWindow.createChildren(self)
end

function DT_ManualUI_ImageModal:prerender()
    ISCollapsableWindow.prerender(self)

    -- Dark semi-transparent background
    self:drawRect(0, self:titleBarHeight(), self.width, self.height - self:titleBarHeight(), 0.92, 0.04, 0.04, 0.04)
end

function DT_ManualUI_ImageModal:render()
    ISCollapsableWindow.render(self)

    if not self.texture then
        self:drawTextCentre("Image not available", self.width / 2, self.height / 2 - 10, 0.8, 0.5, 0.5, 1, UIFont.Medium)
        return
    end

    local padding = 16
    local tbh = self:titleBarHeight()
    local captionH = (self.caption and self.caption ~= "") and 28 or 0
    local availW = self.width - (padding * 2)
    local availH = self.height - tbh - (padding * 2) - captionH

    if availW < 20 or availH < 20 then
        return
    end

    -- Maintain aspect ratio
    local imgW = self.origWidth or availW
    local imgH = self.origHeight or availH
    local scale = math.min(availW / imgW, availH / imgH)
    local drawW = imgW * scale
    local drawH = imgH * scale

    -- Centre the image
    local drawX = padding + (availW - drawW) / 2
    local drawY = tbh + padding + (availH - drawH) / 2

    self:drawTextureScaled(self.texture, drawX, drawY, drawW, drawH, 1, 1, 1, 1)
    self:drawRectBorder(drawX, drawY, drawW, drawH, 0.6, 0.5, 0.5, 0.5)

    -- Caption below the image
    if self.caption and self.caption ~= "" then
        local captionY = drawY + drawH + 6
        self:drawTextCentre(self.caption, self.width / 2, captionY, 0.80, 0.80, 0.80, 1, UIFont.Small)
    end
end

function DT_ManualUI_ImageModal:onKeyPress(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
        return true
    end
end

function DT_ManualUI_ImageModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_ManualUI_ImageModal.instance = nil
end

function DT_ManualUI_ImageModal:onResize()
    ISCollapsableWindow.onResize(self)
    -- Image is rendered dynamically in render(); nothing extra needed.
end

function DT_ManualUI_ImageModal:new(x, y, w, h)
    local o = ISCollapsableWindow:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.resizable = true
    o.title = "Image Preview"
    o.texture = nil
    o.origWidth = 1
    o.origHeight = 1
    o.caption = ""
    return o
end

-------------------------------------------------------------------
-- Public API – open the modal for a given image block
-------------------------------------------------------------------
function DT_ManualUI_ImageModal.Open(block)
    -- Close previous instance if any
    if DT_ManualUI_ImageModal.instance then
        DT_ManualUI_ImageModal.instance:close()
    end

    local texture = block and block.texture or nil
    if not texture then
        texture = DT_ManualUI_Utils.resolveTexture(block and block.path or "")
    end

    -- Try to read the native texture dimensions
    local origW = (block and block.width) or 400
    local origH = (block and block.height) or 300
    if texture then
        local tw = texture:getWidth()
        local th = texture:getHeight()
        if tw and tw > 0 then origW = tw end
        if th and th > 0 then origH = th end
    end

    -- Modal size: up to 80% of the screen, at least 300×200
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local maxW = math.floor(screenW * 0.80)
    local maxH = math.floor(screenH * 0.80)

    -- Start near the image's native size + some padding for title and caption
    local modalW = DT_ManualUI_Utils.clamp(origW + 40, 300, maxW)
    local modalH = DT_ManualUI_Utils.clamp(origH + 80, 200, maxH)

    local modalX = math.floor((screenW - modalW) / 2)
    local modalY = math.floor((screenH - modalH) / 2)

    local modal = DT_ManualUI_ImageModal:new(modalX, modalY, modalW, modalH)
    modal.texture = texture
    modal.origWidth = origW
    modal.origHeight = origH
    modal.caption = (block and block.caption) or ""
    modal:initialise()
    modal:addToUIManager()
    modal:setVisible(true)
    modal:bringToTop()

    DT_ManualUI_ImageModal.instance = modal
    return modal
end
