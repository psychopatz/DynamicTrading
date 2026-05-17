-- ==============================================================================
-- DTNPC_HealthRevive_State.lua
-- Shared revive state transitions and weakened recovery processing.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function getCurrentMoveState(zombie, npcData)
    if type(npcData) == "table" and npcData.isMovingState == true then
        return true
    end
    if zombie and zombie.getVariableBoolean then
        local ok, value = pcall(zombie.getVariableBoolean, zombie, "bMoving")
        if ok and value == true then
            return true
        end
    end
    return false
end

local function clearReviveState(npcData, keepRequirement)
    if type(npcData) ~= "table" then
        return
    end

    npcData.healthState = nil
    npcData.reviveHelperID = nil
    npcData.reviveHelperOnlineID = nil
    npcData.reviveHelperUsername = nil
    npcData.allyReviveTargetUUID = nil
    npcData.allyRevivePhase = nil
    npcData.allyReviveActionUntil = nil
    npcData.allyReviveLeaseUntil = nil
    npcData.allyReviveResumeState = nil
    npcData.allyReviveRetryAt = nil
    npcData.allyReviveNoticeAt = nil
    npcData.allyReviveSearchAfterAt = nil

    if keepRequirement == true then
        if type(npcData.reviveData) ~= "table" then
            npcData.reviveData = {}
        end
        npcData.reviveData.allyReviveLeaseUUID = nil
        npcData.reviveData.allyReviveLeaseUntil = nil
        npcData.reviveData.allyReviveLeaseState = nil
        npcData.reviveData.revivedAt = nil
        npcData.reviveData.consumedItemCount = nil
        npcData.reviveData.lastOutcome = nil
    else
        npcData.reviveData = nil
    end
end

internal.clearReviveState = clearReviveState

local function markTerminalDeathState(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    clearReviveState(npcData, false)

    npcData.status = "Dead"
    npcData.state = "Dead"
    npcData.healthState = nil
    npcData.incapState = nil
    npcData.preIncapState = nil
    npcData.preIncapStatus = nil
    npcData.preIncapMaster = nil
    npcData.preIncapMasterID = nil
    npcData.requestedReturnStatus = nil
    npcData.returnTime = 0
    npcData.returnStatus = nil
    npcData.master = nil
    npcData.masterID = nil
    npcData.isHostile = false
    npcData.tasks = {}
    npcData.incapStrugglePauseUntil = nil
    npcData.incapNextPauseAt = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil
    npcData.reviveHelperID = nil
    npcData.reviveHelperOnlineID = nil
    npcData.reviveHelperUsername = nil
    npcData.health = 0
    npcData.lastHealth = 0
    npcData.deathFinalizedAt = internal.nowMillis and internal.nowMillis() or 0

    local combatHealth = type(npcData.combatHealth) == "table" and npcData.combatHealth or nil
    if combatHealth then
        combatHealth.enabled = false
        combatHealth.engineProtected = false
        combatHealth.current = 0
        combatHealth.lastEngineHealth = 0
        combatHealth.pendingFallbackIgnoreAmount = 0
        combatHealth.pendingFallbackIgnoreUntil = 0
        combatHealth.incapGraceUntil = 0
        combatHealth.incapFinalKillRequestedAt = npcData.deathFinalizedAt
        if internal.clearActiveBandage then
            internal.clearActiveBandage(combatHealth, false)
        end
        combatHealth.bandageActionUntil = 0
        combatHealth.bandageAnimFallbackUntil = 0
        combatHealth.bandageRetryAt = 0
        combatHealth.bandageResumeState = nil
        combatHealth.bandageAnimVariant = nil
    end

    return true
end

internal.markTerminalDeathState = markTerminalDeathState

local function getPlayerIdentity(playerObj)
    if not playerObj then
        return nil
    end

    local username = playerObj.getUsername and playerObj:getUsername() or nil
    local onlineID = playerObj.getOnlineID and playerObj:getOnlineID() or nil
    return {
        id = username or (onlineID ~= nil and tostring(onlineID) or nil),
        username = username,
        onlineID = onlineID,
    }
end

local function resolveReviveResumeState(npcData)
    if type(npcData) ~= "table" then
        return "Idle"
    end

    if npcData.linkedWorkerID ~= nil and DTNPCColonyRuntime and DTNPCColonyRuntime.SyncBehaviorIdentity then
        local ok, result = pcall(DTNPCColonyRuntime.SyncBehaviorIdentity, npcData)
        if ok and tostring(result or "") ~= "" then
            return tostring(result)
        end
    end

    local preIncapState = tostring(npcData.preIncapState or "")
    if preIncapState ~= ""
        and preIncapState ~= "Incapacitated"
        and preIncapState ~= "Attack"
        and preIncapState ~= "AttackRange"
        and preIncapState ~= "Flee"
        and preIncapState ~= "Dead" then
        return preIncapState
    end

    if npcData.master ~= nil or npcData.masterID ~= nil then
        return "Follow"
    end

    if npcData.guardCombatOrder ~= nil or npcData.stationaryPostX ~= nil then
        return "Guard"
    end

    return "Idle"
end

local function applyReviveState(zombie, npcData, helperIdentity, requiredCount, consumedCount)
    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false, { reason = "missing_health" }
    end

    local maxHealth = tonumber(combatHealth.max) or tonumber(DTNPCHealth.GetMaxHP and DTNPCHealth.GetMaxHP(npcData)) or 1
    local targetCurrent = math.max(
        tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01,
        math.floor((maxHealth * DTNPCHealth.REVIVE_INITIAL_HP_RATIO) + 0.5)
    )

    combatHealth.enabled = true
    combatHealth.engineProtected = true
    combatHealth.current = internal.clamp(targetCurrent, tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01, maxHealth)
    combatHealth.lastEngineHealth = tonumber(combatHealth.engineBuffer) or tonumber(DTNPCHealth.DEFAULT_ENGINE_BUFFER) or 1000
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0
    combatHealth.incapGraceUntil = 0
    internal.clearActiveBandage(combatHealth, false)
    combatHealth.bandageActionUntil = 0
    combatHealth.bandageAnimFallbackUntil = 0
    combatHealth.bandageRetryAt = 0
    combatHealth.bandageResumeState = nil
    combatHealth.bandageAnimVariant = nil

    npcData.incapState = nil
    npcData.state = resolveReviveResumeState(npcData)
    npcData.preIncapState = nil
    npcData.preIncapStatus = nil
    npcData.preIncapMaster = nil
    npcData.preIncapMasterID = nil
    npcData.requestedReturnStatus = nil
    npcData.isMovingState = false
    npcData.lastCustomDamageHandledAt = internal.nowMillis and internal.nowMillis() or 0

    local reviveData = internal.prepareIncapacitatedReviveData and internal.prepareIncapacitatedReviveData(npcData) or internal.ensureReviveDataTable(npcData)
    if reviveData then
        reviveData.requiredItemCount = math.max(1, math.floor(tonumber(requiredCount) or tonumber(reviveData.requiredItemCount) or 1))
        reviveData.revivedAt = internal.nowMillis and internal.nowMillis() or 0
        reviveData.consumedItemCount = math.max(0, math.floor(tonumber(consumedCount) or 0))
        reviveData.lastOutcome = "success"
        reviveData.allyReviveLeaseUUID = nil
        reviveData.allyReviveLeaseUntil = nil
        reviveData.allyReviveLeaseState = nil
    end

    helperIdentity = type(helperIdentity) == "table" and helperIdentity or nil
    npcData.reviveHelperID = helperIdentity and helperIdentity.id or nil
    npcData.reviveHelperUsername = helperIdentity and helperIdentity.username or nil
    npcData.reviveHelperOnlineID = helperIdentity and helperIdentity.onlineID or nil

    if zombie then
        zombie:setTarget(nil)
        zombie:setAttackedBy(nil)
        zombie:setPath2(nil)
        zombie:setRunning(false)
        zombie:setUseless(false)
        zombie:setVariable("bBecomeCrawler", false)
        zombie:setVariable("bCrawling", false)
        zombie:setVariable("FallOnFront", false)
        zombie:setVariable("bMoving", false)
        zombie:setVariable("isMoving", false)
        zombie:setVariable("DTNPCMoveAnim", "")
        zombie:setVariable("DTNPCAnimSpeed", 0.0)
        zombie:setVariable("MovementSpeed", 0.0)
        zombie:setVariable("WalkSpeed", 0.0)
        zombie:setVariable("RunSpeed", 0.0)
        zombie:setVariable("Speed", 0.0)
        zombie:setVariable("WalkType", "")
        zombie:setVariable("DTWalkType", "")
        internal.clearBandageAnimVariables(zombie)
        zombie:setHealth(combatHealth.lastEngineHealth)
        zombie:resetModelNextFrame()
    end

    npcData.health = combatHealth.lastEngineHealth
    npcData.lastHealth = combatHealth.lastEngineHealth
    if internal.syncDerivedHealthState then
        internal.syncDerivedHealthState(npcData, combatHealth)
    end
    return true, {
        requiredCount = reviveData and reviveData.requiredItemCount or requiredCount,
        consumedCount = tonumber(consumedCount) or 0,
        healthState = npcData.healthState,
    }
end

function DTNPCHealth.TryReviveNPC(zombie, npcData, playerObj, options)
    options = type(options) == "table" and options or {}
    if type(npcData) ~= "table" then
        return false, { reason = "invalid_target" }
    end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return false, { reason = "dead_target" }
    end
    if internal.isRemoteClient and internal.isRemoteClient() then
        return false, { reason = "remote_client" }
    end

    local canRevive, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
        ignoreItems = options.ignoreItems == true,
        requiredFullType = options.requiredFullType,
    })
    if options.allowNPC == true then
        canRevive, info = DTNPCHealth.CanReviveTarget(npcData, {
            allowExcludedTarget = options.allowExcludedTarget == true,
        })
    end
    if not canRevive then
        return false, info
    end

    local requiredCount = tonumber(options.requiredCount) or tonumber(info and info.requiredCount) or nil
    if (not requiredCount or requiredCount <= 0) and internal.prepareIncapacitatedReviveData then
        local reviveData = internal.prepareIncapacitatedReviveData(npcData)
        requiredCount = tonumber(reviveData and reviveData.requiredItemCount) or 1
    end
    requiredCount = math.max(1, math.floor(requiredCount or 1))

    local consumedCount = 0
    if options.skipConsume ~= true then
        local consumed
        local removedOk
        removedOk, consumed = DTNPCHealth.ConsumeReviveItems(playerObj, requiredCount, options.requiredFullType)
        if not removedOk then
            return false, {
                reason = "need_supplies",
                requiredCount = requiredCount,
                availableCount = DTNPCHealth.CountReviveItems
                    and DTNPCHealth.CountReviveItems(playerObj, options.requiredFullType)
                    or consumed
                    or 0,
                requiredFullType = options.requiredFullType,
            }
        end
        consumedCount = consumed or requiredCount
    end

    local helperIdentity = options.helperIdentity
    if type(helperIdentity) ~= "table" then
        helperIdentity = getPlayerIdentity(playerObj)
    end

    local revived, result = applyReviveState(zombie, npcData, helperIdentity, requiredCount, consumedCount)
    if not revived then
        return false, result
    end

    if options.deferSync ~= true then
        if internal.syncAndPersistHealth then
            internal.syncAndPersistHealth(zombie, npcData, true, true)
        elseif internal.persistHealthSnapshot then
            internal.persistHealthSnapshot(npcData, true)
        end
    elseif internal.persistHealthSnapshot then
        internal.persistHealthSnapshot(npcData, true)
    end

    return true, result
end

function DTNPCHealth.ProcessWeakenedRecovery(zombie, npcData)
    if not npcData or (internal.isRemoteClient and internal.isRemoteClient()) then
        return false
    end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        clearReviveState(npcData, false)
        npcData.healthState = nil
        return false
    end
    local beforeState = tostring(DTNPCHealth.GetHealthState and DTNPCHealth.GetHealthState(npcData) or npcData.healthState or "")
    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if internal.syncDerivedHealthState then
        internal.syncDerivedHealthState(npcData, combatHealth)
    end
    local afterState = tostring(DTNPCHealth.GetHealthState and DTNPCHealth.GetHealthState(npcData) or npcData.healthState or "")
    if beforeState ~= afterState and (internal.syncAndPersistHealth or internal.persistHealthSnapshot) then
        if internal.syncAndPersistHealth and zombie then
            internal.syncAndPersistHealth(zombie, npcData, true, true)
        elseif internal.persistHealthSnapshot then
            internal.persistHealthSnapshot(npcData, true)
        end
        return true
    end
    return false
end

function DTNPCHealth.ApplyHealthVisualPosture(zombie, npcData)
    if not zombie or not npcData or not DTNPCMobility or not DTNPCMobility.SetLocomotionState then
        return false
    end

    local stateName = tostring(npcData.state or "")
    if stateName == "Bandage" then
        return false
    end

    local healthState = DTNPCHealth.GetHealthState and DTNPCHealth.GetHealthState(npcData) or nil
    local moving = getCurrentMoveState(zombie, npcData)

    if healthState == "Incapacitated" then
        DTNPCMobility.SetLocomotionState(zombie, {
            profileKey = DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl",
            moving = moving,
            animSpeed = moving and nil or 0.0,
        })
        return true
    end

    if healthState == "Weakened" and moving ~= true then
        DTNPCMobility.SetLocomotionState(zombie, {
            profileKey = DTNPCHealth and DTNPCHealth.WEAKENED_CROUCH_PROFILE_KEY or "weakened_crouch",
            moving = false,
            animSpeed = 0.0,
        })
        return true
    end

    return false
end
