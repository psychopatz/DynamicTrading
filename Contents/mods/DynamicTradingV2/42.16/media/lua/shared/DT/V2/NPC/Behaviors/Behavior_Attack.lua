-- ==============================================================================
-- Behavior_Attack.lua
-- Hostile melee combat plus legacy wake-up behavior for movement states.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local MELEE_DEFAULT_REACH = 1.25
local MELEE_DEFAULT_SPEED = 0.05
local MELEE_APPROACH_START_BUFFER = 0.18
local MELEE_APPROACH_STOP_BUFFER = 0.16
local MELEE_ATTACK_COMMIT_BUFFER = 0.12

local function isPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end

local function getTimeMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

local function getDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function createPointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end

    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
        isDead = function() return false end,
    }
end

local clearHostileSightMemory
local disengageHostile

local function isOffscreenFromActivePlayers(zombie)
    local radius = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.HostileOffscreenDespawnRadius) or 70
    local players = DTNPCLogic.GetActivePlayers and DTNPCLogic.GetActivePlayers() or {}
    if #players <= 0 then
        return true
    end

    for i = 1, #players do
        local player = players[i]
        if player and not player:isDead() and math.abs((player:getZ() or 0) - (zombie:getZ() or 0)) <= 1 then
            if getDistance(zombie:getX(), zombie:getY(), player:getX(), player:getY()) <= radius then
                return false
            end
        end
    end

    return true
end

local function randomLostSightTimeoutMs(npcData)
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

local function randomChaseGiveUpMs(npcData)
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
    return timeout
end

local function getPlayerTargetKey(player)
    if not player then
        return nil
    end
    if player.getOnlineID then
        local onlineID = player:getOnlineID()
        if onlineID and onlineID ~= 0 then
            return "player:" .. tostring(onlineID)
        end
    end
    if player.getUsername then
        return "player:" .. tostring(player:getUsername())
    end
    return tostring(player)
end

local function syncHostileState(zombie, npcData, forcePosition)
    if not zombie or not npcData or not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie == zombie then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
        if DTNPCServerCore.BroadcastPosition then
            DTNPCServerCore.BroadcastPosition(zombie, npcData, forcePosition == true)
        end
    end
end

local function pushHostileNotice(zombie, npcData, text, sentiment)
    if not npcData or not text or text == "" then
        return false
    end
    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, text, sentiment or "warning")
    end

    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = text
    npcData.protectNoticeSentiment = sentiment or "warning"
    npcData.protectNoticeDialogueStatus = nil
    npcData.protectNoticeDialogueState = nil
    syncHostileState(zombie, npcData, true)
    return true
end

local function isTradingLike(npcData)
    if not npcData then
        return false
    end
    return tostring(npcData.status or "") == "Trading"
        or tostring(npcData.state or "") == "Trading"
        or tostring(npcData.combatResumeState or "") == "Trading"
        or tostring(npcData.hostileReturnState or "") == "Trading"
        or tostring(npcData.stationaryPostState or "") == "Trading"
end

local function isBanditLike(npcData)
    return npcData
        and (npcData.isBandit == true
            or npcData.banditGroupID ~= nil
            or npcData.raidHostileFaction == true
            or tostring(npcData.factionID or "") == "Bandits"
            or tostring(npcData.archetypeID or "") == "Bandit")
end

local function resolveReturnCoords(zombie, npcData)
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

    local x, y, z = resolveReturnCoords(zombie, npcData)
    if x == nil or y == nil then
        x = zombie:getX()
        y = zombie:getY()
        z = zombie:getZ()
    end

    npcData.hostileReturnX = x
    npcData.hostileReturnY = y
    npcData.hostileReturnZ = z or 0
    npcData.hostileReturnState = npcData.combatResumeState or npcData.state or npcData.status or "Idle"
    return true
end

local function resetHostileChaseTimers(npcData)
    if not npcData then
        return
    end
    npcData.hostileChaseTargetID = nil
    npcData.hostileChaseStartedAt = nil
    npcData.hostileChaseGiveUpAfterMs = nil
end

local function clearHostileCombatMemory(npcData)
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
    resetHostileChaseTimers(npcData)
    clearHostileSightMemory(npcData)
    if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
        DTNPCProtect.ResetCombatRhythm(npcData)
    end
    if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
        DTNPCProtect.ResetMeleeCombat(npcData)
    end
end

local function beginTraderReturn(zombie, npcData)
    local x, y, z = resolveReturnCoords(zombie, npcData)
    if x == nil or y == nil then
        disengageHostile(zombie, npcData, "chase_give_up")
        pushHostileNotice(zombie, npcData, "Fine. Not worth the chase.", "warning")
        return true
    end

    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, "chase_give_up")
    end
    clearHostileCombatMemory(npcData)
    npcData.status = npcData.status or "Trading"
    npcData.state = "GoTo"
    npcData.goToReturnState = "Trading"
    npcData.tasks = {
        { x = x, y = y, z = z or 0 },
    }
    npcData.isMovingState = false
    pushHostileNotice(zombie, npcData, "Enough. Back to business.", "warning")
    syncHostileState(zombie, npcData, true)
    return true
end

local function beginGenericGiveUp(zombie, npcData)
    disengageHostile(zombie, npcData, "chase_give_up")
    pushHostileNotice(zombie, npcData, "Forget it. Not worth the chase.", "warning")
    syncHostileState(zombie, npcData, true)
    return true
end

local function beginBanditPause(zombie, npcData, target, nowMs)
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
    resetHostileChaseTimers(npcData)
    clearHostileSightMemory(npcData)
    pushHostileNotice(zombie, npcData, "Lost them. Hold up a minute.", "warning")
    syncHostileState(zombie, npcData, true)
    return true
end

local function beginBanditFleeHome(zombie, npcData)
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
    resetHostileChaseTimers(npcData)
    clearHostileSightMemory(npcData)
    pushHostileNotice(zombie, npcData, "Enough waiting. We're leaving.", "warning")
    syncHostileState(zombie, npcData, true)
    return true
end

local function pushSearchAmbient(zombie, npcData, nowMs)
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

clearHostileSightMemory = function(npcData)
    if not npcData then
        return
    end

    npcData.hostileLostSightAt = nil
    npcData.hostileLostSightTimeoutMs = nil
    npcData.combatSearchAmbientAt = nil
end

disengageHostile = function(zombie, npcData, reason)
    npcData.isHostile = false
    npcData.state = "Idle"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.hostileTargetType = nil
    clearHostileSightMemory(npcData)
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

local function despawnLostHostile(zombie, npcData)
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
    if not zombie or not npcData or not isPlayerTarget(target) then
        return false
    end

    local canSee = DTNPCProtect and DTNPCProtect.HasLineOfSight and DTNPCProtect.HasLineOfSight(zombie, target) or true
    local nowMs = getTimeMs()
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
        clearHostileSightMemory(npcData)
        return false
    end

    npcData.hostileTargetType = "player"
    npcData.hostileLostSightAt = npcData.hostileLostSightAt or nowMs
    npcData.hostileLastSeenX = npcData.hostileLastSeenX or target:getX()
    npcData.hostileLastSeenY = npcData.hostileLastSeenY or target:getY()
    npcData.hostileLastSeenZ = npcData.hostileLastSeenZ or target:getZ()
    pushSearchAmbient(zombie, npcData, nowMs)

    if DTNPCProtect and DTNPCProtect.StopCombatActions then
        DTNPCProtect.StopCombatActions(zombie, npcData, "lost_sight")
    else
        zombie:setTarget(nil)
    end

    local elapsed = nowMs - (tonumber(npcData.hostileLostSightAt) or nowMs)
    local timeoutMs = randomLostSightTimeoutMs(npcData)
    if elapsed >= timeoutMs then
        if isOffscreenFromActivePlayers(zombie) and despawnLostHostile(zombie, npcData) then
            return true
        end

        disengageHostile(zombie, npcData, "lost_sight_timeout")
        return true
    end

    local chaseMs = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.HostileLastSeenChaseMs) or 4500
    local lastSeenTarget = createPointTarget(npcData.hostileLastSeenX, npcData.hostileLastSeenY, npcData.hostileLastSeenZ)
    if lastSeenTarget and elapsed <= chaseMs then
        local speed = tonumber(options.speed) or 0.045
        DTNPCMobility.MoveTowardTarget(zombie, npcData, {
            target = lastSeenTarget,
            speed = speed,
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
    if not zombie or not npcData or not isPlayerTarget(target) then
        return false
    end
    if DTNPCProtect and DTNPCProtect.IsHostileChasePaused and DTNPCProtect.IsHostileChasePaused(npcData) then
        return true
    end

    local nowMs = getTimeMs()
    local targetKey = getPlayerTargetKey(target)
    if targetKey == nil then
        return false
    end

    if npcData.hostileChaseTargetID ~= targetKey then
        npcData.hostileChaseTargetID = targetKey
        npcData.hostileChaseStartedAt = nowMs
        npcData.hostileChaseGiveUpAfterMs = nil
        DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
    end

    local elapsed = nowMs - (tonumber(npcData.hostileChaseStartedAt) or nowMs)
    local timeoutMs = randomChaseGiveUpMs(npcData)
    if elapsed < timeoutMs then
        return false
    end

    local targetDist = tonumber(dist) or getDistance(zombie:getX(), zombie:getY(), target:getX(), target:getY())
    local minDistance = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.HostileChaseGiveUpMinDistance) or 8
    if targetDist < minDistance then
        return false
    end

    if isTradingLike(npcData) then
        return beginTraderReturn(zombie, npcData)
    end
    if isBanditLike(npcData) then
        return beginBanditPause(zombie, npcData, target, nowMs)
    end

    return beginGenericGiveUp(zombie, npcData)
end

function DTNPCLogic.UpdateHostileGiveUpCooldown(zombie, npcData)
    if not zombie or not npcData then
        return false
    end

    local pauseUntil = tonumber(npcData.hostileChaseCooldownUntil) or 0
    if pauseUntil <= 0 then
        return false
    end

    local nowMs = getTimeMs()
    if nowMs < pauseUntil then
        return false
    end

    npcData.hostileChaseCooldownUntil = nil
    if isBanditLike(npcData)
        and not npcData.isHostile
        and (tonumber(npcData.banditPassiveFleeEligibleAt) or 0) > 0
        and nowMs >= (tonumber(npcData.banditPassiveFleeEligibleAt) or 0) then
        return beginBanditFleeHome(zombie, npcData)
    end

    npcData.banditPassiveFleeEligibleAt = nil
    return false
end

local function runLegacyWakeup(zombie, target, dist)
    if isPlayerTarget(target) then
        zombie:setTarget(nil)
        if target and target.getX and target.getY then
            zombie:faceLocation(target:getX(), target:getY())
        end
        if DTNPC and DTNPC.ApplySafetyFlags then
            DTNPC.ApplySafetyFlags(zombie, DTNPC.GetData and DTNPC.GetData(zombie) or nil, { clearPlayerTarget = true })
        end
        return
    end

    if zombie:isUseless() then
        zombie:setUseless(false)
        zombie:setSpeedMod(1.1)
        zombie:DoZombieStats()
        zombie:setSitAgainstWall(false)
    end

    if target then
        if isPlayerTarget(target) then
            zombie:setTarget(nil)
        else
            zombie:setTarget(target)
        end

        local shouldRun = (tonumber(dist) or 9999) > 3.0 or target:isRunning() or target:isSprinting()
        zombie:setRunning(shouldRun)

        if not zombie:isMoving() and (tonumber(dist) or 9999) > 1.5 then
            zombie:pathToLocation(target:getX(), target:getY(), target:getZ())
        end
    elseif not zombie:isMoving() then
        zombie:setRunning(true)
    end
end

local function resetAttackMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.attackMovePrimed = nil
    npcData.attackMoveReason = nil
end

local function stopMoveAnim(zombie, npcData)
    resetAttackMoveState(npcData)
    DTNPCMobility.Stop(zombie)
end

local function forceWalkAnim(zombie, isRunning)
    DTNPCMobility.SetLocomotionState(zombie, {
        moving = true,
        animSpeed = isRunning and 1.15 or 1.0,
        isRunning = isRunning == true,
        walkType = "1",
    })
end

local function primeAttackMovement(zombie, npcData, dirX, dirY, isRunning, reason)
    if not zombie or not npcData then
        return true
    end

    local moveDirX = tonumber(dirX) or 0
    local moveDirY = tonumber(dirY) or 0
    local len = math.sqrt((moveDirX * moveDirX) + (moveDirY * moveDirY))
    if len <= 0.001 then
        return true
    end

    moveDirX = moveDirX / len
    moveDirY = moveDirY / len
    npcData.isMovingState = true

    npcData.attackMovePrimed = true
    npcData.attackMoveReason = reason or "move"
    forceWalkAnim(zombie, isRunning == true)
    zombie:faceLocation(zombie:getX() + moveDirX, zombie:getY() + moveDirY)
    return true
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

local function getTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function moveTowardTarget(zombie, npcData, speed, target, stopDistance)
    local moved, state = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = speed,
        stopDistance = stopDistance,
        blockCounterKey = "attackBlockedTicks",
        stuckTicks = 10,
        anim = {
            animSpeed = speed > 0.06 and 1.15 or 1.0,
            isRunning = speed > 0.06,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") and npcData then
        npcData.isMovingState = true
    elseif npcData then
        resetAttackMoveState(npcData)
    end

    return moved or state == "arrived" or state == "close_enough", state
end

local function moveAwayFromPoint(zombie, npcData, speed, sourceX, sourceY, desiredDistance, faceTarget)
    local moved, state = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
        fromX = sourceX,
        fromY = sourceY,
        speed = speed,
        desiredDistance = desiredDistance,
        blockCounterKey = "attackBlockedTicks",
        stuckTicks = 8,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") and npcData then
        npcData.isMovingState = true
    elseif npcData then
        resetAttackMoveState(npcData)
    end

    return moved or state == "spaced", state
end

local function preserveAttackWindup(npcData, stats)
    if not npcData then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    local cap = attackRate > 0 and math.floor(attackRate * 0.5) or 0
    npcData.attackTimer = math.min(tonumber(npcData.attackTimer) or 0, cap)
end

local function getTargetKey(target)
    if not target then
        return nil
    end
    local id = target.getID and target:getID() or nil
    if id then
        return "id:" .. tostring(id)
    end
    return tostring(target)
end

local function primeContactSwing(npcData, target, stats)
    if not npcData then
        return
    end

    local targetKey = getTargetKey(target)
    if npcData.meleeContactTargetKey == targetKey and npcData.meleeContactPrimed == true then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    npcData.attackTimer = math.max(tonumber(npcData.attackTimer) or 0, math.max(0, attackRate - 6))
    npcData.meleeContactTargetKey = targetKey
    npcData.meleeContactPrimed = true
end

local function shouldStandAndFight(dangerState, currentDist, attackRange)
    if not dangerState or dangerState.shouldDisengage ~= true then
        return false
    end
    if (tonumber(currentDist) or 9999) > (tonumber(attackRange) or 0) then
        return false
    end
    if dangerState.reason == "low_health" then
        return false
    end

    local selfPressure = dangerState.selfPressure or {}
    local severeThreshold = tonumber(DTNPCProtect.CONFIG.MeleeCrowdSevereThreshold) or 4
    local lowHealthRatio = tonumber(DTNPCProtect.CONFIG.MeleeLowHealthRetreatRatio) or 0.58
    if dangerState.reason == "pressured" and (tonumber(dangerState.healthRatio) or 1) <= (lowHealthRatio + 0.08) then
        return false
    end

    return (tonumber(selfPressure.count) or 0) < severeThreshold
end

DTNPCLogic.Behaviors["Attack"] = function(zombie, npcData, target, dist)
    if not npcData then
        runLegacyWakeup(zombie, target, dist)
        return
    end

    if npcData.state ~= "Attack" then
        runLegacyWakeup(zombie, target, dist)
        return
    end

    if not target and zombie and zombie.getTarget then
        local currentTarget = zombie:getTarget()
        if currentTarget and instanceof and instanceof(currentTarget, "IsoPlayer") and not currentTarget:isDead() then
            zombie:setTarget(nil)
        end
    end

    if not target or target:isDead() then
        npcData.attackTimer = 0
        if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end
        stopMoveAnim(zombie, npcData)
        zombie:setTarget(nil)
        return
    end

    if DTNPCLogic.HandleHostileLostSight
        and DTNPCLogic.HandleHostileLostSight(zombie, npcData, target, dist, { speed = MELEE_DEFAULT_SPEED }) then
        return
    end
    if DTNPCLogic.HandleHostileChaseGiveUp
        and DTNPCLogic.HandleHostileChaseGiveUp(zombie, npcData, target, dist) then
        return
    end

    local resolvedState = DTNPCProtect and DTNPCProtect.ResolveHostileCombatState
        and DTNPCProtect.ResolveHostileCombatState(npcData, "Attack", dist)
        or "Attack"
    npcData.combatTargetDistance = tonumber(dist) or getTargetDistance(zombie, target)

    if resolvedState ~= "Attack" then
        if resolvedState == "AttackRange" and DTNPCLogic.Behaviors["AttackRange"] then
            npcData.state = "AttackRange"
            DTNPCLogic.Behaviors["AttackRange"](zombie, npcData, target, dist)
            return
        end
        runLegacyWakeup(zombie, target, dist)
        return
    end

    ensureManualControl(zombie)
    if isPlayerTarget(target) then
        zombie:setTarget(nil)
    else
        zombie:setTarget(target)
    end

    if DTNPCProtect and DTNPCProtect.ExecuteMeleeCombat then
        DTNPCProtect.ExecuteMeleeCombat(zombie, npcData, target, {
            mode = "hostile",
            blockCounterKey = "attackBlockedTicks",
            fallbackReach = MELEE_DEFAULT_REACH,
            defaultSpeed = MELEE_DEFAULT_SPEED,
            enterBuffer = 0.25,
            holdBuffer = 0.45,
            stopBuffer = MELEE_APPROACH_STOP_BUFFER,
        })
    end
end
