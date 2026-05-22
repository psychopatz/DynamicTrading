-- ==============================================================================
-- Behavior_ColonyCorpseRemoval.lua
-- Colony resident behavior that collects corpses from inside the base and
-- relocates them to the configured corpse dump zone.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime"

local MOVE_SPEED = 0.036
local HAUL_SPEED = 0.031
local STOP_DISTANCE = 0.6
local PICKUP_DWELL_MS = 900
local DROPOFF_DWELL_MS = 650

local function floorNumber(value)
    if tonumber(value) == nil then
        return nil
    end
    return math.floor(tonumber(value) or 0)
end

local function createPointTarget(point)
    if type(point) ~= "table" then
        return nil
    end

    return {
        getX = function()
            return point.x
        end,
        getY = function()
            return point.y
        end,
        getZ = function()
            return point.z or 0
        end,
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

local function stopWorkAnim(zombie, npcData)
    if not zombie then
        return
    end

    zombie:setVariable("LootPosition", "")
    if type(npcData) == "table" then
        npcData.dcCorpseWorkAnimActive = nil
    end
end

local function startWorkAnim(zombie, npcData)
    if not zombie or type(npcData) ~= "table" then
        return
    end

    if npcData.dcCorpseWorkAnimActive == true then
        return
    end

    npcData.dcCorpseWorkAnimActive = true
    zombie:setVariable("LootPosition", "Low")
    if zombie.reportEvent then
        zombie:reportEvent("EventLootItem")
    end
end

local function moveToPoint(zombie, npcData, point, speed)
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
        speed = speed or MOVE_SPEED,
        navigationMode = "planned",
        plannerProfile = "colony",
        staminaMode = "colony_corpse_removal",
        desiredRun = false,
        stopDistance = STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "dcCorpseBlockedTicks",
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
        npcData.dcCorpseBlockedTicks = 0
        return true, moveState
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData.dcCorpseBlockedTicks = 0
        return true, moveState
    end

    stopMovement(zombie)
    return false, moveState
end

local function shouldAlertFromLocalThreat(zombie, npcData, targetPoint)
    if not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return false
    end
    if not DTNPCColonyRuntime.ShouldSenseThreat(npcData, 1000) then
        return false
    end

    local anchorTarget = createPointTarget(targetPoint or {
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
    })
    local target = DTNPCProtect.SelectNearestThreat(zombie, npcData, 10, anchorTarget, 10, true)
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    if not target then
        return false
    end

    DTNPCColonyRuntime.RaiseAlert(npcData, {
        source = "ColonyCorpseRemoval",
        reason = "local_threat",
        target = target,
    })
    DTNPCColonyRuntime.PushAlertNotice(zombie, npcData, "civilian", target)
    return true
end

local function clearTask(npcData)
    if not npcData then
        return
    end

    npcData.dcCorpseRemovalTask = nil
    npcData.dcCorpsePickupStartMs = nil
    npcData.dcCorpseDropStartMs = nil
    npcData.dcCorpseWorkAnimActive = nil
end

local function abortTask(zombie, npcData)
    local task = type(npcData and npcData.dcCorpseRemovalTask) == "table" and npcData.dcCorpseRemovalTask or nil
    stopWorkAnim(zombie, npcData)
    if task and DTNPCColonyRuntime.AbortCorpseRemovalTask then
        DTNPCColonyRuntime.AbortCorpseRemovalTask(npcData, task, {
            x = zombie:getX(),
            y = zombie:getY(),
            z = zombie:getZ(),
        })
    end
    clearTask(npcData)
end

DTNPCLogic.Behaviors["ColonyCorpseRemoval"] = function(zombie, npcData)
    if not zombie or not npcData then
        return
    end

    if not DTNPCColonyRuntime.IsLinkedResident(npcData) then
        if DTNPCLogic.Behaviors["PlayerZone"] then
            DTNPCLogic.Behaviors["PlayerZone"](zombie, npcData)
        end
        return
    end

    local desiredState = DTNPCColonyRuntime.SyncBehaviorIdentity(npcData)
    if desiredState ~= "ColonyCorpseRemoval" then
        abortTask(zombie, npcData)
        npcData.state = desiredState
        syncStateChange(zombie, npcData)
        return
    end

    local dumpPoint = DTNPCColonyRuntime.GetCorpseDumpPoint and DTNPCColonyRuntime.GetCorpseDumpPoint(npcData) or DTNPCColonyRuntime.GetWorkPoint(npcData)
    local alert = DTNPCColonyRuntime.GetAlert(npcData)
    if alert or shouldAlertFromLocalThreat(zombie, npcData, dumpPoint) then
        abortTask(zombie, npcData)
        npcData.state = "ColonyCower"
        syncStateChange(zombie, npcData)
        return
    end

    if not dumpPoint then
        abortTask(zombie, npcData)
        stopMovement(zombie)
        return
    end

    local task = type(npcData.dcCorpseRemovalTask) == "table" and npcData.dcCorpseRemovalTask or nil
    if not task and DTNPCColonyRuntime.AcquireCorpseRemovalTask then
        task = DTNPCColonyRuntime.AcquireCorpseRemovalTask(npcData)
        npcData.dcCorpseRemovalTask = task
    end

    if not task then
        stopWorkAnim(zombie, npcData)
        stopMovement(zombie)
        zombie:faceLocation(dumpPoint.x, dumpPoint.y)
        return
    end

    if task.phase == "to_source" and type(task.source) == "table" then
        if DTNPCColonyRuntime.RefreshCorpseRemovalTask then
            DTNPCColonyRuntime.RefreshCorpseRemovalTask(npcData, task, "claimed", zombie)
        end

        local dx = zombie:getX() - task.source.x
        local dy = zombie:getY() - task.source.y
        local distSq = (dx * dx) + (dy * dy)
        if distSq <= (STOP_DISTANCE * STOP_DISTANCE) then
            stopMovement(zombie)
            zombie:faceLocation(task.source.x, task.source.y)
            local pickupStartedAt = floorNumber(npcData.dcCorpsePickupStartMs) or 0
            if pickupStartedAt <= 0 then
                npcData.dcCorpsePickupStartMs = getTimeInMillis and getTimeInMillis() or 0
                startWorkAnim(zombie, npcData)
                return
            end

            startWorkAnim(zombie, npcData)
            if ((getTimeInMillis and getTimeInMillis() or 0) - pickupStartedAt) < PICKUP_DWELL_MS then
                return
            end

            npcData.dcCorpsePickupStartMs = nil
            stopWorkAnim(zombie, npcData)
            if DTNPCColonyRuntime.PickupCorpseRemovalTask and DTNPCColonyRuntime.PickupCorpseRemovalTask(npcData, task) then
                task.phase = "to_dump"
                return
            end

            clearTask(npcData)
            return
        end

        npcData.dcCorpsePickupStartMs = nil
        stopWorkAnim(zombie, npcData)
        moveToPoint(zombie, npcData, task.source, MOVE_SPEED)
        return
    end

    if task.phase == "to_dump" then
        stopWorkAnim(zombie, npcData)
        if DTNPCColonyRuntime.RefreshCorpseRemovalTask then
            DTNPCColonyRuntime.RefreshCorpseRemovalTask(npcData, task, "carried", zombie)
        end

        local dx = zombie:getX() - dumpPoint.x
        local dy = zombie:getY() - dumpPoint.y
        local distSq = (dx * dx) + (dy * dy)
        if distSq <= (STOP_DISTANCE * STOP_DISTANCE) then
            stopMovement(zombie)
            zombie:faceLocation(dumpPoint.x, dumpPoint.y)
            local dropStartedAt = floorNumber(npcData.dcCorpseDropStartMs) or 0
            if dropStartedAt <= 0 then
                npcData.dcCorpseDropStartMs = getTimeInMillis and getTimeInMillis() or 0
                return
            end

            if ((getTimeInMillis and getTimeInMillis() or 0) - dropStartedAt) < DROPOFF_DWELL_MS then
                return
            end

            npcData.dcCorpseDropStartMs = nil
            if DTNPCColonyRuntime.DropCorpseRemovalTask and DTNPCColonyRuntime.DropCorpseRemovalTask(npcData, task, dumpPoint, zombie) then
                clearTask(npcData)
                return
            end

            abortTask(zombie, npcData)
            return
        end

        npcData.dcCorpseDropStartMs = nil
        moveToPoint(zombie, npcData, dumpPoint, HAUL_SPEED)
        return
    end

    clearTask(npcData)
    stopWorkAnim(zombie, npcData)
    stopMovement(zombie)
end
