-- ==============================================================================
-- DTNPC_Lifecycle_Incapacitation.lua
-- Entering and recovering the incapacitated lifecycle state.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

local function hasTerminalDeathRequest(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return true
    end

    local combatHealth = type(npcData.combatHealth) == "table" and npcData.combatHealth or nil
    return (tonumber(combatHealth and combatHealth.incapFinalKillRequestedAt) or 0) > 0
end

function DTNPCLifecycle.EnterIncapacitated(zombie, npcData, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false
    end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return false
    end
    if npcData.incapState == "Active" or tostring(npcData.state or "") == "Incapacitated" then
        return true
    end

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    if DTNPCHostility and DTNPCHostility.PlayHurtSound then
        DTNPCHostility.PlayHurtSound(zombie, npcData, "Incap")
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Lifecycle",
        "EnterIncapacitated name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " engineHealth=" .. tostring(zombie:getHealth())
            .. " customCurrent=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
    )

    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.capturePlayerAttacker then
        healthInternal.capturePlayerAttacker(npcData, attacker)
    end
    if healthInternal and healthInternal.setIncapacitatedState then
        healthInternal.setIncapacitatedState(zombie, npcData)
    else
        npcData.state = "Incapacitated"
        npcData.incapState = "Active"
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
    end

    if healthInternal and healthInternal.syncHealth then
        healthInternal.syncHealth(zombie, npcData, true)
    end

    local isPlayerAttacker = attacker and instanceof and instanceof(attacker, "IsoPlayer")
    if isPlayerAttacker and npcData.factionID and npcData.factionID ~= "Independent" then
        if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            local attackerName = attacker.getUsername and attacker:getUsername() or "A player"
            DynamicTrading.GameplayLogs.AddFactionEvent(npcData.factionID, DynamicTrading.GameplayEvents.MEMBER_INCAPACITATED_BY_PLAYER, {attackerName, npcData.name or "A member"})
        end
    end

    return true
end

function DTNPCLifecycle.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext)
    if not zombie or not uuid or not npcData then
        return false
    end
    if hasTerminalDeathRequest(npcData) then
        return false
    end

    local corpseX = math.floor(zombie:getX())
    local corpseY = math.floor(zombie:getY())
    local corpseZ = math.floor(zombie:getZ())

    npcData.lastX = corpseX
    npcData.lastY = corpseY
    npcData.lastZ = corpseZ
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
    if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.clearReviveState then
        DTNPCHealth.Internal.clearReviveState(npcData, false)
    else
        npcData.healthState = nil
        npcData.reviveData = nil
        npcData.reviveHelperID = nil
        npcData.reviveHelperOnlineID = nil
        npcData.reviveHelperUsername = nil
    end
    npcData.incapStrugglePauseUntil = nil
    npcData.incapNextPauseAt = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil
    if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.prepareIncapacitatedReviveData then
        DTNPCHealth.Internal.prepareIncapacitatedReviveData(npcData)
    end

    internal.saveSoulIfAvailable(uuid, npcData)
    local incapRemovalContext = DTNPCLifecycle.WithIncapacitationCorpseCleanupContext(removalContext, corpseX, corpseY, corpseZ)
    DTNPCManager.RemoveData(uuid, "Incapacitated", nil, nil, incapRemovalContext)

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        DTNPCLifecycle.CleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, "death_to_incapacitated")
        DTNPCLifecycle.ScheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, "death_to_incapacitated_delayed")
        DynamicTrading.Log("DTV2", "NPC", "Lifecycle", "NPC incapacitated instead of dying: " .. (npcData.name or uuid))
        return true
    end

    DynamicTrading.Log("DTV2", "NPC", "Error", "Failed to respawn incapacitated NPC, falling back to death: " .. tostring(uuid))
    if DynamicTrading_Roster and DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Dead", nil, nil)
    end
    return false
end

function DTNPCLifecycle.PreserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData)
    if not zombie or not uuid or not npcData or npcData.incapState ~= "Active" then
        return false
    end
    if hasTerminalDeathRequest(npcData) then
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

    internal.saveSoulIfAvailable(uuid, npcData)
    DTNPCManager.RemoveData(
        uuid,
        "Incapacitated",
        nil,
        nil,
        DTNPCLifecycle.WithIncapacitationCorpseCleanupContext(nil, corpseX, corpseY, corpseZ)
    )

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        DTNPCLifecycle.CleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, "suspicious_incap_recovery")
        DTNPCLifecycle.ScheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, "suspicious_incap_recovery_delayed")
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
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
