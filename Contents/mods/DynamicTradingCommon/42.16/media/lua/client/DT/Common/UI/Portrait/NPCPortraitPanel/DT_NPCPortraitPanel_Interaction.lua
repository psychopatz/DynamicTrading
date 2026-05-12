local Internal = DT_NPCPortraitPanelInternal

function DT_NPCPortraitPanel:prerender()
    local bgTex

    ISPanel.prerender(self)

    if self.backgroundStyle == "none" then
        return
    end

    bgTex = DT_NPCPortraitRenderers.GetBackgroundTexture()
    if bgTex then
        Internal.DrawTextureFitted(self, bgTex, self.viewportX, self.viewportY, self.viewportW, self.viewportH, 1.0, 1.0, 1.0, 1.0)
    else
        self:drawRect(self.viewportX, self.viewportY, self.viewportW, self.viewportH, 1.0, 0.12, 0.12, 0.12)
    end
end

function DT_NPCPortraitPanel:render()
    local overlayTex
    local overlayAlpha

    ISPanel.render(self)

    if self.currentMode ~= "3d" and self.currentTexture then
        Internal.DrawTextureFitted(self, self.currentTexture, self.viewportX, self.viewportY, self.viewportW, self.viewportH, 1.0, 1.0, 1.0, 1.0)
    end

    if self.overlayStyle and self.overlayStyle ~= "none" then
        overlayTex = DT_NPCPortraitRenderers.GetOverlayTexture()
        overlayAlpha = DT_NPCPortraitRenderers.GetOverlayAlpha(self.overlayStyle, self.targetData)
        if overlayTex and overlayAlpha then
            self:drawTextureScaled(overlayTex, self.viewportX, self.viewportY, self.viewportW, self.viewportH, overlayAlpha, 1.0, 1.0, 1.0)
        end
    end

    if self.backgroundStyle ~= "none" then
        self:drawRectBorder(self.viewportX - 1, self.viewportY - 1, self.viewportW + 2, self.viewportH + 2, 1.0, 1.0, 1.0, 1.0)
    end
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
    local sensitivity
    local mouseX
    local mouseY
    local deltaX
    local deltaY

    if self.isDragging then
        sensitivity = 0.005 / math.max((self.currentZoom or 14.0) * 0.3, 0.5)
        mouseX = self:getMouseX()
        mouseY = self:getMouseY()
        deltaX = (mouseX - self.dragStartX) * sensitivity
        deltaY = (mouseY - self.dragStartY) * sensitivity

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

function DT_NPCPortraitPanel:update()
    ISPanel.update(self)

    if not self.modelView or self.currentMode ~= "3d" then
        return
    end

    if (self.tradePulseTicks or 0) > 0 then
        self.tradePulseTicks = self.tradePulseTicks - 1
        if self.tradePulseTicks < 0 then
            self.tradePulseTicks = 0
        end
    end

    if (self.speechPulseTicks or 0) > 0 then
        self.speechPulseTicks = self.speechPulseTicks - 1
        if self.speechPulseTicks < 0 then
            self.speechPulseTicks = 0
        end
    end

    if (self.tradePulseTicks or 0) <= 0 and (self.speechPulseTicks or 0) <= 0 then
        self.ambientTicksRemaining = (self.ambientTicksRemaining or 0) - 1
        if self.ambientTicksRemaining <= 0 then
            self.ambientIdleState = self:chooseAmbientIdleState()
            self:scheduleAmbientAnimation()
            self:refreshAnimationState(true)
            return
        end
    end

    self:refreshAnimationState(false)
end
