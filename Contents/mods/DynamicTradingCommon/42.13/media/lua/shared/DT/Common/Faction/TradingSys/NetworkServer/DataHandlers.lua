-- ==============================================================================
-- NetworkServer/DataHandlers.lua
-- Logic: Data synchronization handlers (Roster, Trader, Stock)
-- Build 42 Compatible.
-- ==============================================================================

local COMMAND_MODULE = "DynamicTrading_V2"

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/ServerHelpers"

local DataHandlers = {}
local Handlers = {}

-- =============================================================================
-- HELPER: Send Complete SyncStock to Player
-- Used after transactions to update client cache with latest stock and faction wealth
-- =============================================================================
function DataHandlers.SendSyncStockToPlayer(player, traderID)
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
    
    DynamicTrading.Log("DTV2", "Network", "Server", "Sending SyncStock: traderID=" .. tostring(traderID) .. ", factionID=" .. tostring(factionID) .. ", factionWealth=" .. tostring(factionWealth))
    
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncStock", { 
        id = traderID, 
        items = stockData.items, 
        restock = stockData.restock,
        deflation = stockData.deflation,
        factionID = factionID,
        archetype = archetype,
        factionWealth = factionWealth,
        activeFlashEvents = faction and faction.ActiveFlashEvents or {},
        activeFlashEvent = faction and faction.ActiveFlashEvent or { id = nil, expires = 0 },
        name = soul and soul.name or "Trader",
        identitySeed = soul and soul.identitySeed,
        gender = soul and soul.isFemale and "Female" or "Male"
    })
end

-- =============================================================================
-- COMMAND HANDLERS
-- =============================================================================

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
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncTrader", response)
    end
end

-- [ROSTER DATA REQUEST (FOR RADAR)]
Handlers.RequestRoster = function(player, args)
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local engineData = DynamicTrading_Engine.GetEngineData()
    
    -- Optimize Radar Roster: Only send souls that are currently Trading
    local minimalSouls = {}
    if rosterData.Souls then
        for uuid, soul in pairs(rosterData.Souls) do
            if soul.status == "Trading" then
                minimalSouls[uuid] = soul
            end
        end
    end

    local minimalRoster = {
        FactionMembers = rosterData.FactionMembers,
        Souls = minimalSouls,
        Traders = rosterData.Traders -- Traders are usually few, keeping for now
    }
    
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncRoster", {
        roster = minimalRoster,
        factions = factionData,
        globalEvents = engineData and engineData.EventSystem and engineData.EventSystem.activeEvents or {}
    })
end

-- [ON-DEMAND ROSTER REQUEST]
-- Duplicated here for general mod data sync (Radar/Common UIs)
Handlers.RequestFactionRoster = function(player, args)
    local factionID = args.factionID
    if not factionID then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local members = rosterData.FactionMembers and rosterData.FactionMembers[factionID] or {}
    
    local factionSouls = {}
    if rosterData.Souls then
        for _, uuid in ipairs(members) do
            if rosterData.Souls[uuid] then
                factionSouls[uuid] = rosterData.Souls[uuid]
            end
        end
    end
    
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncFactionRoster", {
        factionID = factionID,
        souls = factionSouls
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
        
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncStock", { 
            id = traderID, 
            items = stockData.items, 
            restock = stockData.restock,
            factionID = factionID,
            archetype = archetype,
            factionWealth = factionWealth,
            name = soul and soul.name or "Trader",
            identitySeed = soul and soul.identitySeed,
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
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncStock", { 
                id = traderID, 
                items = stockData.items, 
                restock = stockData.restock,
                factionID = factionID,
                archetype = archetype,
                factionWealth = factionWealth,
                activeFlashEvents = faction and faction.ActiveFlashEvents or {},
                activeFlashEvent = faction and faction.ActiveFlashEvent or { id = nil, expires = 0 },
                name = soul and soul.name or "Trader",
                identitySeed = soul and soul.identitySeed,
                gender = soul and soul.isFemale and "Female" or "Male"
            })
            
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Stock Generated" })
        end
    else
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=false, reason=reason })
    end
end

DataHandlers.Handlers = Handlers
return DataHandlers
