-- ==============================================================================
-- Behavior_Attack_HostileSight.lua
-- Hostile sight loss, chase give-up, and cooldown handling.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack
local modules = BehaviorAttack.Modules or {}

BehaviorAttack.Modules = modules

if modules.HostileSight then
    return
end

modules.HostileSight = true

function BehaviorAttack.IsOffscreenFromActivePlayers(zombie)
    local radius = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.HostileOffscreenDespawnRadius) or 70
    local players = DTNPCLogic.GetActivePlayers and DTNPCLogic.GetActivePlayers() or {}
    if #players <= 0 then
        return true
    end

    for i = 1, #players do
        local player = players[i]
        if player and not player:isDead() and math.abs((player:getZ() or 0) - (zombie:getZ() or 0)) <= 1 then
            if BehaviorAttack.GetDistance(zombie:getX(), zombie:getY(), player:getX(), player:getY()) <= radius then
                return false
            end
        end
    end

    return true
end

function BehaviorAttack.RandomLostSightTimeoutMs(npcData)
    if npcData.hostileLostSightTimeoutMs then
        return tonumber(npcData.hostileLostSightTimeoutMs) or 75000
    end

    local config = DTNPCProtect and DTNPCProtect.CONFIG or {}
    local minMs = math.max(1000, tonumber(config.HostileLostSightSearchMinMs) or 60000)
    local maxMs = math.max(minMs, tonumber(config.HostileLostSightSearchMaxMs) or 90000)
    local timeout = minMs
    if maxMs > minMs then
        timeout = minMs + ZombRand((maxMs - minMs) + 1)
    end
    npcData.hostileLostSightTimeoutMs = timeout
    return timeout
end

function BehaviorAttack.RandomChaseGiveUpMs(npcData)
    if npcData.hostileChaseGiveUpAfterMs then
        return tonumber(npcData.hostileChaseGiveUpAfterMs) or 42000
    end

    local config = DTNPCProtect and DTNPCProtect.CONFIG or {}
    local minMs = math.max(5000, tonumber(config.HostileChaseGiveUpMinMs) or 30000)
    local maxMs = math.max(minMs, tonumber(config.HostileChaseGiveUpMaxMs) or 55000)
    local timeout = minMs
    if maxMs > minMs then
        timeout = minMs + ZombRand((maxMs - minMs) + 1)
    end
    npcData.hostileChaseGiveUpAfterMs = timeout
    BehaviorAttack.HostileDebugLog(npcData, "chase_timer", "giveUpAfterMs=" .. tostring(timeout))
    return timeout
end

function BehaviorAttack.PushSearchAmbient(zombie, npcData, nowMs)
    if not npcData or not zombie then
        return
    end

    local lastAt = tonumber(npcData.combatSearchAmbientAt) or 0
    if lastAt > 0 and (nowMs - lastAt) < 10000 then
        return
    end

    npcData.combatSearchAmbientAt = nowMs
    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = nil
    npcData.protectNoticeSentiment = "warning"
    npcData.protectNoticeDialogueStatus = "Default"
    npcData.protectNoticeDialogueState = "Looking"

    if DTNPCServerCore and DTNPCServerCore.SyncToAllClients then
        local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
        if ownedZombie == zombie then
            DTNPCServerCore.SyncToAllClients(zombie, npcData)
            if DTNPCServerCore.BroadcastPosition then
                DTNPCServerCore.BroadcastPosition(zombie, npcData, true)
            end
        end
    end
end

function BehaviorAttack.DespawnLostHostile(zombie, npcData)
    if isClient() and not isServer() then
        return false
    end
    if not npcData or not npcData.uuid or not DTNPCManager or not DTNPCManager.SetNPCStatus then
        return false
    end

    local currentHours = getGameTime() and getGameTime():getWorldAgeHours() or 0
    local awayHours = ZombRandFloat and ZombRandFloat(2.0, 4.0) or (2 + (ZombRand(120) / 60))
    npcData.requestedReturnStatus = "Resting"
    DTNPCManager.SetNPCStatus(npcData.uuid, "Away", currentHours + awayHours, "Resting")
    return true
end

function DTNPCLogic.HandleHostileLostSight(zombie, npcData, target, dist, options)
    options = type(options) == "table" and options or {}
    if not zombie or not npcData or not BehaviorAttack.IsPlayerTarget(target) then
        return false
    end

    local canSee = DTNPCProtect and DTNPCProtect.HasLineOfSight and DTNPCProtect.HasLineOfSight(zombie, target) or true
    local nowMs = BehaviorAttack.GetTimeMs()
    if DTNPCProtect and DTNPCProtect.IsCombatCapable then
        local capable, reason = DTNPCProtect.IsCombatCapable(zombie, npcData)
        if not capable then
            if DTNPCProtect.StopCombatActions then
                DTNPCProtect.StopCombatActions(zombie, npcData, reason)
            end
            return true
        end
    end
    if canSee then
        npcData.hostileTargetType = "player"
        npcData.hostileLastSeenTargetAt = nowMs
        npcData.hostileLastSeenX = target:getX()
        npcData.hostileLastSeenY = target:getY()
        npcData.hostileLastSeenZ = target:getZ()
        BehaviorAttack.ClearHostileSightMemory(npcData)
        return false
    end

    npcData.hostileTargetType = "player"
    local firstLostSight = npcData.hostileLostSightAt == nil
    npcData.hostileLostSightAt = npcData.hostileLostSightAt or nowMs
    npcData.hostileLastSeenX = npcData.hostileLastSeenX or target:getX()
    npcData.hostileLastSeenY = npcData.hostileLastSeenY or target:getY()
    npcData.hostileLastSeenZ = npcData.hostileLastSeenZ or target:getZ()
    if firstLostSight then
        BehaviorAttack.HostileDebugLog(
            npcData,
            "lost_sight",
            "lastSeen=" .. tostring(npcData.hostileLastSeenX) .. "," .. tostring(npcData.hostileLastSeenY)
        )
    end
    BehaviorAttack.PushSearchAmbient(zombie, npcData, nowMs)

    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, "lost_sight")
    else
        zombie:setTarget(nil)
    end

    local elapsed = nowMs - (tonumber(npcData.hostileLostSightAt) or nowMs)
    local timeoutMs = BehaviorAttack.RandomLostSightTimeoutMs(npcData)
    if elapsed >= timeoutMs then
        if BehaviorAttack.IsOffscreenFromActivePlayers(zombie) and BehaviorAttack.DespawnLostHostile(zombie, npcData) then
            BehaviorAttack.HostileDebugLog(npcData, "lost_sight_despawn", "elapsedMs=" .. tostring(elapsed))
            return true
        end

        BehaviorAttack.DisengageHostile(zombie, npcData, "lost_sight_timeout")
        BehaviorAttack.HostileDebugLog(npcData, "lost_sight_disengage", "elapsedMs=" .. tostring(elapsed))
        return true
    end

    local chaseMs = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.HostileLastSeenChaseMs) or 4500
    local lastSeenTarget = BehaviorAttack.CreatePointTarget(
        npcData.hostileLastSeenX,
        npcData.hostileLastSeenY,
        npcData.hostileLastSeenZ
    )
    if lastSeenTarget and elapsed <= chaseMs then
        local speed = tonumber(options.speed) or 0.045
        local navMode = (tonumber(npcData.hostileSearchBlockedTicks) or 0) >= 2 and "planned" or "direct"
        DTNPCMobility.MoveTowardTarget(zombie, npcData, {
            target = lastSeenTarget,
            speed = speed,
            navigationMode = navMode,
            plannerProfile = "combat_short",
            staminaMode = "pursuit",
            desiredRun = false,
            stopDistance = 0.7,
            blockCounterKey = "hostileSearchBlockedTicks",
            stuckTicks = 10,
            allowObstacleInteract = true,
            allowDamageRetreat = false,
            anim = {
                animSpeed = 1.0,
                isRunning = false,
                walkType = "1",
            },
        })
    end

    return true
end

function DTNPCLogic.HandleHostileChaseGiveUp(zombie, npcData, target, dist)
    if not zombie or not npcData or not BehaviorAttack.IsPlayerTarget(target) then
        return false
    end
    if DTNPCProtect and DTNPCProtect.IsHostileChasePaused and DTNPCProtect.IsHostileChasePaused(npcData) then
        if npcData.hostilePauseDebugLogged ~= true then
            npcData.hostilePauseDebugLogged = true
            BehaviorAttack.HostileDebugLog(
                npcData,
                "chase_paused",
                "cooldownUntil=" .. tostring(npcData.hostileChaseCooldownUntil)
            )
        end
        return true
    end

    local nowMs = BehaviorAttack.GetTimeMs()
    local targetKey = BehaviorAttack.GetPlayerTargetKey(target)
    if targetKey == nil then
        return false
    end

    if npcData.hostileChaseTargetID ~= targetKey then
        npcData.hostileChaseTargetID = targetKey
        npcData.hostileChaseStartedAt = nowMs
        npcData.hostileChaseGiveUpAfterMs = nil
        DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
        BehaviorAttack.HostileDebugLog(npcData, "chase_start", "target=" .. tostring(targetKey))
    end

    local elapsed = nowMs - (tonumber(npcData.hostileChaseStartedAt) or nowMs)
    local timeoutMs = BehaviorAttack.RandomChaseGiveUpMs(npcData)
    if elapsed < timeoutMs then
        return false
    end

    local targetDist = tonumber(dist) or BehaviorAttack.GetDistance(zombie:getX(), zombie:getY(), target:getX(), target:getY())
    local minDistance = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.HostileChaseGiveUpMinDistance) or 8
    if targetDist < minDistance then
        return false
    end

    if BehaviorAttack.IsTradingLike(npcData) then
        return BehaviorAttack.BeginTraderReturn(zombie, npcData)
    end
    if BehaviorAttack.IsBanditLike(npcData) then
        return BehaviorAttack.BeginBanditPause(zombie, npcData, target, nowMs)
    end

    return BehaviorAttack.BeginGenericGiveUp(zombie, npcData)
end

function DTNPCLogic.UpdateHostileGiveUpCooldown(zombie, npcData)
    if not zombie or not npcData then
        return false
    end

    local pauseUntil = tonumber(npcData.hostileChaseCooldownUntil) or 0
    if pauseUntil <= 0 then
        return false
    end

    local nowMs = BehaviorAttack.GetTimeMs()
    if nowMs < pauseUntil then
        return false
    end

    npcData.hostileChaseCooldownUntil = nil
    npcData.hostilePauseDebugLogged = nil
    BehaviorAttack.HostileDebugLog(npcData, "chase_cooldown_done", "state=" .. tostring(npcData.state))
    if BehaviorAttack.IsBanditLike(npcData)
        and not npcData.isHostile
        and (tonumber(npcData.banditPassiveFleeEligibleAt) or 0) > 0
        and nowMs >= (tonumber(npcData.banditPassiveFleeEligibleAt) or 0) then
        return BehaviorAttack.BeginBanditFleeHome(zombie, npcData)
    end

    npcData.banditPassiveFleeEligibleAt = nil
    return false
end
