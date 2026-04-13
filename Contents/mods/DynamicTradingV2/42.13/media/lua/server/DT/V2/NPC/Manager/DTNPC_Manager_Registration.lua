-- ==============================================================================
-- DTNPC_Manager_Registration.lua
-- NPC Registration, Removal, Status, and Unregister (death) logic.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.Register(zombie, npcData)
    if not zombie or not npcData then return end
    if npcData.status == "Dead" then return end
    
    local bodyInstanceID = zombie:getPersistentOutfitID()
    
    -- Get or create UUID
    local uuid = npcData.uuid
    if not uuid then
        -- Check if this zombie already has a UUID in modData
        local modData = zombie:getModData()
        uuid = modData.DTNPC_UUID
        
        if not uuid then
            -- Brand new NPC, generate UUID
            uuid = DTNPCManager.GenerateSoulID(npcData.name)
            DynamicTrading.Log("DTV2", "NPC", "Soul", "Generated new Soul ID for NPC: " .. (npcData.name or "Unknown") .. " - " .. uuid)
        else
            DynamicTrading.Log("DTV2", "NPC", "Soul", "Found UUID in zombie modData: " .. uuid)
        end
        
        npcData.uuid = uuid
    end
    
    -- Store UUID in zombie modData for future lookups
    local modData = zombie:getModData()
    modData.DTNPC_UUID = uuid
    
    -- Check for duplicate registration
    if DTNPCManager.PendingRegistrations[uuid] then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Registration for UUID " .. uuid .. " already in progress. Skipping duplicate.")
        return
    end
    
    -- Update outfit ID mapping
    DTNPCManager.BodyInstanceIDToUUID[bodyInstanceID] = uuid
    
    DTNPCManager.PendingRegistrations[uuid] = true
    
    -- Update npcData data
    npcData.currentBodyInstanceID = bodyInstanceID
    npcData.startupBodyInstanceHint = nil
    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.health = zombie:getHealth()
    npcData.registeredTime = os.time()
    
    -- Store in database by UUID
    DTNPCManager.Data[uuid] = npcData
    DTNPCManager.Save()

    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.ClearThreat then
        DTNPC_ZombieAggro.ClearThreat(uuid)
    end

    if DTNPCManager.RespawnRuntime and DTNPCManager.RespawnRuntime.MissingBodies then
        DTNPCManager.RespawnRuntime.MissingBodies[uuid] = nil
    end
    
    DTNPCManager.PendingRegistrations[uuid] = nil
    
    DynamicTrading.Log("DTV2", "NPC", "Register", "Registered NPC: " .. (npcData.name or "Unknown") .. " (UUID: " .. uuid .. ", BodyInstanceID: " .. bodyInstanceID .. ") at " .. npcData.lastX .. "," .. npcData.lastY .. "," .. npcData.lastZ)
end

function DTNPCManager.ReclaimZombie(zombie, npcData, reason)
    if not zombie or not npcData then return nil end
    if zombie:isDead() then return nil end
    if npcData.status == "Dead" then return nil end

    local modData = zombie:getModData()
    local uuid = npcData.uuid or modData.DTNPC_UUID
    if not uuid then return nil end

    npcData.uuid = uuid
    if not npcData.visualID then
        npcData.visualID = ZombRand(1000000)
    end

    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)

    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    modData.DTNPCVisualID = npcData.visualID

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:DoZombieStats()
    if DTNPCHealth and DTNPCHealth.InitializeForSpawn then
        DTNPCHealth.InitializeForSpawn(zombie, npcData, { resetCurrent = false })
    else
        zombie:setHealth(2)
    end

    zombie:resetModelNextFrame()

    DTNPCManager.Register(zombie, npcData)

    if DTNPCServerCore and DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
    end

    if DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
        DTNPCManager.RespawnDebug.Log(
            "reclaim_" .. tostring(uuid),
            "Process=reclaim_existing_zombie uuid=" .. tostring(uuid) ..
                " name=" .. tostring(npcData.name or "Unknown") ..
                " reason=" .. tostring(reason or "repair") ..
                " bodyInstanceID=" .. tostring(zombie:getPersistentOutfitID()) ..
                " visualID=" .. tostring(npcData.visualID),
            true
        )
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Adopt",
        "Reclaimed existing world zombie for " .. (npcData.name or uuid) .. " (" .. (reason or "repair") .. ")"
    )

    return zombie
end

function DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus, removalContext)
    if DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]

        if DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnNPCRemoved then
            DTNPC_ZombieAggro.OnNPCRemoved(uuid)
        end
        
        -- Remove from outfit mapping
        local currentBodyInstanceID = npcData.currentBodyInstanceID
        if currentBodyInstanceID then
            DTNPCManager.BodyInstanceIDToUUID[currentBodyInstanceID] = nil
        end
        
        -- Remove from spatial hash
        if DTNPC_SpatialHash and DTNPC_SpatialHash.RemoveNPC then
            DTNPC_SpatialHash.RemoveNPC(uuid)
        end
        
        -- Remove from distance frequency tracker
        if DTNPC_DistanceFrequency and DTNPC_DistanceFrequency.RemoveNPC then
            DTNPC_DistanceFrequency.RemoveNPC(uuid)
        end
        
        -- Update persistent status in Roster
        if DynamicTrading_Roster and status ~= nil then
            DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
        end

        -- Remove from database
        DTNPCManager.Data[uuid] = nil
        DTNPCManager.PendingRegistrations[uuid] = nil
        if DTNPCManager.RespawnRuntime and DTNPCManager.RespawnRuntime.MissingBodies then
            DTNPCManager.RespawnRuntime.MissingBodies[uuid] = nil
        end
        DTNPCManager.Save()
        
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Removed NPC data from world tracker: " .. (npcData.name or uuid) .. " (Status: " .. (status or "Removed") .. ")")
        
        -- Broadcast removal to all clients
        if DTNPCServerCore and DTNPCServerCore.NotifyRemoval then
            DTNPCServerCore.NotifyRemoval(uuid, currentBodyInstanceID, npcData.name, status, removalContext)
        end
    end
end

function DTNPCManager.SetNPCStatus(uuid, status, returnTime, returnStatus)
    -- 1. Always update the persistent Roster (Bridge)
    if DynamicTrading_Roster then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    end

    -- 2. If the status implies they are "Away" or "Dead", clean up physical presence
    if status == "Away" or status == "Dead" then
        if DTNPCManager.Data[uuid] then
            DynamicTrading.Log("DTV2", "NPC", "Status", "Status change to " .. status .. " requires world removal.")
            DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus) -- PASS ALL DATA
        end
        
        -- Clean up physical zombie if it exists
        if DTNPCServerCore and DTNPCServerCore.FindZombieByUUID then
            local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                DynamicTrading.Log("DTV2", "NPC", "Remove", "Forcefully removed physical zombie for Away/Dead state: " .. uuid)
            end
        end
    end
end

local function saveSoulIfAvailable(uuid, npcData)
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and uuid and npcData then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end
end

local pendingIncapacitationCorpseCleanups = {}

local function cleanupStrayIncapacitationCorpse(x, y, z, npcData, reason)
    local cell = getCell and getCell() or nil
    local square = cell and cell:getGridSquare(x, y, z or 0) or nil
    if not square then
        return false
    end

    local removed = 0
    local function purgeFromList(list)
        if not list then
            return
        end

        for i = list:size() - 1, 0, -1 do
            local obj = list:get(i)
            if obj and instanceof and instanceof(obj, "IsoDeadBody") then
                obj:removeFromWorld()
                obj:removeFromSquare()
                removed = removed + 1
            end
        end
    end

    if square.getStaticMovingObjects then
        purgeFromList(square:getStaticMovingObjects())
    end
    if removed <= 0 and square.getMovingObjects then
        purgeFromList(square:getMovingObjects())
    end

    if removed > 0 then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Death",
            "Removed stray incapacitation corpse(s) for "
                .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
                .. " count=" .. tostring(removed)
                .. " reason=" .. tostring(reason or "incap_transition")
                .. " square=" .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(z or 0)
        )
        return true
    end

    return false
end

local function runPendingIncapacitationCorpseCleanups()
    for i = #pendingIncapacitationCorpseCleanups, 1, -1 do
        local cleanup = pendingIncapacitationCorpseCleanups[i]
        cleanup.attempts = (cleanup.attempts or 0) + 1

        local removed = cleanupStrayIncapacitationCorpse(
            cleanup.x,
            cleanup.y,
            cleanup.z,
            cleanup.npcData,
            cleanup.reason
        )

        if removed or cleanup.attempts >= (cleanup.maxAttempts or 8) then
            table.remove(pendingIncapacitationCorpseCleanups, i)
        end
    end

    if #pendingIncapacitationCorpseCleanups <= 0 and Events and Events.OnTick then
        Events.OnTick.Remove(runPendingIncapacitationCorpseCleanups)
    end
end

local function scheduleIncapacitationCorpseCleanup(x, y, z, npcData, reason)
    if not x or not y then
        return
    end

    table.insert(pendingIncapacitationCorpseCleanups, {
        x = x,
        y = y,
        z = z or 0,
        npcData = npcData,
        reason = reason,
        attempts = 0,
        maxAttempts = 8,
    })

    if Events and Events.OnTick then
        Events.OnTick.Remove(runPendingIncapacitationCorpseCleanups)
        Events.OnTick.Add(runPendingIncapacitationCorpseCleanups)
    end
end

local function withIncapacitationCorpseCleanupContext(removalContext, x, y, z)
    local context = {}
    if type(removalContext) == "table" then
        for key, value in pairs(removalContext) do
            context[key] = value
        end
    end

    context.cleanupCorpse = true
    context.corpseX = x
    context.corpseY = y
    context.corpseZ = z or 0
    return context
end

local function withPreservedCorpseContext(removalContext)
    local context = {}
    if type(removalContext) == "table" then
        for key, value in pairs(removalContext) do
            context[key] = value
        end
    end

    context.preserveCorpse = true
    return context
end

local function withFinalKillContext(zombie, removalContext)
    local isCorpseReady = zombie and zombie.isDead and zombie:isDead() == true
    if isCorpseReady then
        return withPreservedCorpseContext(removalContext)
    end

    local context = {}
    if type(removalContext) == "table" then
        for key, value in pairs(removalContext) do
            context[key] = value
        end
    end
    context.preserveCorpse = false
    context.forcedLiveBodyRemoval = true
    return context
end

local function createCorpseFromIncapacitatedZombie(zombie, npcData)
    if not zombie or not IsoDeadBody then
        return false, nil
    end

    local ok, body = pcall(IsoDeadBody.new, zombie, false, true)
    if not ok or not body then
        ok, body = pcall(IsoDeadBody.new, zombie, false)
    end
    if not ok or not body then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Failed to create manual corpse for "
                .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
                .. " error=" .. tostring(body)
        )
        return false, nil
    end

    local bodyModData = body.getModData and body:getModData() or nil
    if bodyModData and npcData then
        bodyModData.DTNPC_UUID = npcData.uuid
        bodyModData.DTNPC_Name = npcData.name
        bodyModData.DTNPC_FinalKillCorpse = true
    end

    if isServer() and body.transmitCompleteItemToClients then
        pcall(function()
            body:transmitCompleteItemToClients()
        end)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Death",
        "Created manual corpse for incapacitated final kill: "
            .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
    )
    return true, body
end

local function withStaleBodyCleanupContext(removalContext, x, y, z)
    local context = withIncapacitationCorpseCleanupContext(removalContext, x, y, z)
    context.staleBodyOnly = true
    return context
end

local function preserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData)
    if not zombie or not uuid or not npcData or npcData.incapState ~= "Active" then
        return false
    end

    local combatHealth = npcData.combatHealth
    local spawnedAt = tonumber(combatHealth and combatHealth.spawnInitializedAt) or 0
    local now = getTimeInMillis and getTimeInMillis() or 0
    local graceUntil = tonumber(combatHealth and combatHealth.incapGraceUntil) or 0
    local fallbackGraceMs = DTNPCHealth and tonumber(DTNPCHealth.INCAP_GRACE_WINDOW_MS) or 1200
    if graceUntil <= 0 and spawnedAt > 0 then
        graceUntil = spawnedAt + fallbackGraceMs
    end
    local ageMs = spawnedAt > 0 and (now - spawnedAt) or math.huge
    local attacker = zombie:getAttackedBy()

    if attacker or ageMs < 0 or now > graceUntil then
        return false
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Warn",
        "Preserving suspicious incapacitated death for "
            .. tostring(npcData.name or uuid)
            .. " uuid=" .. tostring(uuid)
            .. " spawnAgeMs=" .. tostring(ageMs)
            .. " engineHealth=" .. tostring(zombie:getHealth())
            .. " customCurrent=" .. tostring(combatHealth and combatHealth.current or nil)
    )

    local corpseX = npcData.lastX or math.floor(zombie:getX())
    local corpseY = npcData.lastY or math.floor(zombie:getY())
    local corpseZ = npcData.lastZ or math.floor(zombie:getZ())

    saveSoulIfAvailable(uuid, npcData)
    DTNPCManager.RemoveData(
        uuid,
        "Incapacitated",
        nil,
        nil,
        withIncapacitationCorpseCleanupContext(nil, corpseX, corpseY, corpseZ)
    )

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        cleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, "suspicious_incap_recovery")
        scheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, "suspicious_incap_recovery_delayed")
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Death",
            "Recovered suspicious incapacitated death by respawning body: " .. tostring(npcData.name or uuid)
        )
        return true
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Error",
        "Failed to recover suspicious incapacitated death, falling back to permanent death: " .. tostring(uuid)
    )
    return false
end

local function recoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext)
    if not zombie or not uuid or not npcData or npcData.incapState == "Active" then
        return false
    end
    if not DTNPCHealth or not DTNPCHealth.EnsureDefaults then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    local customCurrent = tonumber(combatHealth and combatHealth.current) or 0
    if not combatHealth or combatHealth.enabled ~= true or customCurrent <= (tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01) then
        return false
    end

    local corpseX = math.floor(zombie:getX())
    local corpseY = math.floor(zombie:getY())
    local corpseZ = math.floor(zombie:getZ())

    npcData.lastX = corpseX
    npcData.lastY = corpseY
    npcData.lastZ = corpseZ
    npcData.health = math.max(1, tonumber(combatHealth.engineBuffer) or DTNPCHealth.DEFAULT_ENGINE_BUFFER)
    npcData.lastHealth = npcData.health
    combatHealth.engineProtected = true
    combatHealth.eventDrivenOnly = false
    combatHealth.lastEngineHealth = npcData.health

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Warn",
        "Recovered premature engine death while custom HP remained for "
            .. tostring(npcData.name or uuid)
            .. " uuid=" .. tostring(uuid)
            .. " customCurrent=" .. tostring(customCurrent)
            .. " customMax=" .. tostring(combatHealth.max)
            .. " engineHealth=" .. tostring(zombie:getHealth())
    )

    saveSoulIfAvailable(uuid, npcData)
    DTNPCManager.RemoveData(uuid, nil, nil, nil, withStaleBodyCleanupContext(removalContext, corpseX, corpseY, corpseZ))

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        cleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, "premature_custom_health_death")
        scheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, "premature_custom_health_death_delayed")
        return true
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Error",
        "Failed to recover premature custom health death; falling back to normal death path: " .. tostring(uuid)
    )
    return false
end

function DTNPCManager.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext)
    if not zombie or not uuid or not npcData then return false end

    local corpseX = math.floor(zombie:getX())
    local corpseY = math.floor(zombie:getY())
    local corpseZ = math.floor(zombie:getZ())

    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.health = 2
    npcData.preIncapState = npcData.state
    npcData.state = "Incapacitated"
    npcData.incapState = "Active"
    npcData.preIncapStatus = npcData.status or "Resting"
    npcData.preIncapMaster = npcData.master
    npcData.preIncapMasterID = npcData.masterID
    npcData.isHostile = false
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.requestedReturnStatus = "Resting"
    npcData.removalRequested = nil
    npcData.incapStrugglePauseUntil = nil
    npcData.incapNextPauseAt = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil

    saveSoulIfAvailable(uuid, npcData)
    local incapRemovalContext = withIncapacitationCorpseCleanupContext(removalContext, corpseX, corpseY, corpseZ)
    DTNPCManager.RemoveData(uuid, "Incapacitated", nil, nil, incapRemovalContext)

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        cleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, "death_to_incapacitated")
        scheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, "death_to_incapacitated_delayed")
        DynamicTrading.Log("DTV2", "NPC", "Death", "NPC incapacitated instead of dying: " .. (npcData.name or uuid))
        return true
    end

    DynamicTrading.Log("DTV2", "NPC", "Error", "Failed to respawn incapacitated NPC, falling back to death: " .. tostring(uuid))
    if DynamicTrading_Roster and DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Dead", nil, nil)
    end
    return false
end

function DTNPCManager.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
    local uuid = (npcData and npcData.uuid) or DTNPCManager.GetUUIDFromZombie(zombie)
    if not uuid or not DTNPCManager.Data[uuid] then
        return false
    end

    local liveData = DTNPCManager.Data[uuid]
    if liveData.incapState ~= "Active" then
        return false
    end

    local removalContext = nil
    if attacker and instanceof and instanceof(attacker, "IsoPlayer") then
        removalContext = {
            killerUsername = attacker.getUsername and attacker:getUsername() or nil,
            killerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil,
        }
    elseif liveData.lastPlayerAttackerUsername then
        removalContext = {
            killerUsername = liveData.lastPlayerAttackerUsername,
            killerOnlineID = liveData.lastPlayerAttackerOnlineID,
        }
    end

    DynamicTrading.Log("DTV2", "NPC", "Death", "Incapacitated NPC killed for good: " .. (liveData.name or uuid))
    local finalKillContext = withFinalKillContext(zombie, removalContext)
    local manualCorpseCreated = false
    if finalKillContext.forcedLiveBodyRemoval == true then
        manualCorpseCreated = createCorpseFromIncapacitatedZombie(zombie, liveData) == true
        finalKillContext.manualCorpseCreated = manualCorpseCreated
    end
    DTNPCManager.RemoveData(uuid, "Dead", nil, nil, finalKillContext)

    if finalKillContext.forcedLiveBodyRemoval == true and zombie and not (zombie.isDead and zombie:isDead()) then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Engine Kill did not convert incapacitated body to corpse; "
                .. (manualCorpseCreated and "manual corpse created, " or "manual corpse failed, ")
                .. "removing live body for " .. tostring(liveData.name or uuid)
        )
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end
    return true
end

function DTNPCManager.Unregister(zombie)
    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    local zombieRuntimeID = DTNPC_ZombieAggro and DTNPC_ZombieAggro._internal and DTNPC_ZombieAggro._internal.getZombieRuntimeID
        and DTNPC_ZombieAggro._internal.getZombieRuntimeID(zombie)
        or nil
    if zombieRuntimeID and DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnZombieInvalidated then
        DTNPC_ZombieAggro.OnZombieInvalidated(zombieRuntimeID)
    end
    local removalContext = nil
    local attacker = zombie and zombie:getAttackedBy() or nil
    if attacker and instanceof(attacker, "IsoPlayer") then
        removalContext = {
            killerUsername = attacker.getUsername and attacker:getUsername() or nil,
            killerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil,
        }
    end
    
    if uuid and DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Death",
            "Unregister triggered for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " engineHealth=" .. tostring(zombie and zombie:getHealth() or nil)
                .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
                .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
                .. " incapState=" .. tostring(npcData.incapState)
                .. " state=" .. tostring(npcData.state)
                .. " status=" .. tostring(npcData.status)
        )
        if npcData.incapState == "Active" and preserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData) then
            return
        end

        if not removalContext and npcData.lastPlayerAttackerUsername then
            local elapsed = npcData.lastPlayerAttackedAt and (getTimeInMillis() - npcData.lastPlayerAttackedAt) or nil
            if not elapsed or elapsed <= 15000 then
                removalContext = {
                    killerUsername = npcData.lastPlayerAttackerUsername,
                    killerOnlineID = npcData.lastPlayerAttackerOnlineID,
                }
            end
        end
        if npcData.incapState == "Active" then
            DTNPCManager.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
            return
        end

        if recoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext) then
            return
        end

        if DTNPCManager.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext) then
            return
        end

        DynamicTrading.Log("DTV2", "NPC", "Death", "NPC Died: " .. (npcData.name or uuid))
        DTNPCManager.RemoveData(uuid, "Dead", nil, nil, removalContext)
    else
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unregister ignored zombie with no authoritative UUID; refusing outfit-ID fallback.")
    end
end

Events.OnZombieDead.Add(DTNPCManager.Unregister)
