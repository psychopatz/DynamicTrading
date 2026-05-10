-- ==============================================================================
-- Behavior_Attack_HostileState.lua
-- Hostile chase memory, disengage, and give-up state transitions.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack
local modules = BehaviorAttack.Modules or {}
local internal = BehaviorAttack.Internal or {}

BehaviorAttack.Modules = modules
BehaviorAttack.Internal = internal

if modules.HostileState then
    return
end

modules.HostileState = true

function BehaviorAttack.ResolveReturnCoords(zombie, npcData)
    if not npcData then
        return nil, nil, nil
    end

    local x = tonumber(npcData.stationaryPostX)
    local y = tonumber(npcData.stationaryPostY)
    if x ~= nil and y ~= nil then
        return x, y, tonumber(npcData.stationaryPostZ) or (zombie and zombie:getZ() or 0)
    end

    x = tonumber(npcData.anchorX)
    y = tonumber(npcData.anchorY)
    if x ~= nil and y ~= nil then
        return x, y, tonumber(npcData.anchorZ) or (zombie and zombie:getZ() or 0)
    end

    x = tonumber(npcData.hostileReturnX)
    y = tonumber(npcData.hostileReturnY)
    if x ~= nil and y ~= nil then
        return x, y, tonumber(npcData.hostileReturnZ) or (zombie and zombie:getZ() or 0)
    end

    local home = npcData.homeCoords
    if type(home) == "table" and home.x ~= nil and home.y ~= nil then
        return tonumber(home.x), tonumber(home.y), tonumber(home.z) or 0
    end

    return nil, nil, nil
end

function DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
    if not zombie or not npcData or npcData.hostileReturnX ~= nil then
        return false
    end

    local x, y, z = BehaviorAttack.ResolveReturnCoords(zombie, npcData)
    if x == nil or y == nil then
        x = zombie:getX()
        y = zombie:getY()
        z = zombie:getZ()
    end

    npcData.hostileReturnX = x
    npcData.hostileReturnY = y
    npcData.hostileReturnZ = z or 0
    npcData.hostileReturnState = npcData.combatResumeState or npcData.state or npcData.status or "Idle"
    BehaviorAttack.HostileDebugLog(
        npcData,
        "chase_origin",
        "x=" .. tostring(x) .. " y=" .. tostring(y) .. " state=" .. tostring(npcData.hostileReturnState)
    )
    return true
end

function BehaviorAttack.ResetHostileChaseTimers(npcData)
    if not npcData then
        return
    end
    npcData.hostileChaseTargetID = nil
    npcData.hostileChaseStartedAt = nil
    npcData.hostileChaseGiveUpAfterMs = nil
end

function BehaviorAttack.ClearHostileSightMemory(npcData)
    if not npcData then
        return
    end

    npcData.hostileLostSightAt = nil
    npcData.hostileLostSightTimeoutMs = nil
    npcData.combatSearchAmbientAt = nil
end

function BehaviorAttack.ClearHostileCombatMemory(npcData)
    if not npcData then
        return
    end
    npcData.isHostile = false
    npcData.master = nil
    npcData.masterID = nil
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.hostileTargetType = nil
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    npcData.lastPlayerAttackerUsername = nil
    npcData.lastPlayerAttackerOnlineID = nil
    BehaviorAttack.ResetHostileChaseTimers(npcData)
    BehaviorAttack.ClearHostileSightMemory(npcData)
    if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
        DTNPCProtect.ResetCombatRhythm(npcData)
    end
    if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
        DTNPCProtect.ResetMeleeCombat(npcData)
    end
end

function BehaviorAttack.DisengageHostile(zombie, npcData, reason)
    npcData.isHostile = false
    npcData.state = "Idle"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.hostileTargetType = nil
    BehaviorAttack.ClearHostileSightMemory(npcData)
    if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
        DTNPCProtect.ResetMeleeCombat(npcData)
    end
    if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
        DTNPCProtect.ResetCombatRhythm(npcData)
    end
    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, reason or "lost_sight")
    else
        DTNPCMobility.Stop(zombie)
        zombie:setTarget(nil)
    end
end

function BehaviorAttack.BeginTraderReturn(zombie, npcData)
    local x, y, z = BehaviorAttack.ResolveReturnCoords(zombie, npcData)
    if x == nil or y == nil then
        BehaviorAttack.DisengageHostile(zombie, npcData, "chase_give_up")
        BehaviorAttack.PushHostileNotice(zombie, npcData, "Fine. Not worth the chase.", "warning")
        BehaviorAttack.HostileDebugLog(npcData, "trader_give_up", "no return coords; disengaged")
        return true
    end

    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, "chase_give_up")
    end
    BehaviorAttack.ClearHostileCombatMemory(npcData)
    npcData.status = npcData.status or "Trading"
    npcData.state = "GoTo"
    npcData.goToReturnState = "Trading"
    npcData.tasks = {
        { x = x, y = y, z = z or 0 },
    }
    npcData.isMovingState = false
    BehaviorAttack.PushHostileNotice(zombie, npcData, "Enough. Back to business.", "warning")
    BehaviorAttack.HostileDebugLog(npcData, "trader_return", "returning to x=" .. tostring(x) .. " y=" .. tostring(y))
    BehaviorAttack.SyncHostileState(zombie, npcData, true)
    return true
end

function BehaviorAttack.BeginGenericGiveUp(zombie, npcData)
    BehaviorAttack.DisengageHostile(zombie, npcData, "chase_give_up")
    BehaviorAttack.PushHostileNotice(zombie, npcData, "Forget it. Not worth the chase.", "warning")
    BehaviorAttack.HostileDebugLog(npcData, "chase_give_up", "generic disengage")
    BehaviorAttack.SyncHostileState(zombie, npcData, true)
    return true
end

function BehaviorAttack.BeginBanditPause(zombie, npcData, target, nowMs)
    local pauseMs = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.BanditChasePauseMs) or 120000
    pauseMs = math.max(15000, pauseMs)

    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, "bandit_chase_pause")
    end

    npcData.banditChaseGiveUps = (tonumber(npcData.banditChaseGiveUps) or 0) + 1
    npcData.banditPausedTargetUsername = target and target.getUsername and target:getUsername() or npcData.lastPlayerAttackerUsername
    npcData.banditPausedTargetOnlineID = target and target.getOnlineID and target:getOnlineID() or npcData.lastPlayerAttackerOnlineID
    npcData.hostileChaseCooldownUntil = nowMs + pauseMs
    npcData.banditPassiveFleeEligibleAt = npcData.hostileChaseCooldownUntil
    npcData.isHostile = false
    npcData.state = "Stay"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    BehaviorAttack.ResetHostileChaseTimers(npcData)
    BehaviorAttack.ClearHostileSightMemory(npcData)
    BehaviorAttack.PushHostileNotice(zombie, npcData, "Lost them. Hold up a minute.", "warning")
    BehaviorAttack.HostileDebugLog(npcData, "bandit_pause", "cooldownMs=" .. tostring(pauseMs))
    BehaviorAttack.SyncHostileState(zombie, npcData, true)
    return true
end

function BehaviorAttack.BeginBanditFleeHome(zombie, npcData)
    if not zombie or not npcData then
        return false
    end

    npcData.banditDemandResolved = true
    npcData.banditLeaving = true
    npcData.isHostile = false
    npcData.state = "Flee"
    npcData.master = npcData.banditPausedTargetUsername or npcData.lastPlayerAttackerUsername or npcData.master
    npcData.masterID = npcData.banditPausedTargetOnlineID or npcData.lastPlayerAttackerOnlineID or npcData.masterID
    npcData.requestedReturnStatus = "Resting"
    npcData.hostileChaseCooldownUntil = nil
    npcData.banditPassiveFleeEligibleAt = nil
    npcData.tasks = {}
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil
    BehaviorAttack.ResetHostileChaseTimers(npcData)
    BehaviorAttack.ClearHostileSightMemory(npcData)
    BehaviorAttack.PushHostileNotice(zombie, npcData, "Enough waiting. We're leaving.", "warning")
    BehaviorAttack.HostileDebugLog(npcData, "bandit_flee", "passive enough after chase cooldown")
    BehaviorAttack.SyncHostileState(zombie, npcData, true)
    return true
end
