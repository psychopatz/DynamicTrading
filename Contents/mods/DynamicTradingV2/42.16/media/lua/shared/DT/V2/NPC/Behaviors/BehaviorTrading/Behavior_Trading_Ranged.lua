-- ==============================================================================
-- Behavior_Trading_Ranged.lua
-- Ranged defense behavior used while trading.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading
require "Misc/DT_LightSystem"
require "DT/V2/Systems/Firearm/DT_FirearmSystem"
local DANGER_RETREAT_SPEED = 0.068
local DANGER_REACTION_DELAY = 18

local function performRangedShot(zombie, npcData, target, stats, shotSpecs, moved)
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

    if DT_FirearmSystem and DT_FirearmSystem.FireShot then
        DT_FirearmSystem.FireShot(zombie, target:getX(), target:getY(), target:getZ(), {
            weaponItem = shotSpecs.weaponItem,
        })
    end

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

DTNPCLogic.Behaviors["TradingDefenseRanged"] = function(zombie, npcData)
    local target, targetDist = Trading.SelectStationaryThreat(zombie, npcData)
    if not DTNPCProtect.HasUsableRangedLoadout(npcData) then
        Trading.ReturnToPostOrResume(zombie, npcData)
        return
    end
    if not target then
        Trading.ReturnToPostOrResume(zombie, npcData)
        return
    end

    if DTNPCProtect and DTNPCProtect.IsCombatCapable then
        local capable, reason = DTNPCProtect.IsCombatCapable(zombie, npcData)
        if not capable then
            if DTNPCProtect.StopCombatActions then
                DTNPCProtect.StopCombatActions(zombie, npcData, reason)
            end
            Trading.ReturnToPostOrResume(zombie, npcData)
            return
        end
    end

    Trading.EnsureManualControl(zombie)

    if DTNPCProtect and DTNPCProtect.UpdateRangedReloadAction then
        local busy = DTNPCProtect.UpdateRangedReloadAction(zombie, npcData, target)
        if busy then
            Trading.StopMoveAnim(zombie)
            if DTNPC and DTNPC.SetRangedCombatIdleState then
                DTNPC.SetRangedCombatIdleState(zombie, npcData)
            end
            Trading.MarkCombatPursuit(npcData, target, targetDist, false)
            return
        end
    end

    if DTNPCMobility and DTNPCMobility.IsSpecialActionActive then
        local specialActive = DTNPCMobility.IsSpecialActionActive(npcData)
        if specialActive and npcData._dtSpecialAction == "fence" then
            if DTNPCMobility.UpdateSpecialAction then
                DTNPCMobility.UpdateSpecialAction(zombie, npcData)
            end
            Trading.MarkCombatPursuit(npcData, target, targetDist, false)
            return
        end
    end

    local anchorTarget = Trading.GetCombatAnchorTarget(zombie, npcData)
    local anchorX = anchorTarget and anchorTarget:getX() or nil
    local anchorY = anchorTarget and anchorTarget:getY() or nil
    local anchorZ = anchorTarget and anchorTarget:getZ() or zombie:getZ()
    local leashRadius = Trading.GetCombatLeashRadius(npcData)
    local outsideLeash, leashDist, leashLimit = Trading.IsOutsideCombatLeash(zombie, npcData)
    if outsideLeash then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "TradingDefenseLeash",
                "Too far from post. Returning.",
                "warning",
                "dist=" .. tostring(string.format("%.2f", leashDist or 0)) .. " leash=" .. tostring(string.format("%.2f", leashLimit or leashRadius))
            )
        end
        Trading.ReturnToPostOrResume(zombie, npcData)
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

    local desiredMin = recovering and math.max(Trading.RANGED_KITE_MIN, recovery and recovery.distance or Trading.RANGED_KITE_MIN) or Trading.RANGED_KITE_MIN
    local desiredMax = recovering and math.max(Trading.RANGED_KITE_MAX, desiredMin + 0.75) or Trading.RANGED_KITE_MAX
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
    local moveSpeed = 0
    local retreatSourceX = tx
    local retreatSourceY = ty
    if dangerState and dangerState.shouldDisengage == true then
        retreatSourceX = tonumber(dangerState.fleeFromX) or tx
        retreatSourceY = tonumber(dangerState.fleeFromY) or ty
        npcData.reactionTimer = DANGER_REACTION_DELAY
        moveDir = -1
        moveSpeed = DANGER_RETREAT_SPEED
    elseif len < desiredMin then
        npcData.reactionTimer = (npcData.reactionTimer or 0) + 1
        if npcData.reactionTimer >= 18 then
            moveDir = -1
            moveSpeed = Trading.RANGED_BACKPEDAL_SPEED
        end
    elseif len > desiredMax then
        npcData.reactionTimer = 0
        moveDir = 1
        moveSpeed = Trading.RANGED_ADVANCE_SPEED
    else
        npcData.reactionTimer = 0
    end

    local moved = false
    if moveDir ~= 0 then
        zombie:setVariable("DTIdleState", "0")
        if not Trading.PrimeMovement(zombie, npcData, dx * moveDir, dy * moveDir, false, "ranged-kite") then
            return
        end
        local moveState = nil
        if moveDir > 0 then
            moved, moveState = Trading.MoveTowardTarget(
                zombie,
                npcData,
                moveSpeed,
                target,
                desiredMin + 0.1,
                anchorX,
                anchorY,
                anchorZ,
                leashRadius
            )
        else
            moved, moveState = Trading.MoveAwayFromTarget(
                zombie,
                npcData,
                moveSpeed,
                retreatSourceX,
                retreatSourceY,
                dangerState and dangerState.shouldDisengage == true
                    and math.max(desiredMin + 0.75, tonumber(dangerState.retreatDistance) or (desiredMin + 1.5))
                    or (desiredMin + 0.75),
                anchorX,
                anchorY,
                anchorZ,
                leashRadius
            )
        end

        moved = moved == true or moveState == "damage_retreat"
        if moveState == "exhausted" then
            moved = false
            Trading.StopMoveAnim(zombie)
        elseif moveState == "leash" then
            if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                DTNPCProtect.ReportCombatIssue(
                    zombie,
                    npcData,
                    "TradingDefenseLeashAdvance",
                    "Won't chase that far. Returning.",
                    "warning",
                    "targetDist=" .. tostring(string.format("%.2f", len))
                )
            end
            Trading.ReturnToPostOrResume(zombie, npcData)
            return
        elseif moveState == "special_action" or moveState == "interacted_fence" then
            moved = false
        elseif not moved and not (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
            Trading.StopMoveAnim(zombie)
        end
    else
        Trading.StopMoveAnim(zombie)
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    if not moved then
        Trading.FaceTarget(zombie, target)
    end

    if targetDist > Trading.RANGED_MAX_RANGE then
        Trading.MarkCombatPursuit(npcData, target, targetDist, false)
        if Trading.ShouldAbortCombatPursuit(npcData) then
            if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                DTNPCProtect.ReportCombatIssue(
                    zombie,
                    npcData,
                    "TradingDefenseRangeTimeout",
                    "Can't reach that threat. Returning.",
                    "warning",
                    "targetDist=" .. tostring(string.format("%.2f", targetDist))
                )
            end
            Trading.ReturnToPostOrResume(zombie, npcData)
        end
        return
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    if recovering then
        npcData.attackTimer = 0
        Trading.MarkCombatPursuit(npcData, target, targetDist, false)
        return
    end

    -- Burst Logic
    if npcData.burstRemaining and npcData.burstRemaining > 0 then
        npcData.burstTimer = (npcData.burstTimer or 0) + 1
        local shotSpecs = npcData.shotSpecs
        if shotSpecs and npcData.burstTimer >= (shotSpecs.recoilDelay or 10) then
            npcData.burstTimer = 0
            npcData.burstRemaining = npcData.burstRemaining - 1
            performRangedShot(zombie, npcData, target, stats, shotSpecs, moved)
        end
        Trading.MarkCombatPursuit(npcData, target, targetDist, true)
        return
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.fireRate then
        Trading.MarkCombatPursuit(npcData, target, targetDist, false)
        return
    end

    npcData.attackTimer = 0
    local shotSpecs = DTNPCProtect.GetRangedShotSpecs(npcData)
    performRangedShot(zombie, npcData, target, stats, shotSpecs, moved)

    if shotSpecs.isAuto and ZombRand(100) < 60 then
        npcData.burstRemaining = ZombRand(2, 5)
        npcData.burstTimer = 0
        npcData.shotSpecs = shotSpecs
    end
    Trading.MarkCombatPursuit(npcData, target, targetDist, true)
end
