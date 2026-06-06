-- ==============================================================================
-- DTNPC_ProtectMeleeArbiter_State.lua
-- State and manual-control helpers for DTNPC melee arbiter.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis
local isPlayerTarget = Internal.IsMeleeArbiterPlayerTarget

local function resetMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.attackMovePrimed = nil
    npcData.protectMovePrimed = nil
    npcData.tradingMovePrimed = nil
end

local function stopMoveAnim(zombie, npcData)
    resetMoveState(npcData)
    DTNPCMobility.Stop(zombie)
end

local function setPhase(npcData, phase, lockMs)
    if not npcData then
        return
    end

    npcData.meleeCombatPhase = phase
    npcData.meleeCombatPhaseUntil = (tonumber(lockMs) or 0) > 0 and (nowMillis() + lockMs) or 0
    npcData.meleeCombatLastDecisionAt = nowMillis()
end

local function resetForTarget(npcData, targetKey)
    if not npcData then
        return
    end

    if npcData.meleeCombatTargetKey == targetKey then
        return
    end

    npcData.meleeCombatTargetKey = targetKey
    npcData.meleeCombatPhase = nil
    npcData.meleeCombatPhaseUntil = 0
    npcData.meleeCombatLastDecisionAt = 0
    npcData.attackTimer = 0
    npcData.meleeContactTargetKey = nil
    npcData.meleeContactPrimed = nil
end

function DTNPCProtect.ResetMeleeCombat(npcData)
    if not npcData then
        return
    end

    npcData.meleeCombatTargetKey = nil
    npcData.meleeCombatPhase = nil
    npcData.meleeCombatPhaseUntil = 0
    npcData.meleeCombatLastDecisionAt = 0
    npcData.meleeContactTargetKey = nil
    npcData.meleeContactPrimed = nil
end

local function ensureManualControl(zombie, target, options)
    if options and options.ensureManualControl == false then
        return
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

Internal.ResetMeleeArbiterMoveState = resetMoveState
Internal.StopMeleeArbiterMoveAnim = stopMoveAnim
Internal.SetMeleeArbiterPhase = setPhase
Internal.ResetMeleeArbiterForTarget = resetForTarget
Internal.EnsureMeleeArbiterManualControl = ensureManualControl
