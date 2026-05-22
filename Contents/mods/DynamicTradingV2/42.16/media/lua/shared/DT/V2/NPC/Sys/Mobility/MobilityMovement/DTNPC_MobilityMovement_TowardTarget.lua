-- ==============================================================================
-- DTNPC_MobilityMovement_TowardTarget.lua
-- Target-approach helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility

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

    local navigationState = nil
    local navigationTarget = target
    local movementGoalX = tx
    local movementGoalY = ty
    local movementGoalZ = tonumber(target.getZ and target:getZ() or zombie:getZ()) or zombie:getZ()
    if Mobility.ResolveNavigationTarget then
        navigationState = Mobility.ResolveNavigationTarget(zombie, npcData, target, options)
        if navigationState and navigationState.teleported == true then
            return true, navigationState.state or "leash_teleport", len
        end
        if navigationState and navigationState.active == true then
            if not navigationState.target then
                Mobility.Stop(zombie, options.anim)
                return false, navigationState.state or "route_wait", len
            end

            navigationState.actualTarget = target
            navigationState.stopDistance = stopDistance
            navigationTarget = navigationState.target
            movementGoalX = tonumber(navigationState.goalX or (navigationTarget.getX and navigationTarget:getX()) or tx) or tx
            movementGoalY = tonumber(navigationState.goalY or (navigationTarget.getY and navigationTarget:getY()) or ty) or ty
            movementGoalZ = tonumber(navigationState.goalZ or (navigationTarget.getZ and navigationTarget:getZ()) or movementGoalZ) or movementGoalZ
            dx = movementGoalX - zx
            dy = movementGoalY - zy
            local waypointDistance = math.sqrt((dx * dx) + (dy * dy))
            if waypointDistance <= 0.001 then
                if navigationState.routeComplete == true and len <= (stopDistance + 0.45) then
                    Mobility.Stop(zombie, options.anim)
                    return true, "arrived", len
                end
                dx = tx - zx
                dy = ty - zy
            end
        end
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
                staminaMode = "retreat",
                desiredRun = false,
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
        staminaMode = options.staminaMode,
        desiredRun = options.desiredRun == true,
        goalX = movementGoalX,
        goalY = movementGoalY,
        progressGoalX = movementGoalX,
        progressGoalY = movementGoalY,
        closeDoorTarget = navigationTarget,
        closeDoorSafeRadius = options.closeDoorSafeRadius,
        allowDamageRetreat = options.allowDamageRetreat ~= false,
        damageRetreatDistance = options.damageRetreatDistance,
        damageRetreatLockMs = options.damageRetreatLockMs,
        steeringAngles = options.steeringAngles,
    })

    if navigationState and navigationState.active == true and Mobility.HandleNavigationResult then
        local handled, handledState = Mobility.HandleNavigationResult(zombie, npcData, navigationState, state, len)
        if handledState then
            moved = handled == true
            state = handledState
        end
    end

    if not moved and len <= (stopDistance + 0.35) then
        Mobility.Stop(zombie, options.anim)
        return true, "close_enough", len
    end

    return moved, state, len
end
