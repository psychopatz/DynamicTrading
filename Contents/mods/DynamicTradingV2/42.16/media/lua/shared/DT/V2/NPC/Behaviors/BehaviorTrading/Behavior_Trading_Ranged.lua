-- ==============================================================================
-- Behavior_Trading_Ranged.lua
-- Ranged defense behavior used while trading.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading

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

    Trading.EnsureManualControl(zombie)

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

    local moveDir = 0
    local moveSpeed = 0
    if len < desiredMin then
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
        local nextX = zx + (dx * moveSpeed * moveDir)
        local nextY = zy + (dy * moveSpeed * moveDir)
        local nextOutsideLeash = false
        if anchorX ~= nil and anchorY ~= nil then
            local nextDx = nextX - anchorX
            local nextDy = nextY - anchorY
            nextOutsideLeash = math.sqrt((nextDx * nextDx) + (nextDy * nextDy)) > leashRadius
        end
        if nextOutsideLeash then
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
        elseif Trading.IsTileSafe(nextX, nextY, zz) then
            Trading.ForceWalkAnim(zombie, false)
            zombie:setX(nextX)
            zombie:setY(nextY)
            zombie:faceLocation(nextX + (dx * moveDir), nextY + (dy * moveDir))
            moved = true
        else
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

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    local attacked = false
    if npcData.attackTimer < stats.fireRate then
        Trading.MarkCombatPursuit(npcData, target, targetDist, false)
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerRangedCombatAnim then
        DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    end
    attacked = true
    DTNPCProtect.ConsumeAmmo(npcData, 1)
    DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
    zombie:getEmitter():playSound("DT_GunRandom")

    local hitChance = moved and stats.hitMove or stats.hitStill
    Trading.MarkCombatPursuit(npcData, target, targetDist, attacked)
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
