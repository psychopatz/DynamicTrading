-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_Stock.lua
-- Logic: Stock synchronization and generation handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local DataHandlers = context.DataHandlers
    local Handlers = context.Handlers
    local commandModule = context.COMMAND_MODULE
    local activeStockWatchers = DataHandlers._activeStockWatchers or {}
    DataHandlers._activeStockWatchers = activeStockWatchers

    local function getWatcherKey(player)
        if not player then
            return nil
        end

        if player.getUsername then
            local username = player:getUsername()
            if username and username ~= "" then
                return tostring(username)
            end
        end

        if player.getOnlineID then
            return "online:" .. tostring(player:getOnlineID())
        end

        return tostring(player)
    end

    local function forEachOnlinePlayer(callback)
        if not callback then
            return
        end

        if isServer() then
            local online = getOnlinePlayers and getOnlinePlayers() or nil
            if not online then
                return
            end

            for i = 0, online:size() - 1 do
                local player = online:get(i)
                if player then
                    callback(player)
                end
            end
        else
            local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
            if player then
                callback(player)
            end
        end
    end

    local function getWatchersForTrader(traderID, create)
        if not traderID then
            return nil
        end

        local watchers = activeStockWatchers[traderID]
        if not watchers and create then
            watchers = {}
            activeStockWatchers[traderID] = watchers
        end
        return watchers
    end

    local function isTableEmpty(tbl)
        if type(tbl) ~= "table" then
            return true
        end

        for _, _ in pairs(tbl) do
            return false
        end

        return true
    end

    local function buildSyncStockPayload(traderID, stockData, includeFlashEvents)
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderID) or DynamicTrading_Roster.GetTrader(traderID)
        local factionID = soul and soul.factionID or nil
        local archetype = soul and soul.archetypeID or "General"
        local faction = factionID and DynamicTrading_Factions.GetFaction(factionID) or nil
        local factionWealth = faction and faction.wealth or 0
        local session = DT_TraderSession and DT_TraderSession.GetSession and DT_TraderSession.GetSession(traderID) or nil
        local traderBudget = session and tonumber(session.budget) or nil

        return {
            id = traderID,
            version = stockData.version or 0,
            items = stockData.items,
            restock = stockData.restock,
            deflation = stockData.deflation,
            factionID = factionID,
            archetype = archetype,
            factionWealth = factionWealth,
            budget = traderBudget,
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

    function DataHandlers.RegisterStockWatcher(player, traderID)
        local watcherKey = getWatcherKey(player)
        if not watcherKey or not traderID then
            return false
        end

        local watchers = getWatchersForTrader(traderID, true)
        watchers[watcherKey] = true
        return true
    end

    function DataHandlers.UnregisterStockWatcher(player, traderID)
        local watcherKey = getWatcherKey(player)
        local watchers = getWatchersForTrader(traderID, false)
        if not watcherKey or not watchers then
            return false
        end

        watchers[watcherKey] = nil
        if isTableEmpty(watchers) then
            activeStockWatchers[traderID] = nil
        end
        return true
    end

    function DataHandlers.UnregisterPlayerFromAllStockWatchers(player)
        local watcherKey = getWatcherKey(player)
        if not watcherKey then
            return
        end

        for traderID, watchers in pairs(activeStockWatchers) do
            watchers[watcherKey] = nil
            if isTableEmpty(watchers) then
                activeStockWatchers[traderID] = nil
            end
        end
    end

    function DataHandlers.BroadcastSyncStock(traderID, excludePlayer)
        local stockData = DynamicTrading_Stock.GetStock(traderID)
        if not stockData then
            return
        end

        local payload = buildSyncStockPayload(traderID, stockData, true)
        local watchers = getWatchersForTrader(traderID, false)
        local excludedWatcherKey = getWatcherKey(excludePlayer)
        local delivered = {}
        if excludedWatcherKey then
            delivered[excludedWatcherKey] = true
        end
        if isServer() and (not watchers or isTableEmpty(watchers)) then
            DynamicTrading.Log("DTV2", "Network", "Server", "Skipping SyncStock broadcast for " .. tostring(traderID) .. " because there are no active watchers")
            return
        end

        DynamicTrading.Log(
            "DTV2",
            "Network",
            "Server",
            "Broadcasting SyncStock: traderID=" .. tostring(traderID) ..
            ", version=" .. tostring(payload.version) ..
            ", budget=" .. tostring(payload.budget)
        )

        if not isServer() then
            DynamicTrading.ServerHelpers.BroadcastResponse(commandModule, "SyncStock", payload)
            return
        end

        forEachOnlinePlayer(function(onlinePlayer)
            local watcherKey = getWatcherKey(onlinePlayer)
            if watcherKey and watcherKey ~= excludedWatcherKey and watchers[watcherKey] then
                delivered[watcherKey] = true
                DynamicTrading.ServerHelpers.SendResponse(onlinePlayer, commandModule, "SyncStock", payload)
            end
        end)

        for watcherKey, _ in pairs(watchers) do
            if not delivered[watcherKey] then
                watchers[watcherKey] = nil
            end
        end
        if isTableEmpty(watchers) then
            activeStockWatchers[traderID] = nil
        end
    end

    Handlers.BeginTradeView = function(player, args)
        local traderID = args and args.traderID or nil
        if not traderID then
            return
        end

        DataHandlers.RegisterStockWatcher(player, traderID)
        local stockData = DynamicTrading_Stock.GetStock(traderID)
        if stockData then
            DataHandlers.SendSyncStockToPlayer(player, traderID)
        end
    end

    Handlers.EndTradeView = function(player, args)
        local traderID = args and args.traderID or nil
        if not traderID then
            DataHandlers.UnregisterPlayerFromAllStockWatchers(player)
            return
        end

        DataHandlers.UnregisterStockWatcher(player, traderID)
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
                stockData.playerInteracted = true
                stockData.lastInteractedBy = player and player.getUsername and player:getUsername() or nil
                stockData.lastInteractedAt = getTimeInMillis and getTimeInMillis() or nil
                DataHandlers.SendSyncStockToPlayer(player, traderID)
                DataHandlers.BroadcastSyncStock(traderID, player)
                DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "TradeResult", { success = true, reason = "Stock Generated" })
            end
        else
            DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "TradeResult", { success = false, reason = reason })
        end
    end
end
