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
    if not item or not item.item then return end
    
    -- Use UI instance for correct 'self' scope in callback functions
    local ui = DT_TradingWindow.instance
    if not ui then return end

    -- Create Context Menu
    local context = ISContextMenu.get(0, self:getAbsoluteX() + x, self:getAbsoluteY() + y)
    
    -- Option: Trace Price
    context:addOption("[DEBUG] Trace Price Calculation", ui, DT_TradingWindow.DebugTracePrice, d)
    
    -- Option: Dump Rejections (Only available in Sell mode/tab)
    if not ui.isBuying then
        context:addOption("[DEBUG] Dump Scan Rejections", ui, DT_TradingWindow.DebugDumpRejections)
    end
end

function DT_TradingWindow:DebugTracePrice(listItem)
    if not listItem then return end
    
    print("========================================================")
    print(" DT DEBUG TRACE: " .. tostring(listItem.name))
    print("========================================================")
    
    local ui = DT_TradingWindow.instance
    if not ui or not ui.dataProvider then 
        print("[DT ERROR] UI or DataProvider missing")
        return 
    end
    
    local trader = ui.dataProvider:getTrader(ui.traderID, ui.archetype)
    
    if listItem.isBuy then
        -- Buy Price Trace
        ui.dataProvider:getBuyPrice(listItem.key, listItem.customData, true) -- true = verbose
    else
        -- Sell Price Trace
        -- We need the invItem
        local invItem = listItem.invItem
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
            ui.dataProvider:getSellPrice(invItem, listItem.key, trader, true) -- true = verbose
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
