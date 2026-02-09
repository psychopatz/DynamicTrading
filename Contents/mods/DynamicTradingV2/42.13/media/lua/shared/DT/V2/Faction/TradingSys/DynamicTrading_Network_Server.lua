-- ==============================================================================
-- media/lua/server/DynamicTrading_Network_Server.lua
-- Logic: Server-side handling of Client Requests (Networking V2)
-- Build 42 Compatible.
-- ==============================================================================

if isClient() and not isServer() then return end

local ServerNetwork = {}
local COMMAND_MODULE = "DynamicTrading_V2"

-- Ensure we have access to our systems
require "DT/V2/Faction/TradingSys/DynamicTrading_Factions"
require "DT/V2/Faction/TradingSys/DynamicTrading_Roster"
require "DT/V2/Faction/TradingSys/DynamicTrading_Stock"
require "DT/V2/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Config"
require "DT/Common/ServerHelpers"


-- =============================================================================
-- 1. COMMAND HANDLERS
-- =============================================================================
local Handlers = {}

-- [TRADER DATA REQUEST]
Handlers.RequestTrader = function(player, args)
    local traderID = args.traderID
    local traderData = DynamicTrading_Roster.GetTrader(traderID)
    if traderData then
        local response = {
            id = traderID,
            visuals = traderData.visuals,
            factionID = traderData.factionID,
            homeCoords = traderData.homeCoords,
            isSpawned = traderData.isPhysicallySpawned
        }
        sendServerCommand(player, COMMAND_MODULE, "SyncTrader", response)
    end
end

-- [ROSTER DATA REQUEST (FOR RADAR)]
Handlers.RequestRoster = function(player, args)
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    
    sendServerCommand(player, COMMAND_MODULE, "SyncRoster", {
        roster = rosterData,
        factions = factionData
    })
end

-- [STOCK DATA REQUEST]
Handlers.RequestStock = function(player, args)
    local traderID = args.traderID
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    if stockData then
        -- Get soul data for factionID and archetype
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderID)
        local factionID = soul and soul.factionID or nil
        local archetype = soul and soul.archetypeID or "General"
        
        -- Get faction wealth for budget
        local factionWealth = 0
        if factionID then
            local faction = DynamicTrading_Factions.GetFaction(factionID)
            if faction then
                factionWealth = faction.wealth or 0
            end
        end
        
        sendServerCommand(player, COMMAND_MODULE, "SyncStock", { 
            id = traderID, 
            items = stockData.items, 
            restock = stockData.restock,
            factionID = factionID,
            archetype = archetype,
            factionWealth = factionWealth,
            name = soul and soul.name or "Trader",
            portraitID = soul and soul.portraitID,
            gender = soul and soul.isFemale and "Female" or "Male"
        })
    end
end

-- [STOCK GENERATION REQUEST]
Handlers.GenerateStock = function(player, args)
    local traderID = args.traderID
    local success, reason = DynamicTrading_Stock.CheckAndGenerateStock(traderID)
    
    if success then
        -- Send updated stock back to client (useful for Debug UI and Trading UI)
        local stockData = DynamicTrading_Stock.GetStock(traderID)
        if stockData then
            -- Get soul data for factionID and archetype (same as RequestStock)
            local soul = DynamicTrading_Roster.GetSoulRegistry(traderID)
            local factionID = soul and soul.factionID or nil
            local archetype = soul and soul.archetypeID or "General"
            
            -- Get faction wealth for budget
            local factionWealth = 0
            if factionID then
                local faction = DynamicTrading_Factions.GetFaction(factionID)
                if faction then
                    factionWealth = faction.wealth or 0
                end
            end
             
            -- Send complete SyncStock with all required fields
            sendServerCommand(player, COMMAND_MODULE, "SyncStock", { 
                id = traderID, 
                items = stockData.items, 
                restock = stockData.restock,
                factionID = factionID,
                archetype = archetype,
                factionWealth = factionWealth,
                name = soul and soul.name or "Trader",
                portraitID = soul and soul.portraitID,
                gender = soul and soul.isFemale and "Female" or "Male"
            })
            
            sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Stock Generated" })
        end
    else
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=false, reason=reason })
    end
end

-- [HELPER: Send Complete SyncStock to Player]
-- Used after transactions to update client cache with latest stock and faction wealth
local function SendSyncStockToPlayer(player, traderID)
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    if not stockData then return end
    
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderID) or DynamicTrading_Roster.GetTrader(traderID)
    local factionID = soul and soul.factionID or nil
    local archetype = soul and soul.archetypeID or "General"
    
    -- Get current faction wealth (after transaction)
    local factionWealth = 0
    if factionID then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction then
            factionWealth = faction.wealth or 0
        end
    end
    
    print("[DT-V2-Server] Sending SyncStock: traderID=" .. tostring(traderID) .. ", factionID=" .. tostring(factionID) .. ", factionWealth=" .. tostring(factionWealth))
    
    sendServerCommand(player, COMMAND_MODULE, "SyncStock", { 
        id = traderID, 
        items = stockData.items, 
        restock = stockData.restock,
        deflation = stockData.deflation,
        factionID = factionID,
        archetype = archetype,
        factionWealth = factionWealth,
        name = soul and soul.name or "Trader",
        portraitID = soul and soul.portraitID,
        gender = soul and soul.isFemale and "Female" or "Male"
    })
end

-- [TRADE TRANSACTION - BUY/SELL]
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
        sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Trader unavailable" })
        return
    end
    
    local itemData = DynamicTrading.Config.MasterList[key]
    if not itemData then
        print(DEBUG_PREFIX .. " ERROR: Item not in MasterList: " .. tostring(key))
        sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Item not found" })
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
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not in stock" })
            return
        end
        
        local currentQty = type(itemStock) == "table" and itemStock.qty or itemStock
        local unitPrice = type(itemStock) == "table" and (itemStock.price or itemStock.basePrice) or (itemData.basePrice or 100)
        local totalCost = unitPrice * clientQty
        
        print(DEBUG_PREFIX .. " Buy: " .. key .. " x" .. clientQty .. " @ $" .. unitPrice)
        
        -- 2. Check Stock
        if currentQty < clientQty then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Sold Out!" })
            return
        end
        
        -- 3. Check Player Wealth
        local playerWealth = DynamicTrading.ServerHelpers.GetWealth(player)
        if playerWealth < totalCost then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not enough cash!" })
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
            
            -- Add item to player
            DynamicTrading.ServerHelpers.AddItem(inv, itemData.item, clientQty)
            
            -- Sync stock
            ModData.transmit("DynamicTrading_Stock")
            
            print(DEBUG_PREFIX .. " SUCCESS: Bought " .. safeDisplayName)
            
            -- Send updated stock to client cache (fixes UI not refreshing)
            SendSyncStockToPlayer(player, traderID)
            
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { 
                success = true, 
                itemName = safeDisplayName,
                price = totalCost,
                isBuy = true
            })
        else
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Transaction Error" })
        end
        
    elseif txType == "sell" then
        -- 1. Locate item by ID
        local itemObj = inv:getItemById(args.itemID)
        if not itemObj then
            itemObj = DynamicTrading.ServerHelpers.FindItemByIDRecursive(inv, args.itemID)
        end
        
        if not itemObj then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Item missing!" })
            return
        end
        
        -- 2. Calculate sell price
        local basePrice = itemData.basePrice or 0
        local unitPrice = math.floor(basePrice * 0.5)
        
        -- Condition penalty
        if itemObj:getConditionMax() and itemObj:getConditionMax() > 0 then
            local cond = itemObj:getCondition() / itemObj:getConditionMax()
            unitPrice = math.floor(unitPrice * cond)
        end
        
        local totalGain = unitPrice * clientQty
        print(DEBUG_PREFIX .. " Sell: " .. key .. " @ $" .. totalGain)
        
        -- 3. Check faction can afford
        local factionWealth = factionData and factionData.wealth or 999999
        if factionWealth < totalGain then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Trader cannot afford this!" })
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
        
        print(DEBUG_PREFIX .. " SUCCESS: Sold " .. itemObj:getDisplayName())
        
        -- Send updated stock to client cache (fixes UI not refreshing)
        SendSyncStockToPlayer(player, traderID)
        
        sendServerCommand(player, "DynamicTrading", "TransactionResult", { 
            success = true, 
            itemName = itemObj:getDisplayName(),
            price = totalGain,
            isBuy = false
        })
    end
end


-- [FACTION DATA REQUEST]
Handlers.RequestFactionData = function(player, args)
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local stockData = ModData.get("DynamicTrading_Stock") or {}
    
    sendServerCommand(player, COMMAND_MODULE, "SyncFactionDebugData", {
        factions = factionData,
        roster = rosterData,
        stock = stockData
    })
end

-- [DEBUG & ADMIN COMMANDS]
Handlers.DebugCommand = function(player, args)
    -- Security Check: Only allow if Debug is on OR player is an Admin
    if not (isAdmin() or isDebugEnabled()) then 
        print("DT SECURITY: Unauthorized DebugCommand attempt by " .. player:getUsername())
        return 
    end
    
    local action = args.action
    print("DT DEBUG: Server received action [" .. tostring(action) .. "] from " .. player:getUsername())

    if action == "SimulateDay" then
        -- Force the daily update for all factions
        DynamicTrading_Factions.UpdateDaily()
        -- Also force the engine simulation
        DynamicTrading_Engine.RunDailySimulation()
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Simulation Triggered" })

    elseif action == "createTestFaction" then
        local targetID = args.targetID or ("Faction_" .. ZombRand(1000))
        -- This calls our new logic that includes the LocationManager!
        DynamicTrading_Factions.CreateFaction(targetID, {
            memberCount = ZombRand(5, 15),
            stockpile = { food = 200, ammo = 100 }
        })
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Created" })

    elseif action == "WipeFactions" then
        -- Clear the ModData table completely
        local key = "DynamicTrading_Factions"
        -- We must overwrite the actual table content in the ModData system
        local data = ModData.get(key)
        if data then
            -- Clear existing keys
            for k in pairs(data) do data[k] = nil end
        else
            ModData.add(key, {})
        end
        
        -- Re-initialize to restore the "Independent" nomadic faction and Town factions
        DynamicTrading_Factions.Init()
        ModData.transmit(key)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="All Factions Wiped & Repopulated" })

    elseif action == "ForceRestock" then
        -- Reset restock timers for a specific trader
        local traderID = args.targetID
        local stock = DynamicTrading_Stock.GetStock(traderID)
        if stock then
            stock.restock.nextRestockTime = 0
            ModData.transmit("DynamicTrading_Stock")
            sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Restock Forced" })
        end
    elseif action == "ModifySoul" then
        local factionID = args.factionID
        local amount = args.amount
        if amount > 0 then
            for i=1, amount do
                local archetypes = {}
                for aid, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, aid) end
                local randomArch = archetypes[ZombRand(#archetypes) + 1]
                DynamicTrading_Roster.AddSoul(factionID, randomArch)
                
                local f = DynamicTrading_Factions.GetFaction(factionID)
                if f then f.memberCount = f.memberCount + 1 end
            end
        else
            DynamicTrading_Roster.RemoveSoul(factionID, math.abs(amount))
            local f = DynamicTrading_Factions.GetFaction(factionID)
            if f then f.memberCount = math.max(0, f.memberCount + amount) end
        end
        ModData.transmit("DynamicTrading_Factions")
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Roster Modified" })

    elseif action == "ModifyStockpile" then
        local factionID = args.factionID
        local res = args.resource
        local amt = args.amount
        DynamicTrading_Factions.ModifyStockpile(factionID, res, amt)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Stockpile Modified" })

    elseif action == "ModifyWealth" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading_Factions.ModifyWealth(factionID, amt)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Wealth Modified" })

    elseif action == "ModifyReputation" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading_Factions.ModifyReputation(factionID, player:getUsername(), amt)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Reputation Modified" })

    elseif action == "ForceSpawn" then
        local town = args.town or "Rosewood"
        local factionID = town .. "_" .. tostring(math.floor(ZombRand(100000, 999999)))
        DynamicTrading_Factions.CreateFaction(factionID, {
            town = town,
            memberCount = 10
        })
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Spawned" })
    end
end

-- =============================================================================
-- 2. MAIN EVENT LISTENER
-- =============================================================================
-- This function listens for the 'sendClientCommand' from the UI
local function OnClientCommand(module, command, player, args)
    -- Handle V2-specific commands
    if module == COMMAND_MODULE and Handlers[command] then
        Handlers[command](player, args)
        return
    end
    
    -- Handle shared commands from TradingWindow (uses "DynamicTrading" module)
    if module == "DynamicTrading" and Handlers[command] then
        Handlers[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

print("DynamicTrading: Server Network Layer (Factions Update + Trade) Initialized.")
