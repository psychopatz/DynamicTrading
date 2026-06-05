DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime"
require "DT/V2/NPC/Sys/CorpseCleanup/DTNPC_CorpseCleanup"

local MOVE_SPEED = 0.036
local STOP_DISTANCE = 0.6
local CLEANUP_DWELL_MS = 900

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
        speed = MOVE_SPEED,
        navigationMode = "planned",
        plannerProfile = "colony",
        staminaMode = "corpse_cleanup",
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

local function floorNumber(value)
    if tonumber(value) == nil then
        return nil
    end
    return math.floor(tonumber(value) or 0)
end

local function clearTask(npcData)
    if not npcData then
        return
    end

    npcData.dcCorpseCleanupTask = nil
    npcData.dcCorpsePickupStartMs = nil
    npcData.dcCorpseWorkAnimActive = nil
end

local function resolveResumeState(npcData, fallback)
    local resumeState = tostring(npcData and npcData.returnHomeResumeState or "")
    if resumeState ~= "" and resumeState ~= "ReturnHome" then
        return resumeState
    end

    if DTNPCRoles and DTNPCRoles.ResolveDefaultState then
        return DTNPCRoles.ResolveDefaultState(npcData)
    end

    return fallback or "Idle"
end

local function abortTask(zombie, npcData)
    local task = type(npcData and npcData.dcCorpseCleanupTask) == "table" and npcData.dcCorpseCleanupTask or nil
    stopWorkAnim(zombie, npcData)
    if task and DTNPCCorpseCleanup and DTNPCCorpseCleanup.AbortTask then
        DTNPCCorpseCleanup.AbortTask(npcData, task, zombie)
    end
    clearTask(npcData)
end

function DTNPCLogic.RunCorpseCleanupBehavior(zombie, npcData, options)
    options = type(options) == "table" and options or {}
    if not zombie or not npcData then
        return
    end

    local policyMode = options.policyMode or (options.colony == true and "colony" or nil)
    if options.colony == true and not DTNPCColonyRuntime.IsLinkedResident(npcData) then
        if DTNPCLogic.Behaviors["PlayerZone"] then
            DTNPCLogic.Behaviors["PlayerZone"](zombie, npcData)
        end
        return
    end

    if options.colony == true then
        local desiredState = DTNPCColonyRuntime.SyncBehaviorIdentity(npcData)
        if desiredState ~= "ColonyCorpseRemoval" then
            abortTask(zombie, npcData)
            npcData.state = desiredState
            syncStateChange(zombie, npcData)
            return
        end
    elseif DTNPCCorpseCleanup.CanAutonomousCleanup(npcData) ~= true then
        abortTask(zombie, npcData)
        npcData.state = resolveResumeState(npcData, "Idle")
        syncStateChange(zombie, npcData)
        return
    end

    local anchorPoint = DTNPCCorpseCleanup.GetCleanupAnchor(npcData, {
        mode = policyMode,
    })

    local task = type(npcData.dcCorpseCleanupTask) == "table" and npcData.dcCorpseCleanupTask or nil
    if not task and DTNPCCorpseCleanup.AcquireTask then
        task = DTNPCCorpseCleanup.AcquireTask(npcData, {
            mode = policyMode,
        })
        npcData.dcCorpseCleanupTask = task
    end

    if not task then
        stopWorkAnim(zombie, npcData)
        stopMovement(zombie)
        if anchorPoint then
            zombie:faceLocation(anchorPoint.x, anchorPoint.y)
        end
        if options.colony ~= true then
            npcData.state = resolveResumeState(npcData, "Idle")
            syncStateChange(zombie, npcData)
        end
        return
    end

    if DTNPCCorpseCleanup.RefreshTask then
        DTNPCCorpseCleanup.RefreshTask(npcData, task, zombie)
    end

    if task.phase == "to_source" and type(task.source) == "table" then
        local dx = zombie:getX() - task.source.x
        local dy = zombie:getY() - task.source.y
        local distSq = (dx * dx) + (dy * dy)
        if distSq <= (STOP_DISTANCE * STOP_DISTANCE) then
            stopMovement(zombie)
            zombie:faceLocation(task.source.x, task.source.y)
            local startedAt = floorNumber(npcData.dcCorpsePickupStartMs) or 0
            if startedAt <= 0 then
                npcData.dcCorpsePickupStartMs = getTimeInMillis and getTimeInMillis() or 0
                startWorkAnim(zombie, npcData)
                return
            end

            startWorkAnim(zombie, npcData)
            if ((getTimeInMillis and getTimeInMillis() or 0) - startedAt) < CLEANUP_DWELL_MS then
                return
            end

            stopWorkAnim(zombie, npcData)
            local ok = DTNPCCorpseCleanup.CommitTask and DTNPCCorpseCleanup.CommitTask(npcData, task, zombie) or false
            clearTask(npcData)
            if options.colony == true then
                stopMovement(zombie)
                return
            end

            npcData.state = resolveResumeState(npcData, ok == true and "Idle" or "Idle")
            syncStateChange(zombie, npcData)
            return
        end

        npcData.dcCorpsePickupStartMs = nil
        stopWorkAnim(zombie, npcData)
        moveToPoint(zombie, npcData, task.source)
        return
    end

    abortTask(zombie, npcData)
    if options.colony ~= true then
        npcData.state = resolveResumeState(npcData, "Idle")
        syncStateChange(zombie, npcData)
    end
end

DTNPCLogic.Behaviors["CorpseCleanup"] = function(zombie, npcData)
    DTNPCLogic.RunCorpseCleanupBehavior(zombie, npcData, {
        policyMode = "ai",
    })
end

return DTNPCLogic
