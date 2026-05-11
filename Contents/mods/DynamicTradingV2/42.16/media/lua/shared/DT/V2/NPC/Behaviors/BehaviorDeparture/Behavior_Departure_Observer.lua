-- ==============================================================================
-- Behavior_Departure_Observer.lua
-- Observer lookup and fallback movement helpers for NPC departure behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.Departure = DTNPCLogic.Internal.Departure or {}

local internal = DTNPCLogic.Internal.Departure

function internal.getActivePlayers()
    local players = {}
    local online = getOnlinePlayers()
    if online then
        for i = 0, online:size() - 1 do
            local player = online:get(i)
            if player then
                table.insert(players, player)
            end
        end
    end

    if #players == 0 then
        local player = getSpecificPlayer(0)
        if not player and getPlayer then
            player = getPlayer()
        end
        if player then
            table.insert(players, player)
        end
    end
    return players
end

function internal.getNearestPlayer(zombie)
    if not zombie then
        return nil, 9999
    end

    local nearestPlayer = nil
    local nearestDist = 9999
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()

    for _, player in ipairs(internal.getActivePlayers()) do
        local dz = math.abs((player:getZ() or 0) - zz)
        if dz <= 1 then
            local dist = internal.getDist(zx, zy, player:getX(), player:getY())
            if dist < nearestDist then
                nearestPlayer = player
                nearestDist = dist
            end
        end
    end

    return nearestPlayer, nearestDist
end

function internal.tryUnstick(zombie, z, dirX, dirY)
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
        if internal.isTileSafe(candidate.x, candidate.y, z) then
            zombie:setX(candidate.x)
            zombie:setY(candidate.y)
            zombie:setZ(z)
            return true
        end
    end

    return false
end
