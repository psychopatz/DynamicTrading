-- ==============================================================================
-- Behavior_Departure.lua
-- Handles visible NPC departures before they switch back to an off-screen Away state.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local DESPAWN_DIST = 45
local TARGET_REACHED_DIST = 2
local STUCK_TICKS = 15
local STUCK_ABORT_TICKS = 60

local function getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

local function isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    if not sq then return true end
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
end

local function forceRunAnimation(zombie)
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    zombie:setVariable("Speed", 1.2)
    zombie:setVariable("DTWalkType", "Run")
    zombie:setVariable("WalkType", "1")
    zombie:setRunning(true)
end

local function stopDepartureAnimation(zombie)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setVariable("DTWalkType", "")
    zombie:setVariable("WalkType", "")
    zombie:setRunning(false)
end

local function clearDepartureRuntime(npcData)
    npcData.removalRequested = nil
    npcData.isMovingState = nil
    npcData.departureTargetX = nil
    npcData.departureTargetY = nil
    npcData.departureTargetZ = nil
    npcData.departureTravelHours = nil
    npcData.departureBlockedTicks = nil
    npcData.departureStuckLastX = nil
    npcData.departureStuckLastY = nil
    npcData.departureLastDirX = nil
    npcData.departureLastDirY = nil
    npcData.departureStartedAt = nil
    npcData.departureForceDespawnAt = nil
    npcData.departureTimeoutVisibleLogged = nil
end

local function getActivePlayers()
    local players = {}
    local online = getOnlinePlayers()
    if online then
        for i = 0, online:size() - 1 do
            local player = online:get(i)
            if player then
                table.insert(players, player)
            end
        end
    else
        local player = getSpecificPlayer(0)
        if player then
            table.insert(players, player)
        end
    end
    return players
end

local function getNearestPlayer(zombie)
    if not zombie then return nil, 9999 end

    local nearestPlayer = nil
    local nearestDist = 9999
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()

    for _, player in ipairs(getActivePlayers()) do
        local dz = math.abs((player:getZ() or 0) - zz)
        if dz <= 1 then
            local dist = getDist(zx, zy, player:getX(), player:getY())
            if dist < nearestDist then
                nearestPlayer = player
                nearestDist = dist
            end
        end
    end

    return nearestPlayer, nearestDist
end

local function tryUnstick(zombie, z, dirX, dirY)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local candidates = {
        { x = zx + (dirX * 1.5), y = zy + (dirY * 1.5) },
        { x = zx + (dirX * 1.5) - dirY, y = zy + (dirY * 1.5) + dirX },
        { x = zx + (dirX * 1.5) + dirY, y = zy + (dirY * 1.5) - dirX },
        { x = zx - dirY, y = zy + dirX },
        { x = zx + dirY, y = zy - dirX },
    }

    for _, candidate in ipairs(candidates) do
        if isTileSafe(candidate.x, candidate.y, z) then
            zombie:setX(candidate.x)
            zombie:setY(candidate.y)
            zombie:setZ(z)
            return true
        end
    end

    return false
end

local function completeDeparture(zombie, npcData, reason)
    if npcData.removalRequested then return true end

    local uuid = npcData.uuid
    local travelHours = npcData.departureTravelHours or 0
    local returnTime = npcData.returnTime
    local nextStatus = npcData.returnStatus or npcData.requestedReturnStatus or "Resting"

    if returnTime == nil or returnTime <= 0 then
        returnTime = getGameTime():getWorldAgeHours() + travelHours
    end

    stopDepartureAnimation(zombie)

    if not isClient() and DTNPCManager and DTNPCManager.CompleteLiveDeparture then
        return DTNPCManager.CompleteLiveDeparture(uuid, npcData, zombie, reason)
    end

    clearDepartureRuntime(npcData)
    npcData.status = "Away"
    npcData.returnTime = returnTime
    npcData.returnStatus = nextStatus
    npcData.state = "Idle"

    if DynamicTrading_Roster and uuid then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end

    if isClient() then
        sendClientCommand(getPlayer(), "DTNPC", "RemoveNPC", {
            uuid = uuid,
            status = "Away",
            returnTime = returnTime,
            returnStatus = nextStatus
        })
        npcData.removalRequested = true
    elseif DTNPCManager then
        DTNPCManager.RemoveData(uuid, "Away", returnTime, nextStatus)
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end

    return true
end

DTNPCLogic.Behaviors["Departure"] = function(zombie, npcData, target, dist)
    local observer, observerDist = getNearestPlayer(zombie)
    local currentHours = getGameTime():getWorldAgeHours()

    if npcData.departureForceDespawnAt and currentHours >= npcData.departureForceDespawnAt then
        if (not observer) or observerDist > DESPAWN_DIST then
            completeDeparture(zombie, npcData, "force_timeout")
            return
        end

        if not npcData.departureTimeoutVisibleLogged
            and DTNPCManager
            and DTNPCManager.RespawnDebug
            and DTNPCManager.RespawnDebug.Log then
            DTNPCManager.RespawnDebug.Log(
                "departure_wait_visible_" .. tostring(npcData.uuid),
                "Process=departure_timeout_wait_visible uuid=" .. tostring(npcData.uuid) ..
                    " name=" .. tostring(npcData.name or npcData.uuid) ..
                    " observerDist=" .. string.format("%.2f", observerDist) ..
                    " despawnDist=" .. tostring(DESPAWN_DIST),
                true
            )
            npcData.departureTimeoutVisibleLogged = true
        end
    end

    if observer and observerDist > DESPAWN_DIST and observerDist < 1000 then
        completeDeparture(zombie, npcData, "observer_distance")
        return
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local z = zombie:getZ()
    local dx = 0
    local dy = 0
    local hasDestination = false

    if npcData.departureTargetX and npcData.departureTargetY then
        dx = npcData.departureTargetX - zx
        dy = npcData.departureTargetY - zy
        local len = math.sqrt(dx * dx + dy * dy)
        if len > TARGET_REACHED_DIST then
            dx = dx / len
            dy = dy / len
            npcData.departureLastDirX = dx
            npcData.departureLastDirY = dy
            hasDestination = true
        elseif npcData.departureLastDirX and npcData.departureLastDirY then
            dx = npcData.departureLastDirX
            dy = npcData.departureLastDirY
            hasDestination = true
        elseif observer then
            dx = zx - observer:getX()
            dy = zy - observer:getY()
            len = math.sqrt(dx * dx + dy * dy)
            if len > 0 then
                dx = dx / len
                dy = dy / len
                npcData.departureLastDirX = dx
                npcData.departureLastDirY = dy
                hasDestination = true
            else
                completeDeparture(zombie, npcData, "target_reached_visible_zero_dir")
                return
            end
        else
            completeDeparture(zombie, npcData, "target_reached_unseen")
            return
        end
    elseif npcData.departureLastDirX then
        dx = npcData.departureLastDirX
        dy = npcData.departureLastDirY
        hasDestination = true
    elseif observer then
        dx = zx - observer:getX()
        dy = zy - observer:getY()
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            dx = dx / len
            dy = dy / len
            npcData.departureLastDirX = dx
            npcData.departureLastDirY = dy
            hasDestination = true
        end
    end

    if not hasDestination then
        if not zombie:isUseless() then zombie:setUseless(true) end
        stopDepartureAnimation(zombie)
        return
    end

    if not npcData.isMovingState then npcData.isMovingState = false end
    if not npcData.isMovingState then
        npcData.isMovingState = true
        if DTNPCLogic.Behaviors["Attack"] then
            DTNPCLogic.Behaviors["Attack"](zombie, npcData, target, dist)
        end
        return
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local speed = DynamicTrading.GetNPCRunSpeed()
    local nextX = zx + (dx * speed)
    local nextY = zy + (dy * speed)
    local canMove = isTileSafe(nextX, nextY, z)

    if not canMove then
        if isTileSafe(nextX, zy, z) then
            nextY = zy
            canMove = true
        elseif isTileSafe(zx, nextY, z) then
            nextX = zx
            canMove = true
        end
    end

    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        forceRunAnimation(zombie)

        if math.abs(dx) > 0.001 or math.abs(dy) > 0.001 then
            zombie:faceLocation(nextX + dx, nextY + dy)
        end

        if npcData.departureStuckLastX then
            local moved = getDist(nextX, nextY, npcData.departureStuckLastX, npcData.departureStuckLastY)
            if moved < 0.05 then
                npcData.departureBlockedTicks = (npcData.departureBlockedTicks or 0) + 1
            else
                npcData.departureBlockedTicks = 0
            end
        else
            npcData.departureBlockedTicks = 0
        end

        npcData.departureStuckLastX = nextX
        npcData.departureStuckLastY = nextY

        if (npcData.departureBlockedTicks or 0) >= STUCK_ABORT_TICKS then
            completeDeparture(zombie, npcData, "stuck_abort_move")
            return
        end
    else
        npcData.departureBlockedTicks = (npcData.departureBlockedTicks or 0) + 1
        if npcData.departureBlockedTicks >= STUCK_TICKS and tryUnstick(zombie, z, dx, dy) then
            npcData.departureBlockedTicks = 0
            npcData.departureStuckLastX = zombie:getX()
            npcData.departureStuckLastY = zombie:getY()
            forceRunAnimation(zombie)
            return
        end

        if npcData.departureBlockedTicks >= STUCK_ABORT_TICKS then
            completeDeparture(zombie, npcData, "stuck_abort_blocked")
            return
        end

        stopDepartureAnimation(zombie)
    end
end
