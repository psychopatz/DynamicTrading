require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISImage"

require "DynamicTrading_Config"
require "DynamicTrading_Manager"
require "DynamicTrading_Economy"
require "DynamicTrading_Events"
require "DT_DialogueManager" 

-- UI sub-modules
require "DynamicTrading/UI/DynamicTradingUI_Helpers"
require "DynamicTrading/UI/DynamicTradingUI_Layout"
require "DynamicTrading/UI/DynamicTradingUI_List"
require "DynamicTrading/UI/DynamicTradingUI_Actions"
require "DynamicTrading/UI/DynamicTradingUI_Events"

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
    self.isBuying = true
    self.selectedKey = nil
    self.radioObj = nil
    self.collapsed = {}
    self.lastSelectedIndex = -1
    self.localLogs = {}
    
    -- ==========================================================
    -- LOGIC STATE TRACKERS
    -- ==========================================================
    -- Idle Timer (Ticks up every frame)
    self.idleTimer = 0
    
    -- Performance Throttling
    self.updateTick = 0 
    
    -- Observer State
    self.lastHour = -1
    self.wasRaining = false
    self.wasFoggy = false
    
    -- [NEW] MESSAGE QUEUE SYSTEM
    -- Stores pending messages to simulate conversation flow
    -- Structure: { text="", isError=false, isPlayer=false, delay=0, sound=nil }
    self.msgQueue = {}
end

function DynamicTradingUI:resetIdleTimer()
    self.idleTimer = 0
end

-- ==========================================================
-- [NEW] QUEUE HELPER
-- ==========================================================
function DynamicTradingUI:queueMessage(text, isError, isPlayer, delay, soundName)
    table.insert(self.msgQueue, {
        text = text,
        isError = isError or false,
        isPlayer = isPlayer or false,
        delay = delay or 0,
        sound = soundName
    })
end

-- =============================================================================
-- MAIN UPDATE LOOP
-- =============================================================================
function DynamicTradingUI:update()
    ISCollapsableWindow.update(self)

    -- 1. Crash Shield for Listbox
    if self.listbox then
        if self.listbox.items == nil then self.listbox.items = {} end
        if type(self.listbox.selected) ~= "number" then self.listbox.selected = -1 end
    end

    -- 2. Validate Trader Existence
    if not self.traderID then self:close() return end
    
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders and data.Traders[self.traderID]
    
    if not trader then
        self:logLocal("Signal Lost: Trader signed off.", true)
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
            local player = getSpecificPlayer(0)
            if player then
                -- Play specific sound if provided (e.g., cash register)
                if msg.sound then
                     getSoundManager():PlaySound(msg.sound, false, 1.0)
                -- Otherwise play default radio click
                else
                     getSoundManager():PlaySound("DT_RadioRandom", false, 0.1)
                end
            end
            
            -- Remove from queue and reset idle
            table.remove(self.msgQueue, 1)
            self:resetIdleTimer()
        end
    end

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
            if currentHour == 5 then ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "Morning")
            elseif currentHour == 17 then ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "Evening")
            elseif currentHour == 21 then ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "Night")
            end
            self.lastHour = currentHour
        end

        -- C. WEATHER OBSERVER
        if not ambientMsg then 
            if isRaining ~= self.wasRaining then
                ambientMsg = isRaining and DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "RainStart") or DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "RainStop")
                self.wasRaining = isRaining
            elseif isFoggy ~= self.wasFoggy then
                ambientMsg = isFoggy and DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "FogStart")
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
                if DynamicTrading.DialogueManager then
                    local idleMsg = DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
                    if idleMsg then
                        self:queueMessage(idleMsg, false, false, 0)
                    end
                end
                self.idleTimer = 0
            end
        end
    end
end

-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================
function DynamicTradingUI.ToggleWindow(traderID, archetype, radioObj)
    if DynamicTradingUI.instance then
        DynamicTradingUI.instance:close()
        return
    end

    local ui = DynamicTradingUI:new(100, 100, 750, 600)
    ui:initialise()
    ui:addToUIManager()
    ui.traderID = traderID
    ui.archetype = archetype or "General"
    ui.radioObj = radioObj

    local trader = DynamicTrading.Manager.GetTrader(traderID, archetype)
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
    if trader and DynamicTrading.DialogueManager then
        
        -- 1. Player Initiates Call (Delay 0 - Instant)
        local introMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage("Intro", {})
        ui:queueMessage(introMsg, false, true, 0)

        -- 2. Trader Responds (Delay 60 - ~1 Second later)
        local greeting = DynamicTrading.DialogueManager.GenerateGreeting(trader)
        ui:queueMessage(greeting, false, false, 20)
    end

    DynamicTradingUI.instance = ui
end