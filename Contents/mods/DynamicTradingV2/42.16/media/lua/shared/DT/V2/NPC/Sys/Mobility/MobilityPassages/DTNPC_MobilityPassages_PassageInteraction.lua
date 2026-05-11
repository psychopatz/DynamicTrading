-- ==============================================================================
-- DTNPC_MobilityPassages_PassageInteraction.lua
-- Passage interaction, tracking, and closeout helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Mobility.TryOpenPassage(zombie, passage)
    local object = passage and passage.object or nil
    if not object or Internal.isObstacleLocked(object) then
        return false, nil
    end

    local kind = passage.kind or Internal.getPassageKind(object)
    if not kind then
        return false, nil
    end

    local isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)
    if isOpen then
        return false, kind
    end

    local used, usedKind = Internal.tryUsePassageObject(zombie, object)
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

function Internal.isDangerNearPoint(x, y, z, radius, target)
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

function Internal.findPassageObjectAt(x, y, z, kind)
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
        local object = entry and (entry.object or Internal.findPassageObjectAt(entry.x, entry.y, entry.z, "door")) or nil
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
            local isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)

            if not isOpen then
                table.remove(opened, i)
            elseif crossed and not Internal.isDangerNearPoint(x or zombie:getX(), y or zombie:getY(), z, options.safeRadius or 3.0, options.target) then
                local ok = Internal.trySetDoorOpenState(object, false)
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
