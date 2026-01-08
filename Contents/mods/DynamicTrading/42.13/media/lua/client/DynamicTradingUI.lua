-- =============================================================================
-- File: Contents\mods\DynamicTrading\42.13\media\lua\client\UI\DynamicTradingUI.lua
-- =============================================================================

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
require "DynamicTrading/UI/DynamicTradingUI_Icons"
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
    
    -- [NEW] Idle Timer (Ticks up every frame)
    self.idleTimer = 0
end

function DynamicTradingUI:resetIdleTimer()
    self.idleTimer = 0
end

function DynamicTradingUI:update()
    ISCollapsableWindow.update(self)

    -- Crash shield for listbox
    if self.listbox then
        if self.listbox.items == nil then self.listbox.items = {} end
        if type(self.listbox.selected) ~= "number" then self.listbox.selected = -1 end
    end

    if not self.traderID then self:close() return end

    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders and data.Traders[self.traderID]
    if not trader then
        self:logLocal("Signal Lost: Trader signed off.", true)
        self:close()
        return
    end

    self:updateIdentityDisplay(trader)
    self:updateWallet()

    if not self:isConnectionValid() then
        self:close()
        return
    end

    -- [NEW] Idle Logic
    -- 60 ticks roughly equals 1 second. 3600 ticks = 1 minute.
    self.idleTimer = self.idleTimer + 1
    
    if self.idleTimer >= 3600 then
        -- Trigger Idle Message
        if DynamicTrading.DialogueManager then
            local idleMsg = DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
            if idleMsg then
                self:logLocal(idleMsg, false)
            end
        end
        
        -- Reset to prevent spamming (wait another minute)
        self.idleTimer = 0
    end
end

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

    -- Ensure trader data exists/is loaded
    local trader = DynamicTrading.Manager.GetTrader(traderID, archetype)

    ui:populateList()
    
    -- Trigger Initial Greeting
    if trader and DynamicTrading.DialogueManager then
        local greeting = DynamicTrading.DialogueManager.GenerateGreeting(trader)
        ui:logLocal(greeting, false)
    end

    DynamicTradingUI.instance = ui
end