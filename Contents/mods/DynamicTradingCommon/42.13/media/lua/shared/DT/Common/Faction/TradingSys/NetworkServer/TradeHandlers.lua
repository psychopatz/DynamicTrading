-- ==============================================================================
-- NetworkServer/TradeHandlers.lua
-- Logic: Buy/Sell trade transaction handlers
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/Faction/TradingSys/DynamicTrading_Economy"
require "DT/Common/Config"
require "DT/Common/ServerHelpers"

local DataHandlers = require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers"

local TradeHandlers = {}
local Handlers = {}

-- =============================================================================
-- TRADE TRANSACTION - BUY/SELL
-- =============================================================================
Handlers.TradeTransaction = function(player, args)
    local DEBUG_PREFIX = "[DT-V2-Trade]"
    print(DEBUG_PREFIX .. " TradeTransaction received")
    print(DEBUG_PREFIX .. " Type: " .. tostring(args.type) .. ", TraderID: " .. tostring(args.traderID))
    
    local txType = args.type
    local traderID = args.traderID
    local key = args.key
    local clientQty = tonumber(args.qty) or 1
    
    -- Get stock and item data
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    if not stockData then
        print(DEBUG_PREFIX .. " ERROR: No stock data for trader")
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Trader unavailable" })
        return
    end
    
    local itemData = DynamicTrading.Config.MasterList[key]
    if not itemData then
        print(DEBUG_PREFIX .. " ERROR: Item not in MasterList: " .. tostring(key))
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
    print(DEBUG_PREFIX .. " FactionID: " .. tostring(factionID) .. ", Faction wealth: $" .. tostring(factionData and factionData.wealth or 0))
    
    if txType == "buy" then
        -- 1. Get price from stock
        local itemStock = stockData.items[key]
        if not itemStock then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not in stock" })
            return
        end
        
        local currentQty = type(itemStock) == "table" and itemStock.qty or itemStock
        local customData = type(itemStock) == "table" and itemStock.customData or nil
        
        -- Use Unified V2 Pricing (Correctly handles condition scaling)
        local unitPrice = DynamicTrading.Economy.V2.GetBuyPrice(traderID, key, customData)
        local totalCost = unitPrice * clientQty
        
        -- Get Base Price (Pre-event) for Dialogue markup checks
        local baseUnitPrice = DynamicTrading.Economy.V2.GetBuyPrice(traderID, key, customData, false, true)
        local totalBaseCost = baseUnitPrice * clientQty
        
        print(DEBUG_PREFIX .. " Buy: " .. key .. " x" .. clientQty .. " @ $" .. unitPrice .. " (Base: $" .. baseUnitPrice .. ")")
        
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
            
            print(DEBUG_PREFIX .. " Buy Inflation: Category=[" .. tostring(category) .. "] | Adding Heat: " .. tostring(change))
            print(DEBUG_PREFIX .. " SUCCESS: Bought " .. safeDisplayName)
            
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
        -- 1. Locate item by ID
        local itemObj = inv:getItemById(args.itemID)
        if not itemObj then
            itemObj = DynamicTrading.ServerHelpers.FindItemByIDRecursive(inv, args.itemID)
        end
        
        if not itemObj then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Item missing!" })
            return
        end
        
        -- 2. Calculate sell price
        -- Use Unified V2 Pricing Logic (which handles Decay, Fluid, etc.)
        local unitPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, itemObj, key)
        local totalGain = unitPrice * clientQty
        
        -- Get Base Price (Pre-event)
        local baseUnitPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, itemObj, key, false, true)
        local totalBaseGain = baseUnitPrice * clientQty

        print(DEBUG_PREFIX .. " Sell: " .. key .. " @ $" .. totalGain .. " (Base: $" .. totalBaseGain .. ")")
        
        -- 3. Check faction can afford
        local factionWealth = factionData and factionData.wealth or 999999
        if factionWealth < totalGain then
            DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { success=false, msg="Trader cannot afford this!" })
            return
        end
        
        -- 4. Unequip if necessary
        if player:getPrimaryHandItem() == itemObj then
            player:setPrimaryHandItem(nil)
        end
        if player:getSecondaryHandItem() == itemObj then
            player:setSecondaryHandItem(nil)
        end
        
        -- 5. Execute Trade
        DynamicTrading.ServerHelpers.RemoveItem(itemObj)
        
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
        stockData.deflation[key] = (stockData.deflation[key] or 0) + 1
        
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
                    DynamicTrading_Engine.UpdateHeat(category, -sensitivity)
                    engineData.WorldEconomy.DeflatedGlobal[key] = true
                    print(DEBUG_PREFIX .. " GLOBAL DEFLATION triggered for category: " .. tostring(category) .. " ( - " .. sensitivity .. ")")
                else
                    print(DEBUG_PREFIX .. " Deflation Roll Failed: " .. roll .. "/" .. chance)
                end
            else
                print(DEBUG_PREFIX .. " Deflation Skipped: Already deflated this item type today.")
            end
        end
        
        print(DEBUG_PREFIX .. " SUCCESS: Sold " .. itemObj:getDisplayName())
        
        -- Send updated stock to client cache (fixes UI not refreshing)
        DataHandlers.SendSyncStockToPlayer(player, traderID)
        
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", { 
            success = true, 
            itemName = itemObj:getDisplayName(),
            price = totalGain,
            basePrice = totalBaseGain,
            isBuy = false
        })
    end
end

TradeHandlers.Handlers = Handlers
return TradeHandlers
