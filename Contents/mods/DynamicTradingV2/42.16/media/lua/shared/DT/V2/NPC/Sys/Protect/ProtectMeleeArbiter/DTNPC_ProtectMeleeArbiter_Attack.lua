-- ==============================================================================
-- DTNPC_ProtectMeleeArbiter_Attack.lua
-- Attack-side helpers for DTNPC melee arbiter.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis
local isPlayerTarget = Internal.IsMeleeArbiterPlayerTarget
local stopMoveAnim = Internal.StopMeleeArbiterMoveAnim
local setPhase = Internal.SetMeleeArbiterPhase

local function isSevereDanger(dangerState)
    if not dangerState or dangerState.shouldDisengage ~= true then
        return false
    end

    if dangerState.reason == "low_health" then
        return true
    end

    local selfPressure = dangerState.selfPressure or {}
    local targetPressure = dangerState.targetPressure or {}
    local severeThreshold = tonumber(DTNPCProtect.CONFIG.MeleeCrowdSevereThreshold) or 4
    return math.max(tonumber(selfPressure.count) or 0, tonumber(targetPressure.count) or 0) >= severeThreshold
end

local function preserveAttackWindup(npcData, stats)
    if not npcData then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    local cap = attackRate > 0 and math.floor(attackRate * 0.65) or 0
    npcData.attackTimer = math.min(tonumber(npcData.attackTimer) or 0, cap)
end

local function maybeAnnounceCrowdRefusal(zombie, npcData, dangerState)
    if not zombie or not npcData or not dangerState then
        return false
    end

    local reason = tostring(dangerState.reason or "")
    if reason ~= "crowd" and reason ~= "surrounded" and reason ~= "pressured" then
        return false
    end

    local currentTime = nowMillis()
    local lastTime = tonumber(npcData._dtCrowdRefuseNoticeAt) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < 4500 then
        return false
    end
    npcData._dtCrowdRefuseNoticeAt = currentTime

    if DTNPCProtect.PushCombatFlavorNotice then
        return DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, "CrowdRefuse", "warning", "Companion", "CrowdRefuse")
    end
    if DTNPCProtect.PushCompanionAmbientCue then
        return DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, "Companion", "CrowdRefuse")
    end
    return false
end

local function primeContactSwing(npcData, targetKey, stats)
    if not npcData then
        return
    end

    if npcData.meleeContactTargetKey == targetKey and npcData.meleeContactPrimed == true then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    npcData.attackTimer = math.max(tonumber(npcData.attackTimer) or 0, math.max(0, attackRate - 6))
    npcData.meleeContactTargetKey = targetKey
    npcData.meleeContactPrimed = true
end

local function commitAttack(zombie, npcData, target, targetKey, stats, currentDist, options)
    local capable = true
    local reason = nil
    if DTNPCProtect.IsCombatCapable then
        capable, reason = DTNPCProtect.IsCombatCapable(zombie, npcData)
    end
    if not capable then
        if DTNPCProtect.StopCombatActions then
            DTNPCProtect.StopCombatActions(zombie, npcData, reason)
        end
        return {
            status = "not_capable",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = reason,
        }
    end

    setPhase(npcData, "commit", 0)
    stopMoveAnim(zombie, npcData)
    zombie:faceLocation(target:getX(), target:getY())
    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    if not (options.mode == "hostile" and isPlayerTarget(target)) then
        primeContactSwing(npcData, targetKey, stats)
    end
    npcData.attackTimer = (tonumber(npcData.attackTimer) or 0) + 1
    if npcData.attackTimer < stats.attackRate then
        return {
            status = "commit",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = "windup",
        }
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
        if DTNPCHostility and DTNPCHostility.PlayHurtSound then
            DTNPCHostility.PlayHurtSound(zombie, npcData, "Effort")
        end
    end
    DTNPCProtect.ConsumeWeaponCondition(npcData, "melee", 1)

    local hit = false
    if ZombRand(100) < stats.hitChance then
        hit = DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "melee",
            damage = stats.damage,
        }) == true
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "melee", target)
    end

    return {
        status = "commit",
        moved = false,
        attacked = true,
        hit = hit,
        distance = currentDist,
        reason = "swing",
    }
end

Internal.IsSevereMeleeArbiterDanger = isSevereDanger
Internal.PreserveMeleeArbiterAttackWindup = preserveAttackWindup
Internal.MaybeAnnounceMeleeArbiterCrowdRefusal = maybeAnnounceCrowdRefusal
Internal.CommitMeleeArbiterAttack = commitAttack
