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
