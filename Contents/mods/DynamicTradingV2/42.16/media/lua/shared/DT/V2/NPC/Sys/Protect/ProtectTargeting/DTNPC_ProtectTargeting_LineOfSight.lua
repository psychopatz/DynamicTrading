-- ==============================================================================
-- DTNPC_ProtectTargeting_LineOfSight.lua
-- Line-of-sight helpers for DTNPC protect targeting.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function getObjectSquare(object)
    return object and object.getSquare and object:getSquare() or nil
end

local function getSquareRoom(square)
    return square and square.getRoom and square:getRoom() or nil
end

local function getSquareDistanceSq(a, b)
    if not a or not b then
        return 9999
    end

    local ax = a.getX and a:getX() or 0
    local ay = a.getY and a:getY() or 0
    local bx = b.getX and b:getX() or 0
    local by = b.getY and b:getY() or 0
    local dx = ax - bx
    local dy = ay - by
    return (dx * dx) + (dy * dy)
end

local function tryLosUtil(observerSquare, targetSquare)
    if not LosUtil or not observerSquare or not targetSquare then
        return nil
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return nil
    end

    local ox = observerSquare.getX and observerSquare:getX() or nil
    local oy = observerSquare.getY and observerSquare:getY() or nil
    local oz = observerSquare.getZ and observerSquare:getZ() or 0
    local tx = targetSquare.getX and targetSquare:getX() or nil
    local ty = targetSquare.getY and targetSquare:getY() or nil
    local tz = targetSquare.getZ and targetSquare:getZ() or 0
    if ox == nil or oy == nil or tx == nil or ty == nil then
        return nil
    end

    local method = LosUtil.lineClear
    if type(method) ~= "function" then
        return nil
    end

    local ok, result = pcall(method, cell, ox, oy, oz, tx, ty, tz, false)
    if not ok then
        ok, result = pcall(method, LosUtil, cell, ox, oy, oz, tx, ty, tz, false)
    end
    if not ok then
        return nil
    end

    if result == true then
        return true
    end
    if result == false then
        return false
    end

    local text = tostring(result or "")
    if string.find(text, "Blocked", 1, true) or string.find(text, "ClosedDoor", 1, true) then
        return false
    end
    if string.find(text, "Clear", 1, true) then
        return true
    end

    return nil
end

local function hasLineOfSight(observer, target)
    if not observer or not target then
        return false
    end

    if observer.CanSee then
        local ok, canSee = pcall(observer.CanSee, observer, target)
        if ok and canSee == true then
            return true
        end
    end

    local observerSquare = getObjectSquare(observer)
    local targetSquare = getObjectSquare(target)
    local losResult = tryLosUtil(observerSquare, targetSquare)
    if losResult ~= nil then
        return losResult == true
    end

    local observerRoom = getSquareRoom(observerSquare)
    local targetRoom = getSquareRoom(targetSquare)
    if observerRoom and targetRoom and observerRoom ~= targetRoom then
        return false
    end
    if (observerRoom ~= nil) ~= (targetRoom ~= nil) and getSquareDistanceSq(observerSquare, targetSquare) > 4.84 then
        return false
    end

    return true
end

Internal.HasLineOfSight = hasLineOfSight

DTNPCProtect.HasLineOfSight = hasLineOfSight
