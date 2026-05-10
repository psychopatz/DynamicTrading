-- ==============================================================================
-- Behavior_AntiStuck.lua
-- Shared guarded recovery helpers for behaviors that need rare anti-stuck snaps.
-- ==============================================================================

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

DTNPCBehaviorAntiStuck = DTNPCBehaviorAntiStuck or {}

local AntiStuck = DTNPCBehaviorAntiStuck

local function getStateBucket(npcData, behaviorKey, create)
    if type(npcData) ~= "table" or not behaviorKey then
        return nil
    end

    local buckets = npcData._dtBehaviorAntiStuck
    if not buckets and create then
        buckets = {}
        npcData._dtBehaviorAntiStuck = buckets
    end
    if not buckets then
        return nil
    end

    local key = tostring(behaviorKey)
    local bucket = buckets[key]
    if not bucket and create then
        bucket = {}
        buckets[key] = bucket
    end
    return bucket
end

local function getDistance(x1, y1, x2, y2)
    local dx = (tonumber(x2) or 0) - (tonumber(x1) or 0)
    local dy = (tonumber(y2) or 0) - (tonumber(y1) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function resolveTarget(options)
    options = type(options) == "table" and options or {}

    local target = options.target
    if target and target.getX and target.getY then
        local targetZ = target.getZ and target:getZ() or options.targetZ
        return target:getX(), target:getY(), targetZ
    end

    return tonumber(options.targetX), tonumber(options.targetY), tonumber(options.targetZ)
end

local function appendCandidate(candidates, x, y)
    if x == nil or y == nil then
        return
    end

    for i = 1, #candidates do
        local existing = candidates[i]
        if math.abs(existing.x - x) <= 0.05 and math.abs(existing.y - y) <= 0.05 then
            return
        end
    end

    candidates[#candidates + 1] = { x = x, y = y }
end

local function buildCandidates(zombie, targetX, targetY, options)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local dx = targetX - zx
    local dy = targetY - zy
    local len = math.sqrt((dx * dx) + (dy * dy))

    if len <= 0.001 then
        dx = tonumber(options and options.fallbackDirX) or 1
        dy = tonumber(options and options.fallbackDirY) or 0
        len = math.sqrt((dx * dx) + (dy * dy))
    end

    if len <= 0.001 then
        dx = 1
        dy = 0
        len = 1
    end

    dx = dx / len
    dy = dy / len

    local arrivalRadius = math.max(0.45, tonumber(options and options.arrivalRadius) or 1.0)
    local radii = type(options and options.radii) == "table" and options.radii
        or { arrivalRadius, arrivalRadius + 0.55, arrivalRadius + 1.1 }
    local sideScale = math.max(0.5, tonumber(options and options.sideScale) or 0.7)
    local candidates = {}

    for i = 1, #radii do
        local radius = math.max(0.2, tonumber(radii[i]) or arrivalRadius)
        local side = radius * sideScale

        appendCandidate(candidates, targetX - (dx * radius), targetY - (dy * radius))
        appendCandidate(candidates, targetX - (dx * radius) - (dy * side), targetY - (dy * radius) + (dx * side))
        appendCandidate(candidates, targetX - (dx * radius) + (dy * side), targetY - (dy * radius) - (dx * side))
        appendCandidate(candidates, targetX + (dy * radius), targetY - (dx * radius))
        appendCandidate(candidates, targetX - (dy * radius), targetY + (dx * radius))
        appendCandidate(candidates, targetX + (dx * radius), targetY + (dy * radius))
    end

    if options and options.allowExactTarget == true then
        appendCandidate(candidates, targetX, targetY)
    end

    return candidates
end

function AntiStuck.Reset(npcData, behaviorKey)
    if type(npcData) ~= "table" or not behaviorKey then
        return
    end

    local buckets = npcData._dtBehaviorAntiStuck
    if not buckets then
        return
    end

    buckets[tostring(behaviorKey)] = nil
end

function AntiStuck.TryRecover(zombie, npcData, options)
    if not zombie or type(npcData) ~= "table" then
        return false, "invalid"
    end

    options = type(options) == "table" and options or {}
    local behaviorKey = tostring(options.behaviorKey or options.key or "default")
    local bucket = getStateBucket(npcData, behaviorKey, true)
    bucket.tick = (bucket.tick or 0) + 1

    local targetX, targetY, targetZ = resolveTarget(options)
    if targetX == nil or targetY == nil then
        return false, "no_target"
    end

    local currentDist = tonumber(options.currentDist) or getDistance(zombie:getX(), zombie:getY(), targetX, targetY)
    local targetMoveResetDistance = math.max(0, tonumber(options.targetMoveResetDistance) or 2.5)
    if bucket.lastTargetX ~= nil and bucket.lastTargetY ~= nil then
        local targetShift = getDistance(bucket.lastTargetX, bucket.lastTargetY, targetX, targetY)
        if targetShift >= targetMoveResetDistance then
            bucket.stallTicks = 0
            bucket.blockedTicks = 0
        end
    end
    bucket.lastTargetX = targetX
    bucket.lastTargetY = targetY
    bucket.lastTargetZ = targetZ

    local progressEpsilon = math.max(0.01, tonumber(options.progressEpsilon) or 0.15)
    local madeProgress = false
    if bucket.lastDistance ~= nil and (bucket.lastDistance - currentDist) > progressEpsilon then
        madeProgress = true
    end
    bucket.lastDistance = currentDist

    local moveState = tostring(options.moveState or "")
    local moved = options.moved == true
    local interacted = string.find(moveState, "interacted_", 1, true) ~= nil
    local successful = moved
        or moveState == "moving"
        or moveState == "unstuck"
        or moveState == "arrived"
        or moveState == "close_enough"
        or moveState == "special_action"
        or moveState == "exhausted"
        or moveState == "damage_retreat"

    if successful or interacted or madeProgress then
        bucket.stallTicks = 0
        bucket.blockedTicks = 0
        return false, successful and "moving" or "progress"
    end

    local blockedTicks = math.max(
        0,
        tonumber(options.blockedTicks)
            or tonumber(options.blockCounterKey and npcData[options.blockCounterKey])
            or 0
    )
    local isBlocked = blockedTicks > 0 or moveState == "blocked"
    if isBlocked then
        bucket.blockedTicks = (bucket.blockedTicks or 0) + 1
    else
        bucket.blockedTicks = 0
    end
    bucket.stallTicks = (bucket.stallTicks or 0) + 1

    local recoveries = math.max(0, tonumber(bucket.recoveries) or 0)
    local maxRecoveries = math.max(0, tonumber(options.maxRecoveries) or 1)
    if maxRecoveries > 0 and recoveries >= maxRecoveries then
        return false, "limit"
    end

    local cooldownTicks = math.max(0, tonumber(options.cooldownTicks) or 0)
    local lastRecoverTick = tonumber(bucket.lastRecoverTick) or -999999
    if (bucket.tick - lastRecoverTick) < cooldownTicks then
        return false, "cooldown"
    end

    local floorDelta = math.abs((tonumber(targetZ) or zombie:getZ()) - (zombie:getZ() or 0))
    local minDistance = math.max(0, tonumber(options.minDistance) or 0)
    local blockedThreshold = math.max(0, tonumber(options.blockedThreshold) or 0)
    local stallThreshold = math.max(blockedThreshold, tonumber(options.stallThreshold) or blockedThreshold)
    local hardBlockedThreshold = math.max(blockedThreshold, tonumber(options.hardBlockedThreshold) or blockedThreshold)
    local farDistance = tonumber(options.farDistance)
    local farStallThreshold = math.max(0, tonumber(options.farStallThreshold) or stallThreshold)

    local confirmed = false
    if hardBlockedThreshold > 0
        and blockedTicks >= hardBlockedThreshold
        and (currentDist >= minDistance or floorDelta > 0.1) then
        confirmed = true
    elseif blockedThreshold > 0
        and blockedTicks >= blockedThreshold
        and (bucket.stallTicks or 0) >= stallThreshold
        and (currentDist >= minDistance or floorDelta > 0.1) then
        confirmed = true
    elseif farDistance
        and currentDist >= farDistance
        and (bucket.stallTicks or 0) >= farStallThreshold then
        confirmed = true
    end

    if not confirmed then
        return false, "pending"
    end

    local candidates = buildCandidates(zombie, targetX, targetY, options)
    local targetFloor = tonumber(targetZ) or zombie:getZ()
    local faceX = tonumber(options.faceX) or targetX
    local faceY = tonumber(options.faceY) or targetY

    for i = 1, #candidates do
        local candidate = candidates[i]
        if DTNPCMobility.IsTileSafe(candidate.x, candidate.y, targetFloor) then
            zombie:setX(candidate.x)
            zombie:setY(candidate.y)
            zombie:setZ(targetFloor)
            DTNPCMobility.Stop(zombie)
            zombie:faceLocation(faceX, faceY)

            if options.blockCounterKey then
                npcData[options.blockCounterKey] = 0
            end

            bucket.lastRecoverTick = bucket.tick
            bucket.recoveries = recoveries + 1
            bucket.stallTicks = 0
            bucket.blockedTicks = 0
            bucket.lastDistance = getDistance(candidate.x, candidate.y, targetX, targetY)
            return true, "recovered"
        end
    end

    return false, "no_safe_spot"
end
