-- ==============================================================================
-- DTNPC_ManagerTick_WorldSweep.lua
-- Main scheduler and world sweep for server-side NPC tick management.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}
DTNPCManager.TickRuntime = DTNPCManager.TickRuntime or {}

local tickInternal = DTNPCManager.TickInternal
local tickRuntime = DTNPCManager.TickRuntime
tickRuntime.WorldSweepBuckets = tickRuntime.WorldSweepBuckets or { phase = 0 }

local function isPotentialDTNPCZombie(zombie)
    if not zombie then
        return false
    end

    local modData = zombie:getModData()
    if modData and (modData.DTNPC_UUID or modData.IsDTNPC or modData.DTNPC_Data or modData.DTNPCBrain) then
        return true
    end

    local bodyInstanceID = zombie:getPersistentOutfitID()
    return bodyInstanceID ~= nil
        and DTNPCManager.BodyInstanceIDToUUID ~= nil
        and DTNPCManager.BodyInstanceIDToUUID[bodyInstanceID] ~= nil
end

local function isZombieBucketActive(zombie, phase, divisor)
    local numericDivisor = math.max(1, math.floor(tonumber(divisor) or 1))
    local bodyInstanceID = zombie and zombie.getPersistentOutfitID and tonumber(zombie:getPersistentOutfitID()) or 0
    bodyInstanceID = math.max(0, math.floor(bodyInstanceID or 0))
    return ((bodyInstanceID + math.max(0, math.floor(tonumber(phase) or 0))) % numericDivisor) == 0
end

local function processZombieTracking(zombie, uuid, savedData, players, shouldBroadcast, runDistanceRefresh, runRepairCheck)
    if DTNPC and DTNPC.ApplySafetyFlags then
        DTNPC.ApplySafetyFlags(zombie, savedData, { clearPlayerTarget = true })
    elseif DTNPC and DTNPC.ApplyCharacterFlags then
        DTNPC.ApplyCharacterFlags(zombie, savedData)
    end

    if DTNPCHealth and DTNPCHealth.ProcessDeferredSpawnRestore then
        local restored = DTNPCHealth.ProcessDeferredSpawnRestore(zombie, savedData)
        if restored then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Health",
                "Server manager restored deferred engine buffer for "
                    .. tostring(savedData.name or uuid)
                    .. " uuid=" .. tostring(uuid)
                    .. " engineHealth=" .. tostring(zombie:getHealth())
            )
        end
    end

    local currentBodyInstanceID = zombie:getPersistentOutfitID()
    local savedBodyInstanceID = savedData.currentBodyInstanceID
    if savedBodyInstanceID ~= currentBodyInstanceID then
        if savedBodyInstanceID then
            DTNPCManager.BodyInstanceIDToUUID[savedBodyInstanceID] = nil
        end
        savedData.currentBodyInstanceID = currentBodyInstanceID
        DTNPCManager.BodyInstanceIDToUUID[currentBodyInstanceID] = uuid
    end

    local newX = math.floor(zombie:getX())
    local newY = math.floor(zombie:getY())
    local newZ = math.floor(zombie:getZ())
    savedData.lastX = newX
    savedData.lastY = newY
    savedData.lastZ = newZ
    savedData.health = zombie:getHealth()

    DTNPC_SpatialHash.InsertNPC(uuid, newX, newY, newZ, nil)

    if runDistanceRefresh and #players > 0 then
        DTNPC_DistanceFrequency.UpdateNPC(uuid, newX, newY, players)
    end

    if zombie:isUseless() and (savedData.state == "Stay" or savedData.state == "Guard" or savedData.state == "Idle" or savedData.state == "Trading") then
        zombie:setPath2(nil)
        zombie:setTarget(nil)
    end

    if runRepairCheck then
        local modData = zombie:getModData()
        local needsRepair = (not modData.IsDTNPC)
            or (modData.DTNPC_UUID ~= uuid)
            or (not modData.DTNPC_Data)
            or (not modData.DTNPCVisualID)
            or (modData.DTNPCVisualID == 0)
            or (savedData.visualID and modData.DTNPCVisualID ~= savedData.visualID)

        if needsRepair and DTNPCManager.ReclaimZombie then
            DTNPCManager.ReclaimZombie(zombie, savedData, "tick-repair")
        end
    end

    if shouldBroadcast and DTNPCServerCore and DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, savedData)
    end
end

local function adoptExistingZombie(zombie, uuid, rosterData, players)
    if not (DTNPCManager.IsPhysicalWorldStatus and DTNPCManager.IsPhysicalWorldStatus(rosterData.status, rosterData)) then
        tickInternal.RemoveStaleWorldBody(uuid, zombie, rosterData, "active-adoption-away")
        return nil
    end

    local isWorkerLinkedCompanion = tostring(rosterData.dcCompanionJob or "") == "TravelCompanion"
        and tostring(rosterData.linkedWorkerID or "") ~= ""
    if isWorkerLinkedCompanion and #players <= 0 then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Adopt",
            "Skipping active adoption for worker-linked travel companion with no active players: " .. tostring(rosterData.name or uuid)
        )
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        return nil
    end

    DynamicTrading.Log("DTV2", "NPC", "Adopt", "Active Adoption: Found existing NPC in world, reclaiming: " .. (rosterData.name or uuid))
    if DTNPCManager.ReclaimZombie then
        DTNPCManager.ReclaimZombie(zombie, rosterData, "active-adoption")
    else
        DTNPCManager.Register(zombie, rosterData)
    end

    return DTNPCManager.Data[uuid]
end

local function processZombie(zombie, players, shouldBroadcast, bucketPhase)
    if zombie and zombie:isDead() then
        local deadUUID = DTNPCManager.GetUUIDFromZombie(zombie)
        if deadUUID and DTNPCLifecycle and DTNPCLifecycle.HandleZombieDead then
            DTNPCLifecycle.HandleZombieDead(zombie)
        end
        return
    end

    if not zombie then
        return
    end

    if not isPotentialDTNPCZombie(zombie) then
        return
    end

    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    if not uuid then
        return
    end

    local savedData = DTNPCManager.Data[uuid]
    if not savedData and DynamicTrading_Roster then
        local rosterData = DynamicTrading_Roster.GetSoul(uuid)
        if rosterData and rosterData.status ~= "Dead" then
            savedData = adoptExistingZombie(zombie, uuid, rosterData, players)
        end
    end

    if savedData then
        processZombieTracking(
            zombie,
            uuid,
            savedData,
            players,
            shouldBroadcast,
            shouldBroadcast or isZombieBucketActive(zombie, bucketPhase, 2),
            isZombieBucketActive(zombie, bucketPhase, 4)
        )
    end
end

function DTNPCManager.OnTick()
    local counters = tickRuntime.Counters
    local flags = tickRuntime.Flags
    local constants = tickRuntime.Constants
    local cachedCell = nil
    local cachedZombieList = nil
    local cachedPlayers = nil

    local function getWorldZombieList()
        if cachedZombieList ~= nil then
            return cachedZombieList
        end

        cachedCell = cachedCell or getCell()
        cachedZombieList = cachedCell and cachedCell:getZombieList() or false
        return cachedZombieList ~= false and cachedZombieList or nil
    end

    local function getActivePlayers()
        if cachedPlayers == nil then
            cachedPlayers = DTNPCManager.GetActivePlayers()
        end
        return cachedPlayers
    end

    counters.tickCounter = counters.tickCounter + 1
    counters.positionBroadcastCounter = counters.positionBroadcastCounter + 1
    counters.activeRespawnCheckCounter = counters.activeRespawnCheckCounter + 1
    counters.shellCleanupCheckCounter = counters.shellCleanupCheckCounter + 1
    counters.rosterRespawnCheckCounter = counters.rosterRespawnCheckCounter + 1
    counters.awayTransitionCheckCounter = counters.awayTransitionCheckCounter + 1
    counters.restingRegenCheckCounter = counters.restingRegenCheckCounter + 1
    counters.tradeCycleCheckCounter = counters.tradeCycleCheckCounter + 1

    if flags.startupHintPassTicks < 50 then
        flags.startupHintPassTicks = flags.startupHintPassTicks + 1
        tickInternal.ProcessStartupBodyHints()
    end

    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnManagerTick then
        DTNPC_ZombieAggro.OnManagerTick()
    end

    local shouldBroadcast = counters.positionBroadcastCounter >= constants.POSITION_BROADCAST_RATE
    if shouldBroadcast then
        counters.positionBroadcastCounter = 0
    end

    local shouldCheckActiveRespawn = counters.activeRespawnCheckCounter >= constants.ACTIVE_RESPAWN_CHECK_RATE
    if shouldCheckActiveRespawn then
        counters.activeRespawnCheckCounter = 0
    end

    local shouldCheckRosterRespawn = counters.rosterRespawnCheckCounter >= constants.ROSTER_RESPAWN_CHECK_RATE
    if shouldCheckRosterRespawn then
        counters.rosterRespawnCheckCounter = 0
    end

    local shouldCheckAwayTransitions = counters.awayTransitionCheckCounter >= constants.AWAY_TRANSITION_CHECK_RATE
    if shouldCheckAwayTransitions then
        counters.awayTransitionCheckCounter = 0
        if tickInternal.EnsureRespawnHooks() then
            DTNPCManager.ProcessAwayTransitions()
        end
    end

    local shouldCheckRestingRegen = counters.restingRegenCheckCounter >= constants.RESTING_REGEN_CHECK_RATE
    if shouldCheckRestingRegen then
        counters.restingRegenCheckCounter = 0
        tickInternal.ProcessOfflineRestingRegen()
    end

    local shouldCheckTradeCycles = counters.tradeCycleCheckCounter >= constants.TRADE_CYCLE_CHECK_RATE
    if shouldCheckTradeCycles then
        counters.tradeCycleCheckCounter = 0
        if tickInternal.EnsureRespawnHooks() then
            DTNPCManager.ProcessTradeCycles()
            if DTNPCManager.ProcessBanditHouseRoamers then
                DTNPCManager.ProcessBanditHouseRoamers()
            end
        end
    end

    if shouldCheckActiveRespawn and tickInternal.EnsureRespawnHooks() then
        for uuid, npcData in pairs(DTNPCManager.Data) do
            DTNPCManager.CheckForRespawn(npcData, uuid)
        end
    end

    if DTNPCServerCore and DTNPCServerCore.ProcessPendingArrivals then
        DTNPCServerCore.ProcessPendingArrivals()
    end

    local shellCleanupRan = false
    if counters.shellCleanupCheckCounter >= constants.SHELL_CLEANUP_CHECK_RATE then
        counters.shellCleanupCheckCounter = 0
        local shellZombieList = getWorldZombieList()
        if shellZombieList then
            tickInternal.CleanupNearbyAbstractSoulShells(shellZombieList, getActivePlayers())
            shellCleanupRan = true
        end
    end

    if shouldCheckRosterRespawn and tickInternal.EnsureRespawnHooks() then
        DTNPCManager.CheckRosterSpawns()
    end

    if counters.tickCounter < constants.TICK_RATE then
        return
    end
    counters.tickCounter = 0

    if DynamicTrading_TradeScheduler and DynamicTrading_TradeScheduler.NormalizeRosterState then
        DynamicTrading_TradeScheduler.NormalizeRosterState(nil, getGameTime():getWorldAgeHours())
    end

    local zombieList = getWorldZombieList()
    if not zombieList then
        return
    end

    local players = getActivePlayers()
    if not shellCleanupRan then
        tickInternal.CleanupNearbyAbstractSoulShells(zombieList, players)
    end

    local bucketState = tickRuntime.WorldSweepBuckets
    bucketState.phase = (math.max(0, math.floor(tonumber(bucketState.phase) or 0)) + 1) % 32
    local bucketPhase = bucketState.phase

    for i = 0, zombieList:size() - 1 do
        processZombie(zombieList:get(i), players, shouldBroadcast, bucketPhase)
    end
end
