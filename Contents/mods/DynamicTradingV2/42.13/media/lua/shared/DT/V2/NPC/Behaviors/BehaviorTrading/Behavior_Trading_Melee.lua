-- ==============================================================================
-- Behavior_Trading_Melee.lua
-- Melee defense behavior used while trading.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading

DTNPCLogic.Behaviors["TradingDefenseMelee"] = function(zombie, npcData)
    local target = nil
    local targetDist = 9999
    target, targetDist = Trading.SelectStationaryThreat(zombie, npcData)
    if not DTNPCProtect.HasUsableMeleeLoadout(npcData) then
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
                "TradingDefenseMeleeLeash",
                "Too far from post. Returning.",
                "warning",
                "dist=" .. tostring(string.format("%.2f", leashDist or 0)) .. " leash=" .. tostring(string.format("%.2f", leashLimit or leashRadius))
            )
        end
        Trading.ReturnToPostOrResume(zombie, npcData)
        return
    end

    local stats = DTNPCProtect.GetMeleeCombatStats(npcData)
    local engageReach = math.max(stats.reach or Trading.TRADING_DEFENSE_MELEE_REACH, 1.45)
    local attackRange = engageReach + Trading.MELEE_APPROACH_START_BUFFER
    local stopDistance = math.max(0.9, engageReach - Trading.MELEE_APPROACH_STOP_BUFFER)
    local currentDist = Trading.GetTargetDistance(zombie, target)
    local recovering, recovery = false, nil
    local dangerState = DTNPCProtect and DTNPCProtect.GetMeleeDangerState
        and DTNPCProtect.GetMeleeDangerState(zombie, npcData, target, {
            engageReach = engageReach,
            retreatDistance = engageReach + 0.7,
        })
        or nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "melee", target)
    end

    if dangerState and dangerState.shouldDisengage then
        npcData.attackTimer = 0
        local retreatDistance = math.max(engageReach + 0.8, tonumber(dangerState.retreatDistance) or (engageReach + 1.2))
        local retreatDirX = zombie:getX() - (dangerState.fleeFromX or target:getX())
        local retreatDirY = zombie:getY() - (dangerState.fleeFromY or target:getY())
        if not Trading.PrimeMovement(zombie, npcData, retreatDirX, retreatDirY, false, "melee-retreat") then
            return
        end
        local movedAway, moveState = Trading.MoveAwayFromTarget(
            zombie,
            npcData,
            math.max(0.034, (stats.chaseSpeed or Trading.TRADING_DEFENSE_DEFAULT_SPEED) * 0.9),
            dangerState.fleeFromX or target:getX(),
            dangerState.fleeFromY or target:getY(),
            retreatDistance,
            anchorX,
            anchorY,
            anchorZ,
            leashRadius
        )
        if moveState == "leash" then
            Trading.ReturnToPostOrResume(zombie, npcData)
            return
        end
        if not movedAway then
            Trading.StopMoveAnim(zombie)
            if DTNPC and DTNPC.SetMeleeCombatIdleState then
                DTNPC.SetMeleeCombatIdleState(zombie, npcData)
            end
        end
        Trading.MarkCombatPursuit(npcData, target, currentDist, false)
        return
    end

    if recovering then
        npcData.attackTimer = 0
        local retreatDistance = math.max(engageReach + 0.45, recovery and recovery.distance or (engageReach + 0.7))
        if currentDist < retreatDistance then
            local retreatDirX = zombie:getX() - target:getX()
            local retreatDirY = zombie:getY() - target:getY()
            if not Trading.PrimeMovement(zombie, npcData, retreatDirX, retreatDirY, false, "melee-recover") then
                return
            end
            local movedAway, moveState = Trading.MoveAwayFromTarget(
                zombie,
                npcData,
                math.max(0.028, (stats.chaseSpeed or Trading.TRADING_DEFENSE_DEFAULT_SPEED) * 0.75),
                target:getX(),
                target:getY(),
                retreatDistance,
                anchorX,
                anchorY,
                anchorZ,
                leashRadius
            )
            if moveState == "leash" then
                Trading.ReturnToPostOrResume(zombie, npcData)
                return
            end
            if not movedAway then
                Trading.StopMoveAnim(zombie)
            end
        else
            Trading.StopMoveAnim(zombie)
            if DTNPC and DTNPC.SetMeleeCombatIdleState then
                DTNPC.SetMeleeCombatIdleState(zombie, npcData)
            end
        end
        Trading.MarkCombatPursuit(npcData, target, currentDist, false)
        return
    end

    if currentDist > attackRange then
        local advanceDirX = target:getX() - zombie:getX()
        local advanceDirY = target:getY() - zombie:getY()
        if not Trading.PrimeMovement(zombie, npcData, advanceDirX, advanceDirY, (stats.chaseSpeed or Trading.TRADING_DEFENSE_DEFAULT_SPEED) > 0.06, "melee-advance") then
            return
        end
        local arrived, moveState = Trading.MoveTowardTarget(
            zombie,
            npcData,
            stats.chaseSpeed or Trading.TRADING_DEFENSE_DEFAULT_SPEED,
            target,
            stopDistance,
            anchorX,
            anchorY,
            anchorZ,
            leashRadius
        )
        currentDist = Trading.GetTargetDistance(zombie, target)
        Trading.MarkCombatPursuit(npcData, target, currentDist, false)

        if moveState == "leash" then
            if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                DTNPCProtect.ReportCombatIssue(
                    zombie,
                    npcData,
                    "TradingDefenseMeleeLeashAdvance",
                    "Won't chase that far. Returning.",
                    "warning",
                    "targetDist=" .. tostring(string.format("%.2f", currentDist))
                )
            end
            Trading.ReturnToPostOrResume(zombie, npcData)
            return
        end

        if not arrived then
            if Trading.ShouldAbortCombatPursuit(npcData) then
                if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                    DTNPCProtect.ReportCombatIssue(
                        zombie,
                        npcData,
                        "TradingDefenseMeleeTimeout",
                        "Can't reach that threat. Returning.",
                        "warning",
                        "targetDist=" .. tostring(string.format("%.2f", currentDist))
                    )
                end
                Trading.ReturnToPostOrResume(zombie, npcData)
            end
            return
        end

        if currentDist > attackRange then
            if Trading.ShouldAbortCombatPursuit(npcData) then
                if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                    DTNPCProtect.ReportCombatIssue(
                        zombie,
                        npcData,
                        "TradingDefenseMeleeClosingTimeout",
                        "Can't close in on that threat. Returning.",
                        "warning",
                        "targetDist=" .. tostring(string.format("%.2f", currentDist))
                    )
                end
                Trading.ReturnToPostOrResume(zombie, npcData)
            end
            return
        end
    end

    Trading.StopMoveAnim(zombie)
    zombie:faceLocation(target:getX(), target:getY())
    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.attackRate then
        Trading.MarkCombatPursuit(npcData, target, currentDist, false)
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    end
    Trading.MarkCombatPursuit(npcData, target, currentDist, true)
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
