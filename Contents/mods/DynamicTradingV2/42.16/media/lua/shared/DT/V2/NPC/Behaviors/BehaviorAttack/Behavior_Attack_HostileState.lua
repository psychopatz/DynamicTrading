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

function BehaviorAttack.ClearHostileNoTargetState(npcData)
    if not npcData then
        return
    end

    npcData.hostileNoTargetSince = nil
    npcData.hostileNoTargetCooldownMs = nil
end

local function isCombatState(state)
    local text = tostring(state or "")
    return text == "Attack"
        or text == "AttackRange"
        or text == "TradingDefenseMelee"
        or text == "TradingDefenseRanged"
end

function BehaviorAttack.GetHostileResumeState(npcData)
    if not npcData then
        return "Idle"
    end

    local candidates = {
        npcData.hostileReturnState,
        npcData.combatResumeState,
        npcData.stationaryPostState,
        npcData.state,
    }

    for i = 1, #candidates do
        local candidate = tostring(candidates[i] or "")
        if candidate ~= "" and candidate ~= "Resting" and not isCombatState(candidate) then
            return candidate
        end
    end

    if BehaviorAttack.IsTradingLike(npcData) then
        return "Trading"
    end

    if tostring(npcData.status or "") == "Resting" then
        local postState = tostring(npcData.stationaryPostState or "")
        if postState ~= "" and not isCombatState(postState) then
            return postState
        end
        return "Idle"
    end

    return "Idle"
end

function BehaviorAttack.GetHostileNoTargetCooldownMs(npcData)
    local configured = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.HostileNoTargetCooldownMs)
    if configured ~= nil then
        return math.max(750, configured)
    end

    local fallback = 2500
    if DTNPCProtect and DTNPCProtect.GetCombatUnreachableTimeoutMs then
        fallback = math.min(fallback, tonumber(DTNPCProtect.GetCombatUnreachableTimeoutMs(npcData)) or fallback)
    end
    return math.max(750, fallback)
end

function BehaviorAttack.SelectReplacementHostileTarget(zombie, npcData)
    if not zombie or not npcData or not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return nil, 9999
    end

    local anchorTarget = nil
    local anchorRadius = nil
    if not BehaviorAttack.IsBanditLike(npcData) then
        anchorTarget = DTNPCProtect.GetCombatAnchorTarget and DTNPCProtect.GetCombatAnchorTarget(npcData, zombie) or nil
        anchorRadius = DTNPCProtect.GetStationaryCombatLeashRadius and DTNPCProtect.GetStationaryCombatLeashRadius(npcData) or nil
    end
    local target, targetDist = DTNPCProtect.SelectNearestThreat(zombie, npcData, nil, anchorTarget, anchorRadius, true)
    local threatType = npcData.combatTargetType

    if target and (threatType == "player" or threatType == "dtnpc" or threatType == "bandits" or threatType == "zombie") then
        return target, targetDist
    end

    if DTNPCProtect and DTNPCProtect.ClearCombatTarget then
        DTNPCProtect.ClearCombatTarget(npcData)
    else
        npcData.combatTargetID = nil
        npcData.combatTargetType = nil
    end
    return nil, 9999
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
    BehaviorAttack.ClearHostileNoTargetState(npcData)
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
    BehaviorAttack.ClearHostileNoTargetState(npcData)
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
    local resumeMaster = npcData.master
    local resumeMasterID = npcData.masterID
    BehaviorAttack.ClearHostileCombatMemory(npcData)
    npcData.master = resumeMaster
    npcData.masterID = resumeMasterID
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

function BehaviorAttack.BeginHostileResume(zombie, npcData, reason)
    if not zombie or not npcData then
        return false
    end

    if BehaviorAttack.IsTradingLike(npcData) then
        return BehaviorAttack.BeginTraderReturn(zombie, npcData)
    end

    local resumeState = BehaviorAttack.GetHostileResumeState(npcData)
    local x, y, z = BehaviorAttack.ResolveReturnCoords(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, reason or "hostile_target_lost")
    else
        DTNPCMobility.Stop(zombie)
        zombie:setTarget(nil)
    end

    local resumeMaster = npcData.master
    local resumeMasterID = npcData.masterID
    BehaviorAttack.ClearHostileCombatMemory(npcData)
    npcData.master = resumeMaster
    npcData.masterID = resumeMasterID
    npcData.state = resumeState
    npcData.tasks = {}
    npcData.isMovingState = false
    npcData.goToReturnState = nil

    if x ~= nil and y ~= nil then
        local dist = BehaviorAttack.GetDistance(zombie:getX(), zombie:getY(), x, y)
        if dist > 0.9 then
            npcData.state = "GoTo"
            npcData.goToReturnState = resumeState
            npcData.tasks = {
                { x = x, y = y, z = z or 0 },
            }
        end
    end

    BehaviorAttack.HostileDebugLog(
        npcData,
        "hostile_resume",
        "resumeState=" .. tostring(resumeState) .. " reason=" .. tostring(reason or "hostile_target_lost")
    )
    BehaviorAttack.SyncHostileState(zombie, npcData, true)
    return true
end

function BehaviorAttack.HandleMissingHostileTarget(zombie, npcData)
    if not zombie or not npcData then
        return nil, 9999, false
    end

    if DTNPCLogic.RememberHostileChaseOrigin then
        DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
    end

    local replacementTarget, replacementDist = BehaviorAttack.SelectReplacementHostileTarget(zombie, npcData)
    if replacementTarget then
        BehaviorAttack.ClearHostileNoTargetState(npcData)
        npcData.combatTargetDistance = tonumber(replacementDist)
        npcData.attackTimer = 0
        npcData.reactionTimer = 0
        return replacementTarget, replacementDist, false
    end

    if BehaviorAttack.IsBanditLike(npcData) then
        BehaviorAttack.ClearHostileNoTargetState(npcData)
        return nil, 9999, false
    end

    local nowMs = BehaviorAttack.GetTimeMs()
    if not npcData.hostileNoTargetSince then
        npcData.hostileNoTargetSince = nowMs
        npcData.hostileNoTargetCooldownMs = BehaviorAttack.GetHostileNoTargetCooldownMs(npcData)
        BehaviorAttack.HostileDebugLog(
            npcData,
            "hostile_target_missing",
            "cooldownMs=" .. tostring(npcData.hostileNoTargetCooldownMs)
        )
    end

    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
        DTNPCProtect.ResetCombatRhythm(npcData)
    end
    if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
        DTNPCProtect.ResetMeleeCombat(npcData)
    end
    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, "hostile_target_missing")
    else
        DTNPCMobility.Stop(zombie)
        zombie:setTarget(nil)
    end

    local cooldownMs = tonumber(npcData.hostileNoTargetCooldownMs) or BehaviorAttack.GetHostileNoTargetCooldownMs(npcData)
    if (nowMs - (tonumber(npcData.hostileNoTargetSince) or nowMs)) < cooldownMs then
        return nil, 9999, true
    end

    BehaviorAttack.ClearHostileNoTargetState(npcData)
    return nil, 9999, BehaviorAttack.BeginHostileResume(zombie, npcData, "hostile_target_lost")
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
    BehaviorAttack.ClearHostileNoTargetState(npcData)
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
    BehaviorAttack.ClearHostileNoTargetState(npcData)
    BehaviorAttack.PushHostileNotice(zombie, npcData, "Enough waiting. We're leaving.", "warning")
    BehaviorAttack.HostileDebugLog(npcData, "bandit_flee", "passive enough after chase cooldown")
    BehaviorAttack.SyncHostileState(zombie, npcData, true)
    return true
end
