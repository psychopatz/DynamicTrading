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
    
    -- [NEW] Transmission Delay State
    -- Used to separate the Player Intro from the Trader Greeting
    self.greetingTimer = -1 
end

function DynamicTradingUI:resetIdleTimer()
    self.idleTimer = 0
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
    -- GREETING DELAY SYSTEM (Simulate Radio Lag)
    -- ==========================================================
    if self.greetingTimer > 0 then
        self.greetingTimer = self.greetingTimer - 1
        if self.greetingTimer == 0 then
            -- Trigger the Trader's Reply now
            if DynamicTrading.DialogueManager then
                local greeting = DynamicTrading.DialogueManager.GenerateGreeting(trader)
                self:logLocal(greeting, false, false) -- isPlayer = false
                
                -- SFX
                local player = getSpecificPlayer(0)
                if player then getSoundManager():PlaySound("DT_RadioClick", false, 0.5) end
            end
            self.greetingTimer = -1 -- Disable
        end
    end

    -- ==========================================================
    -- OBSERVER & IDLE SYSTEM
    -- ==========================================================
    -- We run logic checks every 30 frames (~0.5 seconds) to save CPU.
    self.updateTick = self.updateTick + 1
    if self.updateTick >= 30 then
        self.updateTick = 0
        
        -- A. SETUP CONTEXT
        local gt = GameTime:getInstance()
        local cm = ClimateManager:getInstance()
        local currentHour = gt:getHour()
        local isRaining = cm:getRainIntensity() > 0.4
        local isFoggy = cm:getFogIntensity() > 0.4
        local eventTriggered = false
        local ambientMsg = nil

        -- B. TIME OBSERVER (Triggers only when hour changes)
        if currentHour ~= self.lastHour then
            if currentHour == 5 then
                ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "Morning")
            elseif currentHour == 17 then
                ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "Evening")
            elseif currentHour == 21 then
                ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "Night")
            end
            self.lastHour = currentHour
        end

        -- C. WEATHER OBSERVER
        if not ambientMsg then 
            if isRaining ~= self.wasRaining then
                if isRaining then
                    ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "RainStart")
                else
                    ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "RainStop")
                end
                self.wasRaining = isRaining
            elseif isFoggy ~= self.wasFoggy then
                if isFoggy then
                    ambientMsg = DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, "FogStart")
                end
                self.wasFoggy = isFoggy
            end
        end

        -- D. EXECUTE AMBIENT EVENT
        -- Only fire ambient events if we aren't currently waiting for the initial greeting
        if ambientMsg and self.greetingTimer == -1 then
            self:logLocal(ambientMsg, false, false) 
            self:resetIdleTimer() 
            eventTriggered = true
            
            local player = getSpecificPlayer(0)
            if player then getSoundManager():PlaySound("DT_RadioClick", false, 0.5) end
        end

        -- E. IDLE LOGIC
        if not eventTriggered and self.greetingTimer == -1 then
            self.idleTimer = self.idleTimer + 30
            
            if self.idleTimer >= 3600 then
                if DynamicTrading.DialogueManager then
                    local idleMsg = DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
                    if idleMsg then
                        self:logLocal(idleMsg, false, false)
                        local player = getSpecificPlayer(0)
                        if player then getSoundManager():PlaySound("DT_RadioClick", false, 0.5) end
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
        
        -- 1. Player Initiates Call (Immediate)
        local introMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage("Intro", {})
        ui:logLocal(introMsg, false, true) -- isPlayer = true

        -- 2. Queue Trader Response (Delayed)
        -- We set the timer to 50 ticks (~0.8 seconds). 
        -- The update() loop handles firing the reply when this hits 0.
        ui.greetingTimer = 50 
        
        -- SFX (Initial click for player)
        local player = getSpecificPlayer(0)
        if player then getSoundManager():PlaySound("DT_RadioClick", false, 0.5) end
    end

    DynamicTradingUI.instance = ui
end