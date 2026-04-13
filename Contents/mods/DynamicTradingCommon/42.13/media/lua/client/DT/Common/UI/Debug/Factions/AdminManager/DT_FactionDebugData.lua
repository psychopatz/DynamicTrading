-- ==============================================================================
-- DT_FactionDebugData.lua
-- Faction Debug Tool: Data Management Layer
-- Handles data fetching, caching, and population logic
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"

DT_FactionDebugData = DT_FactionDebugData or {}

-- ==========================================================
-- CACHED DATA (Multiplayer Optimization)
-- ==========================================================
DT_FactionDebugData.cachedFactionData = nil
DT_FactionDebugData.cachedRosterData = nil

-- ==========================================================
-- DATA REFRESH
-- ==========================================================
function DT_FactionDebugData.refreshFactionList(callback)
    -- In multiplayer, request data from server
    if isClient() and not isServer() then
        DT_DebugNetworkAdapter.requestFactionData()
        -- Data will arrive via OnServerCommand and trigger callback
        if callback then
            DT_FactionDebugData.pendingCallback = callback
        end
        return
    end
    
    -- In singleplayer, access directly
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    if callback then
        callback(factionData)
    end
    return factionData
end

function DT_FactionDebugData.refreshRosterForFaction(factionID, callback)
    if isClient() and not isServer() then
        DynamicTrading.Log("DTCommons", "Debug", "UI", "Requesting detailed roster for faction: " .. tostring(factionID))
        DT_DebugNetworkAdapter.requestFactionRoster(factionID)
        if callback then
            DT_FactionDebugData.pendingRosterCallback = callback
        end
        return
    end
    
    -- In singleplayer, access directly
    local rosterData = ModData.get("DynamicTrading_Roster")
    if callback and rosterData then
        callback(rosterData)
    end
    return rosterData
end

-- ==========================================================
-- DATA POPULATION FOR UI
-- ==========================================================
function DT_FactionDebugData.getSortedFactionList(factionData)
    if not factionData then return {} end
    
    local keys = {}
    for id in pairs(factionData) do 
        table.insert(keys, id) 
    end
    table.sort(keys)
    
    local sorted = {}
    for _, id in ipairs(keys) do
        table.insert(sorted, {
            id = id,
            data = factionData[id]
        })
    end
    
    return sorted
end

function DT_FactionDebugData.getRosterForFaction(factionID, rosterData)
    if not rosterData or not factionID then return {} end
    
    local roster = {}
    local members = rosterData.FactionMembers and rosterData.FactionMembers[factionID]
    
    if members and #members > 0 then
        for _, uuid in ipairs(members) do
            local soul = rosterData.Souls and rosterData.Souls[uuid]
            local trader = rosterData.Traders and rosterData.Traders[uuid]
            if soul then
                table.insert(roster, {
                    uuid = uuid,
                    soul = soul,
                    trader = trader
                })
            end
        end
    end
    
    return roster
end

-- ==========================================================
-- FACTION DETAILS FORMATTER
-- ==========================================================
function DT_FactionDebugData.formatFactionDetails(faction)
    if not faction then return "No faction selected." end
    
    local text = " <RGB:1,1,0> TITLE: " .. (faction.name or "Unknown") .. " <LINE> "
    text = text .. " <RGB:1,1,1> ID: " .. (faction.id or "N/A") .. " <LINE> "
    text = text .. "Town: " .. tostring(faction.town or "N/A") .. " <LINE> "
    
    if faction.homeCoords then
        text = text .. "Base: " .. faction.homeCoords.name .. " <LINE> "
        text = text .. "Coords: " .. faction.homeCoords.x .. "," .. faction.homeCoords.y .. "," .. faction.homeCoords.z .. " <LINE> "
    else
        text = text .. "Base: NOMADIC <LINE> "
    end
    
    text = text .. "Wealth: <RGB:0.2,1,0.2> " .. tostring(faction.wealth or 0) .. " <LINE> "
    text = text .. " <LINE> <RGB:0.2,0.2,1> PLAYER REPUTATIONS: <LINE> "
    
    if faction.reputation and type(faction.reputation) == "table" then
        for user, rep in pairs(faction.reputation) do
            text = text .. " <RGB:0.7,0.7,0.7> - " .. user .. ": <RGB:1,1,1> " .. rep .. " <LINE> "
        end
    else
        text = text .. " <RGB:0.7,0.7,0.7> - No reputation data. <LINE> "
    end
    
    text = text .. " <LINE> <RGB:1,1,0> ACTIVE FLASH EVENTS: <LINE> "
    local flashEvents = faction.ActiveFlashEvents or {}
    if #flashEvents == 0 and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        flashEvents = {
            {
                id = faction.ActiveFlashEvent.id,
                expires = faction.ActiveFlashEvent.expires or 0
            }
        }
    end

    if #flashEvents > 0 then
        local currentHours = getGameTime():getWorldAgeHours()
        for _, entry in ipairs(flashEvents) do
            if entry and entry.id then
                local diff = math.max(0, (entry.expires or 0) - currentHours)
                text = text .. " <RGB:0,1,1> " .. tostring(entry.id) .. " <RGB:0.7,0.7,0.7> (Expires in: " .. string.format("%.1f", diff) .. "h) <LINE> "
            end
        end
    else
        text = text .. " <RGB:0.7,0.7,0.7> - None <LINE> "
    end
    
    text = text .. " <LINE> <RGB:0,1,0> STOCKPILE: <LINE> "
    if faction.stockpile then
        for k, v in pairs(faction.stockpile) do
            text = text .. " <RGB:0.7,0.7,0.7> - " .. k .. ": <RGB:1,1,1> " .. v .. " <LINE> "
        end
    end
    
    return text
end

-- ==========================================================
-- SERVER COMMAND HANDLER
-- ==========================================================
function DT_FactionDebugData.handleServerResponse(command, args)
    if command == "SyncFactionDebugData" then
        -- Cache the data locally
        DT_FactionDebugData.cachedFactionData = args.factions
        DT_FactionDebugData.cachedRosterData = args.roster
        
        -- Trigger pending callback
        if DT_FactionDebugData.pendingCallback then
            DT_FactionDebugData.pendingCallback(args.factions, args.roster)
            DT_FactionDebugData.pendingCallback = nil
        end
        
        return true
    elseif command == "SyncFactionRoster" then
        -- Detailed souls for a specific faction arrived (MP)
        local factionID = args.factionID
        local souls = args.souls
        
        DT_FactionDebugData.cachedRosterData = DT_FactionDebugData.cachedRosterData or {}
        DT_FactionDebugData.cachedRosterData.Souls = DT_FactionDebugData.cachedRosterData.Souls or {}
        
        -- Merge the new souls into our cache
        for uuid, soul in pairs(souls) do
            DT_FactionDebugData.cachedRosterData.Souls[uuid] = soul
        end
        
        -- Trigger pending callback
        if DT_FactionDebugData.pendingRosterCallback then
            DT_FactionDebugData.pendingRosterCallback(DT_FactionDebugData.cachedRosterData, factionID)
            DT_FactionDebugData.pendingRosterCallback = nil
        end
        
        return true
    elseif command == "TradeResult" then
        DynamicTrading.Log("DTCommons", "Debug", "UI", tostring(args and args.reason or "TradeResult"))
        if DT_FactionDebugWindow and DT_FactionDebugWindow.instance and DT_FactionDebugWindow.instance:getIsVisible() then
            DT_FactionDebugWindow.instance:refreshList()
        end
        if DT_ColonyArchiveDebugWindow
            and DT_ColonyArchiveDebugWindow.instance
            and DT_ColonyArchiveDebugWindow.instance:getIsVisible() then
            DT_ColonyArchiveDebugWindow.instance:refreshList()
        end
        return true
    end
    
    return false
end

-- Register the handler
DT_DebugNetworkAdapter.registerServerCommandHandler(function(command, args)
    DT_FactionDebugData.handleServerResponse(command, args)
end)

DynamicTrading.Log("DTCommons", "Debug", "UI", "Faction Debug Data Layer Loaded")
