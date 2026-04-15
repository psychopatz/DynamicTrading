-- ==============================================================================
-- Behavior_Protect.lua
-- Companion protect behaviors for ranged and melee escort combat.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local RANGED_KITE_MIN = 3.25
local RANGED_KITE_MAX = 8.5
local RANGED_MAX_RANGE = 13.5
local RANGED_ADVANCE_SPEED = 0.05
local RANGED_BACKPEDAL_SPEED = 0.03
local MELEE_REACH = 1.25
local MELEE_DEFAULT_SPEED = 0.05
local MELEE_APPROACH_START_BUFFER = 0.18
local MELEE_APPROACH_STOP_BUFFER = 0.16
local MELEE_ATTACK_COMMIT_BUFFER = 0.12
local PROTECT_LEASH = 14
local PROTECT_MASTER_ENGAGE_RADIUS = 10

local function isTileSafe(x, y, z)
    return DTNPCMobility.IsTileSafe(x, y, z)
end

local function faceTarget(zombie, target)
    if zombie and target then
        zombie:faceLocation(target:getX(), target:getY())
    end
end

local function getTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function resetProtectMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.protectMovePrimed = nil
    npcData.protectMoveReason = nil
end

local function stopMoveAnim(zombie, npcData)
    resetProtectMoveState(npcData)
    DTNPCMobility.Stop(zombie)
end

local function forceWalkAnim(zombie, isRunning)
    DTNPCMobility.SetLocomotionState(zombie, {
        moving = true,
        animSpeed = isRunning and 1.15 or 1.0,
        isRunning = isRunning == true,
        walkType = "1",
    })
end

local function primeProtectMovement(zombie, npcData, dirX, dirY, isRunning, reason)
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

    npcData.protectMovePrimed = true
    npcData.protectMoveReason = reason or "move"
    forceWalkAnim(zombie, isRunning == true)
    zombie:faceLocation(zombie:getX() + moveDirX, zombie:getY() + moveDirY)
    return true
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

local function clearProtectCombat(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.ResetGuardedCombatState then
        DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
            resetMoveState = resetProtectMoveState,
            clearAutoProtectState = true,
        })
        return
    end

    if npcData then
        npcData.attackTimer = 0
        npcData.reactionTimer = 0
        npcData.autoProtectActiveState = nil
        resetProtectMoveState(npcData)
        DTNPCProtect.ClearCombatTarget(npcData)
        if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end
    end
    if zombie then
        zombie:setTarget(nil)
    end
end

local function pushCompanionModeNotice(zombie, npcData, dialogueStatus, dialogueState, mode)
    if DTNPCProtect and DTNPCProtect.PushCompanionModeNotice then
        return DTNPCProtect.PushCompanionModeNotice(zombie, npcData, dialogueStatus, dialogueState, mode)
    end

    if not npcData then
        return false
    end
    if mode and npcData.companionAmbientMode == mode then
        return false
    end

    if DTNPCProtect and DTNPCProtect.PushCompanionAmbientCue then
        if DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, dialogueStatus, dialogueState) then
            npcData.companionAmbientMode = mode or npcData.companionAmbientMode
            return true
        end
    end

    return false
end

local function announceCombatEngage(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.AnnounceCompanionCombatEngage then
        DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, "combat")
        if DTNPCProtect and DTNPCProtect.LogProtectDebug then
            DTNPCProtect.LogProtectDebug(npcData, "engage", "target=" .. tostring(npcData and npcData.combatTargetID))
        end
        return
    end

    if not npcData then
        return
    end

    local targetID = npcData.combatTargetID
    if npcData.companionCombatActive == true and npcData.companionLastCombatTargetID == targetID then
        return
    end

    npcData.companionCombatActive = true
    npcData.companionLastCombatTargetID = targetID
    npcData.companionLastRangedTargetID = nil
    pushCompanionModeNotice(zombie, npcData, "Companion", "Attack", "combat")
    if DTNPCProtect and DTNPCProtect.LogProtectDebug then
        DTNPCProtect.LogProtectDebug(npcData, "engage", "target=" .. tostring(targetID))
    end
end

local function announceRangedAttack(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.AnnounceCompanionRangedAttack then
        DTNPCProtect.AnnounceCompanionRangedAttack(zombie, npcData, "ranged")
        return
    end

    if not npcData then
        return
    end

    local targetID = npcData.combatTargetID
    if not targetID or npcData.companionLastRangedTargetID == targetID then
        return
    end

    npcData.companionLastRangedTargetID = targetID
    pushCompanionModeNotice(zombie, npcData, "Companion", "AttackRange", "ranged")
end

local function announceReturnToMaster(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.AnnounceCompanionCombatReturn then
        DTNPCProtect.AnnounceCompanionCombatReturn(zombie, npcData, "return")
        return
    end

    if not npcData or npcData.companionCombatActive ~= true then
        return
    end

    npcData.companionCombatActive = false
    npcData.companionLastCombatTargetID = nil
    npcData.companionLastRangedTargetID = nil
    pushCompanionModeNotice(zombie, npcData, "Companion", "Return", "return")
end

local function followEscort(zombie, npcData, master, dist)
    announceReturnToMaster(zombie, npcData)
    clearProtectCombat(zombie, npcData)
    if DTNPCLogic.Behaviors["Follow"] then
        DTNPCLogic.Behaviors["Follow"](zombie, npcData, master, dist)
    end
end

local function getProtectEngageRadius(npcData)
    return tonumber(npcData and npcData.protectEngageRadius) or PROTECT_MASTER_ENGAGE_RADIUS
end

local function moveTowardTarget(zombie, npcData, speed, target, stopDistance)
    local moved, state = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = speed,
        stopDistance = stopDistance,
        blockCounterKey = "protectBlockedTicks",
        stuckTicks = 10,
        anim = {
            animSpeed = speed > 0.06 and 1.15 or 1.0,
            isRunning = speed > 0.06,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") and npcData then
        npcData.isMovingState = true
    elseif npcData then
        resetProtectMoveState(npcData)
    end

    return moved or state == "arrived" or state == "close_enough", state
end

local function moveAwayFromTarget(zombie, npcData, speed, sourceX, sourceY, desiredDistance, faceTarget)
    local moved, state = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
        fromX = sourceX,
        fromY = sourceY,
        speed = speed,
        desiredDistance = desiredDistance,
        blockCounterKey = "protectBlockedTicks",
        stuckTicks = 8,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") and npcData then
        npcData.isMovingState = true
    elseif npcData then
        resetProtectMoveState(npcData)
    end

    return moved or state == "spaced", state
end

local function preserveAttackWindup(npcData, stats)
    if not npcData then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    local cap = attackRate > 0 and math.floor(attackRate * 0.5) or 0
    npcData.attackTimer = math.min(tonumber(npcData.attackTimer) or 0, cap)
end

local function getTargetKey(target)
    if not target then
        return nil
    end
    local id = target.getID and target:getID() or nil
    if id then
        return "id:" .. tostring(id)
    end
    return tostring(target)
end

local function primeContactSwing(npcData, target, stats)
    if not npcData then
        return
    end

    local targetKey = getTargetKey(target)
    if npcData.meleeContactTargetKey == targetKey and npcData.meleeContactPrimed == true then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    npcData.attackTimer = math.max(tonumber(npcData.attackTimer) or 0, math.max(0, attackRate - 6))
    npcData.meleeContactTargetKey = targetKey
    npcData.meleeContactPrimed = true
end

local function shouldStandAndFight(dangerState, currentDist, attackRange)
    if not dangerState or dangerState.shouldDisengage ~= true then
        return false
    end
    if (tonumber(currentDist) or 9999) > (tonumber(attackRange) or 0) then
        return false
    end
    if dangerState.reason == "low_health" then
        return false
    end

    local selfPressure = dangerState.selfPressure or {}
    local severeThreshold = tonumber(DTNPCProtect.CONFIG.MeleeCrowdSevereThreshold) or 4
    local lowHealthRatio = tonumber(DTNPCProtect.CONFIG.MeleeLowHealthRetreatRatio) or 0.58
    if dangerState.reason == "pressured" and (tonumber(dangerState.healthRatio) or 1) <= (lowHealthRatio + 0.08) then
        return false
    end

    return (tonumber(selfPressure.count) or 0) < severeThreshold
end

local function syncProtectStateChange(zombie, npcData)
    if DTNPCServerCore and DTNPCServerCore.SyncToAllClients then
        local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
        if ownedZombie == zombie then
            DTNPCServerCore.SyncToAllClients(zombie, npcData)
            if DTNPCServerCore.BroadcastPosition then
                DTNPCServerCore.BroadcastPosition(zombie, npcData)
            end
        end
    end
end

local function protectTargetOrEscort(zombie, npcData, master, distToMaster, requestedState)
    local effectiveState = DTNPCProtect.ResolveProtectState(npcData, requestedState)

    if effectiveState == "ProtectRanged" and requestedState ~= "ProtectRanged" then
        npcData.state = "ProtectRanged"
        syncProtectStateChange(zombie, npcData)
        DTNPCLogic.Behaviors["ProtectRanged"](zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    if effectiveState == "ProtectMelee" and requestedState ~= "ProtectMelee" then
        npcData.state = "ProtectMelee"
        syncProtectStateChange(zombie, npcData)
        DTNPCLogic.Behaviors["ProtectMelee"](zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    if not effectiveState or not master or distToMaster > PROTECT_LEASH then
        if requestedState and distToMaster and distToMaster > PROTECT_LEASH and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectLeash",
                "Too far from you. Regrouping.",
                "warning",
                "distToMaster=" .. tostring(string.format("%.2f", tonumber(distToMaster) or 0))
            )
        elseif requestedState and not effectiveState and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            local text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, effectiveState)
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectNoLoadout:" .. tostring(requestedState),
                text or "No combat loadout ready.",
                sentiment or "warning",
                "requested=" .. tostring(requestedState)
            )
        end
        followEscort(zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    local target, targetDist = DTNPCProtect.SelectNearestZombie(
        zombie,
        npcData,
        nil,
        master,
        getProtectEngageRadius(npcData)
    )
    if not target then
        if requestedState and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectNoTarget:" .. tostring(requestedState),
                "No threat in protect range.",
                "neutral",
                "requested=" .. tostring(requestedState) .. " engageRadius=" .. tostring(getProtectEngageRadius(npcData))
            )
        end
        followEscort(zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    announceCombatEngage(zombie, npcData)
    ensureManualControl(zombie)
    return target, targetDist, false
end

local function executeProtectRanged(zombie, npcData, target, targetDist)
    if DTNPCProtect and DTNPCProtect.ExecuteGuardedRangedCombat then
        DTNPCProtect.ExecuteGuardedRangedCombat(zombie, npcData, target, targetDist, {
            mode = "protect",
            issuePrefix = "ProtectRanged",
            unavailableText = "Can't fire. No usable firearm.",
            onStartMove = function(runZombie)
                forceWalkAnim(runZombie, false)
            end,
            onStopMove = function(stopZombie, stopNpcData)
                stopMoveAnim(stopZombie, stopNpcData)
            end,
            onCombatIdle = function(idleZombie, idleNpcData)
                if DTNPC and DTNPC.SetRangedCombatIdleState then
                    DTNPC.SetRangedCombatIdleState(idleZombie, idleNpcData)
                end
            end,
            onRangedAttack = function(attackZombie, attackNpcData)
                announceRangedAttack(attackZombie, attackNpcData)
            end,
        })
        return
    end

    if DTNPCProtect and not DTNPCProtect.HasUsableRangedLoadout(npcData) then
        if DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectRangedUnavailable",
                "Can't fire. No usable firearm.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", tonumber(targetDist) or 0))
            )
        end
        return
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    if len > 0.001 then
        dx = dx / len
        dy = dy / len
    end

    local recovering, recovery = false, nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "ranged", target)
    end

    local desiredMin = recovering and math.max(RANGED_KITE_MIN, recovery and recovery.distance or RANGED_KITE_MIN) or RANGED_KITE_MIN
    local desiredMax = recovering and math.max(RANGED_KITE_MAX, desiredMin + 0.75) or RANGED_KITE_MAX

    local moveDir = 0
    local moveSpeed = 0
    if len < desiredMin then
        npcData.reactionTimer = (npcData.reactionTimer or 0) + 1
        if npcData.reactionTimer >= 18 then
            moveDir = -1
            moveSpeed = RANGED_BACKPEDAL_SPEED
        end
    elseif len > desiredMax then
        npcData.reactionTimer = 0
        moveDir = 1
        moveSpeed = RANGED_ADVANCE_SPEED
    else
        npcData.reactionTimer = 0
    end

    local moved = false
    if moveDir ~= 0 then
        zombie:setVariable("DTIdleState", "0")
        local nextX = zx + (dx * moveSpeed * moveDir)
        local nextY = zy + (dy * moveSpeed * moveDir)
        if isTileSafe(nextX, nextY, zz) then
            forceWalkAnim(zombie, false)
            zombie:setX(nextX)
            zombie:setY(nextY)
            zombie:faceLocation(nextX + (dx * moveDir), nextY + (dy * moveDir))
            moved = true
        else
            stopMoveAnim(zombie, npcData)
        end
    else
        stopMoveAnim(zombie, npcData)
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    if not moved then
        faceTarget(zombie, target)
    end

    if targetDist > RANGED_MAX_RANGE then
        return
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    if recovering then
        npcData.attackTimer = 0
        return
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.fireRate then
        return
    end

    npcData.attackTimer = 0
    announceRangedAttack(zombie, npcData)
    if DTNPC and DTNPC.TriggerRangedCombatAnim then
        DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    end
    DTNPCProtect.ConsumeAmmo(npcData, 1)
    DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
    zombie:getEmitter():playSound("DT_GunRandom")

    local hitChance = moved and stats.hitMove or stats.hitStill
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

local function executeProtectMelee(zombie, npcData, target, targetDist)
    if DTNPCProtect and DTNPCProtect.ExecuteGuardedMeleeCombat then
        DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, {
            mode = "protect",
            issuePrefix = "ProtectMelee",
            unavailableText = "Can't swing. No usable melee weapon.",
            blockedText = "Can't reach that zombie.",
            blockCounterKey = "protectBlockedTicks",
            fallbackReach = MELEE_REACH,
            defaultSpeed = MELEE_DEFAULT_SPEED,
            enterBuffer = 0.25,
            holdBuffer = 0.45,
            stopBuffer = MELEE_APPROACH_STOP_BUFFER,
            debugLabel = "ProtectMeleeSwing",
        })
        return
    end

    if DTNPCProtect and not DTNPCProtect.HasUsableMeleeLoadout(npcData) then
        if DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectMeleeUnavailable",
                "Can't swing. No usable melee weapon.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", tonumber(targetDist) or 0))
            )
        end
        return
    end

    local result = DTNPCProtect.ExecuteMeleeCombat and DTNPCProtect.ExecuteMeleeCombat(zombie, npcData, target, {
        mode = "protect",
        blockCounterKey = "protectBlockedTicks",
        fallbackReach = MELEE_REACH,
        defaultSpeed = MELEE_DEFAULT_SPEED,
        enterBuffer = 0.25,
        holdBuffer = 0.45,
        stopBuffer = MELEE_APPROACH_STOP_BUFFER,
    }) or nil

    if result and result.status == "blocked" and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
        DTNPCProtect.ReportCombatIssue(
            zombie,
            npcData,
            "ProtectMeleeBlocked",
            "Can't reach that zombie.",
            "warning",
            "currentDist=" .. tostring(string.format("%.2f", tonumber(result.distance) or tonumber(targetDist) or 0))
        )
    end

    if result and result.attacked and DTNPCProtect and DTNPCProtect.LogProtectDebug and isDebugEnabled and isDebugEnabled() then
        DTNPCProtect.LogProtectDebug(
            npcData,
            "ProtectMeleeSwing",
            "dist=" .. tostring(string.format("%.2f", tonumber(result.distance) or 0))
        )
    end
end

DTNPCLogic.Behaviors["ProtectRanged"] = function(zombie, npcData, master, distToMaster)
    local target, targetDist, handled = protectTargetOrEscort(zombie, npcData, master, distToMaster, "ProtectRanged")
    if handled then
        return
    end
    executeProtectRanged(zombie, npcData, target, targetDist)
end

DTNPCLogic.Behaviors["ProtectMelee"] = function(zombie, npcData, master, distToMaster)
    local target, targetDist, handled = protectTargetOrEscort(zombie, npcData, master, distToMaster, "ProtectMelee")
    if handled then
        return
    end
    executeProtectMelee(zombie, npcData, target, targetDist)
end

DTNPCLogic.Behaviors["ProtectAuto"] = function(zombie, npcData, master, distToMaster)
    if not master or distToMaster > PROTECT_LEASH then
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    local target, targetDist = DTNPCProtect.SelectNearestZombie(
        zombie,
        npcData,
        nil,
        master,
        getProtectEngageRadius(npcData)
    )
    if not target then
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    local resolvedState = DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    npcData.autoProtectActiveState = resolvedState

    if not resolvedState then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            local text, sentiment = DTNPCProtect.BuildFallbackNotice("ProtectAuto", nil)
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectNoLoadout:ProtectAuto",
                text or "No combat loadout ready.",
                sentiment or "warning",
                "requested=ProtectAuto"
            )
        end
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    announceCombatEngage(zombie, npcData)
    ensureManualControl(zombie)

    if resolvedState == "ProtectRanged" then
        executeProtectRanged(zombie, npcData, target, targetDist)
        return
    end
    if resolvedState == "ProtectMelee" then
        executeProtectMelee(zombie, npcData, target, targetDist)
        return
    end

    followEscort(zombie, npcData, master, distToMaster)
end
