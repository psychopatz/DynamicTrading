-- ==============================================================================
-- DTNPC_ProtectMeleeArbiter_Movement.lua
-- Movement helpers for DTNPC melee arbiter.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local DEFAULT_SPEED = Internal.MeleeArbiterDefaultSpeed

local function moveTowardTarget(zombie, npcData, target, stats, stopDistance, options)
    local speed = stats.chaseSpeed or options.defaultSpeed or DEFAULT_SPEED
    local blockCounterKey = options.blockCounterKey
    local navMode = (tonumber(blockCounterKey and npcData[blockCounterKey]) or 0) >= 2 and "planned" or "direct"
    local moved, state, distance = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = speed,
        navigationMode = navMode,
        plannerProfile = "combat_short",
        staminaMode = "melee_pursuit",
        desiredRun = speed > 0.06,
        stopDistance = stopDistance,
        blockCounterKey = blockCounterKey,
        stuckTicks = options.stuckTicks or 10,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        allowObstacleInteract = options.allowObstacleInteract ~= false,
        allowDamageRetreat = options.allowDamageRetreat ~= false,
        damageRetreatDistance = options.damageRetreatDistance,
        damageRetreatLockMs = options.damageRetreatLockMs,
        closeDoorSafeRadius = options.closeDoorSafeRadius or 3.0,
        anim = {
            animSpeed = speed > 0.06 and 1.15 or 1.0,
            isRunning = speed > 0.06,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") then
        npcData.isMovingState = true
    end

    return moved, state, distance
end

local function moveAwayFromPoint(zombie, npcData, stats, sourceX, sourceY, desiredDistance, options)
    local retreatRun = options.retreatRun == true
    local speed = math.max(0.034, (stats.chaseSpeed or options.defaultSpeed or DEFAULT_SPEED) * (retreatRun and 1.15 or 0.9))
    local moved, state, distance = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
        fromX = sourceX,
        fromY = sourceY,
        speed = speed,
        staminaMode = "retreat",
        desiredRun = retreatRun,
        desiredDistance = desiredDistance,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.retreatStuckTicks or 8,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        allowObstacleInteract = false,
        allowDamageRetreat = options.allowDamageRetreat ~= false,
        damageRetreatDistance = options.damageRetreatDistance,
        damageRetreatLockMs = options.damageRetreatLockMs,
        anim = {
            animSpeed = retreatRun and 1.15 or 1.0,
            isRunning = retreatRun,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") then
        npcData.isMovingState = true
    end

    return moved, state, distance
end

Internal.MoveMeleeArbiterTowardTarget = moveTowardTarget
Internal.MoveMeleeArbiterAwayFromPoint = moveAwayFromPoint
