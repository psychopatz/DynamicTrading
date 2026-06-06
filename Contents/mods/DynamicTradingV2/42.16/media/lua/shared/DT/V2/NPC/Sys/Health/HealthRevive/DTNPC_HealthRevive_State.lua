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
        npcData.reviveData.playerReviveLeaseUntil = nil
        npcData.reviveData.playerReviveLeaseUsername = nil
        npcData.reviveData.playerReviveLeaseOnlineID = nil
        npcData.reviveData.revivedAt = nil
        npcData.reviveData.consumedItemCount = nil
        npcData.reviveData.lastOutcome = nil
    else
        npcData.reviveData = nil
    end
end

internal.clearReviveState = clearReviveState

local function clearReviveCombatCarryover(npcData, combatHealth, revivedAt)
    if type(combatHealth) ~= "table" then
        return
    end

    revivedAt = tonumber(revivedAt) or 0
    combatHealth.lastDamageAt = 0
    combatHealth.lastDamageAmount = 0
    combatHealth.lastDamageSource = nil
    combatHealth.lastAttackerType = nil
    combatHealth.lastAttackerID = nil
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0
    combatHealth.incapGraceUntil = 0
    combatHealth.postReviveGraceUntil = revivedAt + math.max(0, tonumber(DTNPCHealth.POST_REVIVE_GRACE_WINDOW_MS) or 2500)
    combatHealth.lastRevivedAt = revivedAt

    if type(npcData) == "table" then
        npcData.lastPlayerAttackerUsername = nil
        npcData.lastPlayerAttackerOnlineID = nil
        npcData.lastPlayerAttackedAt = nil
    end
end

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
        combatHealth.postReviveGraceUntil = 0
        combatHealth.lastRevivedAt = 0
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

    if DTNPCRoles and DTNPCRoles.ResolveDefaultState then
        local ok, state = pcall(DTNPCRoles.ResolveDefaultState, npcData)
        if ok and tostring(state or "") ~= "" then
            return tostring(state)
        end
    end

    return "Idle"
end

local function playReviveSuccessSound(zombie)
    local soundName = tostring(DTNPCHealth and DTNPCHealth.REVIVE_SUCCESS_SOUND or "DT_Healed")
    if soundName == "" then
        return false
    end

    local emitter = zombie and zombie.getEmitter and zombie:getEmitter() or nil
    if emitter and emitter.playSound then
        emitter:playSound(soundName)
        return true
    end

    if zombie and zombie.playSound then
        zombie:playSound(soundName)
        return true
    end

    local square = zombie and zombie.getSquare and zombie:getSquare() or nil
    local soundManager = getSoundManager and getSoundManager() or nil
    if square and soundManager and soundManager.PlayWorldSound then
        soundManager:PlayWorldSound(soundName, square, 0, 8, 1.0, false)
        return true
    end

    return false
end

local function pushReviveThankYouNotice(zombie, npcData, helperIdentity)
    if not zombie or type(npcData) ~= "table" then
        return false
    end

    local helperName = type(helperIdentity) == "table" and tostring(helperIdentity.username or "") or ""
    local line = "Thank you. I can make it home from here."
    if helperName ~= "" then
        line = "Thank you, " .. helperName .. ". I can make it home from here."
    end

    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, "friendly", "Chat")
    end

    return false
end

local function applyReviveState(zombie, npcData, helperIdentity, requiredCount, consumedCount)
    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false, { reason = "missing_health" }
    end

    local maxHealth = tonumber(combatHealth.max) or tonumber(DTNPCHealth.GetMaxHP and DTNPCHealth.GetMaxHP(npcData)) or 1
    local targetCurrent = math.min(maxHealth, math.max(1, math.floor(tonumber(DTNPCHealth.REVIVE_INITIAL_HP) or 10)))
    local revivedAt = internal.nowMillis and internal.nowMillis() or 0

    combatHealth.enabled = true
    combatHealth.engineProtected = true
    combatHealth.current = internal.clamp(targetCurrent, tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01, maxHealth)
    combatHealth.lastEngineHealth = tonumber(combatHealth.engineBuffer) or tonumber(DTNPCHealth.DEFAULT_ENGINE_BUFFER) or 1000
    clearReviveCombatCarryover(npcData, combatHealth, revivedAt)
    internal.clearActiveBandage(combatHealth, false)
    combatHealth.bandageActionUntil = 0
    combatHealth.bandageAnimFallbackUntil = 0
    combatHealth.bandageRetryAt = 0
    combatHealth.bandageResumeState = nil
    combatHealth.bandageAnimVariant = nil

    npcData.incapState = nil
    npcData.state = resolveReviveResumeState(npcData)
    npcData.reviveAssistHoldUntil = nil
    npcData.reviveAssistRescuerUUID = nil
    npcData.preIncapState = nil
    npcData.preIncapStatus = nil
    npcData.preIncapMaster = nil
    npcData.preIncapMasterID = nil
    npcData.requestedReturnStatus = nil
    npcData.isMovingState = false
    npcData.incapStrugglePauseUntil = nil
    npcData.incapNextPauseAt = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil
    npcData.removalRequested = nil
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    npcData.tasks = {}
    npcData.lastCustomDamageHandledAt = revivedAt

    local reviveData = internal.prepareIncapacitatedReviveData and internal.prepareIncapacitatedReviveData(npcData) or internal.ensureReviveDataTable(npcData)
    if reviveData then
        reviveData.requiredItemCount = math.max(1, math.floor(tonumber(requiredCount) or tonumber(reviveData.requiredItemCount) or 1))
        reviveData.revivedAt = revivedAt
        reviveData.consumedItemCount = math.max(0, math.floor(tonumber(consumedCount) or 0))
        reviveData.lastOutcome = "success"
        reviveData.allyReviveLeaseUUID = nil
        reviveData.allyReviveLeaseUntil = nil
        reviveData.allyReviveLeaseState = nil
        reviveData.playerReviveLeaseUntil = nil
        reviveData.playerReviveLeaseUsername = nil
        reviveData.playerReviveLeaseOnlineID = nil
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
    if zombie and DTNPC and DTNPC.MarkBodyOwnership then
        DTNPC.MarkBodyOwnership(zombie, npcData)
    end
    pushReviveThankYouNotice(zombie, npcData, helperIdentity)
    playReviveSuccessSound(zombie)
    return true, {
        requiredCount = reviveData and reviveData.requiredItemCount or requiredCount,
        consumedCount = tonumber(consumedCount) or 0,
        healthState = npcData.healthState,
        currentHP = tonumber(combatHealth.current) or 0,
        state = tostring(npcData.state or "Idle"),
    }
end

function DTNPCHealth.IsReviveHelpActive(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    local reviveData = type(npcData.reviveData) == "table" and npcData.reviveData or nil
    if type(reviveData) ~= "table" then
        return false
    end

    local now = internal.nowMillis and internal.nowMillis() or 0
    local allyUntil = tonumber(reviveData.allyReviveLeaseUntil) or 0
    if allyUntil > now then
        return true
    end

    local playerUntil = tonumber(reviveData.playerReviveLeaseUntil) or 0
    return playerUntil > now
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

    if internal.resolveAuthoritativeNPCContext then
        zombie, npcData = internal.resolveAuthoritativeNPCContext(zombie, npcData)
    end
    if type(npcData) ~= "table" then
        return false, { reason = "invalid_target" }
    end

    local canRevive, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
        ignoreItems = options.ignoreItems == true,
        requiredFullType = options.requiredFullType,
    })
    if options.allowNPC == true then
        canRevive, info = DTNPCHealth.CanReviveTarget(npcData, {
            allowExcludedTarget = options.allowExcludedTarget == true,
            ignoreItems = options.ignoreItems == true,
            requiredFullType = options.requiredFullType,
            playerObj = playerObj,
        })
    end
    if not canRevive then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Revive",
            "Revive rejected target=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " helper=" .. tostring(playerObj and playerObj.getUsername and playerObj:getUsername() or options.helperIdentity and options.helperIdentity.username or "NPC")
                .. " reason=" .. tostring(info and info.reason or "invalid")
        )
        return false, info
    end

    local requiredCount = tonumber(options.requiredCount) or tonumber(info and info.requiredCount) or nil
    if (not requiredCount or requiredCount <= 0) and internal.prepareIncapacitatedReviveData then
        local reviveData = internal.prepareIncapacitatedReviveData(npcData)
        requiredCount = tonumber(reviveData and reviveData.requiredItemCount) or 1
    end
    requiredCount = math.max(1, math.floor(requiredCount or 1))

    local consumedCount = 0
    local requireItems = info and info.requiresItems == true
    if options.skipConsume ~= true and requireItems then
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
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Revive",
            "Revive apply failed target=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " helper=" .. tostring(helperIdentity and helperIdentity.username or "NPC")
                .. " reason=" .. tostring(result and result.reason or "missing_health")
        )
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

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Revive",
        "Revive committed target=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " helper=" .. tostring(helperIdentity and helperIdentity.username or "NPC")
            .. " state=" .. tostring(npcData.state or "Idle")
            .. " hp=" .. tostring(result and result.currentHP or "nil")
    )

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
