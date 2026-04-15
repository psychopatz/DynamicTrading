-- ==============================================================================
-- DTNPC_Lifecycle_FinalDeath.lua
-- Final death resolution and server-side dead/unregister flow.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

function DTNPCLifecycle.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() or npcData.incapState ~= "Active" then
        return false, false
    end

    context = type(context) == "table" and context or {}

    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false, false
    end

    local currentTime = internal.nowMillis()
    local graceUntil = tonumber(combatHealth.incapGraceUntil) or 0

    if DTNPCLifecycle.ShouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context) then
        return true, false
    end

    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.capturePlayerAttacker then
        healthInternal.capturePlayerAttacker(npcData, attacker)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Lifecycle",
        "HandleIncapacitatedDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " amount=" .. tostring(amount)
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " currentTime=" .. tostring(currentTime)
            .. " graceUntil=" .. tostring(graceUntil)
    )

    if currentTime < graceUntil then
        combatHealth.lastDamageAt = currentTime
        combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
        combatHealth.lastAttackerType = internal.getAttackerType(attacker)
        combatHealth.lastAttackerID = internal.getAttackerID(attacker)
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        if healthInternal and healthInternal.syncAndPersistHealth then
            healthInternal.syncAndPersistHealth(zombie, npcData, false, true)
        end
        return true, false
    end

    combatHealth.engineProtected = false
    combatHealth.incapGraceUntil = 0
    combatHealth.incapFinalKillRequestedAt = currentTime
    combatHealth.lastDamageAt = currentTime
    combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    combatHealth.lastAttackerType = internal.getAttackerType(attacker)
    combatHealth.lastAttackerID = internal.getAttackerID(attacker)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    npcData.health = 0
    npcData.lastHealth = 0
    combatHealth.lastEngineHealth = 0
    zombie:setHealth(0)

    if zombie.Kill then
        zombie:Kill(attacker or zombie)
        DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
        return true, true
    end

    return false, false
end

function DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker, context)
    local uuid = (npcData and npcData.uuid) or internal.getUUIDFromZombie(zombie)
    local liveData = internal.getLiveNPCData(uuid, npcData)
    if not uuid or not liveData then
        return false
    end
    if liveData.incapState ~= "Active" then
        return false
    end

    local removalContext = internal.copyContext(context)
    local killerContext = internal.buildKillerContext(attacker, liveData)
    if killerContext then
        for key, value in pairs(killerContext) do
            removalContext[key] = value
        end
    end

    DynamicTrading.Log("DTV2", "NPC", "Lifecycle", "Incapacitated NPC killed for good: " .. (liveData.name or uuid))
    local finalKillContext = DTNPCLifecycle.WithFinalKillContext(zombie, removalContext)
    local manualCorpseCreated = false
    if finalKillContext.forcedLiveBodyRemoval == true then
        manualCorpseCreated = DTNPCLifecycle.CreateCorpseFromZombie(zombie, liveData, "incapacitated_final_kill") == true
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

function DTNPCLifecycle.HandleZombieDead(zombie)
    local uuid = internal.getUUIDFromZombie(zombie)
    local zombieRuntimeID = DTNPC_ZombieAggro and DTNPC_ZombieAggro._internal and DTNPC_ZombieAggro._internal.getZombieRuntimeID
        and DTNPC_ZombieAggro._internal.getZombieRuntimeID(zombie)
        or nil
    if zombieRuntimeID and DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnZombieInvalidated then
        DTNPC_ZombieAggro.OnZombieInvalidated(zombieRuntimeID)
    end

    local attacker = zombie and zombie:getAttackedBy() or nil
    local removalContext = internal.buildKillerContext(attacker)

    if uuid and DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "ZombieDead triggered for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " engineHealth=" .. tostring(zombie and zombie:getHealth() or nil)
                .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
                .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
                .. " incapState=" .. tostring(npcData.incapState)
                .. " state=" .. tostring(npcData.state)
                .. " status=" .. tostring(npcData.status)
        )

        if npcData.incapState == "Active" and DTNPCLifecycle.PreserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData) then
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
            DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker, removalContext)
            return
        end

        if DTNPCLifecycle.RecoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext) then
            return
        end

        if DTNPCLifecycle.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext) then
            return
        end

        DynamicTrading.Log("DTV2", "NPC", "Lifecycle", "NPC Died: " .. (npcData.name or uuid))
        DTNPCManager.RemoveData(uuid, "Dead", nil, nil, removalContext)
    else
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unregister ignored zombie with no authoritative UUID; refusing outfit-ID fallback.")
    end
end
