function DT_NPCPortraitPanel:initialise()
    ISPanel.initialise(self)

    self.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.borderColor = { r = 1, g = 1, b = 1, a = 0 }

    self.targetData = nil
    self.targetCharacter = nil
    self.legacyProvider = nil
    self.forceMode = nil
    self.overlayStyle = self.overlayStyle or "none"
    self.backgroundStyle = self.backgroundStyle or "scene"
    self.viewportMode = self.viewportMode or "square"
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

    self.animationProfile = self.animationProfile or "default"
    self.currentIdleState = 20
    self.ambientIdleState = 20
    self.speechIdleState = 21
    self.speechPulseTicks = 0
    self.tradeIdleState = 25
    self.tradePulseTicks = 0
    self.speechTriggerCount = 0
    self.tradeTriggerCount = 0
    self.ambientTicksRemaining = 0
end

function DT_NPCPortraitPanel:createChildren()
    ISPanel.createChildren(self)

    self:updateViewport()
    self:resetPortraitAnimation(true)
    self:applyViewState()
    self:refreshPortrait(true)
end

function DT_NPCPortraitPanel:ensureModelView()
    if self.modelView then
        return true
    end

    if not DT_NPCPortraitRenderers.Use3DPortraits() then
        return false
    end

    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("System", "UI", "Info", "DynamicTrading: Instantiating 3D Portrait View (Lazy-Load)")
    end

    self.modelView = ISUI3DModel:new(0, 0, self.viewportW or self.width, self.viewportH or self.height)
    self.modelView.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.modelView.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.modelView:initialise()
    self.modelView:instantiate()
    pcall(function()
        self.modelView:setAnimSetName("zombie")
    end)
    self:addChild(self.modelView)

    self:updateViewport()
    self:applyViewState()

    return true
end

function DT_NPCPortraitPanel:new(x, y, width, height, options)
    local o

    options = options or {}

    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.overlayStyle = options.overlayStyle or "none"
    o.isRadioMode = options.isRadioMode == true
    o.interactive = options.interactive == true
    o.forceMode = options.forceMode
    o.animationProfile = options.animationProfile or "default"

    return o
end
