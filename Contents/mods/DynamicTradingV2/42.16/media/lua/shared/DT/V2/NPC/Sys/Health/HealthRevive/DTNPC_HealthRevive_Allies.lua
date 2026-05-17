-- ==============================================================================
-- DTNPC_HealthRevive_Allies.lua
-- Same-faction live-NPC rescue flow for incapacitated allies.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function createPointTarget(x, y, z)
    return {
        getX = function() return x end,
        getY = function() return y end,
        getZ = function() return z or 0 end,
    }
end

local function getNPCDataForZombie(zombie)
    if not zombie or not zombie.getModData then
        return nil
    end

    local modData = zombie:getModData()
    if not modData then
        return nil
    end

    local npcData = modData.DTNPC_Data or modData.DTNPCBrain
    if npcData then
        return npcData
    end

    local uuid = modData.DTNPC_UUID or nil
    if uuid and DTNPCManager and DTNPCManager.Data then
        return DTNPCManager.Data[uuid]
    end

    return nil
end

local function findZombieByUUID(uuid)
    if not uuid or not DTNPCServerCore or not DTNPCServerCore.FindZombieByUUID then
        return nil
    end
    return DTNPCServerCore.FindZombieByUUID(uuid)
end

local function getFactionID(npcData)
    return tostring(npcData and npcData.factionID or "")
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

local function isThreatOrBlockedState(state)
    state = tostring(state or "")
    return state == "Attack"
        or state == "AttackRange"
        or state == "Flee"
        or state == "TradingDefenseRanged"
        or state == "TradingDefenseMelee"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
        or state == "Bandage"
        or state == "Departure"
        or state == "Incapacitated"
        or state == "ReviveAlly"
end

local function resolveResumeState(npcData)
    if type(npcData) ~= "table" then
        return "Idle"
    end

    local state = tostring(npcData.allyReviveResumeState or "")
    if state ~= "" and state ~= "ReviveAlly" then
        return state
    end

    if npcData.linkedWorkerID ~= nil and DTNPCColonyRuntime and DTNPCColonyRuntime.SyncBehaviorIdentity then
        local ok, result = pcall(DTNPCColonyRuntime.SyncBehaviorIdentity, npcData)
        if ok and tostring(result or "") ~= "" then
            return tostring(result)
        end
    end

    if npcData.master ~= nil or npcData.masterID ~= nil then
        return "Follow"
    end

    if npcData.stationaryPostX ~= nil or npcData.guardCombatOrder ~= nil then
        return "Guard"
    end

    return "Idle"
end

local function syncState(zombie, npcData, fullSync, forceSave)
    if type(npcData) ~= "table" or (internal.isRemoteClient and internal.isRemoteClient()) then
        return
    end

    if internal.syncHealth and zombie then
        internal.syncHealth(zombie, npcData, fullSync == true)
    end
    if forceSave == true and internal.persistHealthSnapshot then
        internal.persistHealthSnapshot(npcData, true)
    end
end

local function getReviveLease(targetData)
    if type(targetData) ~= "table" then
        return nil
    end

    local reviveData = internal.prepareIncapacitatedReviveData and internal.prepareIncapacitatedReviveData(targetData)
        or internal.ensureReviveDataTable and internal.ensureReviveDataTable(targetData)
        or nil
    return reviveData
end

local function releaseLease(targetData, rescuerUUID, force)
    local reviveData = type(targetData) == "table" and targetData.reviveData or nil
    if type(reviveData) ~= "table" then
        return false
    end

    local owner = tostring(reviveData.allyReviveLeaseUUID or "")
    if force ~= true and owner ~= "" and tostring(rescuerUUID or "") ~= owner then
        return false
    end

    reviveData.allyReviveLeaseUUID = nil
    reviveData.allyReviveLeaseUntil = nil
    reviveData.allyReviveLeaseState = nil
    return true
end

local function clearRescuerState(npcData)
    if type(npcData) ~= "table" then
        return
    end

    npcData.allyReviveTargetUUID = nil
    npcData.allyRevivePhase = nil
    npcData.allyReviveActionUntil = nil
    npcData.allyReviveLeaseUntil = nil
    npcData.allyReviveNoticeAt = nil
    npcData.allyReviveSearchAfterAt = nil
end

local function cancelRescue(zombie, npcData, targetData, reason, retryDelayMs, options)
    if type(npcData) ~= "table" then
        return false
    end

    options = type(options) == "table" and options or {}

    if type(targetData) == "table" then
        releaseLease(targetData, npcData.uuid, options.forceLeaseRelease == true)
    end

    clearRescuerState(npcData)

    if reason ~= "completed" then
        local now = internal.nowMillis and internal.nowMillis() or 0
        local retryDelay = math.max(0, math.floor(tonumber(retryDelayMs) or tonumber(DTNPCHealth.ALLY_REVIVE_RETRY_DELAY_MS) or 0))
        npcData.allyReviveRetryAt = now + retryDelay
    else
        npcData.allyReviveRetryAt = nil
    end

    if npcData.state == "ReviveAlly" then
        npcData.state = resolveResumeState(npcData)
    end
    npcData.allyReviveResumeState = nil

    syncState(zombie, npcData, options.fullSync == true, options.forceSave == true)
    return true
end

local function leaseOwnedBy(rescuerData, targetData)
    local reviveData = type(targetData) == "table" and targetData.reviveData or nil
    if type(reviveData) ~= "table" then
        return false
    end

    local owner = tostring(reviveData.allyReviveLeaseUUID or "")
    local leaseUntil = tonumber(reviveData.allyReviveLeaseUntil) or 0
    local now = internal.nowMillis and internal.nowMillis() or 0
    return owner ~= "" and owner == tostring(rescuerData and rescuerData.uuid or "") and leaseUntil > now
end

local function acquireLease(rescuerData, targetData)
    if type(rescuerData) ~= "table" or type(targetData) ~= "table" then
        return false
    end

    local reviveData = getReviveLease(targetData)
    if type(reviveData) ~= "table" then
        return false
    end

    local now = internal.nowMillis and internal.nowMillis() or 0
    local currentOwner = tostring(reviveData.allyReviveLeaseUUID or "")
    local leaseUntil = tonumber(reviveData.allyReviveLeaseUntil) or 0
    if currentOwner ~= "" and currentOwner ~= tostring(rescuerData.uuid or "") and leaseUntil > now then
        return false
    end

    reviveData.allyReviveLeaseUUID = tostring(rescuerData.uuid or "")
    reviveData.allyReviveLeaseUntil = now + math.max(1000, math.floor(tonumber(DTNPCHealth.ALLY_REVIVE_LEASE_MS) or 6000))
    reviveData.allyReviveLeaseState = "reserved"
    rescuerData.allyReviveLeaseUntil = reviveData.allyReviveLeaseUntil
    return true
end

local function isSameFactionRescueCandidate(rescuerData, targetData)
    if type(rescuerData) ~= "table" or type(targetData) ~= "table" then
        return false
    end
    if rescuerData.uuid == nil or targetData.uuid == nil or rescuerData.uuid == targetData.uuid then
        return false
    end
    if hasTerminalDeathRequest(targetData) then
        return false
    end
    if hasTerminalDeathRequest(rescuerData) then
        return false
    end
    if rescuerData.incapState == "Active" or targetData.incapState ~= "Active" then
        return false
    end

    local rescuerFaction = getFactionID(rescuerData)
    if rescuerFaction == "" or rescuerFaction ~= getFactionID(targetData) then
        return false
    end

    local healthState = DTNPCHealth.GetHealthState and DTNPCHealth.GetHealthState(rescuerData) or nil
    if healthState == "Incapacitated" or healthState == "Weakened" then
        return false
    end

    if rescuerData.linkedWorkerID == nil and (rescuerData.master ~= nil or rescuerData.masterID ~= nil) then
        return false
    end

    return true
end

local function canRescuerAttempt(npcData, state)
    if type(npcData) ~= "table" then
        return false
    end
    if (internal.isRemoteClient and internal.isRemoteClient()) or npcData.state == "ReviveAlly" then
        return false
    end
    if hasTerminalDeathRequest(npcData) then
        return false
    end
    if isThreatOrBlockedState(state or npcData.state) then
        return false
    end

    local now = internal.nowMillis and internal.nowMillis() or 0
    if now < (tonumber(npcData.allyReviveRetryAt) or 0) then
        return false
    end
    if now < (tonumber(npcData.allyReviveSearchAfterAt) or 0) then
        return false
    end

    if not DTNPCHealth.HasUsableBandageSupply or not DTNPCHealth.HasUsableBandageSupply(npcData) then
        return false
    end

    return true
end

local function hasNearbyThreat(actorZombie, actorData, x, y, z, radius)
    if not actorZombie or not actorData or not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return false, nil
    end

    local anchor = createPointTarget(x or actorZombie:getX(), y or actorZombie:getY(), z or actorZombie:getZ())
    local threat = DTNPCProtect.SelectNearestThreat(
        actorZombie,
        actorData,
        tonumber(radius) or tonumber(DTNPCHealth.ALLY_REVIVE_THREAT_RADIUS) or 11,
        anchor,
        tonumber(radius) or tonumber(DTNPCHealth.ALLY_REVIVE_THREAT_RADIUS) or 11,
        true
    )

    return threat ~= nil, threat
end

local function hasThreatAroundRescue(rescuerZombie, rescuerData, targetZombie, targetData)
    local radius = tonumber(DTNPCHealth.ALLY_REVIVE_THREAT_RADIUS) or 11
    local threatened, threat = hasNearbyThreat(
        rescuerZombie,
        rescuerData,
        rescuerZombie and rescuerZombie:getX() or nil,
        rescuerZombie and rescuerZombie:getY() or nil,
        rescuerZombie and rescuerZombie:getZ() or nil,
        radius
    )
    if threatened then
        return true, threat
    end

    if targetZombie and targetData then
        threatened, threat = hasNearbyThreat(
            targetZombie,
            targetData,
            targetZombie:getX(),
            targetZombie:getY(),
            targetZombie:getZ(),
            radius
        )
        if threatened then
            return true, threat
        end
    end

    return false, nil
end

local function hasThreatNearTarget(targetZombie, targetData)
    local radius = tonumber(DTNPCHealth.ALLY_REVIVE_THREAT_RADIUS) or 11
    return hasNearbyThreat(
        targetZombie,
        targetData,
        targetZombie and targetZombie:getX() or nil,
        targetZombie and targetZombie:getY() or nil,
        targetZombie and targetZombie:getZ() or nil,
        radius
    )
end

local function consumeReviveSupply(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false
    end

    local linkedSupply = internal.consumeLinkedWorkerBandageSupply and internal.consumeLinkedWorkerBandageSupply(npcData) or nil
    if linkedSupply then
        if linkedSupply.tierID then
            combatHealth.bandageTier = linkedSupply.tierID
        end
        return true
    end

    if combatHealth.bandageUnlimited == true then
        return true
    end

    local charges = math.max(0, tonumber(combatHealth.bandageCharges) or 0)
    if charges <= 0 then
        return false
    end

    combatHealth.bandageCharges = charges - 1
    return true
end

local function pushReviveNotice(zombie, npcData, line)
    if not zombie or type(npcData) ~= "table" or not line or line == "" then
        return false
    end
    if not DTNPCProtect or not DTNPCProtect.PushCompanionNotice then
        return false
    end

    local now = internal.nowMillis and internal.nowMillis() or 0
    local lastAt = tonumber(npcData.allyReviveNoticeAt) or 0
    if lastAt > 0 and (now - lastAt) < 2500 then
        return false
    end

    npcData.allyReviveNoticeAt = now
    return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, "warning", "Chat")
end

function DTNPCHealth.FindAllyReviveTarget(zombie, npcData, options)
    options = type(options) == "table" and options or {}
    if not zombie or not canRescuerAttempt(npcData, options.state or npcData.state) then
        return nil, nil
    end

    local threatened = hasThreatAroundRescue(zombie, npcData, nil, nil)
    if threatened then
        npcData.allyReviveSearchAfterAt = (internal.nowMillis and internal.nowMillis() or 0) + 1500
        return nil, nil
    end

    local cell = getCell and getCell() or nil
    local zombieList = cell and cell.getZombieList and cell:getZombieList() or nil
    if not zombieList then
        return nil, nil
    end

    local bestZombie = nil
    local bestData = nil
    local bestDistSq = nil
    local searchRadius = math.max(1, tonumber(options.searchRadius) or tonumber(DTNPCHealth.ALLY_REVIVE_SEARCH_RADIUS) or 16)
    local maxDistSq = searchRadius * searchRadius

    for index = 0, zombieList:size() - 1 do
        local targetZombie = zombieList:get(index)
        if targetZombie and targetZombie ~= zombie and not targetZombie:isDead() then
            local targetData = getNPCDataForZombie(targetZombie)
            if isSameFactionRescueCandidate(npcData, targetData) then
                local canRevive = DTNPCHealth.CanReviveTarget and DTNPCHealth.CanReviveTarget(targetData, {
                    allowExcludedTarget = true,
                }) or false
                if canRevive then
                    local dx = zombie:getX() - targetZombie:getX()
                    local dy = zombie:getY() - targetZombie:getY()
                    local dz = math.abs((zombie:getZ() or 0) - (targetZombie:getZ() or 0))
                    local distSq = (dx * dx) + (dy * dy)
                    if dz <= 1 and distSq <= maxDistSq then
                        local reviveData = type(targetData.reviveData) == "table" and targetData.reviveData or nil
                        local owner = tostring(reviveData and reviveData.allyReviveLeaseUUID or "")
                        local leaseUntil = tonumber(reviveData and reviveData.allyReviveLeaseUntil) or 0
                        local now = internal.nowMillis and internal.nowMillis() or 0
                        if owner == "" or owner == tostring(npcData.uuid or "") or leaseUntil <= now then
                            local threatenedTarget = hasThreatNearTarget(targetZombie, targetData)
                            if not threatenedTarget then
                                if bestDistSq == nil or distSq < bestDistSq then
                                    bestZombie = targetZombie
                                    bestData = targetData
                                    bestDistSq = distSq
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not bestZombie then
        npcData.allyReviveSearchAfterAt = (internal.nowMillis and internal.nowMillis() or 0) + 1500
    else
        npcData.allyReviveSearchAfterAt = nil
    end

    return bestZombie, bestData
end

function DTNPCHealth.TryEnterAllyRevive(zombie, npcData, state)
    if not zombie or not canRescuerAttempt(npcData, state) then
        return false
    end

    local targetZombie, targetData = DTNPCHealth.FindAllyReviveTarget(zombie, npcData, {
        state = state,
    })
    if not targetZombie or not targetData then
        return false
    end

    if not acquireLease(npcData, targetData) then
        npcData.allyReviveRetryAt = (internal.nowMillis and internal.nowMillis() or 0) + 1000
        return false
    end

    npcData.allyReviveTargetUUID = targetData.uuid
    npcData.allyReviveResumeState = tostring(state or npcData.state or "Idle")
    npcData.allyRevivePhase = "move"
    npcData.allyReviveActionUntil = 0
    npcData.allyReviveSearchAfterAt = nil
    npcData.state = "ReviveAlly"
    syncState(zombie, npcData, true, true)
    return true
end

function DTNPCHealth.ProcessAllyRevive(zombie, npcData)
    if not zombie or type(npcData) ~= "table" then
        return { action = "abort", reason = "invalid" }
    end
    if internal.isRemoteClient and internal.isRemoteClient() then
        return { action = "hold", reason = "remote_client" }
    end

    local targetUUID = npcData.allyReviveTargetUUID
    if not targetUUID then
        cancelRescue(zombie, npcData, nil, "missing_target", 1000, {
            fullSync = true,
            forceSave = true,
        })
        return { action = "abort", reason = "missing_target" }
    end

    local targetZombie = findZombieByUUID(targetUUID)
    local targetData = getNPCDataForZombie(targetZombie)
    if not targetZombie or not targetData or not isSameFactionRescueCandidate(npcData, targetData) then
        cancelRescue(zombie, npcData, targetData, "invalid_target", 1000, {
            fullSync = true,
            forceSave = true,
            forceLeaseRelease = true,
        })
        return { action = "abort", reason = "invalid_target" }
    end

    if not leaseOwnedBy(npcData, targetData) then
        if not acquireLease(npcData, targetData) then
            cancelRescue(zombie, npcData, targetData, "lease_lost", 1500, {
                fullSync = true,
                forceSave = true,
            })
            return { action = "abort", reason = "lease_lost" }
        end
    end

    local threatened, threat = hasThreatAroundRescue(zombie, npcData, targetZombie, targetData)
    if threatened then
        pushReviveNotice(zombie, npcData, "Too hot. Fall back!")
        cancelRescue(zombie, npcData, targetData, "threatened", 2500, {
            fullSync = true,
            forceSave = true,
        })
        return { action = "abort", reason = "threatened", threat = threat }
    end

    if not DTNPCHealth.HasUsableBandageSupply or not DTNPCHealth.HasUsableBandageSupply(npcData) then
        pushReviveNotice(zombie, npcData, "I need medical supplies first.")
        cancelRescue(zombie, npcData, targetData, "need_supplies", 5000, {
            fullSync = true,
            forceSave = true,
        })
        return { action = "abort", reason = "need_supplies" }
    end

    acquireLease(npcData, targetData)

    local dx = zombie:getX() - targetZombie:getX()
    local dy = zombie:getY() - targetZombie:getY()
    local dz = math.abs((zombie:getZ() or 0) - (targetZombie:getZ() or 0))
    local distSq = (dx * dx) + (dy * dy)
    local stopDist = tonumber(DTNPCHealth.REVIVE_INTERACT_RANGE) or 3.5
    if dz > 1 or distSq > (stopDist * stopDist) then
        npcData.allyRevivePhase = "move"
        return {
            action = "move",
            point = {
                x = targetZombie:getX(),
                y = targetZombie:getY(),
                z = targetZombie:getZ(),
            },
            target = targetZombie,
        }
    end

    local now = internal.nowMillis and internal.nowMillis() or 0
    local actionUntil = tonumber(npcData.allyReviveActionUntil) or 0
    if actionUntil <= now then
        if tostring(npcData.allyRevivePhase or "") ~= "apply" then
            npcData.allyRevivePhase = "apply"
            npcData.allyReviveActionUntil = now + math.max(1000, math.floor(tonumber(DTNPCHealth.ALLY_REVIVE_ACTION_DURATION_MS) or 3500))
            pushReviveNotice(zombie, npcData, "Hang on. I'm getting you up.")
            syncState(zombie, npcData, false, true)
            return {
                action = "apply",
                point = {
                    x = targetZombie:getX(),
                    y = targetZombie:getY(),
                    z = targetZombie:getZ(),
                },
                target = targetZombie,
            }
        end
    end

    actionUntil = tonumber(npcData.allyReviveActionUntil) or 0
    if actionUntil > now then
        return {
            action = "apply",
            point = {
                x = targetZombie:getX(),
                y = targetZombie:getY(),
                z = targetZombie:getZ(),
            },
            target = targetZombie,
        }
    end

    if not consumeReviveSupply(npcData) then
        cancelRescue(zombie, npcData, targetData, "consume_failed", 5000, {
            fullSync = true,
            forceSave = true,
        })
        return { action = "abort", reason = "consume_failed" }
    end

    local helperIdentity = {
        id = npcData.uuid and tostring(npcData.uuid) or nil,
        username = npcData.name and tostring(npcData.name) or nil,
        onlineID = nil,
    }

    local revived, result = DTNPCHealth.TryReviveNPC(targetZombie, targetData, nil, {
        allowNPC = true,
        allowExcludedTarget = true,
        skipConsume = true,
        requiredCount = 1,
        helperIdentity = helperIdentity,
        deferSync = false,
    })
    if not revived then
        cancelRescue(zombie, npcData, targetData, result and result.reason or "revive_failed", 3000, {
            fullSync = true,
            forceSave = true,
        })
        return { action = "abort", reason = result and result.reason or "revive_failed" }
    end

    if type(targetData.reviveData) == "table" then
        targetData.reviveData.lastOutcome = "ally_success"
    end

    pushReviveNotice(zombie, npcData, "Back on your feet.")
    cancelRescue(zombie, npcData, targetData, "completed", 0, {
        fullSync = true,
        forceSave = true,
        forceLeaseRelease = true,
    })
    syncState(targetZombie, targetData, true, true)
    return {
        action = "done",
        result = result,
        target = targetZombie,
    }
end
