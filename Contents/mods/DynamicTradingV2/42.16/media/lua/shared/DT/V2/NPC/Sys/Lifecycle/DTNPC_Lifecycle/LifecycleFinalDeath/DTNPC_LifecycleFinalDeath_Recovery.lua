-- ==============================================================================
-- DTNPC_LifecycleFinalDeath_Recovery.lua
-- Premature engine-death recovery helpers.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

local function hasRecentAuthoritativeClientWeaponReport(combatHealth, now)
    local recentSource = tostring(combatHealth and combatHealth.lastDamageSource or "")
    local recentDamageAt = tonumber(combatHealth and combatHealth.lastDamageAt) or 0
    local recentWindowMs = 2000

    now = tonumber(now) or internal.nowMillis()
    return recentDamageAt > 0
        and (now - recentDamageAt) <= recentWindowMs
        and (
            recentSource == "client_weapon_hit_report"
            or recentSource == "client_weapon_hit_report_dead_body"
        )
end

local function isAttackerlessEngineFallbackSource(combatHealth)
    local recentSource = tostring(combatHealth and combatHealth.lastDamageSource or "")
    return recentSource == "engine_fallback" or recentSource == "incap_engine_fallback"
end

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

local function notePrematureRecoveryChain(combatHealth)
    if type(combatHealth) ~= "table" then
        return 0
    end

    local now = internal.nowMillis()
    local windowMs = math.max(1000, tonumber(DTNPCHealth and DTNPCHealth.PREMATURE_DEATH_RECOVERY_WINDOW_MS) or 8000)
    local windowStartedAt = tonumber(combatHealth.prematureDeathWindowStartedAt) or 0
    local count = tonumber(combatHealth.prematureDeathRecoveryCount) or 0

    if windowStartedAt <= 0 or (now - windowStartedAt) > windowMs then
        windowStartedAt = now
        count = 0
    end

    count = count + 1
    combatHealth.prematureDeathWindowStartedAt = windowStartedAt
    combatHealth.prematureDeathRecoveryCount = count
    combatHealth.lastPrematureDeathRecoveryAt = now
    return count
end

local function isCredibleCombatDeath(zombie, npcData, combatHealth)
    if not zombie or not npcData or not combatHealth then
        return false
    end

    local attacker = zombie.getAttackedBy and zombie:getAttackedBy() or nil
    if attacker then
        return true
    end

    local now = internal.nowMillis()
    local postReviveGraceUntil = tonumber(combatHealth.postReviveGraceUntil) or 0
    if postReviveGraceUntil > now and not hasRecentAuthoritativeClientWeaponReport(combatHealth, now) then
        return false
    end

    local recentDamageAt = tonumber(combatHealth.lastDamageAt) or 0
    local recentDamageWindowMs = 3000
    local hasRecentDamage = recentDamageAt > 0 and (now - recentDamageAt) <= recentDamageWindowMs
    if hasRecentDamage
        and isAttackerlessEngineFallbackSource(combatHealth)
        and not hasRecentAuthoritativeClientWeaponReport(combatHealth, now) then
        return false
    end
    if hasRecentDamage then
        return true
    end

    if npcData.combatTargetID ~= nil
        or npcData.combatTargetType ~= nil
        or npcData.combatPursuitTargetID ~= nil
        or npcData.companionCombatActive == true then
        return true
    end

    return false
end

local function scheduleControlledRespawn(zombie, uuid, npcData, removalContext, reason)
    if not zombie or not uuid or not npcData then
        return false
    end

    local bodyInstanceID = zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or nil
    local retryAt = internal.nowMillis() + math.max(250, tonumber(DTNPCHealth and DTNPCHealth.BODY_RECOVERY_RETRY_MS) or 2000)
    npcData.bodyRecoveryRetryAt = retryAt

    if DTNPCManager and DTNPCManager.BumpPresenceRevision then
        DTNPCManager.BumpPresenceRevision(npcData)
    end
    if DTNPCManager and DTNPCManager.ClearPhysicalBodyIdentity then
        DTNPCManager.ClearPhysicalBodyIdentity(npcData, bodyInstanceID)
    end

    internal.saveSoulIfAvailable(uuid, npcData)
    if DTNPCManager and DTNPCManager.Save then
        DTNPCManager.Save()
    end

    if bodyInstanceID and DTNPCServerCore and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, bodyInstanceID, DTNPCManager and DTNPCManager.GetPresenceRevision and DTNPCManager.GetPresenceRevision(npcData) or nil)
    end

    zombie:removeFromWorld()
    zombie:removeFromSquare()

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Warn",
        "Scheduled controlled respawn after suspicious engine death for "
            .. tostring(npcData.name or uuid)
            .. " uuid=" .. tostring(uuid)
            .. " retryAt=" .. tostring(retryAt)
            .. " reason=" .. tostring(reason or "premature_custom_health_death")
    )

    return true
end

function DTNPCLifecycle.RecoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext)
    if not zombie or not uuid or not npcData or npcData.incapState == "Active" then
        return false
    end
    if hasTerminalDeathRequest(npcData) then
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
    if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.syncDerivedHealthState then
        DTNPCHealth.Internal.syncDerivedHealthState(npcData, combatHealth)
    end

    if isCredibleCombatDeath(zombie, npcData, combatHealth) then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "Skipped premature engine-death recovery because the death looks combat-driven for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " lastDamageSource=" .. tostring(combatHealth.lastDamageSource)
                .. " attackerType=" .. tostring(internal.getAttackerType and internal.getAttackerType(zombie:getAttackedBy()) or nil)
        )
        return false
    end

    local recoveryCount = notePrematureRecoveryChain(combatHealth)
    local maxRecoveryChain = math.max(1, tonumber(DTNPCHealth and DTNPCHealth.PREMATURE_DEATH_RECOVERY_MAX_CHAIN) or 2)

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
            .. " recoveryCount=" .. tostring(recoveryCount)
    )

    if recoveryCount >= maxRecoveryChain
        and npcData.incapState ~= "Active"
        and DTNPCLifecycle.ConvertDeathToIncapacitated then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Escalating repeated suspicious engine death into incapacitation for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " recoveryCount=" .. tostring(recoveryCount)
        )
        return DTNPCLifecycle.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext)
    end

    if scheduleControlledRespawn(
        zombie,
        uuid,
        npcData,
        DTNPCLifecycle.WithStaleBodyCleanupContext(removalContext, corpseX, corpseY, corpseZ),
        "premature_custom_health_death"
    ) then
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
