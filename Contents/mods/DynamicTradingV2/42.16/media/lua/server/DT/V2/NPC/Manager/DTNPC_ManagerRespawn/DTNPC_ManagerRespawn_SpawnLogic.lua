-- ==============================================================================
-- DTNPC_ManagerRespawn_SpawnLogic.lua
-- Respawn checking and spawning logic for NPCs.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- Physical world bodies need a tighter spawn radius than metadata/radar discovery.
-- At larger distances the engine can unload zombies even though our roster still
-- considers them "nearby", which causes false respawn loops and visible pop-in.
local RESPAWN_RANGE = 55
local RESPAWN_CONFIRM_RANGE = 24
local RESPAWN_CONFIRM_MISSES = 3

DTNPCManager.RespawnRuntime = DTNPCManager.RespawnRuntime or {}
DTNPCManager.RespawnRuntime.MissingBodies = DTNPCManager.RespawnRuntime.MissingBodies or {}

local function clearMissingBodyCheck(uuid)
    if not uuid then return end
    DTNPCManager.RespawnRuntime.MissingBodies[uuid] = nil
end

local function noteMissingBodyCheck(uuid, player, dist)
    if not uuid then return nil end

    local entry = DTNPCManager.RespawnRuntime.MissingBodies[uuid]
    local now = getGameTime():getWorldAgeHours()

    if not entry then
        entry = {
            count = 0,
            firstSeenAt = now,
        }
        DTNPCManager.RespawnRuntime.MissingBodies[uuid] = entry
    end

    entry.count = (entry.count or 0) + 1
    entry.lastSeenAt = now
    entry.lastDistance = dist
    entry.playerName = player and player:getUsername() or nil

    return entry
end

local function isTrackedSquareLoaded(npcData)
    if not npcData or not npcData.lastX or not npcData.lastY then return false end

    local cell = getCell()
    if not cell then return false end

    local x = math.floor(npcData.lastX)
    local y = math.floor(npcData.lastY)
    local z = math.floor(npcData.lastZ or 0)

    return cell:getGridSquare(x, y, z) ~= nil
end

local function getNearestRespawnObserver(npcData)
    if not npcData or not npcData.lastX or not npcData.lastY then
        return nil, nil
    end

    local nearestPlayer = nil
    local nearestDist = nil

    local players = DTNPCManager.GetActivePlayers()
    for _, player in ipairs(players) do
        local dx = player:getX() - npcData.lastX
        local dy = player:getY() - npcData.lastY
        local dz = player:getZ() - (npcData.lastZ or 0)
        local dist = math.sqrt(dx * dx + dy * dy)

        if math.abs(dz) <= 1 and dist < RESPAWN_RANGE and (not nearestDist or dist < nearestDist) then
            nearestPlayer = player
            nearestDist = dist
        end
    end

    return nearestPlayer, nearestDist
end

local function isRosterStatusSpawnable(status)
    return status == "Resting" or status == "Working" or status == "Trading"
end

local function shouldKeepRosterSoulAbstract(uuid, registry, status)
    if tostring(status or "") ~= "Resting" then
        return false
    end
    if not DynamicTrading_Roster or not DynamicTrading_Roster.ShouldAbstractSoulAtRest then
        return false
    end
    return DynamicTrading_Roster.ShouldAbstractSoulAtRest(registry or uuid) == true
end

function DTNPCManager.CheckForRespawn(npcData, uuid)
    if not npcData or not npcData.lastX or not npcData.lastY then return end
    if npcData.status == "Dead" then return false end
    local bodyRecoveryRetryAt = tonumber(npcData.bodyRecoveryRetryAt) or 0
    if bodyRecoveryRetryAt > 0 and bodyRecoveryRetryAt > (getTimeInMillis and getTimeInMillis() or 0) then
        return false
    end

    local player, dist = getNearestRespawnObserver(npcData)
    if not player then
        clearMissingBodyCheck(uuid)
        return false
    end

    local zombie = DTNPCServerCore.FindZombieByUUID(uuid)

    if not zombie then
        if DTNPCServerCore.FindReusableWorldBody then
            zombie = DTNPCServerCore.FindReusableWorldBody(uuid, npcData, {
                allowPositionalMatch = true,
                positionRadius = 1.25,
            })
            if zombie and DTNPCManager.ReclaimZombie then
                clearMissingBodyCheck(uuid)
                DynamicTrading.Log("DTV2", "NPC", "Adopt", "Reclaiming saved-position startup body for " .. (npcData.name or uuid))
                DTNPCManager.ReclaimZombie(zombie, npcData, "respawn-position-adoption")
                return true
            end
        end

        local playerName = tostring(player:getUsername())

        if dist > RESPAWN_CONFIRM_RANGE then
            clearMissingBodyCheck(uuid)
            DTNPCManager.RespawnDebug.Log(
                "respawn_missing_defer_distance_" .. tostring(uuid),
                "Process=respawn_check decision=defer_missing uuid=" .. tostring(uuid) ..
                    " name=" .. tostring(npcData.name or uuid) ..
                    " player=" .. playerName ..
                    " dist=" .. string.format("%.1f", dist) ..
                    " reason=observer_not_close_enough",
                true
            )
            return false
        end

        if not isTrackedSquareLoaded(npcData) then
            clearMissingBodyCheck(uuid)
            DTNPCManager.RespawnDebug.Log(
                "respawn_missing_defer_square_" .. tostring(uuid),
                "Process=respawn_check decision=defer_missing uuid=" .. tostring(uuid) ..
                    " name=" .. tostring(npcData.name or uuid) ..
                    " player=" .. playerName ..
                    " dist=" .. string.format("%.1f", dist) ..
                    " reason=tracked_square_unloaded",
                true
            )
            return false
        end

        local missingEntry = noteMissingBodyCheck(uuid, player, dist)
        if not missingEntry or missingEntry.count < RESPAWN_CONFIRM_MISSES then
            DTNPCManager.RespawnDebug.Log(
                "respawn_missing_confirm_" .. tostring(uuid),
                "Process=respawn_check decision=wait_for_confirmed_missing uuid=" .. tostring(uuid) ..
                    " name=" .. tostring(npcData.name or uuid) ..
                    " player=" .. playerName ..
                    " dist=" .. string.format("%.1f", dist) ..
                    " missCount=" .. tostring(missingEntry and missingEntry.count or 0) ..
                    " requiredMisses=" .. tostring(RESPAWN_CONFIRM_MISSES),
                true
            )
            return false
        end

        clearMissingBodyCheck(uuid)
        DTNPCManager.RespawnDebug.Log(
            "respawn_missing_" .. tostring(uuid),
            "Process=respawn_check decision=spawn_missing_confirmed uuid=" .. tostring(uuid) ..
                " name=" .. tostring(npcData.name or uuid) ..
                " player=" .. playerName ..
                " dist=" .. string.format("%.1f", dist) ..
                " missCount=" .. tostring(missingEntry.count),
            true
        )
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Respawning NPC after confirmed missing body: " .. (npcData.name or uuid) .. " near player " .. playerName .. " (dist: " .. string.format("%.1f", dist) .. ")")
        DTNPCServerCore.RespawnNPC(npcData, uuid)
        return true
    elseif DTNPCManager.ReclaimZombie then
        clearMissingBodyCheck(uuid)

        if DTNPCServerCore.PruneDuplicateZombies then
            zombie = DTNPCServerCore.PruneDuplicateZombies(uuid, npcData, zombie, "respawn-check")
        end

        local modData = zombie:getModData()
        local needsRepair = (not modData.IsDTNPC)
            or (modData.DTNPC_UUID ~= uuid)
            or (not modData.DTNPC_Data)
            or (not modData.DTNPCVisualID)
            or (modData.DTNPCVisualID == 0)
            or (npcData.visualID and modData.DTNPCVisualID ~= npcData.visualID)

        if needsRepair then
            DTNPCManager.RespawnDebug.Log(
                "respawn_repair_" .. tostring(uuid),
                "Process=respawn_check decision=reclaim_repair uuid=" .. tostring(uuid) ..
                    " name=" .. tostring(npcData.name or uuid) ..
                    " player=" .. tostring(player:getUsername()) ..
                    " bodyInstanceID=" .. tostring(zombie:getPersistentOutfitID()) ..
                    " hasIsDTNPC=" .. tostring(modData.IsDTNPC == true) ..
                    " modUUID=" .. tostring(modData.DTNPC_UUID) ..
                    " visualID=" .. tostring(modData.DTNPCVisualID),
                true
            )
            DTNPCManager.ReclaimZombie(zombie, npcData, "respawn-check")
            return true
        end
    end

    return false
end

function DTNPCManager.CheckRosterSpawns()
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end

    if DynamicTrading_TradeScheduler and DynamicTrading_TradeScheduler.NormalizeRosterState then
        DynamicTrading_TradeScheduler.NormalizeRosterState(rosterData, getGameTime():getWorldAgeHours())
    end
    
    local players = DTNPCManager.GetActivePlayers()
    if #players == 0 then return end

    local soulCount = 0
    for _ in pairs(rosterData.Souls) do
        soulCount = soulCount + 1
    end

    DTNPCManager.RespawnDebug.Log(
        "cycle_start",
        "Process=start players=" .. tostring(#players) ..
            " souls=" .. tostring(soulCount) ..
            " hashInitialized=" .. tostring(DTNPC_SpatialHash.IsInitialized)
    )
    
    -- Initialize spatial hash if needed
    if not DTNPC_SpatialHash.IsInitialized then
        DTNPCManager.RespawnDebug.Log("hash_rebuild_start", "Process=spatial_hash_rebuild_start", true)
        DTNPC_SpatialHash.RebuildFromRoster(rosterData)
        local stats = DTNPC_SpatialHash.GetGridStats and DTNPC_SpatialHash.GetGridStats() or {}
        DTNPCManager.RespawnDebug.Log(
            "hash_rebuild_done",
            "Process=spatial_hash_rebuild_done cells=" .. tostring(stats.cellCount or 0) ..
                " indexedNPCs=" .. tostring(stats.totalNPCs or 0),
            true
        )
    end
    
    -- Cleanup empty cells periodically (dirty flag optimization)
    DTNPC_SpatialHash.CleanupEmptyCells()
    
    local currentHours = getGameTime():getWorldAgeHours()
    local spawnedCount = 0
    local hashSpawnAttempts = 0
    
    -- Query NPCs near each player using spatial hash (O(n) instead of O(n²))
    local hashCandidates = 0
    for _, player in ipairs(players) do
        local playerX = player:getX()
        local playerY = player:getY()
        local playerZ = player:getZ()
        
        -- Get NPCs in spawn range + buffer
        local nearbySpawns = DTNPC_SpatialHash.GetNPCsInRadius(playerX, playerY, RESPAWN_RANGE)
        
        for uuid, npcData in pairs(nearbySpawns) do
            hashCandidates = hashCandidates + 1
            -- Skip if already active
            if not DTNPCManager.Data[uuid] then
                local registry = rosterData.Souls[uuid]
                
                if registry then
                    local status = registry.status or "Resting"
                    
                    -- Skip if spawn backoff active
                    if not (registry.spawnRetryTime and currentHours < registry.spawnRetryTime) then
                        -- Only spawn spawnnable statuses
                        if isRosterStatusSpawnable(status) and not shouldKeepRosterSoulAbstract(uuid, registry, status) then
                            local targetX = npcData.x or (registry.lastX or (registry.homeCoords and registry.homeCoords.x))
                            local targetY = npcData.y or (registry.lastY or (registry.homeCoords and registry.homeCoords.y))
                            local targetZ = npcData.z or (registry.lastZ or (registry.homeCoords and registry.homeCoords.z) or 0)
                            
                            if targetX and targetY then
                                -- Final Z-check before spawn
                                local dz = playerZ - targetZ
                                if math.abs(dz) <= 1 then
                                    hashSpawnAttempts = hashSpawnAttempts + 1
                                    
                                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                                    if npcData then
                                        -- [NEW] Safety Check: Check if already physically in world before spawning clone
                                        local existingZombie = DTNPCServerCore.FindZombieByUUID(uuid)
                                        if existingZombie then
                                            if DTNPCServerCore.PruneDuplicateZombies then
                                                existingZombie = DTNPCServerCore.PruneDuplicateZombies(uuid, npcData, existingZombie, "roster-hash")
                                            end
                                            DTNPCManager.RespawnDebug.Log(
                                                "roster_hash_reclaim_" .. tostring(uuid),
                                                "Process=roster_hash decision=reclaim_existing uuid=" .. tostring(uuid) ..
                                                    " name=" .. tostring(npcData.name or uuid) ..
                                                    " bodyInstanceID=" .. tostring(existingZombie:getPersistentOutfitID()),
                                                true
                                            )
                                            DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (npcData.name or uuid) .. " already found in world. Reclaiming instead of spawning duplicate.")
                                            if DTNPCManager.ReclaimZombie then
                                                DTNPCManager.ReclaimZombie(existingZombie, npcData, "roster-hash")
                                            else
                                                DTNPCManager.Register(existingZombie, npcData)
                                            end
                                            registry.spawnRetryTime = nil
                                            spawnedCount = spawnedCount + 1
                                        else
                                            npcData.lastX = targetX
                                            npcData.lastY = targetY
                                            npcData.lastZ = targetZ
                                            npcData.status = status
                                            DTNPCManager.RespawnDebug.Log(
                                                "roster_hash_spawn_" .. tostring(uuid),
                                                "Process=roster_hash decision=spawn_new uuid=" .. tostring(uuid) ..
                                                    " name=" .. tostring(npcData.name or uuid) ..
                                                    " target=" .. tostring(targetX) .. "," .. tostring(targetY) .. "," .. tostring(targetZ),
                                                true
                                            )
                                            
                                            local zombie = DTNPCServerCore.RespawnNPC(npcData, uuid)
                                            if zombie then
                                                registry.spawnRetryTime = nil
                                                
                                                -- Initialize distance frequency tracking
                                                DTNPC_DistanceFrequency.InitializeNPC(uuid)
                                                
                                                spawnedCount = spawnedCount + 1
                                            else
                                                registry.spawnRetryTime = currentHours + 0.1
                                            end
                                        end
                                    end
                                end
                            end
                        elseif shouldKeepRosterSoulAbstract(uuid, registry, status) then
                            DTNPCManager.RespawnDebug.Log(
                                "roster_hash_abstract_" .. tostring(uuid),
                                "Process=roster_hash decision=skip_abstract_resting uuid=" .. tostring(uuid) ..
                                    " name=" .. tostring(registry.name or uuid),
                                true
                            )
                        end
                    end
                end
            end
        end
    end
    
    -- FALLBACK: If spatial hash yielded nothing, scan roster directly for nearby NPCs
    -- This ensures spawning works even if hash is stale or uninitialized
    local usedFallback = false
    local fallbackSpawnAttempts = 0
    if hashCandidates == 0 and #players > 0 then
        usedFallback = true
        DTNPCManager.RespawnDebug.Log("fallback_start", "Process=fallback_roster_scan_start reason=hash_empty", true)
        for uuid, registry in pairs(rosterData.Souls) do
            -- Skip if already active (Live)
            if not DTNPCManager.Data[uuid] then
                local status = registry.status or "Resting"
                
                -- Skip if spawn backoff active
                if not (registry.spawnRetryTime and currentHours < registry.spawnRetryTime) then
                    if isRosterStatusSpawnable(status) and not shouldKeepRosterSoulAbstract(uuid, registry, status) then
                        local npcX = registry.lastX or (registry.homeCoords and registry.homeCoords.x)
                        local npcY = registry.lastY or (registry.homeCoords and registry.homeCoords.y)
                        local npcZ = registry.lastZ or (registry.homeCoords and registry.homeCoords.z) or 0
                        
                        if npcX and npcY then
                            -- Check if any player is within range
                            for _, player in ipairs(players) do
                                local playerX = player:getX()
                                local playerY = player:getY()
                                local playerZ = player:getZ()
                                
                                local dx = playerX - npcX
                                local dy = playerY - npcY
                                local dz = playerZ - npcZ
                                local dist = math.sqrt(dx * dx + dy * dy)
                                
                                if math.abs(dz) <= 1 and dist < RESPAWN_RANGE then
                                    fallbackSpawnAttempts = fallbackSpawnAttempts + 1
                                    
                                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                                    if npcData then
                                        local existingZombie = DTNPCServerCore.FindZombieByUUID(uuid)
                                        if existingZombie then
                                            if DTNPCServerCore.PruneDuplicateZombies then
                                                existingZombie = DTNPCServerCore.PruneDuplicateZombies(uuid, npcData, existingZombie, "roster-fallback")
                                            end
                                            DTNPCManager.RespawnDebug.Log(
                                                "roster_fallback_reclaim_" .. tostring(uuid),
                                                "Process=roster_fallback decision=reclaim_existing uuid=" .. tostring(uuid) ..
                                                    " name=" .. tostring(npcData.name or uuid) ..
                                                    " bodyInstanceID=" .. tostring(existingZombie:getPersistentOutfitID()),
                                                true
                                            )
                                            DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (npcData.name or uuid) .. " already found during fallback scan. Reclaiming instead of spawning duplicate.")
                                            if DTNPCManager.ReclaimZombie then
                                                DTNPCManager.ReclaimZombie(existingZombie, npcData, "roster-fallback")
                                            else
                                                DTNPCManager.Register(existingZombie, npcData)
                                            end
                                            registry.spawnRetryTime = nil
                                            spawnedCount = spawnedCount + 1
                                        else
                                            npcData.lastX = npcX
                                            npcData.lastY = npcY
                                            npcData.lastZ = npcZ
                                            npcData.status = status
                                            DTNPCManager.RespawnDebug.Log(
                                                "roster_fallback_spawn_" .. tostring(uuid),
                                                "Process=roster_fallback decision=spawn_new uuid=" .. tostring(uuid) ..
                                                    " name=" .. tostring(npcData.name or uuid) ..
                                                    " target=" .. tostring(npcX) .. "," .. tostring(npcY) .. "," .. tostring(npcZ),
                                                true
                                            )
                                            
                                            local zombie = DTNPCServerCore.RespawnNPC(npcData, uuid)
                                            if zombie then
                                                registry.spawnRetryTime = nil
                                                DTNPC_DistanceFrequency.InitializeNPC(uuid)
                                                spawnedCount = spawnedCount + 1
                                            else
                                                registry.spawnRetryTime = currentHours + 0.1
                                            end
                                        end
                                    end
                                    break  -- Spawned for this player, move to next NPC
                                end
                            end
                        end
                    elseif shouldKeepRosterSoulAbstract(uuid, registry, status) then
                        DTNPCManager.RespawnDebug.Log(
                            "roster_fallback_abstract_" .. tostring(uuid),
                            "Process=roster_fallback decision=skip_abstract_resting uuid=" .. tostring(uuid) ..
                                " name=" .. tostring(registry.name or uuid),
                            true
                        )
                    end
                end
            end
        end
    end

    local resultMessage =
        "Process=check_complete spawned=" .. tostring(spawnedCount) ..
        " hashCandidates=" .. tostring(hashCandidates) ..
        " hashAttempts=" .. tostring(hashSpawnAttempts) ..
        " fallbackUsed=" .. tostring(usedFallback) ..
        " fallbackAttempts=" .. tostring(fallbackSpawnAttempts)

    -- Always print if we did useful work; otherwise print periodically.
    DTNPCManager.RespawnDebug.Log("cycle_result", resultMessage, spawnedCount > 0 or usedFallback)
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loaded successfully")
