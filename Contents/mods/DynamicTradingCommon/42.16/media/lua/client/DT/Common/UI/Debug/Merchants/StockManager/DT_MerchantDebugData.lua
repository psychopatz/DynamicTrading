-- ==============================================================================
-- DT_MerchantDebugData.lua
-- Merchant Debug Tool: Data Management Layer
-- Handles merchant stock data fetching and population
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"

DT_MerchantDebugData = DT_MerchantDebugData or {}

local function safeHasStock(stock)
    if type(stock) ~= "table" then return false end
    local items = stock.items
    if type(items) ~= "table" then return false end

    local ok, hasAny = pcall(function()
        for _ in pairs(items) do
            return true
        end
        return false
    end)

    return ok and hasAny or false
end

function DT_MerchantDebugData.onSyncData(stock, roster)
    if DT_MerchantDebugData.pendingCallback then
        DT_MerchantDebugData.pendingCallback(stock or {}, roster or {})
        DT_MerchantDebugData.pendingCallback = nil
    end
end

-- ==========================================================
-- DATA REFRESH
-- ==========================================================
function DT_MerchantDebugData.refreshMerchantList(callback)
    if isClient() and not isServer() then
        DT_DebugNetworkAdapter.requestFactionData()
        if callback then
            DT_MerchantDebugData.pendingCallback = callback
        end
        return
    end
    
    local stockData = ModData.get("DynamicTrading_Stock") or {}
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    if callback then
        callback(stockData, rosterData)
    end
    return stockData, rosterData
end

-- ==========================================================
-- DATA POPULATION FOR UI
-- ==========================================================
function DT_MerchantDebugData.getMerchantList(stockData, rosterData)
    local merchants = {}
    local keys = {}
    
    -- Iterate over SOULS but FILTER for only "Trading" status
    if rosterData.Souls then
        for id, soul in pairs(rosterData.Souls) do 
            if soul.status == "Trading" then
                table.insert(keys, id) 
            end
        end
    end
    table.sort(keys)

    for _, uuid in ipairs(keys) do
        local stock = stockData[uuid]
        local soul = rosterData.Souls and rosterData.Souls[uuid]
        
        -- Fallbacks if soul data is missing but stock exists
        local name = soul and soul.name or ("Unknown (" .. uuid .. ")")
        local faction = soul and soul.factionID or "Independent"
        
        -- Status Checks
        local isTrading = (soul and soul.status == "Trading")
        local isCallable = (soul and soul.isCallable) or false
        local factionStatus = soul and soul.status or "Unknown"

        local data = {
            uuid = uuid,
            name = name,
            faction = faction,
            archetype = soul and soul.archetypeID or "N/A",
            stock = stock,
            hasStock = safeHasStock(stock),
            isTrading = isTrading,
            isCallable = isCallable,
            status = factionStatus
        }
        table.insert(merchants, data)
    end
    
    return merchants
end

function DT_MerchantDebugData.getStockItems(stock)
    if not stock or not stock.items then return {} end
    
    local sortedItems = {}
    for k, v in pairs(stock.items) do
        table.insert(sortedItems, { type = k, data = v })
    end
    table.sort(sortedItems, function(a, b) return a.type < b.type end)
    
    return sortedItems
end

function DT_MerchantDebugData.hasStock(stock)
    return safeHasStock(stock)
end

-- ==========================================================
-- SERVER COMMAND HANDLER
-- ==========================================================
function DT_MerchantDebugData.handleServerResponse(command, args)
    if command == "SyncFactionDebugData" then
        local roster = args.roster or {}
        local stock = args.stock or {}
        DT_MerchantDebugData.onSyncData(stock, roster)
        
        return true
    elseif command == "TradeResult" then
        -- Show feedback for operations
        local success = args.success
        local reason = args.reason or "Unknown"
        DynamicTrading.Log("DTCommons", "Debug", "UI", "Merchant Debug: " .. tostring(reason))
        return true
    end
    
    return false
end

-- Register the handler
DT_DebugNetworkAdapter.registerServerCommandHandler(function(command, args)
    DT_MerchantDebugData.handleServerResponse(command, args)
end)

DynamicTrading.Log("DTCommons", "Debug", "UI", "Merchant Debug Data Layer Loaded")
