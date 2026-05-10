-- ==============================================================================
-- DTNPC_MobilityPassages.lua
-- Door and window traversal helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

local function callObjectMethod(object, names, ...)
    if not object then
        return false, nil
    end

    for i = 1, #names do
        local method = object[names[i]]
        if type(method) == "function" then
            local ok, result = pcall(method, object, ...)
            if ok then
                return true, result
            end
        end
    end

    return false, nil
end

local function objectBool(object, names, defaultValue)
    local ok, result = callObjectMethod(object, names)
    if not ok then
        return defaultValue == true
    end
    return result == true
end

local function resetFenceAnimFinished(zombie)
    if not zombie then
        return
    end

    zombie:setVariable("BumpAnimFinished", false)
    zombie:setVariable("ClimbFenceFinished", false)
end

local function isFenceAnimFinished(zombie)
    if not zombie then
        return false
    end

    if zombie.getVariableBoolean and zombie:getVariableBoolean("BumpAnimFinished") == true then
        return true
    end

    local value = zombie.getVariableString and zombie:getVariableString("BumpAnimFinished") or ""
    value = string.lower(tostring(value or ""))
    return value == "true" or value == "1"
end

function Internal.getSquareAt(cell, x, y, z)
    if not cell then
        return nil
    end

    return cell:getGridSquare(math.floor(tonumber(x) or 0), math.floor(tonumber(y) or 0), math.floor(tonumber(z) or 0))
end

function Internal.getObjectSquare(object)
    return object and object.getSquare and object:getSquare() or nil
end

function Internal.getSquareCoords(square)
    if not square then
        return nil, nil, nil
    end

    return square.getX and square:getX() or nil,
        square.getY and square:getY() or nil,
        square.getZ and square:getZ() or nil
end

function Internal.isDoorLike(object)
    if not object then
        return false
    end
    if instanceof and instanceof(object, "IsoDoor") then
        return true
    end

    local ok, result = callObjectMethod(object, { "isDoor", "IsDoor" })
    return ok and result == true
end

function Internal.isWindowLike(object)
    return object and instanceof and instanceof(object, "IsoWindow") or false
end

function Internal.isObstacleLocked(object)
    local hasKeyLock, keyLock = callObjectMethod(object, { "getLockedByKey" })
    if hasKeyLock and keyLock ~= nil and keyLock ~= false and keyLock ~= 0 then
        return true
    end

    return objectBool(object, { "isLocked", "IsLocked" }, false)
        or objectBool(object, { "isBarricaded", "IsBarricaded" }, false)
end

local function tryUsePassageObject(zombie, object)
    if not object or Internal.isObstacleLocked(object) then
        return false, nil
    end

    local isOpen = objectBool(object, { "IsOpen", "isOpen" }, false)
    if Internal.isDoorLike(object) then
        if not isOpen then
            local ok = callObjectMethod(object, { "ToggleDoor", "toggleDoor" }, zombie)
            return ok == true, "door"
        end
        return false, nil
    end

    if Internal.isWindowLike(object) then
        if objectBool(object, { "isDestroyed", "IsDestroyed" }, false) then
            return false, nil
        end
        if not isOpen then
            local ok = callObjectMethod(object, { "ToggleWindow", "toggleWindow" }, zombie)
            return ok == true, "window"
        end
    end

    return false, nil
end

function Internal.getPassageKind(object)
    if Internal.isDoorLike(object) then
        return "door"
    end
    if Internal.isWindowLike(object) then
        return "window"
    end
    return nil
end

function Internal.isFenceLike(object)
    if not object then
        return false
    end

    local square = Internal.getObjectSquare(object)
    local properties = object.getProperties and object:getProperties() or nil
    local lowFence = properties and properties.get and properties:get("FenceTypeLow") or nil
    local tallFence = properties and properties.get and properties:get("FenceTypeHigh") or nil
    local hoppable = objectBool(object, { "isHoppable" }, false)
    local tallHoppable = objectBool(object, { "isTallHoppable" }, false)

    return lowFence ~= nil or tallFence ~= nil or hoppable or tallHoppable, square, tallFence ~= nil or tallHoppable
end

local function getFenceDirectionFlags(fromSquare, nextSquare)
    local fromX, fromY = Internal.getSquareCoords(fromSquare)
    local nextX, nextY = Internal.getSquareCoords(nextSquare)
    local dx = (nextX or fromX or 0) - (fromX or 0)
    local dy = (nextY or fromY or 0) - (fromY or 0)

    if math.abs(dy) >= math.abs(dx) then
        return true
    end
    return false
end

local function getDirectionalFenceObject(fromSquare, nextSquare)
    if not fromSquare or not nextSquare then
        return nil
    end

    local isNorthSouth = getFenceDirectionFlags(fromSquare, nextSquare)
    local squares = { fromSquare, nextSquare }
    for i = 1, #squares do
        local square = squares[i]
        local okWall, wall = callObjectMethod(square, { "getWall", "getHoppableThumpable" }, isNorthSouth)
        if okWall and wall then
            local isFence, _, isTall = Internal.isFenceLike(wall)
            if isFence then
                return wall, isTall
            end
        end

        local okHoppable, hoppable = callObjectMethod(square, { "getHoppableThumpable" }, isNorthSouth)
        if okHoppable and hoppable then
            local isFence, _, isTall = Internal.isFenceLike(hoppable)
            if isFence then
                return hoppable, isTall
            end
        end
    end

    return nil, false
end

function Mobility.FindFenceBetween(fromSquare, nextSquare)
    local object, isTall = getDirectionalFenceObject(fromSquare, nextSquare)
    if not object then
        return nil
    end

    local objectSquare = Internal.getObjectSquare(object) or fromSquare
    local x, y, z = Internal.getSquareCoords(objectSquare)
    return {
        object = object,
        kind = "fence",
        square = objectSquare,
        x = x,
        y = y,
        z = z,
        tall = isTall == true,
    }
end

local function getFencePendingKey(fence)
    if not fence then
        return nil
    end

    local objectKey = Internal.getObjectRuntimeKey and Internal.getObjectRuntimeKey(fence.object) or nil
    if objectKey and objectKey ~= "" then
        return "object:" .. tostring(objectKey)
    end

    return string.format(
        "square:%s:%s:%s:%s",
        tostring(fence.x or 0),
        tostring(fence.y or 0),
        tostring(fence.z or 0),
        fence.tall == true and "tall" or "low"
    )
end

local function setFenceReject(npcData, fenceKey, durationMs)
    if type(npcData) ~= "table" then
        return
    end

    npcData._dtFenceRejectKey = fenceKey
    npcData._dtFenceRejectUntil = Internal.getTimeMs() + math.max(120, math.floor(tonumber(durationMs) or 260))
end

local function isFenceRejected(npcData, fenceKey)
    if type(npcData) ~= "table" or not fenceKey then
        return false
    end

    local rejectUntil = tonumber(npcData._dtFenceRejectUntil) or 0
    if npcData._dtFenceRejectKey == fenceKey and rejectUntil > Internal.getTimeMs() then
        return true
    end

    return false
end

local function getProbeSquare(cell, originX, originY, originZ, dirX, dirY, distance)
    if not cell then
        return nil
    end

    return Internal.getSquareAt(
        cell,
        originX + ((tonumber(dirX) or 0) * (tonumber(distance) or 0)),
        originY + ((tonumber(dirY) or 0) * (tonumber(distance) or 0)),
        originZ
    )
end

local function resolveFenceLandingSquare(cell, fence, originX, originY, originZ, dirX, dirY)
    if not cell then
        return nil
    end

    local distances = { 1.45, 1.8, 2.15 }
    for i = 1, #distances do
        local landingSquare = getProbeSquare(cell, originX, originY, originZ, dirX, dirY, distances[i])
        if landingSquare then
            local lx, ly, lz = Internal.getSquareCoords(landingSquare)
            local worldX = lx ~= nil and (lx + 0.5) or nil
            local worldY = ly ~= nil and (ly + 0.5) or nil
            if worldX ~= nil and worldY ~= nil and Mobility.IsTileSafe(worldX, worldY, lz or originZ) then
                return landingSquare
            end
        end
    end

    return nil
end

function Mobility.FindFenceAhead(zombie, npcData, options)
    if not zombie or not Internal.getSquareAt then
        return nil
    end

    options = type(options) == "table" and options or {}
    local dirX = tonumber(options.dirX) or 0
    local dirY = tonumber(options.dirY) or 0
    local dirLen = math.sqrt((dirX * dirX) + (dirY * dirY))
    if dirLen <= 0.001 then
        return nil
    end

    dirX = dirX / dirLen
    dirY = dirY / dirLen

    local cell = options.cell or (getCell and getCell() or nil)
    local originX = tonumber(options.originX) or zombie:getX()
    local originY = tonumber(options.originY) or zombie:getY()
    local originZ = tonumber(options.originZ) or zombie:getZ()
    local fromSquare = options.fromSquare or Internal.getSquareAt(cell, originX, originY, originZ)
    if not cell or not fromSquare then
        return nil
    end

    local nearSquare = options.nearSquare or getProbeSquare(cell, originX, originY, originZ, dirX, dirY, 0.8)
    local midSquare = options.midSquare or getProbeSquare(cell, originX, originY, originZ, dirX, dirY, 1.15)
    local farSquare = options.farSquare or getProbeSquare(cell, originX, originY, originZ, dirX, dirY, 1.7)
    local fence = nil
    local fencePairs = {
        { fromSquare, midSquare },
        { nearSquare, farSquare },
        { fromSquare, farSquare },
    }

    for i = 1, #fencePairs do
        local pair = fencePairs[i]
        local left = pair[1]
        local right = pair[2]
        if left and right and left ~= right then
            fence = Mobility.FindFenceBetween(left, right)
            if fence then
                break
            end
        end
    end

    if not fence then
        return nil
    end

    fence.dirX = dirX
    fence.dirY = dirY
    fence.fromSquare = fromSquare
    fence.nearSquare = nearSquare
    fence.midSquare = midSquare
    fence.farSquare = farSquare
    fence.fenceKey = getFencePendingKey(fence)
    fence.landingSquare = resolveFenceLandingSquare(cell, fence, originX, originY, originZ, dirX, dirY)
    return fence
end

function Mobility.ShouldEngageFenceTraverse(zombie, npcData, fence, options)
    if not zombie or type(npcData) ~= "table" or not fence then
        return false, "invalid"
    end

    options = type(options) == "table" and options or {}
    local currentTime = Internal.getTimeMs()
    local cooldownUntil = tonumber(npcData._dtFenceCooldownUntil) or 0
    if cooldownUntil > 0 and currentTime < cooldownUntil then
        return false, "cooldown"
    end

    local fenceKey = fence.fenceKey or getFencePendingKey(fence)
    if isFenceRejected(npcData, fenceKey) then
        return false, "rejected"
    end

    local landingSquare = fence.landingSquare
    if not landingSquare then
        setFenceReject(npcData, fenceKey, 320)
        return false, "no_landing"
    end

    local landingX, landingY, landingZ = Internal.getSquareCoords(landingSquare)
    local landingWorldX = landingX ~= nil and (landingX + 0.5) or nil
    local landingWorldY = landingY ~= nil and (landingY + 0.5) or nil
    if landingWorldX == nil or landingWorldY == nil or not Mobility.IsTileSafe(landingWorldX, landingWorldY, landingZ or zombie:getZ()) then
        setFenceReject(npcData, fenceKey, 320)
        return false, "unsafe_landing"
    end
    if not Internal.isWithinLeash(landingWorldX, landingWorldY, landingZ or zombie:getZ(), options) then
        setFenceReject(npcData, fenceKey, 260)
        return false, "leash"
    end

    local fenceX = tonumber(fence.x)
    local fenceY = tonumber(fence.y)
    local fenceCenterX = fenceX ~= nil and (fenceX + 0.5) or zombie:getX()
    local fenceCenterY = fenceY ~= nil and (fenceY + 0.5) or zombie:getY()
    local engageDistance = tonumber(options.fenceEngageDistance) or (fence.tall == true and 1.18 or 1.05)
    if Internal.getDistance(zombie:getX(), zombie:getY(), fenceCenterX, fenceCenterY) > engageDistance then
        return false, "too_far"
    end

    local dirX = tonumber(fence.dirX) or tonumber(options.dirX) or 0
    local dirY = tonumber(fence.dirY) or tonumber(options.dirY) or 0
    local toLandingX = landingWorldX - zombie:getX()
    local toLandingY = landingWorldY - zombie:getY()
    local landingLen = math.sqrt((toLandingX * toLandingX) + (toLandingY * toLandingY))
    if landingLen <= 0.001 then
        setFenceReject(npcData, fenceKey, 220)
        return false, "no_delta"
    end

    local dot = ((toLandingX / landingLen) * dirX) + ((toLandingY / landingLen) * dirY)
    if dot < 0.25 then
        setFenceReject(npcData, fenceKey, 220)
        return false, "wrong_side"
    end

    return true, "ok"
end

function Mobility.BeginFenceTraverse(zombie, npcData, fence, options)
    if not zombie or type(npcData) ~= "table" or not fence then
        return false, nil
    end

    local allowed, reason = Mobility.ShouldEngageFenceTraverse(zombie, npcData, fence, options)
    if not allowed then
        return false, reason
    end

    options = type(options) == "table" and options or {}
    local landingSquare = fence.landingSquare
    local landingX, landingY, landingZ = Internal.getSquareCoords(landingSquare)
    local worldX = (landingX or zombie:getX()) + 0.5
    local worldY = (landingY or zombie:getY()) + 0.5
    local worldZ = landingZ or zombie:getZ()
    local currentTime = Internal.getTimeMs()
    local animName = fence.tall and "DTNPCClimbFenceTall" or "DTNPCClimbFence"
    local travelDurationMs = fence.tall and 900 or 600
    local finishHoldMs = fence.tall and 240 or 180
    local actionDurationMs = travelDurationMs + finishHoldMs

    npcData._dtFencePendingKey = fence.fenceKey or getFencePendingKey(fence)
    npcData._dtFencePendingAt = currentTime
    npcData._dtFenceRejectKey = nil
    npcData._dtFenceRejectUntil = nil

    if zombie.setTarget then
        zombie:setTarget(nil)
    end
    if zombie.setPath2 then
        zombie:setPath2(nil)
    end
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    if zombie.setRunning then
        zombie:setRunning(false)
    end
    resetFenceAnimFinished(zombie)
    zombie:faceLocation((tonumber(fence.x) or zombie:getX()) + 0.5, (tonumber(fence.y) or zombie:getY()) + 0.5)
    if zombie.setBumpType then
        zombie:setBumpType(animName)
    end

    npcData._dtFenceTraverse = {
        startX = zombie:getX(),
        startY = zombie:getY(),
        startZ = zombie:getZ(),
        endX = worldX,
        endY = worldY,
        endZ = worldZ,
        startedAt = currentTime,
        durationMs = actionDurationMs,
        travelDurationMs = travelDurationMs,
        finishHoldMs = finishHoldMs,
        bumpType = animName,
        tall = fence.tall == true,
        fenceKey = npcData._dtFencePendingKey,
    }

    npcData.isMovingState = false
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    Internal.rememberMotion(npcData, zombie:getX(), zombie:getY(), worldX, worldY, {
        speed = 0.085,
        isRunning = false,
        crawl = false,
        durationMs = travelDurationMs,
    })
    if Mobility.ResetMovementProgress then
        Mobility.ResetMovementProgress(npcData)
    end
    Mobility.StartSpecialAction(npcData, "fence", actionDurationMs, {
        mode = fence.tall and "tall" or "low",
        cooldownMs = fence.tall and 450 or 320,
    })
    return true, "fence"
end

local function findDirectionalPassageObject(fromSquare, nextSquare)
    if not fromSquare or not nextSquare then
        return nil
    end

    local directionalLookups = {
        { "getDoorTo", "getIsoDoorTo" },
        { "getWindowTo", "getWindowOrWindowThumpableTo", "getWindowThumpableTo" },
    }

    for i = 1, #directionalLookups do
        local ok, object = callObjectMethod(fromSquare, directionalLookups[i], nextSquare)
        if ok and object then
            return object
        end
    end

    return nil
end

function Mobility.FindDirectionalPassage(fromSquare, nextSquare)
    local directionalObject = findDirectionalPassageObject(fromSquare, nextSquare)
    if directionalObject then
        local kind = Internal.getPassageKind(directionalObject)
        if kind
            and not Internal.isObstacleLocked(directionalObject)
            and not objectBool(directionalObject, { "IsOpen", "isOpen" }, false)
            and not objectBool(directionalObject, { "isDestroyed", "IsDestroyed" }, false) then
            local objectSquare = Internal.getObjectSquare(directionalObject) or fromSquare
            local x, y, z = Internal.getSquareCoords(objectSquare)
            return {
                object = directionalObject,
                kind = kind,
                square = objectSquare,
                x = x,
                y = y,
                z = z,
            }
        end
    end

    local squares = {
        nextSquare,
        fromSquare,
    }

    for i = 1, #squares do
        local square = squares[i]
        local objects = square and square:getObjects() or nil
        if objects then
            for j = 0, objects:size() - 1 do
                local object = objects:get(j)
                local kind = Internal.getPassageKind(object)
                if kind
                    and not Internal.isObstacleLocked(object)
                    and not objectBool(object, { "IsOpen", "isOpen" }, false) then
                    local objectSquare = Internal.getObjectSquare(object) or square
                    local x, y, z = Internal.getSquareCoords(objectSquare)
                    return {
                        object = object,
                        kind = kind,
                        square = objectSquare,
                        x = x,
                        y = y,
                        z = z,
                    }
                end
            end
        end
    end

    return nil
end

function Mobility.FindPassageBetween(fromSquare, nextSquare)
    return Mobility.FindDirectionalPassage(fromSquare, nextSquare)
end

function Mobility.TryOpenPassage(zombie, passage)
    local object = passage and passage.object or nil
    if not object or Internal.isObstacleLocked(object) then
        return false, nil
    end

    local kind = passage.kind or Internal.getPassageKind(object)
    if not kind then
        return false, nil
    end

    local isOpen = objectBool(object, { "IsOpen", "isOpen" }, false)
    if isOpen then
        return false, kind
    end

    local used, usedKind = tryUsePassageObject(zombie, object)
    return used == true, usedKind or kind
end

function Mobility.TrackOpenedPassage(npcData, passage)
    if type(npcData) ~= "table" or not passage or not passage.object then
        return false
    end

    if passage.kind ~= "door" then
        return false
    end

    local opened = type(npcData._dtOpenedPassages) == "table" and npcData._dtOpenedPassages or {}
    npcData._dtOpenedPassages = opened

    for i = 1, #opened do
        if opened[i].x == passage.x and opened[i].y == passage.y and opened[i].z == passage.z then
            opened[i].openedAt = Internal.getTimeMs()
            return true
        end
    end

    opened[#opened + 1] = {
        kind = passage.kind,
        x = passage.x,
        y = passage.y,
        z = passage.z,
        openedAt = Internal.getTimeMs(),
    }
    return true
end

function Mobility.TryTraverseFence(zombie, npcData, fromSquare, nextSquare, options)
    if not zombie or type(npcData) ~= "table" then
        return false, nil
    end

    local active = Mobility.IsSpecialActionActive and Mobility.IsSpecialActionActive(npcData)
    if active then
        return true, "special_action"
    end

    local collided = false
    if zombie.isCollidedWithDoor and zombie:isCollidedWithDoor() then
        collided = true
    elseif zombie.isCollidedThisFrame and zombie:isCollidedThisFrame() then
        collided = true
    elseif zombie.isCollided and zombie:isCollided() then
        collided = true
    end
    local blockedTicks = options and options.blockCounterKey and tonumber(npcData[options.blockCounterKey]) or 0
    if not collided and blockedTicks < 1 then
        return false, nil
    end

    local fence = Mobility.FindFenceAhead(zombie, npcData, {
        dirX = options and options.dirX,
        dirY = options and options.dirY,
        fromSquare = fromSquare,
        midSquare = nextSquare,
        originX = zombie:getX(),
        originY = zombie:getY(),
        originZ = zombie:getZ(),
    }) or Mobility.FindFenceBetween(fromSquare, nextSquare)

    if not fence then
        npcData._dtFencePendingKey = nil
        npcData._dtFencePendingAt = nil
        return false, nil
    end

    if not fence.fenceKey then
        fence.fenceKey = getFencePendingKey(fence)
    end
    if not fence.landingSquare then
        local cell = getCell and getCell() or nil
        fence.landingSquare = resolveFenceLandingSquare(
            cell,
            fence,
            zombie:getX(),
            zombie:getY(),
            zombie:getZ(),
            tonumber(options and options.dirX) or 0,
            tonumber(options and options.dirY) or 0
        )
    end
    fence.dirX = tonumber(options and options.dirX) or fence.dirX
    fence.dirY = tonumber(options and options.dirY) or fence.dirY
    return Mobility.BeginFenceTraverse(zombie, npcData, fence, options)
end

function Mobility.UpdateSpecialAction(zombie, npcData)
    if not zombie or type(npcData) ~= "table" then
        return false, nil
    end

    local kind = npcData._dtSpecialAction
    if kind ~= "fence" then
        return false, nil
    end

    local traverse = type(npcData._dtFenceTraverse) == "table" and npcData._dtFenceTraverse or nil
    if not traverse then
        Mobility.ClearSpecialAction(npcData, "fence")
        return false, nil
    end

    local currentTime = Internal.getTimeMs()
    local startedAt = tonumber(traverse.startedAt) or currentTime
    local durationMs = math.max(1, tonumber(traverse.durationMs) or 1)
    local travelDurationMs = math.max(1, tonumber(traverse.travelDurationMs) or durationMs)
    local progress = math.max(0, math.min(1, (currentTime - startedAt) / travelDurationMs))
    local eased = nil
    if progress < 0.5 then
        eased = 2 * progress * progress
    else
        local inverse = (-2 * progress) + 2
        eased = 1 - ((inverse * inverse) * 0.5)
    end
    local nextX = (tonumber(traverse.startX) or zombie:getX()) + (((tonumber(traverse.endX) or zombie:getX()) - (tonumber(traverse.startX) or zombie:getX())) * eased)
    local nextY = (tonumber(traverse.startY) or zombie:getY()) + (((tonumber(traverse.endY) or zombie:getY()) - (tonumber(traverse.startY) or zombie:getY())) * eased)
    local nextZ = tonumber(traverse.endZ) or zombie:getZ()

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    if zombie.setPath2 then
        zombie:setPath2(nil)
    end
    if zombie.setTarget then
        zombie:setTarget(nil)
    end
    zombie:setX(nextX)
    zombie:setY(nextY)
    zombie:setZ(nextZ)
    zombie:faceLocation(tonumber(traverse.endX) or nextX, tonumber(traverse.endY) or nextY)
    Mobility.Stop(zombie, { idleState = "0" })

    if progress >= 1 then
        zombie:setX(tonumber(traverse.endX) or nextX)
        zombie:setY(tonumber(traverse.endY) or nextY)
        zombie:setZ(nextZ)
        if isFenceAnimFinished(zombie) or (currentTime - startedAt) >= durationMs then
            npcData._dtFenceTraverse = nil
            npcData._dtFencePendingKey = nil
            npcData._dtFencePendingAt = nil
            resetFenceAnimFinished(zombie)
            if Mobility.ResetMovementProgress then
                Mobility.ResetMovementProgress(npcData)
            end
            Mobility.ClearSpecialAction(npcData, "fence")
            return false, "completed"
        end
        return true, "fence_finish"
    end

    return true, "fence"
end

local function isDangerNearPoint(x, y, z, radius, target)
    local safeRadius = math.max(0.5, tonumber(radius) or 3.0)
    local radiusSq = safeRadius * safeRadius

    if target and target.getX and not (target.isDead and target:isDead()) then
        local dx = target:getX() - x
        local dy = target:getY() - y
        if ((dx * dx) + (dy * dy)) <= radiusSq and math.abs((target:getZ() or z or 0) - (z or 0)) <= 1.1 then
            return true
        end
    end

    local zombieList = getCell() and getCell():getZombieList() or nil
    if not zombieList then
        return false
    end

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC) and math.abs((candidate:getZ() or 0) - (z or 0)) <= 1.1 then
                local dx = candidate:getX() - x
                local dy = candidate:getY() - y
                if ((dx * dx) + (dy * dy)) <= radiusSq then
                    return true
                end
            end
        end
    end

    return false
end

local function findPassageObjectAt(x, y, z, kind)
    local cell = getCell()
    local square = Internal.getSquareAt(cell, x, y, z)
    local objects = square and square:getObjects() or nil
    if not objects then
        return nil
    end

    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if Internal.getPassageKind(object) == kind then
            return object
        end
    end

    return nil
end

function Mobility.TryClosePassedDoor(zombie, npcData, options)
    if not zombie or type(npcData) ~= "table" or type(npcData._dtOpenedPassages) ~= "table" then
        return false
    end

    options = type(options) == "table" and options or {}
    local opened = npcData._dtOpenedPassages
    local closedAny = false

    for i = #opened, 1, -1 do
        local entry = opened[i]
        local object = entry and (entry.object or findPassageObjectAt(entry.x, entry.y, entry.z, "door")) or nil
        if not object or not Internal.isDoorLike(object) then
            table.remove(opened, i)
        else
            local square = Internal.getObjectSquare(object)
            local x, y, z = Internal.getSquareCoords(square)
            x = x or entry.x
            y = y or entry.y
            z = z or entry.z or zombie:getZ()

            local dx = (zombie:getX() or 0) - (x or 0)
            local dy = (zombie:getY() or 0) - (y or 0)
            local crossed = ((dx * dx) + (dy * dy)) >= 1.15
            local isOpen = objectBool(object, { "IsOpen", "isOpen" }, false)

            if not isOpen then
                table.remove(opened, i)
            elseif crossed and not isDangerNearPoint(x or zombie:getX(), y or zombie:getY(), z, options.safeRadius or 3.0, options.target) then
                local ok = callObjectMethod(object, { "ToggleDoor", "toggleDoor" }, zombie)
                if ok then
                    table.remove(opened, i)
                    closedAny = true
                end
            end
        end
    end

    return closedAny
end

function Internal.tryInteractWithObstacle(zombie, npcData, fromX, fromY, fromZ, nextX, nextY, options)
    if not zombie or not options or options.allowObstacleInteract ~= true then
        return false, nil
    end

    local cell = getCell()
    if not cell then
        return false, nil
    end

    local passage = Mobility.FindDirectionalPassage(
        Internal.getSquareAt(cell, fromX, fromY, fromZ),
        Internal.getSquareAt(cell, nextX, nextY, fromZ)
    )
    local opened, kind = Mobility.TryOpenPassage(zombie, passage)
    if opened then
        Mobility.TrackOpenedPassage(npcData, passage)
        return true, kind
    end

    return false, nil
end
