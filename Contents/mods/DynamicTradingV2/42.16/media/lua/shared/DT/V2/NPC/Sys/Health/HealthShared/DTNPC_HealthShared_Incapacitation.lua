-- ==============================================================================
-- DTNPC_HealthShared_Incapacitation.lua
-- Incapacitation-state transitions for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function setIncapacitatedState(zombie, npcData)
    local incapacitatedAt = internal.nowMillis()

    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
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
    if internal.clearReviveState then
        internal.clearReviveState(npcData, false)
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
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    npcData.isMovingState = false
    npcData.combatOrder = nil
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.combatResumeState = nil
    npcData.autoProtectActiveState = nil
    npcData.combatPursuitTargetID = nil
    npcData.combatPursuitStartedAt = 0
    npcData.combatPursuitLastProgressAt = 0
    npcData.combatPursuitLastAttackAt = 0
    npcData.combatPursuitLastDistance = nil
    npcData.companionCombatActive = false
    npcData.companionLastCombatTargetID = nil
    npcData.companionLastRangedTargetID = nil

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    combatHealth.enabled = false
    combatHealth.engineProtected = true
    combatHealth.current = math.max(
        tonumber(DTNPCHealth.INCAP_CUSTOM_HP) or 1,
        tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01
    )
    combatHealth.lastDamageAt = incapacitatedAt
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0
    combatHealth.incapGraceUntil = incapacitatedAt + DTNPCHealth.INCAP_GRACE_WINDOW_MS
    combatHealth.postReviveGraceUntil = 0
    combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    internal.clearActiveBandage(combatHealth, false)
    combatHealth.bandageActionUntil = 0
    combatHealth.bandageRetryAt = 0
    combatHealth.bandageResumeState = nil
    combatHealth.bandageAnimVariant = nil
    npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    npcData.lastCustomDamageHandledAt = combatHealth.lastDamageAt
    if internal.prepareIncapacitatedReviveData then
        internal.prepareIncapacitatedReviveData(npcData)
    end

    zombie:setTarget(nil)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setRunning(false)
    if DTNPCMobility and DTNPCMobility.SetLocomotionState then
        DTNPCMobility.SetLocomotionState(zombie, {
            profileKey = DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl",
            moving = false,
            animSpeed = 0.0,
        })
    else
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
        zombie:setVariable("DTWalkType", "Crawl")
    end
    internal.clearBandageAnimVariables(zombie)
    zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
    zombie:resetModelNextFrame()

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and npcData.uuid then
        DynamicTrading_Roster.SaveSoul(npcData.uuid, npcData)
    end
    if DTNPCManager and DTNPCManager.Save then
        DTNPCManager.Save()
    end

    internal.handleLinkedWorkerIncapacitated(npcData)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "NPC entered incapacitated state on existing body: " .. tostring(npcData.name or npcData.uuid or "Unknown")
    )
end

internal.setIncapacitatedState = setIncapacitatedState
