-- =============================================================================
-- File: media/lua/client/UI/DynamicTradingUI_Actions.lua
-- =============================================================================

require "DT_DialogueManager"

function DynamicTradingUI:onAction()
    -- 1. ACTIVITY RESET
    -- Reset the idle timer so the trader doesn't complain about you being quiet.
    if self.resetIdleTimer then self:resetIdleTimer() end

    -- 2. SELECTION VALIDATION
    if not self.listbox or self.listbox.selected == -1 then return end
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end

    local d = selItem.item
    local player = getSpecificPlayer(0)
    
    -- Fetch trader for potential local error messages (Dialogue)
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    
    local diagArgs = {
        itemName = d.name,
        price = d.price,
        basePrice = d.data and d.data.basePrice or d.price
    }

    -- 3. BUYING PRE-CHECKS
    if self.isBuying then
        -- Check Stock levels
        if d.qty <= 0 then
            diagArgs.success = false
            diagArgs.failReason = "SoldOut"
            local msg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:logLocal(msg, true) 
            return
        end
        
        -- Check Player Wealth
        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"
            local msg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:logLocal(msg, true)
            return
        end
    end

    -- 4. CONSTRUCT TRANSACTION ARGUMENTS
    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = d.data.tags[1] or "Misc",
        qty = 1,
        -- [CRITICAL FIX] We now pass the Unique Item ID for selling.
        -- This ensures the server sells the EXACT physical item selected in the list.
        itemID = d.itemID or -1 
    }

    -- 5. EXECUTE COMMAND
    -- We send the request to the server. 
    -- Feedback (Logs/Sounds/Refreshes) is handled by DynamicTradingUI_Events.lua 
    -- once the server confirms the trade was successful.
    sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
end

function DynamicTradingUI:onToggleMode()
    -- Reset activity timer
    if self.resetIdleTimer then self:resetIdleTimer() end

    self.isBuying = not self.isBuying
    self.selectedKey = nil
    self.lastSelectedIndex = -1
    
    -- Refresh the list (Filters out active radio if switching to Sell)
    self:populateList()
    
    self.btnAction:setEnable(false)
end

function DynamicTradingUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end