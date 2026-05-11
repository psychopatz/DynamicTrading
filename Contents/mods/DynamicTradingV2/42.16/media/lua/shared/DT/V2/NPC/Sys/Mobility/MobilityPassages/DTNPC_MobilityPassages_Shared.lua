-- ==============================================================================
-- DTNPC_MobilityPassages_Shared.lua
-- Shared obstacle, square, and passage helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Internal.callObjectMethod(object, names, ...)
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

function Internal.objectBool(object, names, defaultValue)
    local ok, result = Internal.callObjectMethod(object, names)
    if not ok then
        return defaultValue == true
    end
    return result == true
end

function Internal.resetFenceAnimFinished(zombie)
    if not zombie then
        return
    end

    zombie:setVariable("BumpAnimFinished", false)
    zombie:setVariable("ClimbFenceFinished", false)
end

function Internal.isFenceAnimFinished(zombie)
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

    local ok, result = Internal.callObjectMethod(object, { "isDoor", "IsDoor" })
    return ok and result == true
end

function Internal.isWindowLike(object)
    return object and instanceof and instanceof(object, "IsoWindow") or false
end

function Internal.isObstacleLocked(object)
    local hasKeyLock, keyLock = Internal.callObjectMethod(object, { "getLockedByKey" })
    if hasKeyLock and keyLock ~= nil and keyLock ~= false and keyLock ~= 0 then
        return true
    end

    return Internal.objectBool(object, { "isLocked", "IsLocked" }, false)
        or Internal.objectBool(object, { "isBarricaded", "IsBarricaded" }, false)
end

function Internal.trySetDoorOpenState(object, shouldBeOpen)
    if not object or not Internal.isDoorLike(object) then
        return false
    end

    local desiredOpen = shouldBeOpen == true
    local wasOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)
    if wasOpen == desiredOpen then
        return true
    end

    local ok = Internal.callObjectMethod(object, { "ToggleDoorSilent", "toggleDoorSilent" })
    local isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)

    -- Play sound if state changed
    if ok and isOpen == desiredOpen then
        local props = object:getProperties()
        local doorSound = (props and props:has("DoorSound") and props:get("DoorSound")) or "WoodDoor"
        doorSound = doorSound .. (isOpen and "Open" or "Close")
        
        -- We try to play the sound at the door location
        local square = object:getSquare()
        if square and doorSound then
            getSoundManager():PlayWorldSound(doorSound, square, 0, 10, 1.0, false)
        end
        
        -- Invalidate paths like Bandits mod does
        if square then
            square:InvalidateSpecialObjectPaths()
            if IsoGridSquare.setRecalcLightTime then
                IsoGridSquare.setRecalcLightTime(-1.0)
            end
        end

        return true
    end

    ok = Internal.callObjectMethod(object, { "setOpen", "SetOpen" }, desiredOpen)
    isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)
    if ok and isOpen == desiredOpen then
        return true
    end

    return false
end

function Internal.tryUsePassageObject(zombie, object)
    if not object or Internal.isObstacleLocked(object) then
        return false, nil
    end

    local isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)
    if Internal.isDoorLike(object) then
        if not isOpen then
            local ok = Internal.trySetDoorOpenState(object, true)
            return ok == true, "door"
        end
        return false, nil
    end

    if Internal.isWindowLike(object) then
        if Internal.objectBool(object, { "isDestroyed", "IsDestroyed" }, false) then
            return false, nil
        end
        if not isOpen then
            local ok = Internal.callObjectMethod(object, { "ToggleWindow", "toggleWindow" }, zombie)
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
