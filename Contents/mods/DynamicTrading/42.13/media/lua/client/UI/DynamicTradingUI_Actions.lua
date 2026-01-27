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

    -- BUYING PRE-CHECKS (Local)
    if self.isBuying then
        -- CHECK 1: SOLD OUT
        if d.qty <= 0 then
            diagArgs.success = false
            diagArgs.failReason = "SoldOut"
            
            -- 1. Player: "I'll take that..." (Immediate)
            local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage("Buy", diagArgs) 
            self:queueMessage(playerMsg, false, true, 0)
            
            -- 2. Trader: "It's gone." (~1s Delay)
            local failMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:queueMessage(failMsg, true, false, 10, "DT_RadioRandom")
            
            return
        end
        
        -- CHECK 2: INSUFFICIENT FUNDS
        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"
            
            -- 1. Player: "Can I get a discount?" (Immediate)
            -- The Manager detects 'NoCash' and switches to Haggling lines automatically
            local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage("Buy", diagArgs)
            self:queueMessage(playerMsg, false, true, 0)
            
            -- 2. Trader: "No cash, no deal." (~1s Delay)
            local failMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:queueMessage(failMsg, true, false, 10, "DT_RadioRandom")
            
            return
        end
    end

    -- =============================================================================
    -- SELLING PRE-CHECKS (Local)
    -- =============================================================================
    if not self.isBuying then
        -- 1. Check if it's a non-empty container
        if d.itemID and d.itemID ~= -1 then
            local invItem = nil
            -- Try to find the item in player inventory
            if player then
                local playerInv = player:getInventory()
                -- Warning: getItems() returns an ArrayList, finding by ID is O(N) but necessary unless we trust the object reference persists
                -- We can try to assume d.item or re-fetch. 
                -- Ideally we should iterate to be safe or use object reference if available.
                -- However, for the UI loop we relied on population. Let's iterate briefly or trust we can use the object if we had it.
                -- 'd' in this context is the list item data table, NOT the InventoryItem object directly.
                -- But wait, inside populateList we stored 'itemID'.
                
                -- Let's do a quick scan or use a helper if available. 
                -- Simple scan:
                -- [B42 ROBUST] Recursive search through all carried containers
                local function findItemRecursive(container)
                    local items = container:getItems()
                    for i = 0, items:size() - 1 do
                        local it = items:get(i)
                        if it:getID() == d.itemID then
                            return it
                        end
                        if instanceof(it, "InventoryContainer") then
                            local sub = it:getItemContainer()
                            if sub then
                                local found = findItemRecursive(sub)
                                if found then return found end
                            end
                        end
                    end
                    return nil
                end
                invItem = findItemRecursive(playerInv)
            end
            
            if invItem and instanceof(invItem, "InventoryContainer") then
                local container = invItem:getItemContainer()
                if container and container:getItems() and not container:getItems():isEmpty() then
                    -- IT IS POPULATED!
                    -- Show Modal Interception
                    if DT_SellConfirmationModal then
                        DT_SellConfirmationModal.Show(invItem, self, self.onConfirmSell, d, self.onUnpackContainer)
                        return -- HALT execution here.
                    end
                end
            end
        end

        -- [NEW] TRADER BUDGET CHECK
        if trader and trader.budget and trader.budget < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"
            
            -- 1. Player dialogue
            local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage("Sell", diagArgs)
            self:queueMessage(playerMsg, false, true, 0)
            
            -- 2. Trader response
            local failMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, false, diagArgs)
            self:queueMessage(failMsg, true, false, 10, "DT_RadioRandom")
            
            return
        end
    end

    -- CONSTRUCT ARGUMENTS (If checks pass, send to server)
    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = d.data.tags[1] or "Misc",
        qty = 1,
        itemID = d.itemID or -1 -- Unique ID for secure selling
    }

    -- 1. Prompt Player Dialogue (Restore intended interaction)
    local pAction = self.isBuying and "Buy" or "Sell"
    local pMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage(pAction, diagArgs)
    self:queueMessage(pMsg, false, true, 0)

    -- 2. EXECUTE
    sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
end

function DynamicTradingUI:onConfirmSell(invItem, data)
    -- Callback from Modal
    if not data then return end
    
    local player = getSpecificPlayer(0)
    local args = {
        type = "sell",
        traderID = self.traderID,
        key = data.key,
        category = data.data and data.data.tags[1] or "Misc",
        qty = 1,
        itemID = data.itemID or -1,
        price = data.price -- For dialogue generator
    }
    
    -- 1. Prompt Player Dialogue (Restore intended interaction)
    local pMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage("Sell", {
        itemName = invItem:getDisplayName(),
        price = args.price or 0
    })
    self:queueMessage(pMsg, false, true, 0)

    -- 2. EXECUTE
    sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
end

function DynamicTradingUI:onUnpackContainer(invItem)
    if not invItem then return end
    
    local player = getSpecificPlayer(0)
    local args = {
        itemID = invItem:getID()
    }
    
    sendClientCommand(player, "DynamicTrading", "UnpackContainer", args)
end

-- =============================================================================
-- 2. LOCK/UNLOCK ACTION
-- =============================================================================
function DynamicTradingUI:onToggleLock()
    if not self.selectedItemID or self.selectedItemID == -1 then return end
    
    local player = getSpecificPlayer(0)
    local modData = player:getModData()
    
    -- Initialize the lock table if it doesn't exist
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
    
    -- Refresh the list
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
    
    if self.isBuying then
        -- Buying Mode: Show Ask Favor
        if self.btnAsk then 
            self.btnAsk:setTitle("Talk")
            self.btnAsk:setVisible(true) 
            self.btnAsk:setEnable(true)
        end
        if self.btnLock then self.btnLock:setVisible(false) end
    else
        -- Selling Mode: Show Lock & Ask What They Want
        if self.btnLock then self.btnLock:setVisible(true) end
        if self.btnAsk then
            self.btnAsk:setTitle("ASK WHAT THEY WANT")
            self.btnAsk:setVisible(true)
            self.btnAsk:setEnable(true)
        end
    end
    
    self:populateList()
    self.btnAction:setEnable(false)
end

function DynamicTradingUI:onAsk()
    -- Reset activity timer
    if self.resetIdleTimer then self:resetIdleTimer() end

    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    if not trader or not DynamicTrading.DialogueManager then return end

    if self.isBuying then
        -- [NEW] HUB FLOW
        require "UI/DT_TraderDialogue_Hub"
        DT_TraderDialogue_Hub.Init(nil, trader, self)
    else
        -- ORIGINAL SELL ASK FLOW
        -- 1. Player ask
        local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerSellAskMessage()
        self:queueMessage(playerMsg, false, true, 0)
    
        -- 2. NPC reply
        local npcMsg = DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
        self:queueMessage(npcMsg, false, false, 30) 
    end
end

function DynamicTradingUI:close()
    -- [NEW] Close child conversation window if open
    if DT_ConversationUI and DT_ConversationUI.instance then
        if DT_ConversationUI.instance.parentUI == self then
            DT_ConversationUI.instance:close()
        end
    end

    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end