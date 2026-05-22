-- ==============================================================================
-- Behavior_Patrol.lua
-- Colony guard patrol over real-base perimeter posts with alert-driven response.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime"

local PATROL_SPEED = 0.04
local STOP_DISTANCE = 0.5
local PATROL_PAUSE_MIN_MS = 2200
local PATROL_PAUSE_MAX_MS = 5200
local PATROL_MOVE_GAP_MIN_MS = 700
local PATROL_MOVE_GAP_MAX_MS = 2200

local function nowMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

local function randomRange(minValue, maxValue)
    local minNumber = math.floor(tonumber(minValue) or 0)
    local maxNumber = math.floor(tonumber(maxValue) or minNumber)
    if maxNumber <= minNumber then
        return minNumber
    end
    return minNumber + ZombRand((maxNumber - minNumber) + 1)
end

local function createPointTarget(point)
    if type(point) ~= "table" then
        return nil
    end
    return {
        getX = function() return point.x end,
        getY = function() return point.y end,
        getZ = function() return point.z or 0 end,
    }
end

local function syncStateChange(zombie, npcData)
    if not zombie or not npcData or not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
end

local function stopMovement(zombie)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
        return
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function moveToPoint(zombie, npcData, point)
    local target = createPointTarget(point)
    if not target then
        stopMovement(zombie)
        return false, "invalid"
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = PATROL_SPEED,
        navigationMode = "planned",
        plannerProfile = "colony",
        staminaMode = "colony_patrol",
        desiredRun = false,
        stopDistance = STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "dcPatrolBlockedTicks",
        stuckTicks = 15,
        faceX = point.x,
        faceY = point.y,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })

    if moved or moveState == "arrived" or moveState == "close_enough" or moveState == "damage_retreat" then
        npcData.dcPatrolBlockedTicks = 0
        return true, moveState
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData.dcPatrolBlockedTicks = 0
        return true, moveState
    end

    stopMovement(zombie)
    return false, moveState
end

local function applyPatrolPost(npcData, point)
    if type(npcData) ~= "table" or type(point) ~= "table" then
        return
    end

    npcData.stationaryPostX = point.x
    npcData.stationaryPostY = point.y
    npcData.stationaryPostZ = point.z or 0
    npcData.stationaryPostState = "Guard"
    npcData.anchorX = point.x
    npcData.anchorY = point.y
    npcData.anchorZ = point.z or 0
    npcData.guardCombatOrder = npcData.guardCombatOrder or npcData.guardAttackMode or "GuardAuto"
    npcData.guardAttackMode = npcData.guardCombatOrder
end

local function engageFromPost(zombie, npcData, point)
    applyPatrolPost(npcData, point)
    if not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return false
    end

    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        tonumber(npcData.guardEngageRadius) or 12,
        zombie,
        tonumber(npcData.guardLeashRadius) or tonumber(npcData.guardEngageRadius) or 12,
        true
    )

    if not target then
        npcData.combatTargetID = nil
        npcData.combatTargetType = nil
        return false
    end

    DTNPCColonyRuntime.RaiseAlert(npcData, {
        source = "Patrol",
        reason = "guard_contact",
        target = target,
    })
    DTNPCColonyRuntime.PushAlertNotice(zombie, npcData, "guard", target)

    local previousState = npcData.state
    npcData.state = "Guard"
    if DTNPCLogic.Behaviors["Guard"] then
        DTNPCLogic.Behaviors["Guard"](zombie, npcData, target, targetDist)
    end
    if npcData.state == "Guard" then
        npcData.state = previousState
    end
    return true
end

local function isAlertRelevant(zombie, npcData, alert)
    if not zombie or type(alert) ~= "table" or alert.x == nil or alert.y == nil then
        return false
    end

    local radius = math.max(1, tonumber(npcData and npcData.guardEngageRadius) or 12)
    local dx = zombie:getX() - tonumber(alert.x)
    local dy = zombie:getY() - tonumber(alert.y)
    return ((dx * dx) + (dy * dy)) <= (radius * radius)
end

DTNPCLogic.Behaviors["Patrol"] = function(zombie, npcData)
    if not zombie or not npcData then
        return
    end

    if not DTNPCColonyRuntime.IsLinkedResident(npcData) then
        if DTNPCLogic.Behaviors["Guard"] then
            DTNPCLogic.Behaviors["Guard"](zombie, npcData)
        end
        return
    end

    local desiredState = DTNPCColonyRuntime.SyncBehaviorIdentity(npcData)
    if desiredState ~= "Patrol" then
        npcData.state = desiredState
        syncStateChange(zombie, npcData)
        return
    end

    local posts = DTNPCColonyRuntime.GetPatrolRoutePoints(npcData)
    local alert = DTNPCColonyRuntime.GetAlert(npcData)
    local alertRelevant = alert and isAlertRelevant(zombie, npcData, alert) or false
    if #posts <= 0 then
        local fallback = DTNPCColonyRuntime.GetSafePoint(npcData, DTNPCColonyRuntime.GetWorker(npcData))
        if fallback then
            posts = { fallback }
        end
    end
    if #posts <= 0 then
        stopMovement(zombie)
        return
    end

    local postIndex = math.max(1, math.min(#posts, math.floor(tonumber(npcData.dcGuardPostIndex) or 1)))
    if alertRelevant then
        postIndex = DTNPCColonyRuntime.GetNearestPostIndex(posts, alert.x, alert.y)
        npcData.dcPatrolPauseUntilMs = nil
        npcData.dcPatrolNextMoveAtMs = nil
    elseif npcData.dcAnchorRevision ~= npcData.dcAppliedAnchorRevision then
        postIndex = DTNPCColonyRuntime.GetNearestPostIndex(posts, zombie:getX(), zombie:getY())
        npcData.dcAppliedAnchorRevision = npcData.dcAnchorRevision
        npcData.dcPatrolPauseUntilMs = nil
        npcData.dcPatrolNextMoveAtMs = nil
    end

    npcData.dcGuardPostIndex = postIndex
    local currentPost = posts[postIndex]
    if engageFromPost(zombie, npcData, currentPost) then
        npcData.dcPatrolPauseUntilMs = nil
        npcData.dcPatrolNextMoveAtMs = nil
        return
    end

    local dx = zombie:getX() - currentPost.x
    local dy = zombie:getY() - currentPost.y
    local distSq = (dx * dx) + (dy * dy)
    if distSq <= (STOP_DISTANCE * STOP_DISTANCE) then
        stopMovement(zombie)
        if alertRelevant and alert.x ~= nil and alert.y ~= nil then
            zombie:faceLocation(alert.x, alert.y)
        else
            local nextPost = posts[#posts > 1 and ((postIndex % #posts) + 1) or postIndex] or currentPost
            zombie:faceLocation(nextPost.x, nextPost.y)
        end

        if #posts <= 1 then
            return
        end

        local now = nowMs()
        local pauseUntil = tonumber(npcData.dcPatrolPauseUntilMs) or 0
        if pauseUntil <= 0 then
            pauseUntil = now + randomRange(
                tonumber(npcData.dcPatrolPauseMinMs) or PATROL_PAUSE_MIN_MS,
                tonumber(npcData.dcPatrolPauseMaxMs) or PATROL_PAUSE_MAX_MS
            )
            npcData.dcPatrolPauseUntilMs = pauseUntil
            return
        end

        if now < pauseUntil then
            return
        end

        npcData.dcPatrolPauseUntilMs = nil
        npcData.dcGuardPostIndex = (postIndex % #posts) + 1
        npcData.dcPatrolNextMoveAtMs = now + randomRange(
            tonumber(npcData.dcPatrolMoveGapMinMs) or PATROL_MOVE_GAP_MIN_MS,
            tonumber(npcData.dcPatrolMoveGapMaxMs) or PATROL_MOVE_GAP_MAX_MS
        )
        return
    end

    if not alertRelevant then
        local nextMoveAt = tonumber(npcData.dcPatrolNextMoveAtMs) or 0
        if nextMoveAt > 0 then
            if nowMs() < nextMoveAt then
                stopMovement(zombie)
                return
            end
            npcData.dcPatrolNextMoveAtMs = nil
        end
    end

    applyPatrolPost(npcData, currentPost)
    moveToPoint(zombie, npcData, currentPost)
end
