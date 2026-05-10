-- ==============================================================================
-- DTNPC_ProtectGuardedCombat_logic.lua
-- Shared combat helpers for guard-like anchored combat behavior.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local RANGED_KITE_MIN = 3.25
local RANGED_KITE_MAX = 8.5
local RANGED_MAX_RANGE = 13.5
local RANGED_ADVANCE_SPEED = 0.05
local RANGED_BACKPEDAL_SPEED = 0.03

local function isTileSafe(x, y, z)
    if DTNPCMobility and DTNPCMobility.IsTileSafe then
        return DTNPCMobility.IsTileSafe(x, y, z)
    end
    return true
end

local function faceTarget(zombie, target)
    if zombie and target then
        zombie:faceLocation(target:getX(), target:getY())
    end
end

local function stopMoveAnim(zombie, npcData)
    if npcData then
        npcData.isMovingState = false
    end
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end
end

local function forceWalkAnim(zombie, isRunning)
    if DTNPCMobility and DTNPCMobility.SetLocomotionState then
        DTNPCMobility.SetLocomotionState(zombie, {
            moving = true,
            animSpeed = isRunning and 1.15 or 1.0,
            isRunning = isRunning == true,
            walkType = "1",
        })
    end
end

function DTNPCProtect.EnsureManualCombatControl(zombie)
    if not zombie then
        return
    end
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

function DTNPCProtect.ResetGuardedCombatState(zombie, npcData, options)
    options = type(options) == "table" and options or {}

    if npcData then
        npcData.attackTimer = 0
        npcData.reactionTimer = 0
        npcData.guardReturningToPost = nil
        if options.clearAutoProtectState ~= false then
            npcData.autoProtectActiveState = nil
        end

        if options.resetMoveState then
            options.resetMoveState(npcData)
        else
            npcData.isMovingState = false
        end

        if DTNPCProtect and DTNPCProtect.ClearCombatTarget then
            DTNPCProtect.ClearCombatTarget(npcData)
        end
        if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end

        if options.clearCompanion == true then
            npcData.companionCombatActive = false
            npcData.companionLastCombatTargetID = nil
            npcData.companionLastRangedTargetID = nil
        end
    end

    if zombie then
        zombie:setTarget(nil)
    end
end

function DTNPCProtect.PushCompanionModeNotice(zombie, npcData, dialogueStatus, dialogueState, mode)
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

function DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, mode)
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
    DTNPCProtect.PushCompanionModeNotice(zombie, npcData, "Companion", "Attack", mode or "combat")
end

function DTNPCProtect.AnnounceCompanionRangedAttack(zombie, npcData, mode)
    if not npcData then
        return
    end

    local targetID = npcData.combatTargetID
    if not targetID or npcData.companionLastRangedTargetID == targetID then
        return
    end

    npcData.companionLastRangedTargetID = targetID
    DTNPCProtect.PushCompanionModeNotice(zombie, npcData, "Companion", "AttackRange", mode or "ranged")
end

function DTNPCProtect.AnnounceCompanionCombatReturn(zombie, npcData, mode)
    if not npcData or npcData.companionCombatActive ~= true then
        return
    end

    npcData.companionCombatActive = false
    npcData.companionLastCombatTargetID = nil
    npcData.companionLastRangedTargetID = nil
    DTNPCProtect.PushCompanionModeNotice(zombie, npcData, "Companion", "Return", mode or "return")
end

function DTNPCProtect.ExecuteGuardedRangedCombat(zombie, npcData, target, targetDist, options)
    options = type(options) == "table" and options or {}
    local issuePrefix = tostring(options.issuePrefix or "GuardRanged")

    if DTNPCProtect.IsCombatCapable then
        local capable, reason = DTNPCProtect.IsCombatCapable(zombie, npcData)
        if not capable then
            if DTNPCProtect.StopCombatActions then
                DTNPCProtect.StopCombatActions(zombie, npcData, reason)
            end
            return {
                status = "not_capable",
                moved = false,
                attacked = false,
                reason = reason,
            }
        end
    end

    if DTNPCProtect and not DTNPCProtect.HasUsableRangedLoadout(npcData) then
        local issue = DTNPCProtect.GetRangedLoadoutIssue and DTNPCProtect.GetRangedLoadoutIssue(npcData) or "unavailable"
        local ammoIssue = issue == "no_ammo"
            or issue == "no_ammo_type"
            or issue == "ammo_mismatch"

        if ammoIssue and DTNPCProtect.PushCompanionAmbientCue then
            DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, "Companion", "NoAmmo")
        end
        if DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                issuePrefix .. "Unavailable:" .. tostring(issue),
                ammoIssue and nil or (options.unavailableText or "Can't fire. No usable firearm."),
                "warning",
                "issue=" .. tostring(issue) .. " targetDist=" .. tostring(string.format("%.2f", tonumber(targetDist) or 0))
            )
        end
        return {
            status = "unavailable",
            moved = false,
            attacked = false,
        }
    end

    if DTNPCProtect and DTNPCProtect.UpdateRangedReloadAction then
        local busy, busyReason = DTNPCProtect.UpdateRangedReloadAction(zombie, npcData, target)
        if busy then
            stopMoveAnim(zombie, npcData)
            if DTNPC and DTNPC.SetRangedCombatIdleState then
                DTNPC.SetRangedCombatIdleState(zombie, npcData)
            end
            return {
                status = "reloading",
                moved = false,
                attacked = false,
                reason = busyReason,
            }
        end
    end

    if DTNPCMobility and DTNPCMobility.IsSpecialActionActive then
        local specialActive = DTNPCMobility.IsSpecialActionActive(npcData)
        if specialActive and npcData._dtSpecialAction == "fence" then
            if DTNPCMobility.UpdateSpecialAction then
                DTNPCMobility.UpdateSpecialAction(zombie, npcData)
            end
            faceTarget(zombie, target)
            return {
                status = "special_action",
                moved = false,
                attacked = false,
                reason = "fence",
            }
        end
    end

    local kiteMin = tonumber(options.kiteMin) or RANGED_KITE_MIN
    local kiteMax = tonumber(options.kiteMax) or RANGED_KITE_MAX
    local maxRange = tonumber(options.maxRange) or RANGED_MAX_RANGE
    local advanceSpeed = tonumber(options.advanceSpeed) or RANGED_ADVANCE_SPEED
    local backpedalSpeed = tonumber(options.backpedalSpeed) or RANGED_BACKPEDAL_SPEED

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

    local desiredMin = recovering and math.max(kiteMin, recovery and recovery.distance or kiteMin) or kiteMin
    local desiredMax = recovering and math.max(kiteMax, desiredMin + 0.75) or kiteMax

    local moveDir = 0
    local moveSpeed = 0
    if len < desiredMin then
        npcData.reactionTimer = (npcData.reactionTimer or 0) + 1
        if npcData.reactionTimer >= 18 then
            moveDir = -1
            moveSpeed = backpedalSpeed
        end
    elseif len > desiredMax then
        npcData.reactionTimer = 0
        moveDir = 1
        moveSpeed = advanceSpeed
    else
        npcData.reactionTimer = 0
    end

    local moved = false
    if moveDir ~= 0 then
        zombie:setVariable("DTIdleState", "0")
        local moveState = nil
        if moveDir > 0 and DTNPCMobility and DTNPCMobility.MoveTowardTarget then
            moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
                target = target,
                speed = moveSpeed,
                staminaMode = "pursuit",
                desiredRun = false,
                stopDistance = desiredMin + 0.1,
                allowObstacleInteract = true,
                allowDamageRetreat = true,
                blockCounterKey = options.blockCounterKey or "guardBlockedTicks",
                stuckTicks = 10,
                anchorX = options.anchorX,
                anchorY = options.anchorY,
                anchorZ = options.anchorZ,
                leashRadius = options.leashRadius,
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
        elseif DTNPCMobility and DTNPCMobility.MoveAwayFromPoint then
            moved, moveState = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
                fromX = tx,
                fromY = ty,
                speed = moveSpeed,
                staminaMode = "retreat",
                desiredDistance = desiredMin + 0.75,
                allowObstacleInteract = true,
                allowDamageRetreat = true,
                blockCounterKey = options.blockCounterKey or "guardBlockedTicks",
                stuckTicks = 8,
                anchorX = options.anchorX,
                anchorY = options.anchorY,
                anchorZ = options.anchorZ,
                leashRadius = options.leashRadius,
                faceX = tx,
                faceY = ty,
                faceTargetWhileMoving = true,
                closeDoorTarget = target,
                closeDoorSafeRadius = 3.0,
                anim = {
                    animSpeed = 1.0,
                    isRunning = false,
                    dtWalkType = "Walk",
                },
            })
        end

        moved = moved == true or moveState == "damage_retreat"
        if moveState == "exhausted" then
            moved = false
            if options.onStopMove then
                options.onStopMove(zombie, npcData)
            else
                stopMoveAnim(zombie, npcData)
            end
        elseif moveState == "special_action" or moveState == "interacted_fence" then
            moved = false
        elseif moved then
            if options.onStartMove then
                options.onStartMove(zombie, npcData, false)
            end
        elseif not (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
            if options.onStopMove then
                options.onStopMove(zombie, npcData)
            else
                stopMoveAnim(zombie, npcData)
            end
        end
    else
        if options.onStopMove then
            options.onStopMove(zombie, npcData)
        else
            stopMoveAnim(zombie, npcData)
        end
        if options.onCombatIdle then
            options.onCombatIdle(zombie, npcData)
        elseif DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    if not moved then
        faceTarget(zombie, target)
    end

    if targetDist > maxRange then
        return {
            status = "out_of_range",
            moved = moved,
            attacked = false,
        }
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    if recovering then
        npcData.attackTimer = 0
        return {
            status = "recovering",
            moved = moved,
            attacked = false,
        }
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.fireRate then
        return {
            status = "charging",
            moved = moved,
            attacked = false,
        }
    end

    npcData.attackTimer = 0
    if options.onRangedAttack then
        options.onRangedAttack(zombie, npcData, target)
    end
    if DTNPC and DTNPC.TriggerRangedCombatAnim then
        DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    end

    if DTNPCProtect and DTNPCProtect.ConsumeRangedShot then
        DTNPCProtect.ConsumeRangedShot(npcData, 1)
    else
        DTNPCProtect.ConsumeAmmo(npcData, 1)
    end
    DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
    zombie:getEmitter():playSound("DT_GunRandom")

    local hitChance = moved and stats.hitMove or stats.hitStill
    local hit = false
    if ZombRand(100) < hitChance then
        hit = DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "ranged",
            damage = stats.damage,
        }) == true
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "ranged", target)
    end

    return {
        status = "attack",
        moved = moved,
        attacked = true,
        hit = hit,
    }
end

function DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, options)
    options = type(options) == "table" and options or {}
    local issuePrefix = tostring(options.issuePrefix or "GuardMelee")

    if DTNPCProtect and not DTNPCProtect.HasUsableMeleeLoadout(npcData) then
        if DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                issuePrefix .. "Unavailable",
                options.unavailableText or "Can't swing. No usable melee weapon.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", tonumber(targetDist) or 0))
            )
        end
        return {
            status = "unavailable",
            moved = false,
            attacked = false,
        }
    end

    local result = DTNPCProtect.ExecuteMeleeCombat and DTNPCProtect.ExecuteMeleeCombat(zombie, npcData, target, {
        mode = tostring(options.mode or "guard"),
        blockCounterKey = options.blockCounterKey or "guardBlockedTicks",
        fallbackReach = tonumber(options.fallbackReach) or 1.25,
        defaultSpeed = tonumber(options.defaultSpeed) or 0.05,
        enterBuffer = tonumber(options.enterBuffer) or 0.25,
        holdBuffer = tonumber(options.holdBuffer) or 0.45,
        stopBuffer = tonumber(options.stopBuffer) or 0.16,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
    }) or nil

    if result and result.status == "blocked" and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
        DTNPCProtect.ReportCombatIssue(
            zombie,
            npcData,
            issuePrefix .. "Blocked",
            options.blockedText or "Can't reach that target.",
            "warning",
            "currentDist=" .. tostring(string.format("%.2f", tonumber(result.distance) or tonumber(targetDist) or 0))
        )
    end

    if result and result.attacked and options.debugLabel and DTNPCProtect and DTNPCProtect.LogProtectDebug and isDebugEnabled and isDebugEnabled() then
        DTNPCProtect.LogProtectDebug(
            npcData,
            tostring(options.debugLabel),
            "dist=" .. tostring(string.format("%.2f", tonumber(result.distance) or 0))
        )
    end

    return result or {
        status = "no_result",
        moved = false,
        attacked = false,
    }
end
