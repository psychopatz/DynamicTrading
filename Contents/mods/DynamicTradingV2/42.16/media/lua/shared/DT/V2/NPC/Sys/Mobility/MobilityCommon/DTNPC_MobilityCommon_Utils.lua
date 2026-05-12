-- ==============================================================================
-- DTNPC_MobilityCommon_Utils.lua
-- Shared mobility utility helpers.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

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
            getX = function()
                return originX
            end,
            getY = function()
                return originY
            end,
            getZ = function()
                return originZ
            end,
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
        dtWalkType = options.dtWalkType ~= nil and tostring(options.dtWalkType) or nil,
        walkType = options.walkType ~= nil and tostring(options.walkType) or nil,
        profileKey = options.profileKey ~= nil and tostring(options.profileKey) or nil,
    }
end

function Internal.resetMovementProgress(npcData)
    if type(npcData) ~= "table" then
        return
    end

    npcData._dtMoveProgress = nil
    npcData._dtNoProgressTicks = 0
end
