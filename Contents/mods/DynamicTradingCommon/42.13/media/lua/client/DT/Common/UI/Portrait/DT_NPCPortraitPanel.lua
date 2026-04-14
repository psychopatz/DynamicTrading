-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT PANEL
-- =============================================================================
-- Reusable portrait widget for Trading, Conversation, and debug tools.
-- =============================================================================

require "ISUI/ISPanel"
require "ISUI/ISUI3DModel"

DT_NPCPortraitPanel = DT_NPCPortraitPanel or ISPanel:derive("DT_NPCPortraitPanel")

DT_NPCPortraitPanel.DIRECTIONS = {
    IsoDirections.S,
    IsoDirections.SE,
    IsoDirections.E,
    IsoDirections.NE,
    IsoDirections.N,
    IsoDirections.NW,
    IsoDirections.W,
    IsoDirections.SW,
}

DT_NPCPortraitPanel.DIR_NAMES = {
    [IsoDirections.S] = "S (Front)",
    [IsoDirections.SE] = "SE",
    [IsoDirections.E] = "E (Right)",
    [IsoDirections.NE] = "NE",
    [IsoDirections.N] = "N (Back)",
    [IsoDirections.NW] = "NW",
    [IsoDirections.W] = "W (Left)",
    [IsoDirections.SW] = "SW",
}

function DT_NPCPortraitPanel:initialise()
    ISPanel.initialise(self)

    self.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.borderColor = { r = 1, g = 1, b = 1, a = 0 }

    self.targetData = nil
    self.targetCharacter = nil
    self.legacyProvider = nil
    self.forceMode = nil
    self.overlayStyle = self.overlayStyle or "none"
    self.isRadioMode = self.isRadioMode == true
    self.interactive = self.interactive == true

    self.currentZoom = 14.0
    self.currentXOffset = 0.0
    self.currentYOffset = -0.85
    self.currentDirIndex = 1
    self.isAnimating = true
    self.isIsometric = false

    self.isDragging = false
    self.dragStartX = 0
    self.dragStartY = 0
    self.dragStartXOffset = 0
    self.dragStartYOffset = 0

    self.viewportX = 0
    self.viewportY = 0
    self.viewportW = 0
    self.viewportH = 0

    self.currentMode = "legacy"
    self.currentTexture = nil
    self.currentDescriptor = nil
end

function DT_NPCPortraitPanel:createChildren()
    ISPanel.createChildren(self)

    self.modelView = ISUI3DModel:new(0, 0, self.width, self.height)
    self.modelView.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.modelView.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.modelView:initialise()
    self.modelView:instantiate()
    self:addChild(self.modelView)

    self:updateViewport()
    self:applyViewState()
    self:refreshPortrait(true)
end

function DT_NPCPortraitPanel:updateViewport()
    local size = math.floor(math.min(self.width, self.height))
    if size < 1 then
        size = 1
    end

    self.viewportW = size
    self.viewportH = size
    self.viewportX = math.floor((self.width - size) / 2)
    self.viewportY = math.floor((self.height - size) / 2)

    if self.modelView then
        self.modelView:setX(self.viewportX)
        self.modelView:setY(self.viewportY)
        self.modelView:setWidth(self.viewportW)
        self.modelView:setHeight(self.viewportH)
    end
end

function DT_NPCPortraitPanel:setPortraitBounds(x, y, w, h)
    self:setX(x)
    self:setY(y)
    self:setWidth(w)
    self:setHeight(h)
    self:updateViewport()
end

function DT_NPCPortraitPanel:setLegacyProvider(provider)
    self.legacyProvider = provider
    self:refreshPortrait(true)
end

function DT_NPCPortraitPanel:setTargetCharacter(character, targetData)
    self.targetCharacter = character
    self.targetData = targetData or self.targetData
    self:refreshPortrait(true)
end

function DT_NPCPortraitPanel:setTargetData(targetData)
    self.targetData = targetData
    self.targetCharacter = nil
    self:refreshPortrait(true)
end

function DT_NPCPortraitPanel:setRadioMode(enabled)
    self.isRadioMode = enabled == true
end

function DT_NPCPortraitPanel:setOverlayMode(style)
    if style == true then
        style = "trading"
    elseif style == false or style == nil then
        style = "none"
    end

    self.overlayStyle = style
end

function DT_NPCPortraitPanel:setInteractive(enabled)
    self.interactive = enabled == true
end

function DT_NPCPortraitPanel:setForceMode(mode)
    self.forceMode = mode
    self:refreshPortrait(true)
end

function DT_NPCPortraitPanel:getResolvedMode()
    if self.forceMode == "3d" or self.forceMode == "legacy" then
        return self.forceMode
    end

    return DT_NPCPortraitRenderers.Use3DPortraits() and "3d" or "legacy"
end

function DT_NPCPortraitPanel:applyViewState()
    if not self.modelView then
        return
    end

    self.modelView:setState("idle")
    self.modelView:setDirection(DT_NPCPortraitPanel.DIRECTIONS[self.currentDirIndex] or IsoDirections.S)
    self.modelView:setIsometric(self.isIsometric)
    self.modelView:setDoRandomExtAnimations(false)
    self.modelView:setZoom(self.currentZoom)
    self.modelView:setXOffset(self.currentXOffset)
    self.modelView:setYOffset(self.currentYOffset)

    if self.modelView.javaObject then
        self.modelView.javaObject:setAnimate(self.isAnimating)
    end
end

function DT_NPCPortraitPanel:clearModelTarget()
    if not self.modelView then
        return
    end

    if self.modelView.javaObject then
        self.modelView.javaObject:clearVariables()
    end
end

function DT_NPCPortraitPanel:applyResolvedPortrait(resolved)
    if not self.modelView then
        return
    end

    self.currentMode = resolved and resolved.mode or "legacy"
    self.currentTexture = resolved and resolved.texture or nil
    self.currentDescriptor = resolved and resolved.survivorDesc or nil

    if self.currentMode == "3d" and (resolved.character or resolved.survivorDesc) then
        self.modelView:setVisible(true)
        self:clearModelTarget()

        if resolved.character then
            self.modelView:setCharacter(resolved.character)
        else
            self.modelView:setCharacter(nil)
            self.modelView:setSurvivorDesc(resolved.survivorDesc)
        end

        self:applyViewState()
    else
        self:clearModelTarget()
        self.modelView:setCharacter(nil)
        self.modelView:setVisible(false)
    end
end

function DT_NPCPortraitPanel:refreshPortrait(force)
    local requestedMode = self:getResolvedMode()
    local resolved = DT_NPCPortraitResolver.Resolve(self.targetData, self.targetCharacter, {
        provider = self.legacyProvider,
        forceLegacy = requestedMode == "legacy"
    })

    self:applyResolvedPortrait(resolved)
end

function DT_NPCPortraitPanel:resetViewState()
    self.currentZoom = 14.0
    self.currentXOffset = 0.0
    self.currentYOffset = -0.85
    self.currentDirIndex = 1
    self.isAnimating = true
    self.isIsometric = false
    self:applyViewState()
end

function DT_NPCPortraitPanel:setZoom(value)
    self.currentZoom = math.max(0.5, math.min(20.0, value or self.currentZoom))
    self:applyViewState()
end

function DT_NPCPortraitPanel:adjustZoom(delta)
    self:setZoom((self.currentZoom or 14.0) + (delta or 0))
end

function DT_NPCPortraitPanel:setOffsets(xOffset, yOffset)
    self.currentXOffset = xOffset or self.currentXOffset
    self.currentYOffset = yOffset or self.currentYOffset
    self:applyViewState()
end

function DT_NPCPortraitPanel:adjustOffsets(deltaX, deltaY)
    self:setOffsets((self.currentXOffset or 0) + (deltaX or 0), (self.currentYOffset or 0) + (deltaY or 0))
end

function DT_NPCPortraitPanel:setDirectionIndex(index)
    if index < 1 then
        index = #DT_NPCPortraitPanel.DIRECTIONS
    elseif index > #DT_NPCPortraitPanel.DIRECTIONS then
        index = 1
    end

    self.currentDirIndex = index
    self:applyViewState()
end

function DT_NPCPortraitPanel:cycleDirection(step)
    self:setDirectionIndex((self.currentDirIndex or 1) + (step or 1))
end

function DT_NPCPortraitPanel:setAnimate(enabled)
    self.isAnimating = enabled == true
    self:applyViewState()
end

function DT_NPCPortraitPanel:setIsometric(enabled)
    self.isIsometric = enabled == true
    self:applyViewState()
end

function DT_NPCPortraitPanel:getDirectionName()
    local dir = DT_NPCPortraitPanel.DIRECTIONS[self.currentDirIndex]
    return DT_NPCPortraitPanel.DIR_NAMES[dir] or "?"
end

function DT_NPCPortraitPanel:prerender()
    ISPanel.prerender(self)

    local bgTex = DT_NPCPortraitRenderers.GetBackgroundTexture()
    if bgTex then
        self:drawTextureScaled(bgTex, self.viewportX, self.viewportY, self.viewportW, self.viewportH, 1.0, 1.0, 1.0, 1.0)
    else
        self:drawRect(self.viewportX, self.viewportY, self.viewportW, self.viewportH, 1.0, 0.12, 0.12, 0.12)
    end
end

function DT_NPCPortraitPanel:render()
    ISPanel.render(self)

    if self.currentMode ~= "3d" and self.currentTexture then
        self:drawTextureScaled(self.currentTexture, self.viewportX, self.viewportY, self.viewportW, self.viewportH, 1.0, 1.0, 1.0, 1.0)
    end

    if self.overlayStyle and self.overlayStyle ~= "none" then
        local overlayTex = DT_NPCPortraitRenderers.GetOverlayTexture()
        local overlayAlpha = DT_NPCPortraitRenderers.GetOverlayAlpha(self.overlayStyle, self.targetData)
        if overlayTex and overlayAlpha then
            self:drawTextureScaled(overlayTex, self.viewportX, self.viewportY, self.viewportW, self.viewportH, overlayAlpha, 1.0, 1.0, 1.0)
        end
    end

    self:drawRectBorder(self.viewportX - 1, self.viewportY - 1, self.viewportW + 2, self.viewportH + 2, 1.0, 1.0, 1.0, 1.0)
end

function DT_NPCPortraitPanel:onMouseDown(x, y)
    if not self.interactive or self.currentMode ~= "3d" then
        return ISPanel.onMouseDown(self, x, y)
    end

    if x >= self.viewportX and x <= self.viewportX + self.viewportW and y >= self.viewportY and y <= self.viewportY + self.viewportH then
        self.isDragging = true
        self.dragStartX = x
        self.dragStartY = y
        self.dragStartXOffset = self.currentXOffset
        self.dragStartYOffset = self.currentYOffset
        return true
    end

    return ISPanel.onMouseDown(self, x, y)
end

function DT_NPCPortraitPanel:onMouseMove(dx, dy)
    if self.isDragging then
        local sensitivity = 0.005 / math.max((self.currentZoom or 14.0) * 0.3, 0.5)
        local mouseX = self:getMouseX()
        local mouseY = self:getMouseY()
        local deltaX = (mouseX - self.dragStartX) * sensitivity
        local deltaY = (mouseY - self.dragStartY) * sensitivity

        self:setOffsets(self.dragStartXOffset + deltaX, self.dragStartYOffset - deltaY)
        return true
    end

    return ISPanel.onMouseMove(self, dx, dy)
end

function DT_NPCPortraitPanel:onMouseUp(x, y)
    if self.isDragging then
        self.isDragging = false
        return true
    end

    return ISPanel.onMouseUp(self, x, y)
end

function DT_NPCPortraitPanel:onMouseUpOutside(x, y)
    self.isDragging = false
    return ISPanel.onMouseUpOutside(self, x, y)
end

function DT_NPCPortraitPanel:onMouseWheel(del)
    if not self.interactive or self.currentMode ~= "3d" then
        return false
    end

    self:adjustZoom(-(del * 0.3))
    return true
end

function DT_NPCPortraitPanel:new(x, y, width, height, options)
    options = options or {}

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.overlayStyle = options.overlayStyle or "none"
    o.isRadioMode = options.isRadioMode == true
    o.interactive = options.interactive == true
    o.forceMode = options.forceMode

    return o
end

return DT_NPCPortraitPanel
