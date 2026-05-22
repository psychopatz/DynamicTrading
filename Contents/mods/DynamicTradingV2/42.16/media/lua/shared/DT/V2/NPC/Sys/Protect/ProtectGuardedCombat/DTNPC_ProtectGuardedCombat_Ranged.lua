-- ==============================================================================
-- DTNPC_ProtectGuardedCombat_Ranged.lua
-- Guarded ranged combat execution for DTNPC protect behavior.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local performRangedShot = Internal.PerformGuardedRangedShot
local faceTarget = Internal.FaceGuardedCombatTarget
local stopMoveAnim = Internal.StopGuardedCombatMove
local RANGED_KITE_MIN = Internal.GuardedCombatKiteMin
local RANGED_KITE_MAX = Internal.GuardedCombatKiteMax
local RANGED_MAX_RANGE = Internal.GuardedCombatMaxRange
local RANGED_ADVANCE_SPEED = Internal.GuardedCombatAdvanceSpeed
local RANGED_BACKPEDAL_SPEED = Internal.GuardedCombatBackpedalSpeed

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

    local zx = zombie:getX()
    local zy = zombie:getY()
    local tx = target:getX()
    local ty = target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    if len > 0.001 then
        dx = dx / len
        dy = dy / len
    end

    local recovering = false
    local recovery = nil
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
            local blockedCount = tonumber(npcData[options.blockCounterKey or "guardBlockedTicks"]) or 0
            local navMode = blockedCount >= 2 and "planned" or "direct"
            moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
                target = target,
                speed = moveSpeed,
                navigationMode = navMode,
                plannerProfile = "combat_short",
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

    if npcData.burstRemaining and npcData.burstRemaining > 0 then
        npcData.burstTimer = (npcData.burstTimer or 0) + 1
        local shotSpecs = npcData.shotSpecs
        local hit = false
        if shotSpecs and npcData.burstTimer >= (shotSpecs.recoilDelay or 10) then
            npcData.burstTimer = 0
            npcData.burstRemaining = npcData.burstRemaining - 1
            hit = performRangedShot(zombie, npcData, target, stats, shotSpecs, moved, options)
        end
        return {
            status = "attack",
            moved = moved,
            attacked = true,
            hit = hit,
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
    local shotSpecs = DTNPCProtect.GetRangedShotSpecs(npcData)
    local hit = performRangedShot(zombie, npcData, target, stats, shotSpecs, moved, options)

    if shotSpecs.isAuto and ZombRand(100) < 60 then
        npcData.burstRemaining = ZombRand(2, 5)
        npcData.burstTimer = 0
        npcData.shotSpecs = shotSpecs
    end

    return {
        status = "attack",
        moved = moved,
        attacked = true,
        hit = hit,
    }
end
