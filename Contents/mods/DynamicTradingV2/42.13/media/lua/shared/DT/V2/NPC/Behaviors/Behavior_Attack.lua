-- ==============================================================================
-- Behavior_Attack.lua
-- Hostile melee combat plus legacy wake-up behavior for movement states.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"

local MELEE_DEFAULT_REACH = 1.25
local MELEE_DEFAULT_SPEED = 0.05

local function runLegacyWakeup(zombie, target, dist)
    if zombie:isUseless() then
        zombie:setUseless(false)
        zombie:setSpeedMod(1.1)
        zombie:DoZombieStats()
        zombie:setSitAgainstWall(false)
    end

    if target then
        zombie:setTarget(target)

        local shouldRun = (tonumber(dist) or 9999) > 3.0 or target:isRunning() or target:isSprinting()
        zombie:setRunning(shouldRun)

        if not zombie:isMoving() and (tonumber(dist) or 9999) > 1.5 then
            zombie:pathToLocation(target:getX(), target:getY(), target:getZ())
        end
    elseif not zombie:isMoving() then
        zombie:setRunning(true)
    end
end

local function stopMoveAnim(zombie)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function forceWalkAnim(zombie, isRunning)
    zombie:setVariable("DTIdleState", "0")
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    zombie:setVariable("WalkType", "1")
    zombie:setVariable("Speed", isRunning and 1.15 or 1.0)
    zombie:setRunning(isRunning == true)
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

local function getTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function moveTowardTarget(zombie, speed, target, stopDistance)
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    local desiredDistance = math.max(0, tonumber(stopDistance) or 0)

    if len <= 0.001 or len <= desiredDistance then
        stopMoveAnim(zombie)
        return true
    end

    dx = dx / len
    dy = dy / len

    local step = math.min(speed, math.max(0, len - desiredDistance))
    if step <= 0.001 then
        stopMoveAnim(zombie)
        return true
    end

    local nextX = zx + (dx * step)
    local nextY = zy + (dy * step)
    local cell = getCell()
    local square = cell and cell:getGridSquare(nextX, nextY, zz) or nil
    local canMove = (not square)
        or (square:isFree(false) and not square:isSolid() and not square:isSolidTrans())

    if canMove then
        forceWalkAnim(zombie, speed > 0.06)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:faceLocation(nextX, nextY)
        return true
    end

    if len <= (desiredDistance + 0.35) then
        stopMoveAnim(zombie)
        return true
    end

    stopMoveAnim(zombie)
    return false
end

local function moveAwayFromTarget(zombie, speed, target, desiredDistance)
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = zx - tx
    local dy = zy - ty
    local len = math.sqrt((dx * dx) + (dy * dy))
    local safeDistance = math.max(0, tonumber(desiredDistance) or 0)

    if len >= safeDistance then
        stopMoveAnim(zombie)
        return true
    end

    if len <= 0.001 then
        dx = ZombRandFloat(-1.0, 1.0)
        dy = ZombRandFloat(-1.0, 1.0)
        len = math.sqrt((dx * dx) + (dy * dy))
        if len <= 0.001 then
            stopMoveAnim(zombie)
            return false
        end
    end

    dx = dx / len
    dy = dy / len

    local step = math.min(speed, math.max(0, safeDistance - len))
    if step <= 0.001 then
        stopMoveAnim(zombie)
        return true
    end

    local nextX = zx + (dx * step)
    local nextY = zy + (dy * step)
    local cell = getCell()
    local square = cell and cell:getGridSquare(nextX, nextY, zz) or nil
    local canMove = (not square)
        or (square:isFree(false) and not square:isSolid() and not square:isSolidTrans())

    if canMove then
        forceWalkAnim(zombie, false)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:faceLocation(tx, ty)
        return true
    end

    stopMoveAnim(zombie)
    return false
end

DTNPCLogic.Behaviors["Attack"] = function(zombie, npcData, target, dist)
    if not npcData then
        runLegacyWakeup(zombie, target, dist)
        return
    end

    if npcData.state ~= "Attack" then
        runLegacyWakeup(zombie, target, dist)
        return
    end

    if not target and zombie and zombie.getTarget then
        local currentTarget = zombie:getTarget()
        if currentTarget and instanceof and instanceof(currentTarget, "IsoPlayer") and not currentTarget:isDead() then
            target = currentTarget
            dist = getTargetDistance(zombie, currentTarget)
        end
    end

    if not target or target:isDead() then
        npcData.attackTimer = 0
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end
        stopMoveAnim(zombie)
        zombie:setTarget(nil)
        return
    end

    local resolvedState = DTNPCProtect and DTNPCProtect.ResolveHostileCombatState
        and DTNPCProtect.ResolveHostileCombatState(npcData, "Attack", dist)
        or "Attack"
    npcData.combatTargetDistance = tonumber(dist) or getTargetDistance(zombie, target)

    if resolvedState ~= "Attack" then
        if resolvedState == "AttackRange" and DTNPCLogic.Behaviors["AttackRange"] then
            npcData.state = "AttackRange"
            DTNPCLogic.Behaviors["AttackRange"](zombie, npcData, target, dist)
            return
        end
        runLegacyWakeup(zombie, target, dist)
        return
    end

    ensureManualControl(zombie)
    zombie:setTarget(target)
    zombie:faceLocation(target:getX(), target:getY())

    local stats = DTNPCProtect.GetMeleeCombatStats(npcData)
    local engageReach = math.max(stats.reach or MELEE_DEFAULT_REACH, 1.45)
    local currentDist = getTargetDistance(zombie, target)
    local recovering, recovery = false, nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "melee", target)
    end

    if recovering then
        npcData.attackTimer = 0
        local retreatDistance = math.max(engageReach + 0.45, recovery and recovery.distance or (engageReach + 0.7))
        if currentDist < retreatDistance then
            moveAwayFromTarget(
                zombie,
                math.max(0.028, (stats.chaseSpeed or MELEE_DEFAULT_SPEED) * 0.75),
                target,
                retreatDistance
            )
        else
            stopMoveAnim(zombie)
            if DTNPC and DTNPC.SetMeleeCombatIdleState then
                DTNPC.SetMeleeCombatIdleState(zombie, npcData)
            end
        end
        return
    end

    if currentDist > engageReach then
        local arrived = moveTowardTarget(
            zombie,
            stats.chaseSpeed or MELEE_DEFAULT_SPEED,
            target,
            math.max(0.9, engageReach - 0.1)
        )
        if not arrived then
            return
        end

        currentDist = getTargetDistance(zombie, target)
        if currentDist > engageReach then
            return
        end
    end

    stopMoveAnim(zombie)
    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.attackRate then
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    end
    DTNPCProtect.ConsumeWeaponCondition(npcData, "melee", 1)

    if ZombRand(100) < stats.hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "melee",
            damage = stats.damage,
        })
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "melee", target)
    end
end
