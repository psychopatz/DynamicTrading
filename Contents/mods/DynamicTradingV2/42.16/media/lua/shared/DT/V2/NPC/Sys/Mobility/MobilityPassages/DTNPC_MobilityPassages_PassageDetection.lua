-- ==============================================================================
-- DTNPC_MobilityPassages_PassageDetection.lua
-- Door and window discovery helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Internal.findDirectionalPassageObject(fromSquare, nextSquare)
    if not fromSquare or not nextSquare then
        return nil
    end

    local directionalLookups = {
        { "getDoorTo", "getIsoDoorTo" },
        { "getWindowTo", "getWindowOrWindowThumpableTo", "getWindowThumpableTo" },
    }

    for i = 1, #directionalLookups do
        local ok, object = Internal.callObjectMethod(fromSquare, directionalLookups[i], nextSquare)
        if ok and object then
            return object
        end
    end

    return nil
end

function Mobility.FindDirectionalPassage(fromSquare, nextSquare)
    local directionalObject = Internal.findDirectionalPassageObject(fromSquare, nextSquare)
    if directionalObject then
        local kind = Internal.getPassageKind(directionalObject)
        if kind
            and not Internal.isObstacleLocked(directionalObject)
            and not Internal.objectBool(directionalObject, { "IsOpen", "isOpen" }, false)
            and not Internal.objectBool(directionalObject, { "isDestroyed", "IsDestroyed" }, false) then
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
                    and not Internal.objectBool(object, { "IsOpen", "isOpen" }, false) then
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
