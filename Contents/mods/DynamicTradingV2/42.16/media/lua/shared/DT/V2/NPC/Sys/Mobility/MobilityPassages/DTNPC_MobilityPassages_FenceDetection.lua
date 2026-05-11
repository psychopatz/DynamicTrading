-- ==============================================================================
-- DTNPC_MobilityPassages_FenceDetection.lua
-- Fence discovery and landing resolution for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Internal.isFenceLike(object)
    if not object then
        return false
    end

    local square = Internal.getObjectSquare(object)
    local properties = object.getProperties and object:getProperties() or nil
    local lowFence = properties and properties.get and properties:get("FenceTypeLow") or nil
    local tallFence = properties and properties.get and properties:get("FenceTypeHigh") or nil
    local hoppable = Internal.objectBool(object, { "isHoppable" }, false)
    local tallHoppable = Internal.objectBool(object, { "isTallHoppable" }, false)

    return lowFence ~= nil or tallFence ~= nil or hoppable or tallHoppable, square, tallFence ~= nil or tallHoppable
end

function Internal.getFenceDirectionFlags(fromSquare, nextSquare)
    local fromX, fromY = Internal.getSquareCoords(fromSquare)
    local nextX, nextY = Internal.getSquareCoords(nextSquare)
    local dx = (nextX or fromX or 0) - (fromX or 0)
    local dy = (nextY or fromY or 0) - (fromY or 0)

    if math.abs(dy) >= math.abs(dx) then
        return true
    end
    return false
end

function Internal.getDirectionalFenceObject(fromSquare, nextSquare)
    if not fromSquare or not nextSquare then
        return nil
    end

    local isNorthSouth = Internal.getFenceDirectionFlags(fromSquare, nextSquare)
    local squares = { fromSquare, nextSquare }
    for i = 1, #squares do
        local square = squares[i]
        local okWall, wall = Internal.callObjectMethod(square, { "getWall", "getHoppableThumpable" }, isNorthSouth)
        if okWall and wall then
            local isFence, _, isTall = Internal.isFenceLike(wall)
            if isFence then
                return wall, isTall
            end
        end

        local okHoppable, hoppable = Internal.callObjectMethod(square, { "getHoppableThumpable" }, isNorthSouth)
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
    local object, isTall = Internal.getDirectionalFenceObject(fromSquare, nextSquare)
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

function Internal.getFencePendingKey(fence)
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

function Internal.setFenceReject(npcData, fenceKey, durationMs)
    if type(npcData) ~= "table" then
        return
    end

    npcData._dtFenceRejectKey = fenceKey
    npcData._dtFenceRejectUntil = Internal.getTimeMs() + math.max(120, math.floor(tonumber(durationMs) or 260))
end

function Internal.isFenceRejected(npcData, fenceKey)
    if type(npcData) ~= "table" or not fenceKey then
        return false
    end

    local rejectUntil = tonumber(npcData._dtFenceRejectUntil) or 0
    if npcData._dtFenceRejectKey == fenceKey and rejectUntil > Internal.getTimeMs() then
        return true
    end

    return false
end

function Internal.getProbeSquare(cell, originX, originY, originZ, dirX, dirY, distance)
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

function Internal.resolveFenceLandingSquare(cell, fence, originX, originY, originZ, dirX, dirY)
    if not cell then
        return nil
    end

    local distances = { 1.45, 1.8, 2.15 }
    for i = 1, #distances do
        local landingSquare = Internal.getProbeSquare(cell, originX, originY, originZ, dirX, dirY, distances[i])
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

    local nearSquare = options.nearSquare or Internal.getProbeSquare(cell, originX, originY, originZ, dirX, dirY, 0.8)
    local midSquare = options.midSquare or Internal.getProbeSquare(cell, originX, originY, originZ, dirX, dirY, 1.15)
    local farSquare = options.farSquare or Internal.getProbeSquare(cell, originX, originY, originZ, dirX, dirY, 1.7)
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
    fence.fenceKey = Internal.getFencePendingKey(fence)
    fence.landingSquare = Internal.resolveFenceLandingSquare(cell, fence, originX, originY, originZ, dirX, dirY)
    return fence
end
