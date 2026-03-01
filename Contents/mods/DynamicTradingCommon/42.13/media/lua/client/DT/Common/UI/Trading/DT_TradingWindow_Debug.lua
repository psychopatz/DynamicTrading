-- =============================================================================
-- DT_TradingWindow_Debug: Context Menu & Debug Tools
-- =============================================================================
-- Separated logic for debugging trading items via UI Context Menu.

require "DT/Common/UI/Trading/DT_TradingWindow"

function DT_TradingWindow:onListRightMouseUp(x, y)
    if not isDebugEnabled() then return end

    local row = self:rowAt(x, y)
    if row == -1 then return end

    local item = self.items[row]
    if not item or not item.item or item.item.isCategory then return end
    
    -- Use UI instance for correct 'self' scope in callback functions
    local ui = DT_TradingWindow.instance
    if not ui then return end

    -- Create Context Menu
    local context = ISContextMenu.get(0, self:getAbsoluteX() + x, self:getAbsoluteY() + y)
    
    -- Option: Trace Price
    context:addOption("[DEBUG] Trace Price Calculation", ui, DT_TradingWindow.DebugTracePrice, item)
    
    -- Option: Dump Rejections (Only available in Sell mode/tab)
    if not ui.isBuying then
        context:addOption("[DEBUG] Dump Scan Rejections", ui, DT_TradingWindow.DebugDumpRejections)
    end
end

function DT_TradingWindow:DebugTracePrice(listItem)
    if not listItem then return end
    
    local ui = DT_TradingWindow.instance
    if not ui or not ui.dataProvider then 
        print("[DT ERROR] UI or DataProvider missing")
        return 
    end
    
    print(" DT DEBUG TRACE: " .. tostring(listItem.text or "Unknown"))
    print("========================================================")

    local trader = ui.dataProvider:getTrader(ui.traderID, ui.archetype)
    local d = listItem.item
    if not d then 
        print("[DT ERROR] List item data missing")
        return 
    end

    -- 1. Check Events First for the User
    if DynamicTrading.Events and DynamicTrading.Events.ActiveEvents then
        print("[DT DEBUG] ACTIVE GLOBAL EVENTS: " .. #DynamicTrading.Events.ActiveEvents)
        for _, e in ipairs(DynamicTrading.Events.ActiveEvents) do
            print("  > " .. tostring(e.id))
        end
    end
    if trader and trader.ActiveFlashEvent and trader.ActiveFlashEvent.id then
         print("[DT DEBUG] ACTIVE FACTION EVENT: " .. tostring(trader.ActiveFlashEvent.id))
    end

    if d.isBuy then
        -- Buy Price Trace
        ui.dataProvider:getBuyPrice(d.key, d.customData, true) -- true = verbose
    else
        -- Sell Price Trace
        -- We need the invItem
        local invItem = d.invItem
        if not invItem then
             -- Try to find it again if for some reason it's missing (though it shouldn't be with the new cache)
             if listItem.itemID then
                 local player = getSpecificPlayer(0)
                 local items = player:getInventory():getItems()
                 for i=0, items:size()-1 do
                     if items:get(i):getID() == listItem.itemID then
                         invItem = items:get(i)
                         break
                     end
                 end
             end
        end
        
        if invItem then
            ui.dataProvider:getSellPrice(invItem, d.key, trader, true) -- true = verbose
        else
            print("[DT ERROR] Inventory Item Object not found for trace.")
        end
    end
    
    print("========================================================")
end
function DT_TradingWindow:DebugDumpRejections()
    print("========================================================")
    print(" DT DEBUG: SCAN REJECTIONS DUMP")
    print("========================================================")
    
    if not self.scanRejections or #self.scanRejections == 0 then
        print(" No rejections found in last scan.")
    else
        for i, msg in ipairs(self.scanRejections) do
            print(string.format("[%d] %s", i, msg))
        end
    end
    
    print("========================================================")
end
