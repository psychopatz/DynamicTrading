-- =============================================================================
-- File: Contents\mods\DynamicTrading\42.13\media\lua\client\UI\DynamicTradingUI_Actions.lua
-- =============================================================================

require "DT_DialogueManager"

function DynamicTradingUI:onAction()
    if not self.listbox or self.listbox.selected == -1 then return end
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end

    local d = selItem.item
    local player = getSpecificPlayer(0)
    
    -- 1. FETCH TRADER CONTEXT
    -- We need the trader object to know their Archetype (Sheriff, Smuggler, etc.)
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    
    -- Prepare arguments for the Dialogue Engine
    local diagArgs = {
        itemName = d.name,
        price = d.price,
        basePrice = d.data and d.data.basePrice or d.price
    }

    -- 2. VALIDATION CHECKS (Buying)
    if self.isBuying then
        -- Check Stock
        if d.qty <= 0 then
            diagArgs.success = false
            diagArgs.failReason = "SoldOut"
            
            local msg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:logLocal(msg, true) -- Red text
            return
        end
        
        -- Check Wealth
        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"
            
            local msg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            self:logLocal(msg, true) -- Red text
            return
        end
    end

    -- 3. PREPARE TRANSACTION
    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = d.data.tags[1] or "Misc",
        qty = 1
    }

    -- 4. EXECUTE
    if getWorld():getGameMode() == "Multiplayer" then
        -- In MP, we send the command. 
        -- The "Success" dialogue happens in DynamicTradingUI_Events.lua upon receiving the Server Callback.
        sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
    else
        -- In SP, we execute immediately and log the dialogue here.
        if DynamicTrading.ServerCommands and DynamicTrading.ServerCommands.TradeTransaction then
            DynamicTrading.ServerCommands.TradeTransaction(player, args)
            self:populateList()
            player:playSound("Transaction")

            -- Generate Success Message
            diagArgs.success = true
            local msg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, self.isBuying, diagArgs)
            
            -- Log with standard colors (Green/Blue handled by drawLogItem based on "Purchased/Sold" keywords? 
            -- Actually, since the text is dynamic now, drawLogItem might need to just check 'isError'.
            -- But for now, we pass false for isError).
            self:logLocal(msg, false) 
        end
    end
end

function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    self.selectedKey = nil
    self.lastSelectedIndex = -1
    self:populateList()
    self.btnAction:setEnable(false)
end

function DynamicTradingUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end