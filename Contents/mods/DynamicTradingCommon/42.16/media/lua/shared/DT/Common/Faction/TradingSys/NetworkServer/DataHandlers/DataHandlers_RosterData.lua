-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_RosterData.lua
-- Logic: Trader and roster data synchronization handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local commandModule = context.COMMAND_MODULE

    local function isOwnedTravelCompanionForPlayer(player, npcData)
        if not player or not npcData then
            return false
        end

        local isCompanion = tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
            or tostring(npcData.linkedWorkerID or "") ~= ""
        if not isCompanion then
            return false
        end

        local playerID = player.getOnlineID and player:getOnlineID() or nil
        if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
            return true
        end

        local username = player.getUsername and player:getUsername() or nil
        if not username or username == "" then
            return false
        end

        return (npcData.master and tostring(npcData.master) == username)
            or (npcData.ownerUsername and tostring(npcData.ownerUsername) == username)
            or (npcData.dcCompanionOwner and tostring(npcData.dcCompanionOwner) == username)
    end

    local function buildRadarSoulEntry(soul, npcData, radarCategory)
        local entry = {}
        for key, value in pairs(soul or {}) do
            entry[key] = value
        end

        if npcData then
            entry.state = npcData.state or entry.state
            entry.status = npcData.status or entry.status
            entry.lastX = npcData.lastX or entry.lastX
            entry.lastY = npcData.lastY or entry.lastY
            entry.lastZ = npcData.lastZ or entry.lastZ
            entry.homeCoords = npcData.homeCoords or entry.homeCoords
        end

        entry.radarCategory = radarCategory
        entry.isCallableCompanion = radarCategory == "Callable"

        return entry
    end

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
            DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncTrader", response)
        end
    end

    -- [ROSTER DATA REQUEST (FOR RADAR)]
    Handlers.RequestRoster = function(player, args)
        local rosterData = ModData.get("DynamicTrading_Roster") or {}
        local factionData = ModData.get("DynamicTrading_Factions") or {}
        local engineData = DynamicTrading_Engine.GetEngineData()
        local liveNPCData = DTNPCManager and DTNPCManager.Data or nil

        -- Optimize Radar Roster: keep trading souls plus the local player's callable companions.
        local minimalSouls = {}
        if rosterData.Souls then
            for uuid, soul in pairs(rosterData.Souls) do
                if soul.status == "Trading" then
                    minimalSouls[uuid] = buildRadarSoulEntry(soul, liveNPCData and liveNPCData[uuid] or nil, "Stationary")
                else
                    local npcData = liveNPCData and liveNPCData[uuid] or nil
                    if isOwnedTravelCompanionForPlayer(player, npcData) then
                        minimalSouls[uuid] = buildRadarSoulEntry(soul, npcData, "Callable")
                    end
                end
            end
        end

        local minimalRoster = {
            FactionMembers = rosterData.FactionMembers,
            Souls = minimalSouls,
            Traders = rosterData.Traders
        }

        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncRoster", {
            roster = minimalRoster,
            factions = factionData,
            globalEvents = engineData and engineData.EventSystem and engineData.EventSystem.activeEvents or {}
        })
    end
end
