-- ==============================================================================
-- DTNPC_Mobility.lua
-- Shared helpers for simulated NPC locomotion, animation state, and unsticking.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local function getTimeMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end

    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

local function getAnimSpeed(options)
    if options and options.animSpeed ~= nil then
        return math.max(0, tonumber(options.animSpeed) or 0)
    end

    if options and options.crawl == true then
        return 0.28
    end

    return options and options.isRunning == true and 1.2 or 1.0
end

function DTNPCMobility.IsTileSafe(x, y, z)
    local cell = getCell()
    local square = cell and cell:getGridSquare(x, y, z) or nil
    if not square then
        return true
    end
    if not square:isFree(false) then
        return false
    end
    if square:isSolid() or square:isSolidTrans() then
        return false
    end
    return true
end

function DTNPCMobility.SetLocomotionState(zombie, options)
    if not zombie then
        return
    end

    options = type(options) == "table" and options or {}
    local moving = options.moving == true

    if options.idleState ~= nil then
        zombie:setVariable("DTIdleState", tostring(options.idleState))
    elseif moving then
        zombie:setVariable("DTIdleState", "0")
    end

    if options.crawl ~= nil then
        zombie:setVariable("bBecomeCrawler", options.crawl == true)
        zombie:setVariable("bCrawling", options.crawl == true)
    elseif moving ~= true then
        zombie:setVariable("bBecomeCrawler", false)
        zombie:setVariable("bCrawling", false)
    end

    zombie:setVariable("bMoving", moving)
    zombie:setVariable("isMoving", moving)

    if options.walkType ~= nil then
        zombie:setVariable("WalkType", tostring(options.walkType))
    elseif moving and options.crawl ~= true then
        zombie:setVariable("WalkType", "1")
    end
    if options.dtWalkType ~= nil then
        zombie:setVariable("DTWalkType", tostring(options.dtWalkType))
    end

    zombie:setVariable("Speed", moving and getAnimSpeed(options) or 0.0)
    zombie:setRunning(moving and options.isRunning == true or false)
end

function DTNPCMobility.Stop(zombie, options)
    options = type(options) == "table" and options or {}
    options.moving = false
    DTNPCMobility.SetLocomotionState(zombie, options)
end

local function rememberMotion(npcData, fromX, fromY, toX, toY, options)
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
        startedAt = getTimeMs(),
        durationMs = math.max(40, math.floor((math.max(0.001, tonumber(options.speed) or 0.04) / 0.04) * 70)),
        crawl = options.crawl == true,
        running = options.isRunning == true,
    }
end

local function clearBlockedCounter(npcData, key)
    if type(npcData) == "table" and key then
        npcData[key] = 0
    end
end

local function incrementBlockedCounter(npcData, key)
    if type(npcData) ~= "table" or not key then
        return 0
    end

    npcData[key] = (tonumber(npcData[key]) or 0) + 1
    return npcData[key]
end

local function tryUnstick(zombie, z, dirX, dirY)
    if not zombie then
        return false, nil, nil
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local candidates = {
        { x = zx + (dirX * 1.5), y = zy + (dirY * 1.5) },
        { x = zx + (dirX * 1.5) - dirY, y = zy + (dirY * 1.5) + dirX },
        { x = zx + (dirX * 1.5) + dirY, y = zy + (dirY * 1.5) - dirX },
        { x = zx - dirY, y = zy + dirX },
        { x = zx + dirY, y = zy - dirX },
    }

    for i = 1, #candidates do
        local candidate = candidates[i]
        if DTNPCMobility.IsTileSafe(candidate.x, candidate.y, z) then
            zombie:setX(candidate.x)
            zombie:setY(candidate.y)
            zombie:setZ(z)
            return true, candidate.x, candidate.y
        end
    end

    return false, nil, nil
end

local function isWithinLeash(nextX, nextY, currentZ, options)
    options = type(options) == "table" and options or {}
    local anchorX = tonumber(options.anchorX)
    local anchorY = tonumber(options.anchorY)
    local leashRadius = tonumber(options.leashRadius)

    if anchorX == nil or anchorY == nil or leashRadius == nil then
        return true
    end

    local anchorZ = tonumber(options.anchorZ)
    local leashFloor = anchorZ ~= nil and anchorZ or currentZ
    if math.abs((currentZ or 0) - leashFloor) > 1.1 then
        return false
    end

    local dx = nextX - anchorX
    local dy = nextY - anchorY
    return math.sqrt((dx * dx) + (dy * dy)) <= leashRadius
end

function DTNPCMobility.MoveByDirection(zombie, npcData, options)
    if not zombie then
        return false, "invalid"
    end

    options = type(options) == "table" and options or {}

    local dirX = tonumber(options.dirX) or 0
    local dirY = tonumber(options.dirY) or 0
    local len = math.sqrt((dirX * dirX) + (dirY * dirY))
    if len <= 0.001 then
        DTNPCMobility.Stop(zombie, options.anim)
        return false, "no_direction"
    end

    dirX = dirX / len
    dirY = dirY / len

    local step = math.max(0, tonumber(options.speed) or 0)
    if step <= 0.001 then
        DTNPCMobility.Stop(zombie, options.anim)
        return false, "stopped"
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local nextX = zx + (dirX * step)
    local nextY = zy + (dirY * step)

    if not isWithinLeash(nextX, nextY, zz, options) then
        DTNPCMobility.Stop(zombie, options.anim)
        return false, "leash"
    end

    local canMove = DTNPCMobility.IsTileSafe(nextX, nextY, zz)
    if not canMove and options.allowAxisSlide ~= false then
        if isWithinLeash(nextX, zy, zz, options) and DTNPCMobility.IsTileSafe(nextX, zy, zz) then
            nextY = zy
            canMove = true
        elseif isWithinLeash(zx, nextY, zz, options) and DTNPCMobility.IsTileSafe(zx, nextY, zz) then
            nextX = zx
            canMove = true
        end
    end

    if canMove then
        clearBlockedCounter(npcData, options.blockCounterKey)
        zombie:setX(nextX)
        zombie:setY(nextY)
        if options.targetZ ~= nil then
            zombie:setZ(options.targetZ)
        end

        DTNPCMobility.SetLocomotionState(zombie, {
            moving = true,
            isRunning = options.anim and options.anim.isRunning == true,
            animSpeed = options.anim and options.anim.animSpeed or nil,
            walkType = options.anim and options.anim.walkType or nil,
            dtWalkType = options.anim and options.anim.dtWalkType or nil,
            idleState = options.anim and options.anim.idleState or nil,
            crawl = options.anim and options.anim.crawl == true or false,
        })

        local faceX = tonumber(options.faceX)
        local faceY = tonumber(options.faceY)
        if options.faceTargetWhileMoving == true and faceX ~= nil and faceY ~= nil then
            zombie:faceLocation(faceX, faceY)
        else
            zombie:faceLocation(nextX + dirX, nextY + dirY)
        end

        rememberMotion(npcData, zx, zy, nextX, nextY, {
            speed = step,
            crawl = options.anim and options.anim.crawl == true or false,
            isRunning = options.anim and options.anim.isRunning == true or false,
        })
        if type(npcData) == "table" then
            npcData._dtLastMoveDirX = dirX
            npcData._dtLastMoveDirY = dirY
        end
        return true, "moving"
    end

    local blockedTicks = incrementBlockedCounter(npcData, options.blockCounterKey)
    local stuckTicks = math.max(0, tonumber(options.stuckTicks) or 0)
    if blockedTicks >= stuckTicks and stuckTicks > 0 then
        local unstuck, unstuckX, unstuckY = tryUnstick(zombie, zz, dirX, dirY)
        if unstuck then
            clearBlockedCounter(npcData, options.blockCounterKey)
            DTNPCMobility.SetLocomotionState(zombie, {
                moving = true,
                isRunning = options.anim and options.anim.isRunning == true,
                animSpeed = options.anim and options.anim.animSpeed or nil,
                walkType = options.anim and options.anim.walkType or nil,
                dtWalkType = options.anim and options.anim.dtWalkType or nil,
                idleState = options.anim and options.anim.idleState or nil,
                crawl = options.anim and options.anim.crawl == true or false,
            })
            zombie:faceLocation(unstuckX + dirX, unstuckY + dirY)
            rememberMotion(npcData, zx, zy, unstuckX, unstuckY, {
                speed = step,
                crawl = options.anim and options.anim.crawl == true or false,
                isRunning = options.anim and options.anim.isRunning == true or false,
            })
            if type(npcData) == "table" then
                npcData._dtLastMoveDirX = dirX
                npcData._dtLastMoveDirY = dirY
            end
            return true, "unstuck"
        end
    end

    DTNPCMobility.Stop(zombie, options.anim)
    return false, "blocked"
end

function DTNPCMobility.MoveTowardTarget(zombie, npcData, options)
    if not zombie then
        return false, "invalid", 9999
    end

    options = type(options) == "table" and options or {}
    local target = options.target
    if not target or not target.getX or not target.getY then
        DTNPCMobility.Stop(zombie, options.anim)
        return false, "invalid_target", 9999
    end

    local zx, zy = zombie:getX(), zombie:getY()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    local stopDistance = math.max(0, tonumber(options.stopDistance) or 0)

    if len <= 0.001 or len <= stopDistance then
        DTNPCMobility.Stop(zombie, options.anim)
        return true, "arrived", len
    end

    local step = math.min(math.max(0, tonumber(options.speed) or 0), math.max(0, len - stopDistance))
    if step <= 0.001 then
        DTNPCMobility.Stop(zombie, options.anim)
        return true, "arrived", len
    end

    local moved, state = DTNPCMobility.MoveByDirection(zombie, npcData, {
        dirX = dx,
        dirY = dy,
        speed = step,
        allowAxisSlide = options.allowAxisSlide ~= false,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.stuckTicks,
        anim = options.anim,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        targetZ = options.targetZ,
        faceX = options.faceX,
        faceY = options.faceY,
    })

    if not moved and len <= (stopDistance + 0.35) then
        DTNPCMobility.Stop(zombie, options.anim)
        return true, "close_enough", len
    end

    return moved, state, len
end

function DTNPCMobility.MoveAwayFromPoint(zombie, npcData, options)
    if not zombie then
        return false, "invalid", 9999
    end

    options = type(options) == "table" and options or {}
    local fromX = tonumber(options.fromX)
    local fromY = tonumber(options.fromY)
    if fromX == nil or fromY == nil then
        local target = options.target
        if target and target.getX and target.getY then
            fromX = target:getX()
            fromY = target:getY()
        end
    end
    if fromX == nil or fromY == nil then
        DTNPCMobility.Stop(zombie, options.anim)
        return false, "invalid_target", 9999
    end

    local zx, zy = zombie:getX(), zombie:getY()
    local dx = zx - fromX
    local dy = zy - fromY
    local len = math.sqrt((dx * dx) + (dy * dy))
    local desiredDistance = math.max(0, tonumber(options.desiredDistance) or 0)

    if len >= desiredDistance then
        DTNPCMobility.Stop(zombie, options.anim)
        return true, "spaced", len
    end

    if len <= 0.001 then
        local cachedDirX = tonumber(npcData and npcData._dtLastMoveDirX) or 0
        local cachedDirY = tonumber(npcData and npcData._dtLastMoveDirY) or 0
        if math.abs(cachedDirX) > 0.001 or math.abs(cachedDirY) > 0.001 then
            dx = cachedDirX
            dy = cachedDirY
        else
            dx = ZombRandFloat(-1.0, 1.0)
            dy = ZombRandFloat(-1.0, 1.0)
        end
    end

    local step = math.min(math.max(0, tonumber(options.speed) or 0), math.max(0, desiredDistance - len))
    if step <= 0.001 then
        DTNPCMobility.Stop(zombie, options.anim)
        return true, "spaced", len
    end

    return DTNPCMobility.MoveByDirection(zombie, npcData, {
        dirX = dx,
        dirY = dy,
        speed = step,
        allowAxisSlide = options.allowAxisSlide ~= false,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.stuckTicks,
        anim = options.anim,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        targetZ = options.targetZ,
        faceX = options.faceX,
        faceY = options.faceY,
    })
end
