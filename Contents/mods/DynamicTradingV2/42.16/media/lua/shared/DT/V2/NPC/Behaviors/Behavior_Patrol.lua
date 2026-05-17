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
        createPointTarget(point),
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

    local posts = DTNPCColonyRuntime.GetPerimeterPosts(npcData)
    local alert = DTNPCColonyRuntime.GetAlert(npcData)
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
    if alert and alert.x ~= nil and alert.y ~= nil then
        postIndex = DTNPCColonyRuntime.GetNearestPostIndex(posts, alert.x, alert.y)
    elseif npcData.dcAnchorRevision ~= npcData.dcAppliedAnchorRevision then
        postIndex = DTNPCColonyRuntime.GetNearestPostIndex(posts, zombie:getX(), zombie:getY())
        npcData.dcAppliedAnchorRevision = npcData.dcAnchorRevision
    end

    npcData.dcGuardPostIndex = postIndex
    local currentPost = posts[postIndex]
    if engageFromPost(zombie, npcData, currentPost) then
        return
    end

    local dx = zombie:getX() - currentPost.x
    local dy = zombie:getY() - currentPost.y
    local distSq = (dx * dx) + (dy * dy)
    if distSq <= (STOP_DISTANCE * STOP_DISTANCE) then
        stopMovement(zombie)
        zombie:faceLocation(currentPost.x, currentPost.y)
        if not alert and #posts > 1 then
            npcData.dcGuardPostIndex = (postIndex % #posts) + 1
        end
        return
    end

    applyPatrolPost(npcData, currentPost)
    moveToPoint(zombie, npcData, currentPost)
end
