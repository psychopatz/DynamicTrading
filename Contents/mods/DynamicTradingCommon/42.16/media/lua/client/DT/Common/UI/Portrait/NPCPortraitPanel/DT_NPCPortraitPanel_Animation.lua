local Internal = DT_NPCPortraitPanelInternal

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
    self:applyAnimationVariables()

    if self.modelView.javaObject then
        self.modelView.javaObject:setAnimate(self.isAnimating)
    end
end

function DT_NPCPortraitPanel:getAnimationConfig()
    return DT_NPCPortraitPanel.ANIMATION_PROFILES[self.animationProfile]
        or DT_NPCPortraitPanel.ANIMATION_PROFILES["default"]
end

function DT_NPCPortraitPanel:getAnimationIdentitySeed()
    local targetData = self.targetData or {}
    return tonumber(targetData.identitySeed or targetData.visualID or 1) or 1
end

function DT_NPCPortraitPanel:chooseAmbientIdleState(config)
    local states
    local index
    local state
    local nextIndex

    config = config or self:getAnimationConfig()
    states = config.ambientStates or { 20 }
    if #states == 0 then
        return 20
    end

    index = ZombRand(#states) + 1
    state = states[index] or states[1] or 20

    if #states > 1 and state == self.ambientIdleState then
        nextIndex = (index % #states) + 1
        state = states[nextIndex] or state
    end

    return state
end

function DT_NPCPortraitPanel:scheduleAmbientAnimation(config)
    local minTicks
    local maxTicks

    config = config or self:getAnimationConfig()
    minTicks = tonumber(config.ambientMinTicks) or 240
    maxTicks = tonumber(config.ambientMaxTicks) or minTicks
    self.ambientTicksRemaining = Internal.GetPortraitRandomRange(minTicks, maxTicks)
end

function DT_NPCPortraitPanel:resetPortraitAnimation(forceApply)
    local config = self:getAnimationConfig()

    self.ambientIdleState = self:chooseAmbientIdleState(config)
    self.speechIdleState = config.speechStates and config.speechStates[1] or 23
    self.tradeIdleState = config.transactionStates and config.transactionStates[1] or 25
    self.currentIdleState = self.ambientIdleState
    self.speechPulseTicks = 0
    self.tradePulseTicks = 0
    self.speechTriggerCount = 0
    self.tradeTriggerCount = 0
    self:scheduleAmbientAnimation(config)

    if forceApply then
        self:applyAnimationVariables()
    end
end

function DT_NPCPortraitPanel:chooseSpeechIdleState(config)
    local states
    local seed
    local index
    local state
    local nextIndex

    config = config or self:getAnimationConfig()
    states = config.speechStates or { config.speechState or 21 }
    if #states == 0 then
        return 21
    end

    seed = self:getAnimationIdentitySeed() + (self.speechTriggerCount or 0)
    index = ((seed - 1) % #states) + 1
    state = states[index] or states[1] or 21
    if #states > 1 and state == self.speechIdleState then
        nextIndex = (index % #states) + 1
        state = states[nextIndex] or state
    end
    return state
end

function DT_NPCPortraitPanel:chooseTradeIdleState(config)
    local states
    local seed
    local index
    local state
    local nextIndex

    config = config or self:getAnimationConfig()
    states = config.transactionStates or { config.transactionState or 25 }
    if #states == 0 then
        return 25
    end

    seed = self:getAnimationIdentitySeed() + (self.tradeTriggerCount or 0)
    index = ((seed - 1) % #states) + 1
    state = states[index] or states[1] or 25
    if #states > 1 and state == self.tradeIdleState then
        nextIndex = (index % #states) + 1
        state = states[nextIndex] or state
    end
    return state
end

function DT_NPCPortraitPanel:applyAnimationVariables()
    local idleState

    if not self.modelView or not self.modelView.javaObject then
        return
    end

    idleState = tostring(self.currentIdleState or 20)
    self.modelView:setVariable("DTNPC", "true")
    self.modelView:setVariable("bMoving", "false")
    self.modelView:setVariable("isMoving", "false")
    self.modelView:setVariable("Speed", "0.0")
    self.modelView:setVariable("MovementSpeed", "0.0")
    self.modelView:setVariable("DTNPCAnimSpeed", "0.0")
    self.modelView:setVariable("WalkSpeed", "0.0")
    self.modelView:setVariable("RunSpeed", "0.0")
    self.modelView:setVariable("WalkType", "")
    self.modelView:setVariable("DTWalkType", "")
    self.modelView:setVariable("DTIdleState", idleState)
    self.modelView:setState("idle")
end

function DT_NPCPortraitPanel:refreshAnimationState(force)
    local nextState = self.ambientIdleState or 20

    if (self.tradePulseTicks or 0) > 0 then
        nextState = self.tradeIdleState or 25
    elseif (self.speechPulseTicks or 0) > 0 then
        nextState = self.speechIdleState or 21
    end

    if force or self.currentIdleState ~= nextState then
        self.currentIdleState = nextState
        self:applyAnimationVariables()
    end
end

function DT_NPCPortraitPanel:setSpeechActive(active)
    local nextValue = active == true

    if nextValue then
        self:pulseSpeechAnimation()
    end
end

function DT_NPCPortraitPanel:pulseSpeechAnimation(durationTicks)
    local config = self:getAnimationConfig()
    local pulseTicks = durationTicks or tonumber(config.speechPulseTicks) or 36

    self.speechTriggerCount = (self.speechTriggerCount or 0) + 1
    self.speechIdleState = self:chooseSpeechIdleState()
    self.speechPulseTicks = math.max(1, pulseTicks)
    self:refreshAnimationState(true)
end

function DT_NPCPortraitPanel:pulseTradeAnimation(durationTicks)
    local config = self:getAnimationConfig()
    local pulseTicks = durationTicks or tonumber(config.transactionPulseTicks) or 30

    self.tradeTriggerCount = (self.tradeTriggerCount or 0) + 1
    self.tradeIdleState = self:chooseTradeIdleState()
    self.tradePulseTicks = math.max(1, pulseTicks)
    self:refreshAnimationState(true)
end
