function DynamicTradingUI:onAction()
    if not self.listbox or self.listbox.selected == -1 then return end
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end

    local d = selItem.item
    local player = getSpecificPlayer(0)

    if self.isBuying then
        if d.qty <= 0 then
            self:logLocal("Error: Item is sold out.", true)
            return
        end
        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            self:logLocal("Error: Not enough cash. Need $" .. d.price, true)
            return
        end
    end

    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = d.data.tags[1] or "Misc",
        qty = 1
    }

    if getWorld():getGameMode() == "Multiplayer" then
        sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
    else
        if DynamicTrading.ServerCommands and DynamicTrading.ServerCommands.TradeTransaction then
            DynamicTrading.ServerCommands.TradeTransaction(player, args)
            self:populateList()
            player:playSound("Transaction")

            if self.isBuying then
                self:logLocal("Purchased: " .. d.name .. " (-$" .. d.price .. ")", false)
            else
                self:logLocal("Sold: " .. d.name .. " (+$" .. d.price .. ")", false)
            end
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