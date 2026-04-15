-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_Stock.lua
-- Logic: Stock synchronization and generation handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local DataHandlers = context.DataHandlers
    local Handlers = context.Handlers
    local commandModule = context.COMMAND_MODULE

    local function buildSyncStockPayload(traderID, stockData, includeFlashEvents)
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderID) or DynamicTrading_Roster.GetTrader(traderID)
        local factionID = soul and soul.factionID or nil
        local archetype = soul and soul.archetypeID or "General"
        local faction = factionID and DynamicTrading_Factions.GetFaction(factionID) or nil
        local factionWealth = faction and faction.wealth or 0

        return {
            id = traderID,
            items = stockData.items,
            restock = stockData.restock,
            deflation = stockData.deflation,
            factionID = factionID,
            archetype = archetype,
            factionWealth = factionWealth,
            activeFlashEvents = includeFlashEvents and (faction and faction.ActiveFlashEvents or {}) or nil,
            activeFlashEvent = includeFlashEvents and (faction and faction.ActiveFlashEvent or { id = nil, expires = 0 }) or nil,
            name = soul and soul.name or "Trader",
            identitySeed = soul and soul.identitySeed,
            gender = soul and soul.isFemale and "Female" or "Male",
            returnTime = soul and soul.returnTime
        }
    end

    -- =============================================================================
    -- HELPER: Send Complete SyncStock to Player
    -- Used after transactions to update client cache with latest stock and faction wealth
    -- =============================================================================
    function DataHandlers.SendSyncStockToPlayer(player, traderID)
        local stockData = DynamicTrading_Stock.GetStock(traderID)
        if not stockData then
            return
        end

        local payload = buildSyncStockPayload(traderID, stockData, true)
        DynamicTrading.Log("DTV2", "Network", "Server", "Sending SyncStock: traderID=" .. tostring(traderID) .. ", factionID=" .. tostring(payload.factionID) .. ", factionWealth=" .. tostring(payload.factionWealth))
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncStock", payload)
    end

    -- [STOCK DATA REQUEST]
    Handlers.RequestStock = function(player, args)
        local traderID = args.traderID
        local stockData = DynamicTrading_Stock.GetStock(traderID)
        if stockData then
            DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncStock", buildSyncStockPayload(traderID, stockData, false))
        end
    end

    -- [STOCK GENERATION REQUEST]
    Handlers.GenerateStock = function(player, args)
        local traderID = args.traderID
        local success, reason = DynamicTrading_Stock.CheckAndGenerateStock(traderID)

        if success then
            local stockData = DynamicTrading_Stock.GetStock(traderID)
            if stockData then
                DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncStock", buildSyncStockPayload(traderID, stockData, true))
                DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "TradeResult", { success = true, reason = "Stock Generated" })
            end
        else
            DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "TradeResult", { success = false, reason = reason })
        end
    end
end
