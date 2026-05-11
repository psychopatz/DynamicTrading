-- ==============================================================================
-- Behavior_Trading_Movement.lua
-- Manual locomotion and movement helpers for trading defense behaviors.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading

function Trading.GetMobility()
    if DTNPCMobility and DTNPCMobility.MoveTowardTarget and DTNPCMobility.MoveAwayFromPoint then
        return DTNPCMobility
    end

    if require then
        pcall(require, "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility")
    end

    if DTNPCMobility and DTNPCMobility.MoveTowardTarget and DTNPCMobility.MoveAwayFromPoint then
        return DTNPCMobility
    end

    return nil
end

function Trading.IsTileSafe(x, y, z)
    local mobility = Trading.GetMobility()
    if mobility and mobility.IsTileSafe then
        return mobility.IsTileSafe(x, y, z)
    end

    local cell = getCell()
    local sq = cell and cell:getGridSquare(x, y, z) or nil
    if not sq then return true end
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
end

function Trading.ResetMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.tradingMovePrimed = nil
    npcData.tradingMoveReason = nil
end

function Trading.StopMoveAnim(zombie)
    if not zombie then
        return
    end

    local npcData = DTNPC and DTNPC.GetData and DTNPC.GetData(zombie) or nil
    Trading.ResetMoveState(npcData)

    local mobility = Trading.GetMobility()
    if mobility and mobility.Stop then
        mobility.Stop(zombie)
        return
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

function Trading.ForceWalkAnim(zombie, isRunning)
    if not zombie then
        return
    end

    local mobility = Trading.GetMobility()
    if mobility and mobility.SetLocomotionState then
        mobility.SetLocomotionState(zombie, {
            moving = true,
            animSpeed = isRunning and 1.15 or 1.0,
            isRunning = isRunning == true,
        })
        return
    end

    zombie:setVariable("DTIdleState", "0")
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    zombie:setVariable("WalkType", "1")
    zombie:setVariable("Speed", isRunning and 1.15 or 1.0)
    zombie:setRunning(isRunning == true)
end

function Trading.PrimeMovement(zombie, npcData, dirX, dirY, isRunning, reason)
    if not zombie or not npcData then
        return true
    end

    local moveDirX = tonumber(dirX) or 0
    local moveDirY = tonumber(dirY) or 0
    local len = math.sqrt((moveDirX * moveDirX) + (moveDirY * moveDirY))
    if len <= 0.001 then
        return true
    end

    moveDirX = moveDirX / len
    moveDirY = moveDirY / len

    npcData.isMovingState = true

    if npcData.tradingMovePrimed == true and npcData.tradingMoveReason == reason then
        return true
    end

    npcData.tradingMovePrimed = true
    npcData.tradingMoveReason = reason or "move"
    Trading.ForceWalkAnim(zombie, isRunning == true)
    zombie:faceLocation(zombie:getX() + moveDirX, zombie:getY() + moveDirY)
    return false
end

function Trading.EnsureManualControl(zombie)
    if not zombie then
        return
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

function Trading.MoveTowardTarget(zombie, npcData, speed, target, stopDistance, anchorX, anchorY, anchorZ, leashRadius)
    local mobility = Trading.GetMobility()
    if mobility and mobility.MoveTowardTarget then
        return mobility.MoveTowardTarget(zombie, npcData, {
            target = target,
            speed = speed,
            staminaMode = speed > 0.06 and "pursuit" or "travel",
            desiredRun = speed > 0.06,
            stopDistance = stopDistance,
            allowObstacleInteract = true,
            blockCounterKey = "tradingBlockedTicks",
            stuckTicks = 10,
            anchorX = anchorX,
            anchorY = anchorY,
            anchorZ = anchorZ,
            leashRadius = leashRadius,
            anim = {
                animSpeed = speed > 0.06 and 1.15 or 1.0,
                isRunning = speed > 0.06,
            },
        })
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    local desiredDistance = math.max(0, tonumber(stopDistance) or 0)
    if len <= 0.001 then
        Trading.StopMoveAnim(zombie)
        return true, "arrived"
    end
    if len <= desiredDistance then
        Trading.StopMoveAnim(zombie)
        return true, "arrived"
    end

    dx = dx / len
    dy = dy / len
    local step = math.min(speed, math.max(0, len - desiredDistance))
    if step <= 0.001 then
        Trading.StopMoveAnim(zombie)
        return true, "arrived"
    end

    local nextX = zx + (dx * step)
    local nextY = zy + (dy * step)

    if anchorX ~= nil and anchorY ~= nil and leashRadius ~= nil then
        local leashDx = nextX - anchorX
        local leashDy = nextY - anchorY
        local leashDist = math.sqrt((leashDx * leashDx) + (leashDy * leashDy))
        local leashFloor = tonumber(anchorZ) or zz
        if math.abs(zz - leashFloor) > 1.1 or leashDist > leashRadius then
            Trading.StopMoveAnim(zombie)
            return false, "leash"
        end
    end

    if Trading.IsTileSafe(nextX, nextY, zz) then
        Trading.ForceWalkAnim(zombie, speed > 0.06)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:faceLocation(nextX, nextY)
        return true, "moving"
    end

    if len <= (desiredDistance + 0.35) then
        Trading.StopMoveAnim(zombie)
        return true, "close_enough"
    end

    Trading.StopMoveAnim(zombie)
    return false, "blocked"
end

function Trading.MoveAwayFromTarget(zombie, npcData, speed, sourceX, sourceY, desiredDistance, anchorX, anchorY, anchorZ, leashRadius)
    local mobility = Trading.GetMobility()
    if mobility and mobility.MoveAwayFromPoint then
        return mobility.MoveAwayFromPoint(zombie, npcData, {
            fromX = sourceX,
            fromY = sourceY,
            speed = speed,
            staminaMode = "retreat",
            desiredRun = speed > 0.06,
            desiredDistance = desiredDistance,
            allowObstacleInteract = true,
            blockCounterKey = "tradingBlockedTicks",
            stuckTicks = 8,
            anchorX = anchorX,
            anchorY = anchorY,
            anchorZ = anchorZ,
            leashRadius = leashRadius,
            anim = {
                animSpeed = speed > 0.06 and 1.15 or 1.0,
                isRunning = speed > 0.06,
            },
        })
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local dx = zx - sourceX
    local dy = zy - sourceY
    local len = math.sqrt((dx * dx) + (dy * dy))
    local safeDistance = math.max(0, tonumber(desiredDistance) or 0)

    if len >= safeDistance then
        Trading.StopMoveAnim(zombie)
        return true, "spaced"
    end

    if len <= 0.001 then
        dx = ZombRandFloat(-1.0, 1.0)
        dy = ZombRandFloat(-1.0, 1.0)
        len = math.sqrt((dx * dx) + (dy * dy))
        if len <= 0.001 then
            Trading.StopMoveAnim(zombie)
            return false, "blocked"
        end
    end

    dx = dx / len
    dy = dy / len

    local step = math.min(speed, math.max(0, safeDistance - len))
    if step <= 0.001 then
        Trading.StopMoveAnim(zombie)
        return true, "spaced"
    end

    local nextX = zx + (dx * step)
    local nextY = zy + (dy * step)

    if anchorX ~= nil and anchorY ~= nil and leashRadius ~= nil then
        local leashDx = nextX - anchorX
        local leashDy = nextY - anchorY
        local leashDist = math.sqrt((leashDx * leashDx) + (leashDy * leashDy))
        local leashFloor = tonumber(anchorZ) or zz
        if math.abs(zz - leashFloor) > 1.1 or leashDist > leashRadius then
            Trading.StopMoveAnim(zombie)
            return false, "leash"
        end
    end

    if Trading.IsTileSafe(nextX, nextY, zz) then
        Trading.ForceWalkAnim(zombie, false)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:faceLocation(nextX + dx, nextY + dy)
        return true, "moving"
    end

    Trading.StopMoveAnim(zombie)
    return false, "blocked"
end
