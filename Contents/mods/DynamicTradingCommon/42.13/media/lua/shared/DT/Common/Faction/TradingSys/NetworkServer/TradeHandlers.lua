-- ==============================================================================
-- NetworkServer/TradeHandlers.lua
-- Logic: Buy/Sell trade transaction handlers
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/Faction/TradingSys/DynamicTrading_Economy"
require "DT/Common/Config"
require "DT/Common/ServerHelpers/ServerHelpers"

local DataHandlers = require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers"

local TradeHandlers = {}
local Handlers = {}

local function findSellItem(inv, itemID)
    if not inv or not itemID then
        return nil
    end

    local itemObj = inv:getItemById(itemID)
    if itemObj then
        return itemObj
    end

    return DynamicTrading.ServerHelpers.FindItemByIDRecursive(inv, itemID)
end

local function resolveSellItems(inv, args, traderID, key, requestedQty)
    local ids = args.itemIDs
    local items = {}
    local seenIDs = {}
    local firstPrice = nil
    local firstBasePrice = nil
    local firstFullType = nil

    if requestedQty <= 1 then
        local singleItem = findSellItem(inv, args.itemID)
        if not singleItem then
            return nil, "Item missing!"
        end

        items[1] = singleItem
        firstPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, singleItem, key)
        firstBasePrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, singleItem, key, false, true)
        return items, firstPrice, firstBasePrice
    end

    if type(ids) ~= "table" or #ids < requestedQty then
        return nil, "Items missing!"
    end

    for i = 1, requestedQty do
        local itemID = tonumber(ids[i])
        if not itemID or seenIDs[itemID] then
            return nil, "Invalid item selection"
        end

        local itemObj = findSellItem(inv, itemID)
        if not itemObj then
            return nil, "Items missing!"
        end

        local unitPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, itemObj, key)
        local baseUnitPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, itemObj, key, false, true)

        if i == 1 then
            firstPrice = unitPrice
            firstBasePrice = baseUnitPrice
            firstFullType = itemObj:getFullType()
        elseif itemObj:getFullType() ~= firstFullType or unitPrice ~= firstPrice or baseUnitPrice ~= firstBasePrice then
            return nil, "Items no longer match"
        end

        seenIDs[itemID] = true
        items[#items + 1] = itemObj
    end

    return items, firstPrice, firstBasePrice
end

-- =============================================================================
-- TRADE TRANSACTION - BUY/SELL
-- =============================================================================
Handlers.TradeTransaction = function(player, args)
    local DEBUG_PREFIX = "[DT-V2-Trade]"
    DynamicTrading.Log("DTCommons", "Trade", "Logic", "TradeTransaction received")
    DynamicTrading.Log("DTCommons", "Trade", "Logic", "Type: " .. tostring(args.type) .. ", TraderID: " .. tostring(args.traderID))
    
    local txType = args.type
    local traderID = args.traderID
    local key = args.key
    local clientQty = tonumber(args.qty) or 1
    
    -- Get stock and item data
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    if not stockData then
        DynamicTrading.Log("DTCommons", "Trade", "Logic", "ERROR: No stock data for trader")
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Trader unavailable" })
        return
    end
    
    local itemData = DynamicTrading.Config.MasterList[key]
    if not itemData then
        DynamicTrading.Log("DTCommons", "Trade", "Logic", "ERROR: Item not in MasterList: " .. tostring(key))
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Item not found" })
        return
    end
    
    local inv = player:getInventory()
    local scriptItem = getScriptManager():getItem(itemData.item)
    local safeDisplayName = scriptItem and scriptItem:getDisplayName() or "Unknown Item"
    
    -- Get faction data for wealth
    -- V2 souls use GetSoulRegistry, V1 physical traders use GetTrader
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderID) or DynamicTrading_Roster.GetTrader(traderID)
    local factionID = soul and soul.factionID or nil
    local factionData = factionID and DynamicTrading_Factions.GetFaction(factionID) or nil
    DynamicTrading.Log("DTCommons", "Trade", "Logic", "FactionID: " .. tostring(factionID) .. ", Faction wealth: $" .. tostring(factionData and factionData.wealth or 0))
    
    if txType == "buy" then
        -- 1. Get price from stock
        local itemStock = stockData.items[key]
        if not itemStock then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not in stock" })
            return
        end
        
        local currentQty = type(itemStock) == "table" and itemStock.qty or itemStock
        local customData = type(itemStock) == "table" and itemStock.customData or nil
        
        local buyPreview = DynamicTrading.Economy.V2.GetBulkBuyPreview(traderID, key, customData, clientQty)
        local unitPrice = buyPreview.lastUnitPrice or DynamicTrading.Economy.V2.GetBuyPrice(traderID, key, customData)
        local totalCost = buyPreview.totalPrice or (unitPrice * clientQty)
        
        -- Get Base Price (Pre-event) for Dialogue markup checks
        local baseUnitPrice = DynamicTrading.Economy.V2.GetBuyPrice(traderID, key, customData, false, true)
        local totalBaseCost = buyPreview.totalBasePrice or (baseUnitPrice * clientQty)
        
        DynamicTrading.Log("DTCommons", "Trade", "Logic", "Buy: " .. key .. " x" .. clientQty .. " @ $" .. unitPrice .. " (Base: $" .. baseUnitPrice .. ")")
        
        -- 2. Check Stock
        if currentQty < clientQty then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Sold Out!" })
            return
        end
        
        -- 3. Check Player Wealth
        local playerWealth = DynamicTrading.ServerHelpers.GetWealth(player)
        if playerWealth < totalCost then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not enough cash!" })
            return
        end
        
        -- 4. Execute Trade
        if DynamicTrading.ServerHelpers.RemoveMoney(player, totalCost) then
            -- Decrease stock
            if type(itemStock) == "table" then
                itemStock.qty = itemStock.qty - clientQty
            else
                stockData.items[key] = currentQty - clientQty
            end
            
            -- Add money to faction
            if factionData then
                DynamicTrading_Factions.ModifyWealth(factionID, totalCost)
            end
            
            -- Add item to player (with custom condition support)
            local itemStockData = (type(itemStock) == "table") and itemStock or {}
            local customData = itemStockData.customData
            
            DynamicTrading.ServerHelpers.AddItemWithCondition(inv, itemData.item, clientQty, customData)
            
            -- Sync stock
            ModData.transmit("DynamicTrading_Stock")
            
            -- [NEW] HEAT / INFLATION (Supply & Demand)
            local category = itemData.tags[1] or "Misc"
            local sensitivity = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryInflation) or 0.05
            local change = sensitivity * clientQty
            DynamicTrading_Engine.UpdateHeat(category, change)
            
            DynamicTrading.Log("DTCommons", "Trade", "Logic", "Buy Inflation: Category=[" .. tostring(category) .. "] | Adding Heat: " .. tostring(change))
            DynamicTrading.Log("DTCommons", "Trade", "Logic", "SUCCESS: Bought " .. safeDisplayName)
            
            -- Send updated stock to client cache (fixes UI not refreshing)
            DataHandlers.SendSyncStockToPlayer(player, traderID)
            
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { 
                success = true, 
                itemName = safeDisplayName,
                price = totalCost,
                basePrice = totalBaseCost,
                isBuy = true
            })
        else
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Transaction Error" })
        end
        
    elseif txType == "sell" then
        -- 1. Locate and validate all selected items
        local sellItems, unitPrice, baseUnitPrice = resolveSellItems(inv, args, traderID, key, clientQty)
        if not sellItems or #sellItems ~= clientQty then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg=unitPrice or "Item missing!" })
            return
        end
        
        -- 2. Calculate sell price
        local totalGain = unitPrice * clientQty
        
        -- Get Base Price (Pre-event)
        local totalBaseGain = baseUnitPrice * clientQty

        DynamicTrading.Log("DTCommons", "Trade", "Logic", "Sell: " .. key .. " @ $" .. totalGain .. " (Base: $" .. totalBaseGain .. ")")
        
        -- 3. Check faction can afford
        local factionWealth = factionData and factionData.wealth or 999999
        if factionWealth < totalGain then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Trader cannot afford this!" })
            return
        end
        
        -- 4. Unequip if necessary
        for _, itemObj in ipairs(sellItems) do
            if player:getPrimaryHandItem() == itemObj then
                player:setPrimaryHandItem(nil)
            end
            if player:getSecondaryHandItem() == itemObj then
                player:setSecondaryHandItem(nil)
            end
        end
        
        -- 5. Execute Trade
        for _, itemObj in ipairs(sellItems) do
            DynamicTrading.ServerHelpers.RemoveItem(itemObj)
        end
        
        -- Add money to player
        local bundles = math.floor(totalGain / 100)
        local loose = totalGain % 100
        if bundles > 0 then DynamicTrading.ServerHelpers.AddItem(inv, "Base.MoneyBundle", bundles) end
        if loose > 0 then DynamicTrading.ServerHelpers.AddItem(inv, "Base.Money", loose) end
        
        -- Deduct from faction wealth
        if factionData then
            DynamicTrading_Factions.ModifyWealth(factionID, -totalGain)
        end
        
        -- Update deflation (if tracked)
        if not stockData.deflation then stockData.deflation = {} end
        stockData.deflation[key] = (stockData.deflation[key] or 0) + clientQty
        
        -- Sync stock
        ModData.transmit("DynamicTrading_Stock")
        
        -- [NEW] HEAT / DEFLATION (Supply & Demand)
        local category = itemData.tags[1] or "Misc"
        local engineData = DynamicTrading_Engine.GetEngineData()
        
        -- V1 Logic: Global Deflation (Configurable Roll, Once per item kind per day)
        -- FIXED: Ensure engineData exists before checking table
        if engineData and engineData.WorldEconomy then
             if not engineData.WorldEconomy.DeflatedGlobal then engineData.WorldEconomy.DeflatedGlobal = {} end

            -- Bypass "Once per day" lock for now if debug is on, or just rely on chance
            -- Actually, let's keep the lock but Log it clearly
            if not engineData.WorldEconomy.DeflatedGlobal[key] then
                local chance = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.SellDeflationChance) or 30
                local roll = ZombRand(chance) + 1
                
                if roll == 1 then
                    local sensitivity = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryDeflation) or 0.02
                    -- Invert heat (Selling reduces inflation/heat)
                    DynamicTrading_Engine.UpdateHeat(category, -(sensitivity * clientQty))
                    engineData.WorldEconomy.DeflatedGlobal[key] = true
                    DynamicTrading.Log("DTCommons", "Trade", "Logic", "GLOBAL DEFLATION triggered for category: " .. tostring(category) .. " ( - " .. tostring(sensitivity * clientQty) .. ")")
                else
                    DynamicTrading.Log("DTCommons", "Trade", "Logic", "Deflation Roll Failed: " .. roll .. "/" .. chance)
                end
            else
                DynamicTrading.Log("DTCommons", "Trade", "Logic", "Deflation Skipped: Already deflated this item type today.")
            end
        end
        
        local soldItemName = sellItems[1] and sellItems[1]:getDisplayName() or safeDisplayName
        if clientQty > 1 then
            soldItemName = soldItemName .. " x" .. tostring(clientQty)
        end

        DynamicTrading.Log("DTCommons", "Trade", "Logic", "SUCCESS: Sold " .. soldItemName)
        
        -- Send updated stock to client cache (fixes UI not refreshing)
        DataHandlers.SendSyncStockToPlayer(player, traderID)
        
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { 
            success = true, 
            itemName = soldItemName,
            price = totalGain,
            basePrice = totalBaseGain,
            isBuy = false,
            qty = clientQty
        })
    end
end

TradeHandlers.Handlers = Handlers
return TradeHandlers
