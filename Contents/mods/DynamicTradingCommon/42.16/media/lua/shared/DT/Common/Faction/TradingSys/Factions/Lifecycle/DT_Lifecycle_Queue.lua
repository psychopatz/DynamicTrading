return function(context)
    local Lifecycle = context.Lifecycle
    local MOD_DATA_KEY = context.MOD_DATA_KEY
    local EXPLORATION_DATA_KEY = context.EXPLORATION_DATA_KEY
    local deferredTownQueue = context.deferredTownQueue

    function context.ensureRosterPoolMinimums(data)
        if not (DynamicTrading and DynamicTrading.GetRosterPoolEntriesForFaction and DynamicTrading_Roster and DynamicTrading_Roster.AddSoul) then
            return false
        end

        local rosterData = ModData.get("DynamicTrading_Roster") or {}
        local souls = rosterData.Souls or {}
        local changed = false

        for factionID, faction in pairs(data or {}) do
            if type(faction) == "table" and faction.playerOwned ~= true then
                local members = DynamicTrading_Roster.GetFactionMembers and DynamicTrading_Roster.GetFactionMembers(factionID) or {}
                local archetypeCounts = {}

                for _, uuid in ipairs(members) do
                    local soul = souls[uuid] or (DynamicTrading_Roster.GetSoulRegistry and DynamicTrading_Roster.GetSoulRegistry(uuid)) or nil
                    if soul and tostring(soul.status or "") ~= "Dead" then
                        local archetypeID = tostring(soul.archetypeID or "General")
                        archetypeCounts[archetypeID] = (archetypeCounts[archetypeID] or 0) + 1
                    end
                end

                local rosterEntries = DynamicTrading.GetRosterPoolEntriesForFaction(factionID)
                for _, entry in ipairs(rosterEntries or {}) do
                    local archetypeID = tostring(entry.archetypeID or "General")
                    local currentCount = archetypeCounts[archetypeID] or 0
                    local requiredCount = math.max(0, tonumber(entry.minCount) or 0)

                    while currentCount < requiredCount do
                        DynamicTrading_Roster.AddSoul(factionID, archetypeID, faction.homeCoords, { suppressRecruitLog = true })
                        faction.memberCount = math.max(0, tonumber(faction.memberCount) or 0) + 1
                        currentCount = currentCount + 1
                        archetypeCounts[archetypeID] = currentCount
                        changed = true
                    end
                end
            end
        end

        return changed
    end

    function context.collectSpatialAnchorPlayers()
        local players = {}
        local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil

        if onlinePlayers then
            for index = 0, onlinePlayers:size() - 1 do
                local player = onlinePlayers:get(index)
                if player and player.getX and player.getY then
                    players[#players + 1] = player
                end
            end
        end

        if #players == 0 then
            local localPlayer = nil
            if getSpecificPlayer then
                localPlayer = getSpecificPlayer(0)
            elseif getPlayer then
                localPlayer = getPlayer()
            end

            if localPlayer and localPlayer.getX and localPlayer.getY then
                players[#players + 1] = localPlayer
            end
        end

        return players
    end

    function context.sortDeferredTownQueue()
        table.sort(deferredTownQueue, function(left, right)
            if left.priority ~= right.priority then
                return left.priority > right.priority
            end
            return tostring(left.spawnTown) < tostring(right.spawnTown)
        end)
    end

    function context.ensureExplorationData()
        if not ModData.exists(EXPLORATION_DATA_KEY) then
            ModData.add(EXPLORATION_DATA_KEY, {
                visitedTowns = {},
                playerLastTown = {},
            })
        end

        local data = ModData.get(EXPLORATION_DATA_KEY) or {}
        data.visitedTowns = type(data.visitedTowns) == "table" and data.visitedTowns or {}
        data.playerLastTown = type(data.playerLastTown) == "table" and data.playerLastTown or {}
        return data
    end

    function context.buildExistingTownCounts(data)
        local counts = {}

        for id, faction in pairs(data or {}) do
            if id ~= "Independent"
                and type(faction) == "table"
                and faction.excludeFromPopulationPool ~= true
                and faction.excludeFromFactionCap ~= true
                and faction.isSystemFaction ~= true
                and faction.systemFaction ~= true then
                local key = context.normalizeTownKey(faction.town)
                if key then
                    counts[key] = (counts[key] or 0) + 1
                end
            end
        end

        return counts
    end

    function context.buildExistingCountyCounts(data)
        local counts = {}

        for id, faction in pairs(data or {}) do
            if id ~= "Independent"
                and type(faction) == "table"
                and faction.excludeFromPopulationPool ~= true
                and faction.excludeFromFactionCap ~= true
                and faction.isSystemFaction ~= true
                and faction.systemFaction ~= true then
                local homeCoords = type(faction.homeCoords) == "table" and faction.homeCoords or nil
                local countyName = (homeCoords and homeCoords.county) or nil
                if (not countyName or countyName == "")
                    and homeCoords
                    and DT_GeolocatorSystem
                    and DT_GeolocatorSystem.GetCountyName then
                    countyName = DT_GeolocatorSystem.GetCountyName(homeCoords.x, homeCoords.y)
                end
                local key = context.normalizeTownKey(countyName)
                if key then
                    counts[key] = (counts[key] or 0) + 1
                end
            end
        end

        return counts
    end

    function context.collectPriorityTownKeys()
        local keys = {}
        if not DT_GeolocatorSystem or not DT_GeolocatorSystem.GetLocation then
            return keys
        end

        for _, player in ipairs(context.collectSpatialAnchorPlayers()) do
            local location = DT_GeolocatorSystem.GetLocation(math.floor(player:getX()), math.floor(player:getY()))
            if location then
                local locationKey = context.normalizeTownKey(location.shortName or location.id)
                if locationKey then
                    keys[locationKey] = true
                end
            end
        end

        return keys
    end

    function context.getStartupFactionsPerTown()
        local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
        return math.max(0, tonumber(sandbox and sandbox.MaxFactionsPerTown) or 2)
    end

    function context.scheduleMissingTownPopulation(data)
        for index = #deferredTownQueue, 1, -1 do
            deferredTownQueue[index] = nil
        end

        if type(DT_FactionLocations) ~= "table" then
            return 0, 0
        end

        local existingCounts = context.buildExistingTownCounts(data)
        local priorityTownKeys = context.collectPriorityTownKeys()
        local startupFactionsPerTown = context.getStartupFactionsPerTown()
        local memberCount = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.FactionStartPop) or 3
        local priorityCount = 0

        for townID, townData in pairs(DT_FactionLocations) do
            local spawnTown = (type(townData) == "table" and townData.name) or townID
            local factionSeed = (type(townData) == "table" and townData.id) or townID
            local townKey = context.normalizeTownKey(spawnTown) or context.normalizeTownKey(townID)
            local existing = townKey and (existingCounts[townKey] or 0) or 0
            local missing = math.max(0, startupFactionsPerTown - existing)
            local priority = townKey and priorityTownKeys[townKey] or false

            for _ = 1, missing do
                deferredTownQueue[#deferredTownQueue + 1] = {
                    spawnTown = spawnTown,
                    townKey = townKey,
                    factionSeed = factionSeed,
                    memberCount = memberCount,
                    priority = priority and 1 or 0,
                    queueSource = priority and "startup-near-player" or "startup-deferred",
                }
                if priority then
                    priorityCount = priorityCount + 1
                end
            end
        end

        context.sortDeferredTownQueue()
        return #deferredTownQueue, priorityCount
    end

    function context.promoteTownQueueEntries(townName, priority)
        local townKey = context.normalizeTownKey(townName)
        if not townKey then
            return 0
        end

        local promoted = 0
        for _, entry in ipairs(deferredTownQueue) do
            local entryTownKey = entry.townKey or context.normalizeTownKey(entry.spawnTown)
            if entryTownKey == townKey then
                local targetPriority = tonumber(priority) or 2
                if (tonumber(entry.priority) or 0) < targetPriority then
                    entry.priority = targetPriority
                    entry.queueSource = "player-exploration"
                end
                promoted = promoted + 1
            end
        end

        if promoted > 0 then
            context.sortDeferredTownQueue()
            DynamicTrading.Log(
                "DTCommons",
                "Faction",
                "Queue",
                "Prioritized deferred town queue for " .. tostring(townName)
                    .. "; promotedEntries=" .. tostring(promoted)
                    .. "; queueSize=" .. tostring(#deferredTownQueue)
            )
        end

        return promoted
    end

    function context.handleVisitedTown(player, townName, reason)
        local normalizedTown = context.normalizeTownKey(townName)
        if not normalizedTown then
            return 0
        end

        local explorationData = context.ensureExplorationData()
        local visitedBefore = explorationData.visitedTowns[normalizedTown] == true
        if not visitedBefore then
            explorationData.visitedTowns[normalizedTown] = true
            ModData.transmit(EXPLORATION_DATA_KEY)
            DynamicTrading.Log(
                "DTCommons",
                "Faction",
                "Exploration",
                "Town discovered through exploration: " .. tostring(townName)
                    .. " by " .. tostring(player and player.getUsername and player:getUsername() or "unknown-player")
            )
        end

        local promoted = context.promoteTownQueueEntries(townName, 2)
        if promoted <= 0 then
            DynamicTrading.Log(
                "DTCommons",
                "Faction",
                "Exploration",
                "Town visit did not change queue state for " .. tostring(townName)
                    .. "; no deferred factions remain for that town."
            )
            return 0
        end

        if not context.ensureGeolocatorReady() then
            context.deferredBootstrapPending = true
            DynamicTrading.Log(
                "DTCommons",
                "Faction",
                "Exploration",
                "Queued town " .. tostring(townName)
                    .. " as high-priority exploration target while geolocator finishes preparing."
            )
            return 0
        end

        local immediateProcessed = context.processDeferredTownQueue(
            tostring(reason or "exploration") .. ":" .. tostring(normalizedTown),
            math.max(1, promoted),
            false
        )

        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Exploration",
            "Town " .. tostring(townName)
                .. " moved to the front of the deferred simulation queue during " .. tostring(reason or "exploration")
                .. "; immediateProcessed=" .. tostring(immediateProcessed)
                .. "; remainingDeferred=" .. tostring(#deferredTownQueue)
        )
        return promoted
    end

    function context.updateExplorationDrivenTownGeneration()
        if not context.IS_SERVER_RUNTIME or not DT_GeolocatorSystem or not DT_GeolocatorSystem.GetLocation then
            return 0
        end

        if #deferredTownQueue == 0 then
            return 0
        end

        local explorationData = context.ensureExplorationData()
        local processed = 0

        for _, player in ipairs(context.collectSpatialAnchorPlayers()) do
            local username = player.getUsername and player:getUsername() or tostring(player)
            local location = DT_GeolocatorSystem.GetLocation(math.floor(player:getX()), math.floor(player:getY()))
            local townName = location and (location.shortName or location.id) or nil
            local townKey = context.normalizeTownKey(townName)
            local lastTownKey = explorationData.playerLastTown[username]

            if townKey and townKey ~= lastTownKey then
                explorationData.playerLastTown[username] = townKey
                processed = processed + context.handleVisitedTown(player, townName, "player-visit")
            elseif not townKey and lastTownKey ~= nil then
                explorationData.playerLastTown[username] = nil
            end
        end

        return processed
    end

    context.processDeferredTownQueue = function(reason, maxEntries, randomize)
        if #deferredTownQueue == 0 then
            return 0
        end

        local limit = math.max(1, tonumber(maxEntries) or 1)
        local processed = 0
        local scanned = 0
        local initialQueueSize = #deferredTownQueue

        while processed < limit and #deferredTownQueue > 0 and scanned < initialQueueSize do
            local index = randomize and (ZombRand(#deferredTownQueue) + 1) or 1
            local entry = table.remove(deferredTownQueue, index)
            if entry then
                scanned = scanned + 1
                local townBlocked = DT_FactionRespawnState
                    and DT_FactionRespawnState.IsTownOnCooldown
                    and DT_FactionRespawnState.IsTownOnCooldown(entry.spawnTown)

                if townBlocked then
                    deferredTownQueue[#deferredTownQueue + 1] = entry
                else
                    DynamicTrading.Log(
                        "DTCommons",
                        "Faction",
                        "Queue",
                        "Processing deferred town entry town=" .. tostring(entry.spawnTown)
                            .. " priority=" .. tostring(entry.priority)
                            .. " source=" .. tostring(entry.queueSource or "unknown")
                            .. " reason=" .. tostring(reason or "deferred")
                    )
                    local factionID = tostring(entry.factionSeed) .. "_" .. tostring(100000 + ZombRand(900000))
                    Lifecycle.CreateFaction(factionID, {
                        town = entry.spawnTown,
                        memberCount = entry.memberCount,
                    })
                    processed = processed + 1
                end
            end
        end

        if processed > 0 then
            DynamicTrading.Log(
                "DTCommons",
                "Faction",
                "Logic",
                "Processed " .. tostring(processed) .. " deferred town spawns during " .. tostring(reason or "deferred")
                    .. "; remaining=" .. tostring(#deferredTownQueue)
            )
        end

        return processed
    end
end
