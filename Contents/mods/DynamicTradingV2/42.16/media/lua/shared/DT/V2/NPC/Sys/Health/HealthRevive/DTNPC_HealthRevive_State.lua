-- ==============================================================================
-- DTNPC_HealthRevive_State.lua
-- Shared revive state transitions and weakened recovery processing.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function clearReviveState(npcData, keepRequirement)
    if type(npcData) ~= "table" then
        return
    end

    npcData.healthState = nil
    npcData.reviveHelperID = nil
    npcData.reviveHelperOnlineID = nil
    npcData.reviveHelperUsername = nil

    if keepRequirement == true then
        if type(npcData.reviveData) ~= "table" then
            npcData.reviveData = {}
        end
        npcData.reviveData.revivedAt = nil
        npcData.reviveData.consumedItemCount = nil
        npcData.reviveData.lastOutcome = nil
    else
        npcData.reviveData = nil
    end
end

internal.clearReviveState = clearReviveState

local function getPlayerIdentity(playerObj)
    if not playerObj then
        return nil, nil
    end

    local username = playerObj.getUsername and playerObj:getUsername() or nil
    local onlineID = playerObj.getOnlineID and playerObj:getOnlineID() or nil
    return username, onlineID
end

local function applyReviveState(zombie, npcData, playerObj, requiredCount, consumedCount)
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
    npcData.healthState = "Weakened"
    npcData.state = tostring(npcData.state or "") == "Incapacitated" and "Idle" or (npcData.state or "Idle")
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
    end

    local username, onlineID = getPlayerIdentity(playerObj)
    npcData.reviveHelperID = username or (onlineID ~= nil and tostring(onlineID) or nil)
    npcData.reviveHelperUsername = username
    npcData.reviveHelperOnlineID = onlineID

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
    if internal.isRemoteClient and internal.isRemoteClient() then
        return false, { reason = "remote_client" }
    end

    local canRevive, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
        ignoreItems = options.ignoreItems == true,
        requiredFullType = options.requiredFullType,
    })
    if not canRevive then
        return false, info
    end

    local requiredCount = tonumber(info and info.requiredCount) or nil
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

    local revived, result = applyReviveState(zombie, npcData, playerObj, requiredCount, consumedCount)
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
    if tostring(npcData.healthState or "") ~= "Weakened" then
        return false
    end
    if npcData.incapState == "Active" or tostring(npcData.state or "") == "Incapacitated" then
        npcData.healthState = nil
        return true
    end

    local ratio = DTNPCHealth.GetHealthRatio and DTNPCHealth.GetHealthRatio(npcData) or 0
    if ratio < DTNPCHealth.WEAKENED_RECOVERY_RATIO then
        return false
    end

    clearReviveState(npcData, false)
    if internal.syncAndPersistHealth and zombie then
        internal.syncAndPersistHealth(zombie, npcData, true, true)
    elseif internal.persistHealthSnapshot then
        internal.persistHealthSnapshot(npcData, true)
    end
    return true
end
