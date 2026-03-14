require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISImage"

require "DT/Common/Config"

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
    -- Idle Timer (Ticks up every frame)
    self.idleTimer = 0
    
    -- Performance Throttling
    self.updateTick = 0 
    
    -- [NEW] PERFORMANCE THROTTLING
    -- Prevents FPS drops by limiting inventory scanning frequency
    self.inventoryDirty = false
    self.refreshCooldown = 0
    
    -- Observer State
    self.lastHour = -1
    self.wasRaining = false
    self.wasFoggy = false
    
    -- [NEW] MESSAGE QUEUE SYSTEM
    -- Stores pending messages to simulate conversation flow
    -- Structure: { text="", isError=false, isPlayer=false, delay=0, sound=nil }
    self.msgQueue = {}
    self.typingTick = 0
end

function DT_TradingWindow:resetIdleTimer()
    self.idleTimer = 0
end

-- [NEW] QUEUE HELPER
function DT_TradingWindow:queueMessage(text, isError, isPlayer, delay, soundName, tag)
    -- Fast-forward older messages with the same tag
    if tag then
        for _, m in ipairs(self.msgQueue) do
            if m.tag == tag then
                m.delay = 0
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

-- UI sub-modules (Relative to common)
require "DT/Common/UI/Trading/DT_SellConfirmationModal"
require "DT/Common/UI/Trading/DT_TradingWindow_Helpers"
require "DT/Common/UI/Trading/DT_TradingWindow_Layout"
require "DT/Common/UI/Trading/DT_TradingWindow_List"
require "DT/Common/UI/Trading/DT_TradingWindow_Actions"
require "DT/Common/UI/Trading/DT_TradingWindow_Debug"

-- =============================================================================
-- MAIN UPDATE LOOP
-- =============================================================================
function DT_TradingWindow:update()
    ISCollapsableWindow.update(self)

    -- [CRASH FIX] Safety check for player death
    local player = getSpecificPlayer(0)
    if not player or player:isDead() then
        self:close()
        return
    end

    -- 1. Crash Shield for Listbox
    if self.listbox then
        if self.listbox.items == nil then self.listbox.items = {} end
        if self.listbox.items == nil then self.listbox.items = {} end
        if type(self.listbox.selected) ~= "number" then self.listbox.selected = -1 end
        -- [HOST DEBUG] Hook right click
        self.listbox.onRightMouseUp = self.onListRightMouseUp
    end

    -- [NEW] INVENTORY REFRESH THROTTLING
    -- Instead of refreshing every frame an event fires, we process it here at a safe rate.
    if self.refreshCooldown and self.refreshCooldown > 0 then
        self.refreshCooldown = self.refreshCooldown - 1
    end

    if self.inventoryDirty and self.refreshCooldown and self.refreshCooldown <= 0 then
        self:populateList()
        self.inventoryDirty = false
        self.refreshCooldown = 30 -- Refresh at most twice per second
    end

    -- 2. Validate Trader Existence
    if not self.traderID or not self.dataProvider then self:close() return end
    
    local trader = self.dataProvider:getTrader(self.traderID, self.archetype)
    
    if not trader then
        self:logLocal("Signal Lost: Contact unavailable.", true)
        self:close()
        return
    end

    -- 3. Update Visuals
    self:updateIdentityDisplay(trader)
    self:updateWallet()

    -- 4. Connection Check
    if not self:isConnectionValid() then
        self:close()
        return
    end

    -- [NEW] "Ask a Favor" Button State Management (Agnostic)
    if self.isBuying and self.btnAsk then
        local favorStatus = self.dataProvider:getFavorStatus(trader)
        if favorStatus then
            self.btnAsk:setEnable(favorStatus.canRequest)
            self.btnAsk.tooltip = favorStatus.tooltip
        else
            self.btnAsk:setEnable(false)
        end
    end
    
    -- ==========================================================
    -- MESSAGE QUEUE PROCESSOR
    -- ==========================================================
    if #self.msgQueue > 0 then
        local msg = self.msgQueue[1]
        
        if msg.delay > 0 then
            -- Count down the delay
            msg.delay = msg.delay - 1
        else
            -- Delay finished, show message
            self:logLocal(msg.text, msg.isError, msg.isPlayer)
            
            -- Play Audio Sync
            if player then
                -- Play specific sound if provided (e.g., cash register)
                if msg.sound then
                     self.dataProvider:playSound(msg.sound)
                -- Otherwise play default radio click
                else
                     self.dataProvider:playSound("DT_RadioRandom")
                end
            end
            
            -- Remove from queue and reset idle
            table.remove(self.msgQueue, 1)
            self:resetIdleTimer()
        end
    end

    self.typingTick = self.typingTick + 1

    -- ==========================================================
    -- OBSERVER & IDLE SYSTEM
    -- ==========================================================
    self.updateTick = self.updateTick + 1
    if self.updateTick >= 30 then
        self.updateTick = 0
        
        -- A. SETUP CONTEXT
        local gt = GameTime:getInstance()
        local cm = ClimateManager:getInstance()
        local currentHour = gt:getHour()
        local isRaining = cm:getRainIntensity() > 0.4
        local isFoggy = cm:getFogIntensity() > 0.4
        local ambientMsg = nil

        -- B. TIME OBSERVER
        if currentHour ~= self.lastHour then
            if currentHour == 5 then ambientMsg = self.dataProvider:getAmbientMessage(trader, "Morning")
            elseif currentHour == 17 then ambientMsg = self.dataProvider:getAmbientMessage(trader, "Evening")
            elseif currentHour == 21 then ambientMsg = self.dataProvider:getAmbientMessage(trader, "Night")
            end
            self.lastHour = currentHour
        end

        -- C. WEATHER OBSERVER
        if not ambientMsg then 
            if isRaining ~= self.wasRaining then
                ambientMsg = isRaining and self.dataProvider:getAmbientMessage(trader, "RainStart") or self.dataProvider:getAmbientMessage(trader, "RainStop")
                self.wasRaining = isRaining
            elseif isFoggy ~= self.wasFoggy then
                ambientMsg = isFoggy and self.dataProvider:getAmbientMessage(trader, "FogStart")
                self.wasFoggy = isFoggy
            end
        end

        -- D. EXECUTE AMBIENT EVENT
        -- We add it to the queue with a small delay to avoid interrupting active convos abruptly
        if ambientMsg then
            self:queueMessage(ambientMsg, false, false, 10) 
        end

        -- E. IDLE LOGIC
        -- Only tick up if queue is empty (no active conversation)
        if #self.msgQueue == 0 then
            self.idleTimer = self.idleTimer + 30
            
            if self.idleTimer >= 3600 then
                local idleMsg = self.dataProvider:getIdleMessage(trader)
                if idleMsg then
                    self:queueMessage(idleMsg, false, false, 0)
                end
                self.idleTimer = 0
            end
        end
    end
end

-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================

function DT_TradingWindow:close()
    if DT_ConfigManager and DT_ConfigManager.setWindowState then
        DT_ConfigManager.setWindowState("TradingWindow", self:getX(), self:getY(), self:getWidth(), self:getHeight())
    end
    if self.onCloseCallback then
        local success, err = pcall(self.onCloseCallback, self)
        if not success and DynamicTrading and DynamicTrading.Log then
            DynamicTrading.Log("DTV2", "Trade", "Error", "Trading close callback failed: " .. tostring(err))
        end
    end
    ISCollapsableWindow.close(self)
    DT_TradingWindow.instance = nil
end

-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================
function DT_TradingWindow.ToggleWindow(traderID, archetype, radioObj, dataProvider)
    if DT_TradingWindow.instance then
        DT_TradingWindow.instance:close()
        return
    end
    
    -- [CRASH FIX] Do not open if player is dead
    local player = getSpecificPlayer(0)
    if not player or player:isDead() then return end

    -- Dynamic Sizing Logic (Default)
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = math.min(750, screenW * 0.6)
    local height = math.min(750, screenH * 0.7)
    
    -- Minimum threshold
    width = math.max(600, width)
    height = math.max(650, height)
    
    local x = screenW/2 - width/2
    local y = screenH/2 - height/2

    -- Attempt to load persisted state
    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("TradingWindow")
        if state then
            x = state.x
            y = state.y
            width = state.w
            height = state.h
            
            -- Basic bounds check to prevent lost windows
            if x < 0 then x = 0 end
            if y < 0 then y = 0 end
            if x > screenW - 50 then x = screenW - width end
            if y > screenH - 50 then y = screenH - height end
        end
    end

    local ui = DT_TradingWindow:new(x, y, width, height)
    ui:initialise()
    ui.dataProvider = dataProvider -- INJECT PROVIDER
    ui:addToUIManager()
    ui.traderID = traderID
    ui.archetype = archetype or "General"
    ui.radioObj = radioObj

    local trader = dataProvider:getTrader(traderID, archetype)
    
    -- Dynamic Store Title
    if dataProvider.getWindowTitle then
        ui:setTitle(dataProvider:getWindowTitle(trader))
    else
        ui:setTitle("Trading Window")
    end
    
    ui:populateList()
    
    -- Sync Observer
    local gt = GameTime:getInstance()
    local cm = ClimateManager:getInstance()
    ui.lastHour = gt:getHour()
    ui.wasRaining = cm:getRainIntensity() > 0.4
    ui.wasFoggy = cm:getFogIntensity() > 0.4

    -- ==========================================================
    -- INITIAL HANDSHAKE
    -- ==========================================================
    if trader then
        
        -- 1. Player Initiates Call (Delay 0 - Instant)
        local introMsg = dataProvider:getPlayerMessage("Intro", {})
        ui:queueMessage(introMsg, false, true, 0)

        -- 2. Trader Responds (Delay 60 - ~1 Second later)
        local greeting = dataProvider:getGreeting(trader)
        ui:queueMessage(greeting, false, false, 20)
    end

    DT_TradingWindow.instance = ui
end
-- ==========================================================
-- AUTO-REFRESH HANDLERS
-- ==========================================================

local function onInventoryChange()
    if DT_TradingWindow.instance and DT_TradingWindow.instance:getIsVisible() then
        -- Only flag for refresh if we are in SELLING mode
        if not DT_TradingWindow.instance.isBuying then
            DT_TradingWindow.instance.inventoryDirty = true
        end
    end
end

-- Trigger on any container update (pick up, drop, move)
Events.OnContainerUpdate.Add(onInventoryChange)

-- Trigger specifically when the inventory window refreshes (covers Favorite toggle)
Events.OnRefreshInventoryWindowContainers.Add(onInventoryChange)
