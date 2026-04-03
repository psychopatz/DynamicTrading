-- =============================================================================
-- DYNAMIC TRADING V1: SIGNAL PANEL - STATE
-- =============================================================================

V1_SignalPanel_State_logic = {}

function DT_SignalPanel:prerender()
    ISPanel.prerender(self)
    self:updateSignalLogic()
    self:updateButtonState()
end

function DT_SignalPanel:updateButtonState()
    local player = getSpecificPlayer(0)
    local canScan, timeRem = DynamicTrading.CooldownManager.CanScan(player)

    if canScan then
        self.btnScan:setEnable(true)
        self.btnScan:setTitle("SCAN FREQUENCIES")
        self.btnScan.textColor = { r = 1, g = 1, b = 1, a = 1 }
    else
        self.btnScan:setEnable(false)
        self.btnScan:setTitle("WAIT (" .. math.ceil(timeRem) .. "m)")
        self.btnScan.textColor = { r = 1, g = 0.5, b = 0.5, a = 1 }
    end
end

function DT_SignalPanel:updateSignalLogic()
    local player = getSpecificPlayer(0)
    local signalAvailable = false

    local deltaTime = UIManager.getMillisSinceLastRender()
    if self.clickAnimTimer > 0 then
        self.clickAnimTimer = self.clickAnimTimer - deltaTime
    end

    local totalTrading = DynamicTrading.Manager.GetTotalTradingSignals() or 0
    local foundByMe = DynamicTrading.Manager.GetFoundSignalsCount(player) or 0
    local typeID = self:getRadioTypeID()
    local radioData = typeID and DynamicTrading.Config.GetRadioData(typeID)
    local capacity = radioData and radioData.capacity or 1

    if totalTrading > 0 and foundByMe < totalTrading and foundByMe < capacity then
        signalAvailable = true
    end

    if self.signalFoundPersist then
        self.signalState = "found"
    elseif not signalAvailable then
        self.signalState = "none"
    else
        self.signalState = "search"
    end

    self.signalAnimTimer = self.signalAnimTimer + deltaTime
    if self.signalAnimTimer >= self.signalFrameDuration then
        self.signalAnimTimer = self.signalAnimTimer - self.signalFrameDuration
        self.signalFrame = self.signalFrame + 1
        local max = self.signalFrameCounts[self.signalState] or 3
        if self.signalFrame > max then
            self.signalFrame = 1
        end
    end
end
