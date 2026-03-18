-- =============================================================================
-- CLASS DEFINITION
-- =============================================================================
DT_TradingWindow = DT_TradingWindow or ISCollapsableWindow:derive("DT_TradingWindow")
DT_TradingWindow.instance = nil

function DT_TradingWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 600
    self.minimumHeight = 650
    self.isBuying = true
    self.selectedKey = nil
    self.radioObj = nil
    self.collapsed = {}
    self.lastSelectedIndex = -1
    self.localLogs = {}
    self.dataProvider = nil -- INJECTED ON CREATION

    -- ==========================================================
    -- LOGIC STATE TRACKERS
    -- ==========================================================
    self.idleTimer = 0
    self.updateTick = 0

    -- Prevent FPS drops by limiting inventory scanning frequency.
    self.inventoryDirty = false
    self.refreshCooldown = 0

    self.lastHour = -1
    self.wasRaining = false
    self.wasFoggy = false

    -- Structure: { text="", isError=false, isPlayer=false, delay=0, sound=nil }
    self.msgQueue = {}
    self.typingTick = 0
end

function DT_TradingWindow:resetIdleTimer()
    self.idleTimer = 0
end

function DT_TradingWindow:queueMessage(text, isError, isPlayer, delay, soundName, tag)
    if tag then
        for _, msg in ipairs(self.msgQueue) do
            if msg.tag == tag then
                msg.delay = 0
            end
        end
    end

    table.insert(self.msgQueue, {
        text = text,
        isError = isError or false,
        isPlayer = isPlayer or false,
        delay = delay or 0,
        sound = soundName,
        tag = tag
    })
end
