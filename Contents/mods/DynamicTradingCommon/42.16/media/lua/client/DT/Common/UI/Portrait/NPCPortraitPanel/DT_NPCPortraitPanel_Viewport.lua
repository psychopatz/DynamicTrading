function DT_NPCPortraitPanel:updateViewport()
    local viewportMode = self.viewportMode or "square"
    local size

    if viewportMode == "fill" then
        self.viewportW = math.max(1, math.floor(self.width))
        self.viewportH = math.max(1, math.floor(self.height))
        self.viewportX = 0
        self.viewportY = 0
    else
        size = math.floor(math.min(self.width, self.height))
        if size < 1 then
            size = 1
        end

        self.viewportW = size
        self.viewportH = size
        self.viewportX = math.floor((self.width - size) / 2)
        self.viewportY = math.floor((self.height - size) / 2)
    end

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
    self:resetPortraitAnimation(true)
    self:refreshPortrait(true)
end

function DT_NPCPortraitPanel:setTargetData(targetData)
    self.targetData = targetData
    self.targetCharacter = nil
    self:resetPortraitAnimation(true)
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

function DT_NPCPortraitPanel:setBackgroundStyle(style)
    local nextStyle = style or "scene"
    if nextStyle ~= "scene" and nextStyle ~= "none" then
        nextStyle = "scene"
    end

    self.backgroundStyle = nextStyle
end

function DT_NPCPortraitPanel:setViewportMode(mode)
    local nextMode = mode or "square"

    if nextMode ~= "square" and nextMode ~= "fill" then
        nextMode = "square"
    end

    if self.viewportMode == nextMode then
        return
    end

    self.viewportMode = nextMode
    self:updateViewport()
end

function DT_NPCPortraitPanel:setInteractive(enabled)
    self.interactive = enabled == true
end

function DT_NPCPortraitPanel:setAnimationProfile(profile)
    local nextProfile = profile or "default"

    if not DT_NPCPortraitPanel.ANIMATION_PROFILES[nextProfile] then
        nextProfile = "default"
    end

    if self.animationProfile == nextProfile then
        return
    end

    self.animationProfile = nextProfile
    self:resetPortraitAnimation(true)
    self:applyViewState()
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

function DT_NPCPortraitPanel:resetViewState()
    self.currentZoom = 14.0
    self.currentXOffset = 0.0
    self.currentYOffset = -0.85
    self.currentDirIndex = 1
    self.isAnimating = true
    self.isIsometric = false
    self:resetPortraitAnimation(true)
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
