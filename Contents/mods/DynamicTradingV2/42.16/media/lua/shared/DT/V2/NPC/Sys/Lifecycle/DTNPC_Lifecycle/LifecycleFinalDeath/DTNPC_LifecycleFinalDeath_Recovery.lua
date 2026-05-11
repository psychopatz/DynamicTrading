-- ==============================================================================
-- DTNPC_LifecycleFinalDeath_Recovery.lua
-- Premature engine-death recovery helpers.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

function DTNPCLifecycle.RecoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext)
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

    internal.saveSoulIfAvailable(uuid, npcData)
    DTNPCManager.RemoveData(uuid, nil, nil, nil, DTNPCLifecycle.WithStaleBodyCleanupContext(removalContext, corpseX, corpseY, corpseZ))

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        DTNPCLifecycle.CleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, "premature_custom_health_death")
        DTNPCLifecycle.ScheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, "premature_custom_health_death_delayed")
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
