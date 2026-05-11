-- ==============================================================================
-- Behavior_AttackRange.lua
-- Hostile ranged combat using the shared dynamic loadout/combat helpers.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "Misc/DT_LightSystem"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack"

-- DISTANCE CONFIG
local KITE_DIST_MIN = 3.5
local KITE_DIST_MAX = 8.0
local MAX_RANGE = 14.0

-- SPEED CONFIG
local SPEED_FWD = 0.055
local SPEED_BCK = 0.035
local SPEED_RETREAT_RUN = 0.07
local REACTION_DELAY = 30

local function performRangedShot(zombie, npcData, target, stats, shotSpecs)
    if not zombie or not npcData or not target then return end
    
    if DTNPC and DTNPC.TriggerRangedCombatAnim then
        DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    end

    if DTNPCProtect and DTNPCProtect.ConsumeRangedShot then
        DTNPCProtect.ConsumeRangedShot(npcData, 1)
    elseif DTNPCProtect and DTNPCProtect.ConsumeAmmo then
        DTNPCProtect.ConsumeAmmo(npcData, 1)
    end
    
    if DTNPCProtect and DTNPCProtect.ConsumeWeaponCondition then
        DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
    end
    
    local emitter = zombie:getEmitter()
    if shotSpecs.shotSound then
        emitter:playSound(shotSpecs.shotSound)
    end
    if shotSpecs.shellSound then
        emitter:playSound(shotSpecs.shellSound)
    end

    if DT_LightSystem and DT_LightSystem.MuzzleFlash then
        DT_LightSystem.MuzzleFlash(zombie)
    end

    local isMoving = zombie:isMoving()
    local hitChance = isMoving and stats.hitMove or stats.hitStill
    if ZombRand(100) < hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "ranged",
            damage = stats.damage,
        })
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "ranged", target)
    end
end

local function isPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end

-- ==============================================================================
-- 1. UTILITIES
-- ==============================================================================

local function stopMoveAnim(zombie)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
        return
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

-- ==============================================================================
-- 2. ANIMATION HANDLERS
-- ==============================================================================

local function forceCombatAnim(zombie, isMoving)
    if DTNPCMobility and DTNPCMobility.SetLocomotionState then
        DTNPCMobility.SetLocomotionState(zombie, {
            moving = isMoving == true,
            isRunning = false,
            dtWalkType = "Walk",
            animSpeed = isMoving and 1.0 or 0.0,
        })
        return
    end

    if isMoving then
        zombie:setVariable("bMoving", true)
        zombie:setVariable("isMoving", true)
        
        -- Force standard shamble "1". 
        -- Note: If moving backwards, this will look like a "Moonwalk" because 
        -- zombies lack a backward-walk anim, but it keeps the legs moving.
        zombie:setVariable("WalkType", "1") 
        
        -- Force speed to ensure legs cycle
        zombie:setVariable("Speed", 1.0)
        zombie:setRunning(false)
    else
        -- Aiming Stance (Idle)
        zombie:setVariable("bMoving", false)
        zombie:setVariable("isMoving", false)
        zombie:setVariable("Speed", 0.0)
        zombie:setRunning(false)
    end
end

-- ==============================================================================
-- 3. BEHAVIOR LOGIC
-- ==============================================================================

DTNPCLogic.Behaviors["AttackRange"] = function(zombie, npcData, target, dist)
    if not npcData or npcData.state ~= "AttackRange" then
        return
    end

    if not target and zombie and zombie.getTarget then
        local currentTarget = zombie:getTarget()
        if currentTarget and instanceof and instanceof(currentTarget, "IsoPlayer") and not currentTarget:isDead() then
            zombie:setTarget(nil)
        end
    end

    if not target or target:isDead() then
        if DTNPCLogic.BehaviorAttack and DTNPCLogic.BehaviorAttack.HandleMissingHostileTarget then
            local replacementTarget, replacementDist, handled = DTNPCLogic.BehaviorAttack.HandleMissingHostileTarget(zombie, npcData)
            if handled then
                return
            end
            if replacementTarget then
                target = replacementTarget
                dist = replacementDist
            end
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

    if DTNPCLogic.BehaviorAttack and DTNPCLogic.BehaviorAttack.ClearHostileNoTargetState then
        DTNPCLogic.BehaviorAttack.ClearHostileNoTargetState(npcData)
    end

    if DTNPCLogic.HandleHostileLostSight
        and DTNPCLogic.HandleHostileLostSight(zombie, npcData, target, dist, { speed = SPEED_FWD }) then
        return
    end
    if DTNPCLogic.HandleHostileChaseGiveUp
        and DTNPCLogic.HandleHostileChaseGiveUp(zombie, npcData, target, dist) then
        return
    end

    if DTNPCProtect and DTNPCProtect.IsCombatCapable then
        local capable, reason = DTNPCProtect.IsCombatCapable(zombie, npcData)
        if not capable then
            if DTNPCProtect.StopCombatActions then
                DTNPCProtect.StopCombatActions(zombie, npcData, reason)
            end
            return
        end
    end

    local resolvedState = DTNPCProtect and DTNPCProtect.ResolveHostileCombatState
        and DTNPCProtect.ResolveHostileCombatState(npcData, "AttackRange", dist)
        or "Attack"
    npcData.combatTargetDistance = tonumber(dist)

    if resolvedState ~= "AttackRange" then
        if DTNPCLogic.Behaviors["Attack"] then
            npcData.state = "Attack"
            DTNPCLogic.Behaviors["Attack"](zombie, npcData, target, dist)
        end
        return
    end

    ensureManualControl(zombie)
    if isPlayerTarget(target) then
        zombie:setTarget(nil)
    else
        zombie:setTarget(target)
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()

    if DTNPCProtect and DTNPCProtect.UpdateRangedReloadAction then
        local busy, busyReason = DTNPCProtect.UpdateRangedReloadAction(zombie, npcData, target)
        if busy then
            stopMoveAnim(zombie)
            if DTNPC and DTNPC.SetRangedCombatIdleState then
                DTNPC.SetRangedCombatIdleState(zombie, npcData)
            end
            return
        end
        if busyReason == "reloaded" and DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    if DTNPCMobility and DTNPCMobility.IsSpecialActionActive then
        local specialActive, mode = DTNPCMobility.IsSpecialActionActive(npcData)
        if specialActive and npcData._dtSpecialAction == "fence" then
            if DTNPCMobility.UpdateSpecialAction then
                DTNPCMobility.UpdateSpecialAction(zombie, npcData)
            end
            zombie:faceLocation(tx, ty)
            return
        end
    end
    
    -- 2. Calculate Direction to Target
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt(dx * dx + dy * dy)
    
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    if not npcData.reactionTimer then npcData.reactionTimer = 0 end

    local recovering, recovery = false, nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "ranged", target)
    end
    local desiredMin = recovering and math.max(KITE_DIST_MIN, recovery and recovery.distance or KITE_DIST_MIN) or KITE_DIST_MIN
    local desiredMax = recovering and math.max(KITE_DIST_MAX, desiredMin + 0.75) or KITE_DIST_MAX
    local dangerState = DTNPCProtect and DTNPCProtect.GetMeleeDangerState
        and DTNPCProtect.GetMeleeDangerState(zombie, npcData, target, {
            engageReach = desiredMin,
            retreatDistance = math.max(desiredMax + 1.25, desiredMin + 1.65),
            pressureRadius = 2.8,
            targetPressureRadius = 2.1,
        })
        or nil

    if dangerState and dangerState.shouldDisengage == true then
        desiredMin = math.max(desiredMin, tonumber(dangerState.retreatDistance) or (desiredMin + 1.65))
        desiredMax = math.max(desiredMax, desiredMin + 1.0)
    end

    local moveDir = 0
    local currentSpeed = 0
    local retreatFromX = tx
    local retreatFromY = ty
    local retreatRun = false

    if dangerState and dangerState.shouldDisengage == true then
        retreatFromX = tonumber(dangerState.fleeFromX) or tx
        retreatFromY = tonumber(dangerState.fleeFromY) or ty
        retreatRun = dangerState.selfPressure
            and (tonumber(dangerState.selfPressure.count) or 0) >= 3
            or dangerState.recentZombieDamage == true
            or dangerState.recentHostileDamage == true
        npcData.reactionTimer = REACTION_DELAY + 1
        moveDir = -1
        currentSpeed = retreatRun and SPEED_RETREAT_RUN or math.max(SPEED_BCK, SPEED_FWD)
    elseif len < desiredMin then
        npcData.reactionTimer = npcData.reactionTimer + 1
        if npcData.reactionTimer > REACTION_DELAY then
            moveDir = -1
            currentSpeed = SPEED_BCK
        else
            moveDir = 0
        end
        
    elseif len > desiredMax then
        npcData.reactionTimer = 0
        moveDir = 1
        currentSpeed = SPEED_FWD
    else
        npcData.reactionTimer = 0
        moveDir = 0
    end

    local isMoving = false
    if moveDir ~= 0 then
        if DTNPCLogic.BehaviorAttack and DTNPCLogic.BehaviorAttack.PrimeMovement then
            local primeDir = moveDir > 0 and 1 or -1
            if not DTNPCLogic.BehaviorAttack.PrimeMovement(
                zombie,
                npcData,
                dx * primeDir,
                dy * primeDir,
                false,
                moveDir > 0 and "hostile-ranged-advance" or "hostile-ranged-retreat"
            ) then
                return
            end
        end

        zombie:setVariable("DTIdleState", "0")
        local moved, moveState
        if moveDir > 0 then
            moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
                target = target,
                speed = currentSpeed,
                staminaMode = "pursuit",
                desiredRun = false,
                stopDistance = desiredMin + 0.1,
                allowObstacleInteract = true,
                allowDamageRetreat = true,
                blockCounterKey = "attackRangeBlockedTicks",
                stuckTicks = 12,
                faceX = tx,
                faceY = ty,
                closeDoorTarget = target,
                closeDoorSafeRadius = 3.0,
                anim = {
                    animSpeed = 1.0,
                    isRunning = false,
                    dtWalkType = "Walk",
                },
            })
        else
            moved, moveState = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
                fromX = retreatFromX,
                fromY = retreatFromY,
                speed = currentSpeed,
                staminaMode = "retreat",
                desiredRun = retreatRun == true,
                desiredDistance = dangerState and dangerState.shouldDisengage == true
                    and math.max(desiredMin + 0.75, tonumber(dangerState.retreatDistance) or (desiredMin + 1.5))
                    or (desiredMin + 0.75),
                allowObstacleInteract = true,
                allowDamageRetreat = true,
                blockCounterKey = "attackRangeBlockedTicks",
                stuckTicks = 12,
                faceX = tx,
                faceY = ty,
                faceTargetWhileMoving = true,
                closeDoorTarget = target,
                closeDoorSafeRadius = 3.0,
                anim = {
                    animSpeed = retreatRun and 1.15 or 1.0,
                    isRunning = retreatRun == true,
                    dtWalkType = retreatRun and "Run" or "Walk",
                },
            })
        end

        isMoving = moved == true or moveState == "damage_retreat"
        if moveState == "exhausted" then
            isMoving = false
            forceCombatAnim(zombie, false)
        elseif moveState == "special_action" or moveState == "interacted_fence" then
            isMoving = false
        elseif isMoving then
            forceCombatAnim(zombie, true)
        elseif not (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
            forceCombatAnim(zombie, false)
        end
    else
        if DTNPCLogic.BehaviorAttack then
            npcData.attackMovePrimed = nil
            npcData.attackMoveReason = nil
        end
        forceCombatAnim(zombie, false)
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    if not isMoving and len > 0.001 then
        zombie:faceLocation(tx, ty)
    end

    if len > MAX_RANGE then
        return 
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    if isPlayerTarget(target) then
        stats.fireRate = math.max(72, tonumber(stats.fireRate) or 72)
        stats.hitStill = math.min(tonumber(stats.hitStill) or 0, 58)
        stats.hitMove = math.min(tonumber(stats.hitMove) or 0, 28)
    end
    if recovering then
        npcData.attackTimer = 0
        return
    end

    -- Burst Logic
    if npcData.burstRemaining and npcData.burstRemaining > 0 then
        npcData.burstTimer = (npcData.burstTimer or 0) + 1
        local shotSpecs = npcData.shotSpecs
        if shotSpecs and npcData.burstTimer >= (shotSpecs.recoilDelay or 10) then
            npcData.burstTimer = 0
            npcData.burstRemaining = npcData.burstRemaining - 1
            performRangedShot(zombie, npcData, target, stats, shotSpecs)
        end
        return
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer >= stats.fireRate then
        npcData.attackTimer = 0

        local shotSpecs = DTNPCProtect.GetRangedShotSpecs(npcData)
        performRangedShot(zombie, npcData, target, stats, shotSpecs)

        if shotSpecs.isAuto and ZombRand(100) < 60 then
            npcData.burstRemaining = ZombRand(2, 5)
            npcData.burstTimer = 0
            npcData.shotSpecs = shotSpecs
        end
    end
end
