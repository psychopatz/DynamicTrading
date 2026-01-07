require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISImage"

require "DynamicTrading_Config"
require "DynamicTrading_Manager"
require "DynamicTrading_Economy"
require "DynamicTrading_Events"

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

    DynamicTrading.Manager.GetTrader(traderID, archetype)

    ui:populateList()
    DynamicTradingUI.instance = ui
end