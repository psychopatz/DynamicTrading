-- ==============================================================================
-- DTNPC_MobilityMovement.lua
-- Directional and target-based movement helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

local function applyMovementState(zombie, anim)
    Mobility.SetLocomotionState(zombie, {
        moving = true,
        isRunning = anim and anim.isRunning == true,
        animSpeed = anim and anim.animSpeed or nil,
        walkType = anim and anim.walkType or nil,
        dtWalkType = anim and anim.dtWalkType or nil,
        idleState = anim and anim.idleState or nil,
        crawl = anim and anim.crawl == true or false,
    })
end

function Mobility.MoveByDirection(zombie, npcData, options)
    if not zombie then
        return false, "invalid"
    end

    options = type(options) == "table" and options or {}

    local dirX = tonumber(options.dirX) or 0
    local dirY = tonumber(options.dirY) or 0
    local len = math.sqrt((dirX * dirX) + (dirY * dirY))
    if len <= 0.001 then
        Mobility.Stop(zombie, options.anim)
        return false, "no_direction"
    end

    dirX = dirX / len
    dirY = dirY / len

    local step = math.max(0, tonumber(options.speed) or 0)
    if step <= 0.001 then
        Mobility.Stop(zombie, options.anim)
        return false, "stopped"
    end

    if options.allowDamageRetreat ~= false and options._forcedRetreatActive ~= true then
        local forcedRetreat = Mobility.GetForcedRetreat(zombie, npcData, options)
        if forcedRetreat then
            dirX = forcedRetreat.dirX
            dirY = forcedRetreat.dirY
        end
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local chosenStep = Mobility.ChooseSteeredStep(zombie, npcData, dirX, dirY, step, options)
    local nextX = chosenStep and chosenStep.nextX or (zx + (dirX * step))
    local nextY = chosenStep and chosenStep.nextY or (zy + (dirY * step))
    local moveDirX = chosenStep and chosenStep.dirX or dirX
    local moveDirY = chosenStep and chosenStep.dirY or dirY

    if not Internal.isWithinLeash(nextX, nextY, zz, options) then
        Mobility.Stop(zombie, options.anim)
        return false, "leash"
    end

    if options.allowObstacleInteract == true then
        local interacted = false
        local obstacleKind = nil
        if chosenStep and chosenStep.passage and chosenStep.canMove ~= true then
            local opened, openedKind = Mobility.TryOpenPassage(zombie, chosenStep.passage)
            if opened then
                Mobility.TrackOpenedPassage(npcData, chosenStep.passage)
                interacted = true
                obstacleKind = openedKind
            end
        else
            interacted, obstacleKind = Internal.tryInteractWithObstacle(zombie, npcData, zx, zy, zz, nextX, nextY, options)
        end

        if interacted then
            Internal.clearBlockedCounter(npcData, options.blockCounterKey)
            Mobility.Stop(zombie, options.anim)
            return false, "interacted_" .. tostring(obstacleKind or "obstacle")
        end
    end

    local canMove = chosenStep and chosenStep.canMove or Mobility.IsTileSafe(nextX, nextY, zz)
    if not canMove and options.allowAxisSlide ~= false then
        if Internal.isWithinLeash(nextX, zy, zz, options) and Mobility.IsTileSafe(nextX, zy, zz) then
            nextY = zy
            canMove = true
        elseif Internal.isWithinLeash(zx, nextY, zz, options) and Mobility.IsTileSafe(zx, nextY, zz) then
            nextX = zx
            canMove = true
        end
    end

    if canMove then
        Internal.clearBlockedCounter(npcData, options.blockCounterKey)
        zombie:setX(nextX)
        zombie:setY(nextY)
        if options.targetZ ~= nil then
            zombie:setZ(options.targetZ)
        end

        applyMovementState(zombie, options.anim)

        local faceX = tonumber(options.faceX)
        local faceY = tonumber(options.faceY)
        if options.faceTargetWhileMoving == true and faceX ~= nil and faceY ~= nil then
            zombie:faceLocation(faceX, faceY)
        else
            zombie:faceLocation(nextX + moveDirX, nextY + moveDirY)
        end

        Internal.rememberMotion(npcData, zx, zy, nextX, nextY, {
            speed = step,
            crawl = options.anim and options.anim.crawl == true or false,
            isRunning = options.anim and options.anim.isRunning == true or false,
        })
        if type(npcData) == "table" then
            npcData._dtLastMoveDirX = moveDirX
            npcData._dtLastMoveDirY = moveDirY
            npcData._dtLastSteerDirX = moveDirX
            npcData._dtLastSteerDirY = moveDirY
            npcData._dtBlockedHeading = nil
            npcData._dtBlockedHeadingUntil = 0
        end
        Mobility.TryClosePassedDoor(zombie, npcData, {
            target = options.closeDoorTarget,
            safeRadius = options.closeDoorSafeRadius,
        })
        return true, "moving"
    end

    local blockedTicks = Internal.incrementBlockedCounter(npcData, options.blockCounterKey)
    Internal.setBlockedHeading(npcData, moveDirX, moveDirY)
    local stuckTicks = math.max(0, tonumber(options.stuckTicks) or 0)
    if blockedTicks >= stuckTicks and stuckTicks > 0 then
        local unstuck, unstuckX, unstuckY = Internal.tryUnstick(zombie, zz, moveDirX, moveDirY)
        if unstuck then
            Internal.clearBlockedCounter(npcData, options.blockCounterKey)
            applyMovementState(zombie, options.anim)
            zombie:faceLocation(unstuckX + moveDirX, unstuckY + moveDirY)
            Internal.rememberMotion(npcData, zx, zy, unstuckX, unstuckY, {
                speed = step,
                crawl = options.anim and options.anim.crawl == true or false,
                isRunning = options.anim and options.anim.isRunning == true or false,
            })
            if type(npcData) == "table" then
                npcData._dtLastMoveDirX = moveDirX
                npcData._dtLastMoveDirY = moveDirY
                npcData._dtLastSteerDirX = moveDirX
                npcData._dtLastSteerDirY = moveDirY
            end
            return true, "unstuck"
        end
    end

    Mobility.Stop(zombie, options.anim)
    return false, "blocked"
end

function Mobility.MoveTowardTarget(zombie, npcData, options)
    if not zombie then
        return false, "invalid", 9999
    end

    options = type(options) == "table" and options or {}
    local target = options.target
    if not target or not target.getX or not target.getY then
        Mobility.Stop(zombie, options.anim)
        return false, "invalid_target", 9999
    end

    local zx, zy = zombie:getX(), zombie:getY()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    local stopDistance = math.max(0, tonumber(options.stopDistance) or 0)

    if len <= 0.001 or len <= stopDistance then
        Mobility.Stop(zombie, options.anim)
        return true, "arrived", len
    end

    local step = math.min(math.max(0, tonumber(options.speed) or 0), math.max(0, len - stopDistance))
    if step <= 0.001 then
        Mobility.Stop(zombie, options.anim)
        return true, "arrived", len
    end

    local forcedRetreat = nil
    if options.allowDamageRetreat ~= false then
        forcedRetreat = Mobility.GetForcedRetreat(zombie, npcData, options)
        if forcedRetreat then
            local retreatMoved, retreatState = Mobility.MoveByDirection(zombie, npcData, {
                dirX = forcedRetreat.dirX,
                dirY = forcedRetreat.dirY,
                speed = step,
                allowAxisSlide = options.allowAxisSlide ~= false,
                allowObstacleInteract = options.allowObstacleInteract ~= false,
                allowDamageRetreat = false,
                _forcedRetreatActive = true,
                blockCounterKey = options.blockCounterKey,
                stuckTicks = options.stuckTicks,
                anim = options.anim,
                anchorX = options.anchorX,
                anchorY = options.anchorY,
                anchorZ = options.anchorZ,
                leashRadius = options.leashRadius,
                targetZ = options.targetZ,
                faceX = options.faceX,
                faceY = options.faceY,
                faceTargetWhileMoving = options.faceTargetWhileMoving,
                goalX = zombie:getX() + (forcedRetreat.dirX * step),
                goalY = zombie:getY() + (forcedRetreat.dirY * step),
                closeDoorTarget = options.target,
                closeDoorSafeRadius = options.closeDoorSafeRadius,
                steeringAngles = options.steeringAngles,
            })
            return retreatMoved, retreatState == "moving" and "damage_retreat" or retreatState, len
        end
    end

    local moved, state = Mobility.MoveByDirection(zombie, npcData, {
        dirX = dx,
        dirY = dy,
        speed = step,
        allowAxisSlide = options.allowAxisSlide ~= false,
        allowObstacleInteract = options.allowObstacleInteract ~= false,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.stuckTicks,
        anim = options.anim,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        targetZ = options.targetZ,
        faceX = options.faceX,
        faceY = options.faceY,
        faceTargetWhileMoving = options.faceTargetWhileMoving,
        goalX = tx,
        goalY = ty,
        closeDoorTarget = options.target,
        closeDoorSafeRadius = options.closeDoorSafeRadius,
        allowDamageRetreat = options.allowDamageRetreat ~= false,
        damageRetreatDistance = options.damageRetreatDistance,
        damageRetreatLockMs = options.damageRetreatLockMs,
        steeringAngles = options.steeringAngles,
    })

    if not moved and len <= (stopDistance + 0.35) then
        Mobility.Stop(zombie, options.anim)
        return true, "close_enough", len
    end

    return moved, state, len
end

function Mobility.MoveAwayFromPoint(zombie, npcData, options)
    if not zombie then
        return false, "invalid", 9999
    end

    options = type(options) == "table" and options or {}
    local fromX = tonumber(options.fromX)
    local fromY = tonumber(options.fromY)
    if fromX == nil or fromY == nil then
        local target = options.target
        if target and target.getX and target.getY then
            fromX = target:getX()
            fromY = target:getY()
        end
    end
    if fromX == nil or fromY == nil then
        Mobility.Stop(zombie, options.anim)
        return false, "invalid_target", 9999
    end

    local zx, zy = zombie:getX(), zombie:getY()
    local dx = zx - fromX
    local dy = zy - fromY
    local len = math.sqrt((dx * dx) + (dy * dy))
    local desiredDistance = math.max(0, tonumber(options.desiredDistance) or 0)

    if len >= desiredDistance then
        Mobility.Stop(zombie, options.anim)
        return true, "spaced", len
    end

    if len <= 0.001 then
        local cachedDirX = tonumber(npcData and npcData._dtLastMoveDirX) or 0
        local cachedDirY = tonumber(npcData and npcData._dtLastMoveDirY) or 0
        if math.abs(cachedDirX) > 0.001 or math.abs(cachedDirY) > 0.001 then
            dx = cachedDirX
            dy = cachedDirY
        else
            dx = ZombRandFloat(-1.0, 1.0)
            dy = ZombRandFloat(-1.0, 1.0)
        end
    end

    local step = math.min(math.max(0, tonumber(options.speed) or 0), math.max(0, desiredDistance - len))
    if step <= 0.001 then
        Mobility.Stop(zombie, options.anim)
        return true, "spaced", len
    end

    local forcedRetreat = nil
    if options.allowDamageRetreat ~= false then
        forcedRetreat = Mobility.GetForcedRetreat(zombie, npcData, options)
    end

    local moveDirX = forcedRetreat and forcedRetreat.dirX or dx
    local moveDirY = forcedRetreat and forcedRetreat.dirY or dy

    return Mobility.MoveByDirection(zombie, npcData, {
        dirX = moveDirX,
        dirY = moveDirY,
        speed = step,
        allowAxisSlide = options.allowAxisSlide ~= false,
        allowObstacleInteract = options.allowObstacleInteract ~= false,
        allowDamageRetreat = false,
        _forcedRetreatActive = forcedRetreat ~= nil,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.stuckTicks,
        anim = options.anim,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        targetZ = options.targetZ,
        faceX = options.faceX,
        faceY = options.faceY,
        faceTargetWhileMoving = options.faceTargetWhileMoving,
        goalX = zombie:getX() + (moveDirX * step),
        goalY = zombie:getY() + (moveDirY * step),
        steeringAngles = options.steeringAngles,
    })
end
