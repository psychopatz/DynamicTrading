if isServer() then return end

DynamicTrading_Client = {}
DynamicTrading_Client.Cache = {
    Traders = {},
    Factions = {},
    Stocks = {},
    GlobalEvents = {}
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
        -- args is { [ID] = data, globalEvents = ... }
        if args.factions then
             for id, data in pairs(args.factions) do
                DynamicTrading_Client.Cache.Factions[id] = data
                triggerEvent("OnDynamicTradingFactionUpdated", id)
            end
        end
        if args.globalEvents then
            DynamicTrading_Client.Cache.GlobalEvents = args.globalEvents
        end

    elseif command == "SyncRoster" then
        -- args is { roster = ..., factions = ..., globalEvents = ... }
        if args.factions then
            for id, data in pairs(args.factions) do
                DynamicTrading_Client.Cache.Factions[id] = data
                triggerEvent("OnDynamicTradingFactionUpdated", id)
            end
        end
        if args.roster and args.roster.Souls then
            for id, data in pairs(args.roster.Souls) do
                DynamicTrading_Client.Cache.Traders[id] = data
                triggerEvent("OnDynamicTradingTraderUpdated", id)
            end
        end
        if args.globalEvents then
            DynamicTrading_Client.Cache.GlobalEvents = args.globalEvents
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
        print("[DT-V2-Client] >>> OnSharedServerCommand RECEIVED TransactionResult")
        print("[DT-V2-Client]   success=" .. tostring(args.success) .. ", isBuy=" .. tostring(args.isBuy) .. ", item=" .. tostring(args.itemName))
        print("[DT-V2-Client]   DT_TradingWindow=" .. tostring(DT_TradingWindow) .. ", instance=" .. tostring(DT_TradingWindow and DT_TradingWindow.instance))
        
        if DT_TradingWindow and DT_TradingWindow.instance then
            local ui = DT_TradingWindow.instance
            
            if args.success then
                -- 1. Resolve transaction type (isBuy)
                -- Prefer args from server, fallback to current UI state
                local isBuy = (args.isBuy == true)
                if args.isBuy == nil then isBuy = ui.isBuying end

                -- 2. Resolve trader for dialogue generation
                local trader = ui.dataProvider and ui.dataProvider:getTrader(ui.traderID, ui.archetype)
                
                -- [ROBUSTNESS] Fallback trader if cache is missing
                if not trader then
                    trader = {
                        traderID = ui.traderID,
                        archetype = ui.archetype or "General",
                        name = "Trader"
                    }
                end
                
                -- 3. Trigger Dialogue & SFX
                if DynamicTrading.DialogueManager then
                    local diagArgs = {
                        itemName = args.itemName or "Item",
                        price = args.price or 0,
                        basePrice = args.basePrice or args.price or 0,
                        wasLastOne = args.wasLastOne or false,
                        success = true
                    }
                    
                    local npcMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, diagArgs)
                    
                    if DynamicTrading.Debug then
                        print("[DT-V2-Client] Dialogue Debug:")
                        print("  - Trader Archetype: " .. tostring(trader.archetype))
                        print("  - isBuy: " .. tostring(isBuy))
                        print("  - Generated Msg: " .. tostring(npcMsg))
                    end
                    
                    ui:queueMessage(npcMsg, false, false, 15, "DT_Cashier", "transaction")
                else
                    -- Fallback SFX if dialogue manager is missing
                    ui:queueMessage("...", false, false, 0, "DT_Cashier", "transaction")
                end
                
                -- [FIX] Update wallet display and force immediate list refresh
                if ui.updateWallet then ui:updateWallet() end
                ui:populateList()
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
