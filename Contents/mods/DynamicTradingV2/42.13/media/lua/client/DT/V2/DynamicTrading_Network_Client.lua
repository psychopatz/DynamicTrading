if not isClient() then return end

DynamicTrading_Client = {}
DynamicTrading_Client.Cache = {
    Traders = {},
    Factions = {},
    Stocks = {}
}

local COMMAND_MODULE = "DynamicTrading_V2"

-- =============================================================================
-- API METHODS (UI Should Call These)
-- =============================================================================

function DynamicTrading_Client.RequestTraderData(traderID)
    sendClientCommand(getPlayer(), COMMAND_MODULE, "RequestTrader", { traderID = traderID })
end

function DynamicTrading_Client.RequestFactionData(factionID)
    sendClientCommand(getPlayer(), COMMAND_MODULE, "RequestFaction", { factionID = factionID })
end

function DynamicTrading_Client.RequestStock(traderID)
    sendClientCommand(getPlayer(), COMMAND_MODULE, "RequestStock", { traderID = traderID })
end

function DynamicTrading_Client.PerformTrade(type, traderID, itemFullType, qty)
    local args = {
        type = type,
        traderID = traderID,
        itemFullType = itemFullType,
        qty = qty
    }
    sendClientCommand(getPlayer(), COMMAND_MODULE, "PerformTrade", args)
end

-- =============================================================================
-- SERVER RESPONSE HANDLERS
-- =============================================================================

local function OnServerCommand(module, command, args)
    if module ~= COMMAND_MODULE then return end

    if command == "SyncTrader" then
        local id = args.id
        if id then
            DynamicTrading_Client.Cache.Traders[id] = args
            triggerEvent("OnDynamicTradingTraderUpdated", id)
        end

    elseif command == "SyncFaction" then
        -- args is { [ID] = data }
        for id, data in pairs(args) do
            DynamicTrading_Client.Cache.Factions[id] = data
            triggerEvent("OnDynamicTradingFactionUpdated", id)
        end

    elseif command == "SyncStock" then
        local id = args.id
        if id then
            DynamicTrading_Client.Cache.Stocks[id] = args -- contains items, restock
            triggerEvent("OnDynamicTradingStockUpdated", id)
        end

    elseif command == "TradeResult" then
        if args.success then
            print("DT: Trade Successful")
        else
            print("DT: Trade Failed: " .. tostring(args.reason))
        end
        triggerEvent("OnDynamicTradingTradeCompleted", args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)

-- =============================================================================
-- SHARED MODULE HANDLER (for TransactionResult from DynamicTrading module)
-- This is needed because the server sends TransactionResult to "DynamicTrading",
-- not "DynamicTrading_V2", for compatibility with the common TradingWindow.
-- =============================================================================
local function OnSharedServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end
    
    if command == "TransactionResult" then
        print("[DT-V2-Client] Received TransactionResult: " .. tostring(args.success))
        
        if DT_TradingWindow and DT_TradingWindow.instance then
            local ui = DT_TradingWindow.instance
            
            if args.success then
                -- Get trader for dialogue generation
                local trader = ui.dataProvider and ui.dataProvider:getTrader(ui.traderID, ui.archetype)
                
                if trader and DynamicTrading.DialogueManager then
                    -- Generate NPC response dialogue
                    local diagArgs = {
                        itemName = args.itemName or "Item",
                        price = args.price or 0,
                        success = true
                    }
                    
                    local isBuy = args.isBuy ~= false -- Default to buy if not specified
                    local npcMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, diagArgs)
                    ui:queueMessage(npcMsg, false, false, 15, "DT_Cashier", "transaction")
                end
                
                -- Refresh UI is now handled by OnDynamicTradingStockUpdated event below
            else
                -- Show failure message
                ui:queueMessage(args.msg or "Transaction Failed", true, false, 0, nil, "transaction")
                if HaloTextHelper and getSpecificPlayer(0) then
                    HaloTextHelper.addTextWithArrow(getSpecificPlayer(0), args.msg or "Failed", true, HaloTextHelper.getColorRed())
                end
            end
        end
        
        -- Also trigger generic event for other listeners
        triggerEvent("OnDynamicTradingTradeCompleted", args)
    end
end

Events.OnServerCommand.Add(OnSharedServerCommand)

-- =============================================================================
-- STOCK UPDATE LISTENER (Refreshes UI when stock is synced from server)
-- This ensures the cache is updated BEFORE we refresh the list
-- =============================================================================
local function OnStockUpdated(traderID)
    if DT_TradingWindow and DT_TradingWindow.instance then
        local ui = DT_TradingWindow.instance
        -- Only refresh if this update is for our current trader
        if ui.traderID == traderID then
            print("[DT-V2-Client] Stock updated for current trader, refreshing UI")
            ui:populateList()
        end
    end
end

-- Listen for stock update events
if LuaEventManager then
    LuaEventManager.AddEvent("OnDynamicTradingStockUpdated")
end
Events.OnDynamicTradingStockUpdated.Add(OnStockUpdated)

print("DynamicTrading: Client Network Layer V2 Initialized")
