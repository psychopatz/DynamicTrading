require "DT_DialogueManager"

-- =============================================================================
-- 1. TRANSACTION ACTION (BUY/SELL)
-- =============================================================================
function DynamicTradingUI:onAction()
    -- Reset activity timer
    if self.resetIdleTimer then self:resetIdleTimer() end

    -- Selection validation
    if not self.listbox or self.listbox.selected == -1 then return end
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end

    local d = selItem.item
    local player = getSpecificPlayer(0)
    
    -- Fetch trader for potential local error messages
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    
    local diagArgs = {
        itemName = d.name,
        price = d.price,
        basePrice = d.data and d.data.basePrice or d.price
    }

    -- BUYING PRE-CHECKS
    if self.isBuying then
        if d.qty <= 0 then
            diagArgs.success = false
            diagArgs.failReason = "SoldOut"
            local msg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:logLocal(msg, true) 
            return
        end
        
        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"
            local msg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:logLocal(msg, true)
            return
        end
    end

    -- CONSTRUCT ARGUMENTS
    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = d.data.tags[1] or "Misc",
        qty = 1,
        itemID = d.itemID or -1 -- Unique ID for secure selling
    }

    -- EXECUTE
    sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
end

-- =============================================================================
-- 2. LOCK/UNLOCK ACTION (NEW)
-- =============================================================================
function DynamicTradingUI:onToggleLock()
    if not self.selectedItemID or self.selectedItemID == -1 then return end
    
    local player = getSpecificPlayer(0)
    local modData = player:getModData()
    
    -- Initialize the lock table if it doesn't exist in the save file
    if not modData.DT_LockedItems then
        modData.DT_LockedItems = {}
    end
    
    -- TOGGLE LOGIC
    if modData.DT_LockedItems[self.selectedItemID] then
        -- It was locked, now unlock it
        modData.DT_LockedItems[self.selectedItemID] = nil
        player:setHaloNote("Item Unlocked", 200, 200, 200, 300)
        player:playSound("UnlockDoor")
    else
        -- It was open, now lock it
        modData.DT_LockedItems[self.selectedItemID] = true
        player:setHaloNote("Item Locked (Protected)", 255, 255, 100, 300)
        player:playSound("LockDoor")
    end
    
    -- Refresh the list. 
    -- If locked, it will disappear from the 'Sell' list immediately.
    self:populateList()
end

-- =============================================================================
-- 3. INTERFACE CONTROLS
-- =============================================================================
function DynamicTradingUI:onToggleMode()
    if self.resetIdleTimer then self:resetIdleTimer() end

    self.isBuying = not self.isBuying
    self.selectedKey = nil
    self.selectedItemID = -1
    self.lastSelectedIndex = -1
    
    -- Update Button Visibilities
    if self.btnLock then
        self.btnLock:setVisible(not self.isBuying)
    end
    
    self:populateList()
    self.btnAction:setEnable(false)
end

function DynamicTradingUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end