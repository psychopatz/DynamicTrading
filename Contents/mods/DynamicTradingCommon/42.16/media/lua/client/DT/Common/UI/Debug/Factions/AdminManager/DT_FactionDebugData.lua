-- ==============================================================================
-- DT_FactionDebugData.lua
-- Faction Debug Tool: Data Management Layer
-- Handles data fetching, caching, and population logic
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"
pcall(require, "DT/Common/FactionZones/DT_FactionBaseZones")

DT_FactionDebugData = DT_FactionDebugData or {}

-- ==========================================================
-- CACHED DATA (Multiplayer Optimization)
-- ==========================================================
DT_FactionDebugData.cachedFactionData = nil
DT_FactionDebugData.cachedRosterData = nil
DT_FactionDebugData.cachedRosterPages = DT_FactionDebugData.cachedRosterPages or {}
DT_FactionDebugData.ROSTER_PAGE_LIMIT = 40

local function isDebugUIEnabled()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    return (sandbox and sandbox.Debug == true)
        or (sandbox and sandbox.NPCDebug == true)
        or (sandbox and sandbox.NPCProtectDebug == true)
end

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

function DT_FactionDebugData.refreshRosterForFaction(factionID, callback, offset, limit)
    if isClient() and not isServer() then
        if isDebugUIEnabled() then
            DynamicTrading.Log("DTCommons", "Debug", "UI", "Requesting detailed roster for faction: " .. tostring(factionID))
        end
        DT_DebugNetworkAdapter.requestFactionRoster(
            factionID,
            offset ~= nil and math.max(0, math.floor(tonumber(offset) or 0)) or nil,
            limit ~= nil and math.max(1, math.floor(tonumber(limit) or DT_FactionDebugData.ROSTER_PAGE_LIMIT)) or nil
        )
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
    text = text .. "State: " .. tostring(faction.state or "N/A") .. " | Pop: " .. tostring(faction.memberCount or "N/A") .. " <LINE> "
    
    if faction.homeCoords then
        text = text .. "Base: " .. faction.homeCoords.name .. " <LINE> "
        text = text .. "Coords: " .. faction.homeCoords.x .. "," .. faction.homeCoords.y .. "," .. faction.homeCoords.z .. " <LINE> "
    else
        text = text .. "Base: NOMADIC <LINE> "
    end

    if faction.collapsed == true or tostring(faction.state or "") == "Collapsed" then
        text = text .. " <LINE> <RGB:1,0.25,0.2> COLLAPSE DATA: <LINE> "
        text = text .. " <RGB:0.7,0.7,0.7> - Reason: <RGB:1,1,1> " .. tostring(faction.collapseReason or "unknown") .. " <LINE> "
        text = text .. " <RGB:0.7,0.7,0.7> - Last Event: <RGB:1,1,1> " .. tostring(faction.collapseLastEvent or "N/A") .. " <LINE> "
        text = text .. " <RGB:0.7,0.7,0.7> - Collapsed At: <RGB:1,1,1> " .. tostring(faction.collapsedAt or "N/A") .. "h <LINE> "
    end

    local zoneAPI = DynamicTrading and DynamicTrading.FactionBaseZones or nil
    local zoneRows = zoneAPI and zoneAPI.GetDebugRows and zoneAPI.GetDebugRows(faction) or {}
    if #zoneRows > 0 then
        text = text .. " <LINE> <RGB:0.4,0.8,1> BASE OVERLAY ZONES: <LINE> "
        for _, row in ipairs(zoneRows) do
            local rect = row.rect or {}
            local point = row.point or {}
            text = text
                .. " <RGB:0.7,0.7,0.7> - "
                .. tostring(row.label or row.zoneType or row.id or "Zone")
                .. ": <RGB:1,1,1> "
                .. tostring(rect[1] or "?")
                .. ","
                .. tostring(rect[2] or "?")
                .. " to "
                .. tostring(rect[3] or "?")
                .. ","
                .. tostring(rect[4] or "?")
                .. " @ "
                .. tostring(rect[5] or point.z or 0)
                .. " <LINE> "
        end
    end
    
    text = text .. "ColonyWealth: <RGB:0.2,1,0.2> $" .. tostring(faction.ColonyWealth or 0) .. " <LINE> "
    text = text .. " <LINE> <RGB:0.2,0.2,1> PLAYER DISPOSITIONS: <LINE> "

    if faction.playerDisposition and type(faction.playerDisposition) == "table" then
        for user, rep in pairs(faction.playerDisposition) do
            text = text .. " <RGB:0.7,0.7,0.7> - " .. user .. ": <RGB:1,1,1> " .. rep .. " <LINE> "
        end
    else
        text = text .. " <RGB:0.7,0.7,0.7> - No player disposition data. <LINE> "
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
        local souls = args.souls or args.soulsPage or {}
        local members = args.members or args.membersPage or {}

        DT_FactionDebugData.cachedRosterData = DT_FactionDebugData.cachedRosterData or {}
        DT_FactionDebugData.cachedRosterData.Souls = DT_FactionDebugData.cachedRosterData.Souls or {}
        DT_FactionDebugData.cachedRosterData.FactionMembers = DT_FactionDebugData.cachedRosterData.FactionMembers or {}
        DT_FactionDebugData.cachedRosterData.FactionMembers[factionID] = members
        DT_FactionDebugData.cachedRosterPages[tostring(factionID)] = {
            factionID = factionID,
            offset = math.max(0, math.floor(tonumber(args.offset) or 0)),
            limit = math.max(1, math.floor(tonumber(args.limit) or DT_FactionDebugData.ROSTER_PAGE_LIMIT)),
            totalMembers = math.max(0, math.floor(tonumber(args.totalMembers) or #members)),
            members = members,
            souls = souls,
        }

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
