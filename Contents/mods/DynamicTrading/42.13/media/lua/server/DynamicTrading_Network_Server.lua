if isClient() then return end

local ServerNetwork = {}
local COMMAND_MODULE = "DynamicTrading_V2"

-- =============================================================================
-- COMMAND HANDLERS
-- =============================================================================
local Handlers = {}

-- Client requests specific trader data (Visuals, generic memory)
-- Args: { traderID = "..." }
Handlers.RequestTrader = function(player, args)
    local traderID = args.traderID
    local traderData = DynamicTrading_Roster.GetTrader(traderID)
    
    if traderData then
        -- We only send the necessary visual/bio data, not the whole memory bank of other users
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

-- Client requests Faction data
-- Args: { factionID = "..." }
Handlers.RequestFaction = function(player, args)
    local factionID = args.factionID
    local key = "DynamicTrading_Factions"
    local data = ModData.get(key)
    
    if data and data[factionID] then
        -- Send just this faction
        local payload = { [factionID] = data[factionID] }
        sendServerCommand(player, COMMAND_MODULE, "SyncFaction", payload)
    end
end

-- Client requests Stock/Inventory
-- Args: { traderID = "..." }
Handlers.RequestStock = function(player, args)
    local traderID = args.traderID
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    
    if stockData then
        -- Send items and restock times
        local payload = { 
            id = traderID, 
            items = stockData.items, 
            restock = stockData.restock 
        }
        sendServerCommand(player, COMMAND_MODULE, "SyncStock", payload)
    end
end

-- Client attempts to Buy/Sell
-- Args: { type="buy"|"sell", traderID="...", itemFullType="...", qty=1 }
Handlers.PerformTrade = function(player, args)
    local traderID = args.traderID
    local itemType = args.itemFullType
    local qty = args.qty or 1
    local price = args.price -- Client's expected price (for verification, optional)

    -- Retrieve Server State
    local stock = DynamicTrading_Stock.GetStock(traderID)
    if not stock or not stock.items[itemType] then
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=false, reason="Invalid Item/Trader" })
        return
    end

    local serverItemData = stock.items[itemType]
    local playerInv = player:getInventory()

    if args.type == "buy" then
        -- Validation: Stock
        if serverItemData.qty < qty then
            sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=false, reason="Out of Stock" })
            return
        end
        
        -- Validation: Money (Placeholder logic for currency removal, assumes standard Money/Credit system)
        -- TODO: Integrate with Wallet/Money system. 
        -- For now, we assume success if stock is present for this architecture demo.
        
        -- Logic: Deduct Stock
        DynamicTrading_Stock.UpdateItemQty(traderID, itemType, -qty)
        
        -- Logic: Add Item to Player
        playerInv:AddItems(itemType, qty)
        
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, type="buy", item=itemType, qty=qty })
        
    elseif args.type == "sell" then
        -- Logic: Check player has item
        if not playerInv:containsType(itemType) then
             sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=false, reason="Item Missing" })
             return
        end
        
        -- Logic: Remove from player
        -- playerInv:RemoveOneOf(itemType) -- Simplified
        local items = playerInv:getItemsFromType(itemType)
        if items and items:size() >= qty then
            for i=0, qty-1 do
                local item = items:get(i)
                if item then playerInv:Remove(item) end
            end
            
            -- Logic: Add to Trader Stock
            DynamicTrading_Stock.UpdateItemQty(traderID, itemType, qty)
            
            sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, type="sell", item=itemType, qty=qty })
        else
            sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=false, reason="Not Enough Items" })
        end
    end
end

-- Admin/Debug Commands
-- Args: { action="SimulateDay"|"ForceRestock", targetID="..." }
Handlers.DebugCommand = function(player, args)
    if not (isServer() or isAdmin() or isDebugEnabled()) then return end -- Basic security check
    
    local action = args.action
    if action == "SimulateDay" then
        DynamicTrading_Factions.UpdateDaily()
        DynamicTrading_Engine.RunDailySimulation() -- Syncs Engine too
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Daily Sim Force Run" })
        
    elseif action == "ForceRestock" then
        local traderID = args.targetID
        local stock = DynamicTrading_Stock.GetStock(traderID)
        if stock then
            -- Reset restock timer to now
            stock.restock.nextRestockTime = 0
            -- Trigger stock update (logic currently inside stock system, simplistic reset for now)
            stock.restock.lastRestockTime = 0
            DynamicTrading_Stock.InitializeInventory(traderID, stock.items) -- Re-init to default or custom logic needed
            ModData.transmit("DynamicTrading_Stock")
            sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Restock Triggered for " .. traderID })
        end
    elseif action == "createTestFaction" then
        DynamicTrading_Factions.CreateFaction("TestFaction", {memberCount=50, stockpile={food=1000}})
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Test Faction Created" })
    end
end

-- =============================================================================
-- MAIN EVENT LOOP
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module == COMMAND_MODULE and Handlers[command] then
        Handlers[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
print("DynamicTrading: Server Network Layer V2 Initialized")
