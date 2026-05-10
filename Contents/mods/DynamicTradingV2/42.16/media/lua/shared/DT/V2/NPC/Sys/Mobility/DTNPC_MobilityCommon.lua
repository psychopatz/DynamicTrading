-- ==============================================================================
-- DTNPC_MobilityCommon.lua
-- Shared constants and helpers for NPC mobility modules.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

Constants.DAMAGE_PRESSURE_WINDOW_MS = Constants.DAMAGE_PRESSURE_WINDOW_MS or 2500
Constants.DAMAGE_RETREAT_LOCK_MS = Constants.DAMAGE_RETREAT_LOCK_MS or 900
Constants.DAMAGE_RETREAT_DISTANCE = Constants.DAMAGE_RETREAT_DISTANCE or 2.2
Constants.DAMAGE_RETREAT_LOW_HEALTH_RATIO = Constants.DAMAGE_RETREAT_LOW_HEALTH_RATIO or 0.60
Constants.DAMAGE_RETREAT_ADJACENT_DIST = Constants.DAMAGE_RETREAT_ADJACENT_DIST or 1.2
Constants.BLOCKED_HEADING_MEMORY_MS = Constants.BLOCKED_HEADING_MEMORY_MS or 850
Constants.DEFAULT_STEERING_ANGLES = Constants.DEFAULT_STEERING_ANGLES or { 0, 30, -30, 60, -60, 90, -90 }
Constants.SPECIAL_ACTION_GRACE_MS = Constants.SPECIAL_ACTION_GRACE_MS or 120
Constants.MOVE_PROGRESS_EPSILON = Constants.MOVE_PROGRESS_EPSILON or 0.025
Constants.MOVE_PROGRESS_GOAL_EPSILON = Constants.MOVE_PROGRESS_GOAL_EPSILON or 0.04
Constants.MOVE_PROGRESS_STALL_TICKS = Constants.MOVE_PROGRESS_STALL_TICKS or 18
Constants.MOVE_PROGRESS_STALL_MS = Constants.MOVE_PROGRESS_STALL_MS or 900

function Internal.getTimeMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end

    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

function Internal.getAnimSpeed(options)
    if options and options.animSpeed ~= nil then
        return math.max(0, tonumber(options.animSpeed) or 0)
    end

    if options and options.crawl == true then
        return 0.28
    end

    return options and options.isRunning == true and 1.2 or 1.0
end

function Internal.getDistance(x1, y1, x2, y2)
    local dx = (tonumber(x2) or 0) - (tonumber(x1) or 0)
    local dy = (tonumber(y2) or 0) - (tonumber(y1) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

function Internal.getHealthRatio(npcData)
    if DTNPCHealth and DTNPCHealth.GetHealthRatio then
        return tonumber(DTNPCHealth.GetHealthRatio(npcData)) or 1
    end

    return 1
end

function Internal.getObjectRuntimeKey(object)
    if not object then
        return nil
    end

    if object.getOnlineID then
        local onlineID = object:getOnlineID()
        if onlineID and onlineID ~= 0 then
            return "online:" .. tostring(onlineID)
        end
    end

    if object.getUsername then
        local username = object:getUsername()
        if username and username ~= "" then
            return "user:" .. tostring(username)
        end
    end

    if object.getPersistentOutfitID then
        local outfitID = object:getPersistentOutfitID()
        if outfitID and outfitID ~= 0 then
            return "outfit:" .. tostring(outfitID)
        end
    end

    if object.getID then
        local objectID = object:getID()
        if objectID and objectID ~= 0 then
            return "id:" .. tostring(objectID)
        end
    end

    return tostring(object)
end

function Internal.getAttackerPosition(attackerID, fallbackX, fallbackY, fallbackZ)
    if not attackerID then
        return nil, nil
    end

    local zombieList = getCell() and getCell():getZombieList() or nil
    if not zombieList then
        return nil, nil
    end

    local floorZ = tonumber(fallbackZ) or 0
    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC)
                and math.abs((candidate:getZ() or 0) - floorZ) <= 1.1
                and Internal.getObjectRuntimeKey(candidate) == attackerID then
                return candidate:getX(), candidate:getY()
            end
        end
    end

    return nil, nil
end

function Internal.getNearbyZombiePressure(originX, originY, originZ, radius)
    if DTNPCProtect and DTNPCProtect.GetNearbyZombiePressure then
        local pressure = DTNPCProtect.GetNearbyZombiePressure({
            getX = function() return originX end,
            getY = function() return originY end,
            getZ = function() return originZ end,
        }, radius, nil)
        if pressure then
            return pressure
        end
    end

    local zombieList = getCell() and getCell():getZombieList() or nil
    local safeRadius = math.max(0.25, tonumber(radius) or 2.6)
    local radiusSq = safeRadius * safeRadius
    local count = 0
    local closest = 9999
    local weightedX = 0
    local weightedY = 0
    local totalWeight = 0

    if zombieList then
        for i = 0, zombieList:size() - 1 do
            local candidate = zombieList:get(i)
            if candidate and not candidate:isDead() then
                local modData = candidate:getModData()
                if not (modData and modData.IsDTNPC)
                    and math.abs((candidate:getZ() or 0) - (originZ or 0)) <= 1.1 then
                    local dx = candidate:getX() - originX
                    local dy = candidate:getY() - originY
                    local distSq = (dx * dx) + (dy * dy)
                    if distSq <= radiusSq then
                        local dist = math.sqrt(distSq)
                        local weight = 1 / math.max(0.25, dist)
                        count = count + 1
                        closest = math.min(closest, dist)
                        weightedX = weightedX + (candidate:getX() * weight)
                        weightedY = weightedY + (candidate:getY() * weight)
                        totalWeight = totalWeight + weight
                    end
                end
            end
        end
    end

    return {
        count = count,
        closest = closest,
        centerX = totalWeight > 0 and (weightedX / totalWeight) or originX,
        centerY = totalWeight > 0 and (weightedY / totalWeight) or originY,
    }
end

function Internal.rotateDirection(dirX, dirY, angleDegrees)
    local radians = math.rad(tonumber(angleDegrees) or 0)
    local cosAngle = math.cos(radians)
    local sinAngle = math.sin(radians)
    return (dirX * cosAngle) - (dirY * sinAngle), (dirX * sinAngle) + (dirY * cosAngle)
end

function Internal.setBlockedHeading(npcData, dirX, dirY)
    if type(npcData) ~= "table" then
        return
    end

    npcData._dtBlockedHeading = {
        x = tonumber(dirX) or 0,
        y = tonumber(dirY) or 0,
    }
    npcData._dtBlockedHeadingUntil = Internal.getTimeMs() + Constants.BLOCKED_HEADING_MEMORY_MS
end

function Internal.headingRepeatsBlocked(npcData, dirX, dirY)
    if type(npcData) ~= "table" then
        return false
    end

    local blocked = npcData._dtBlockedHeading
    local untilTime = tonumber(npcData._dtBlockedHeadingUntil) or 0
    if type(blocked) ~= "table" or untilTime <= 0 or Internal.getTimeMs() > untilTime then
        return false
    end

    local dot = ((tonumber(blocked.x) or 0) * (tonumber(dirX) or 0))
        + ((tonumber(blocked.y) or 0) * (tonumber(dirY) or 0))
    return dot >= 0.92
end

function Internal.safeCall(object, methodName, ...)
    if not object then
        return false, nil
    end

    local method = object[methodName]
    if type(method) ~= "function" then
        return false, nil
    end

    local ok, result = pcall(method, object, ...)
    if ok then
        return true, result
    end

    return false, nil
end

function Internal.rememberMotion(npcData, fromX, fromY, toX, toY, options)
    if type(npcData) ~= "table" then
        return
    end

    options = type(options) == "table" and options or {}
    local dx = (toX or fromX or 0) - (fromX or 0)
    local dy = (toY or fromY or 0) - (fromY or 0)

    npcData._dtMotionHint = {
        fromX = fromX,
        fromY = fromY,
        toX = toX,
        toY = toY,
        dirX = dx,
        dirY = dy,
        startedAt = Internal.getTimeMs(),
        durationMs = options.durationMs ~= nil
            and math.max(40, math.floor(tonumber(options.durationMs) or 40))
            or math.max(40, math.floor((math.max(0.001, tonumber(options.speed) or 0.04) / 0.04) * 70)),
        crawl = options.crawl == true,
        running = options.isRunning == true,
    }
end

function Internal.resetMovementProgress(npcData)
    if type(npcData) ~= "table" then
        return
    end

    npcData._dtMoveProgress = nil
    npcData._dtNoProgressTicks = 0
end

function Mobility.ResetMovementProgress(npcData)
    Internal.resetMovementProgress(npcData)
end

function Mobility.RecordMovementProgress(npcData, currentX, currentY, goalX, goalY, options)
    if type(npcData) ~= "table" then
        return nil
    end

    options = type(options) == "table" and options or {}
    if options.reset == true or options.attemptedMove ~= true then
        Internal.resetMovementProgress(npcData)
        return nil
    end

    local currentTime = Internal.getTimeMs()
    local progress = type(npcData._dtMoveProgress) == "table" and npcData._dtMoveProgress or {}
    local prevX = tonumber(progress.x)
    local prevY = tonumber(progress.y)
    local movedDist = nil
    if prevX ~= nil and prevY ~= nil then
        movedDist = Internal.getDistance(prevX, prevY, currentX, currentY)
    end

    local hasGoal = goalX ~= nil and goalY ~= nil
    local currentGoalDist = hasGoal and Internal.getDistance(currentX, currentY, goalX, goalY) or nil
    local bestGoalDist = tonumber(progress.bestGoalDist)
    local previousGoalX = tonumber(progress.goalX)
    local previousGoalY = tonumber(progress.goalY)
    local moveEpsilon = math.max(0.005, tonumber(options.moveEpsilon) or Constants.MOVE_PROGRESS_EPSILON)
    local goalEpsilon = math.max(0.01, tonumber(options.goalEpsilon) or Constants.MOVE_PROGRESS_GOAL_EPSILON)
    local targetShiftReset = math.max(0.2, tonumber(options.targetShiftResetDistance) or 0.75)
    local madeProgress = false

    if options.exempt == true then
        progress.noProgressTicks = 0
        progress.lastProgressAt = currentTime
        if currentGoalDist ~= nil then
            progress.bestGoalDist = currentGoalDist
            progress.goalDist = currentGoalDist
        end
    else
        local targetShift = nil
        if hasGoal and previousGoalX ~= nil and previousGoalY ~= nil then
            targetShift = Internal.getDistance(previousGoalX, previousGoalY, goalX, goalY)
        end
        if targetShift ~= nil and targetShift >= targetShiftReset then
            progress.noProgressTicks = 0
            progress.lastProgressAt = currentTime
            bestGoalDist = currentGoalDist
            progress.bestGoalDist = currentGoalDist
        end

        if movedDist ~= nil and movedDist > moveEpsilon then
            madeProgress = true
        elseif hasGoal and (bestGoalDist == nil or currentGoalDist < (bestGoalDist - goalEpsilon)) then
            madeProgress = true
            progress.bestGoalDist = currentGoalDist
        end

        if hasGoal then
            if progress.bestGoalDist == nil then
                progress.bestGoalDist = currentGoalDist
            end
            progress.goalDist = currentGoalDist
        end
    end

    if madeProgress then
        progress.noProgressTicks = 0
        progress.lastProgressAt = currentTime
    elseif options.exempt ~= true then
        progress.noProgressTicks = (tonumber(progress.noProgressTicks) or 0) + 1
    end

    progress.x = currentX
    progress.y = currentY
    progress.goalX = goalX
    progress.goalY = goalY
    progress.lastMoveAt = currentTime
    progress.moveDist = movedDist or 0
    npcData._dtMoveProgress = progress
    npcData._dtNoProgressTicks = tonumber(progress.noProgressTicks) or 0
    return progress
end

function Mobility.ShouldTriggerProgressRecovery(npcData, options)
    if type(npcData) ~= "table" then
        return false, nil
    end

    options = type(options) == "table" and options or {}
    local progress = type(npcData._dtMoveProgress) == "table" and npcData._dtMoveProgress or nil
    if not progress then
        return false, nil
    end

    local specialActive = Mobility.IsSpecialActionActive and Mobility.IsSpecialActionActive(npcData, "fence")
    if specialActive then
        return false, nil
    end

    local currentTime = Internal.getTimeMs()
    local noProgressTicks = math.max(0, tonumber(progress.noProgressTicks) or tonumber(npcData._dtNoProgressTicks) or 0)
    local lastProgressAt = tonumber(progress.lastProgressAt) or currentTime
    local stallTicks = math.max(0, tonumber(options.stallTicks) or Constants.MOVE_PROGRESS_STALL_TICKS)
    local stallMs = math.max(0, tonumber(options.stallMs) or Constants.MOVE_PROGRESS_STALL_MS)

    if stallTicks > 0 and noProgressTicks >= stallTicks then
        return true, "ticks"
    end
    if stallMs > 0 and (currentTime - lastProgressAt) >= stallMs then
        return true, "time"
    end

    return false, nil
end

function Mobility.ClearSpecialAction(npcData, expectedKind)
    if type(npcData) ~= "table" then
        return false
    end

    if expectedKind and npcData._dtSpecialAction ~= expectedKind then
        return false
    end

    npcData._dtSpecialAction = nil
    npcData._dtSpecialActionUntil = nil
    npcData._dtSpecialActionMode = nil
    return true
end

function Mobility.StartSpecialAction(npcData, kind, durationMs, options)
    if type(npcData) ~= "table" or not kind or kind == "" then
        return 0
    end

    options = type(options) == "table" and options or {}

    local currentTime = Internal.getTimeMs()
    local untilTime = currentTime + math.max(0, math.floor(tonumber(durationMs) or 0))
    npcData._dtSpecialAction = tostring(kind)
    npcData._dtSpecialActionUntil = untilTime
    npcData._dtSpecialActionMode = options.mode or nil
    npcData._dtSpecialActionSeq = (tonumber(npcData._dtSpecialActionSeq) or 0) + 1
    Internal.resetMovementProgress(npcData)
    if kind == "fence" then
        npcData._dtFenceActionSeq = (tonumber(npcData._dtFenceActionSeq) or 0) + 1
        npcData._dtFenceCooldownUntil = untilTime + math.max(180, tonumber(options.cooldownMs) or 320)
    end
    return untilTime
end

function Mobility.GetSpecialActionState(npcData)
    if type(npcData) ~= "table" then
        return nil, 0, nil
    end

    local kind = npcData._dtSpecialAction
    local untilTime = tonumber(npcData._dtSpecialActionUntil) or 0
    local currentTime = Internal.getTimeMs()
    if not kind or kind == "" or untilTime <= 0 then
        return nil, 0, nil
    end

    if currentTime >= (untilTime + Constants.SPECIAL_ACTION_GRACE_MS) then
        Mobility.ClearSpecialAction(npcData)
        return nil, 0, nil
    end

    return tostring(kind), untilTime, npcData._dtSpecialActionMode
end

function Mobility.IsSpecialActionActive(npcData, expectedKind)
    local kind, untilTime, mode = Mobility.GetSpecialActionState(npcData)
    if not kind then
        return false, nil, 0
    end
    if expectedKind and kind ~= expectedKind then
        return false, mode, untilTime
    end
    return true, mode, untilTime
end

function Internal.clearBlockedCounter(npcData, key)
    if type(npcData) == "table" and key then
        npcData[key] = 0
    end
end

function Internal.incrementBlockedCounter(npcData, key)
    if type(npcData) ~= "table" or not key then
        return 0
    end

    npcData[key] = (tonumber(npcData[key]) or 0) + 1
    return npcData[key]
end
