DT_GeolocatorSystem = DT_GeolocatorSystem or {}

local context = {}

function context.normalizeLocationName(name)
    local value = tostring(name or "")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    value = value:gsub("%s+", " ")
    return value
end

function context.normalizeLocationKey(name)
    local value = context.normalizeLocationName(name):lower()
    value = value:gsub("[^%w]+", "_")
    value = value:gsub("_+", "_")
    value = value:gsub("^_+", "")
    value = value:gsub("_+$", "")
    return value
end

function context.clearSequentialTable(target)
    for index = #target, 1, -1 do
        target[index] = nil
    end
end

function context.clampNumber(value, minValue, maxValue)
    local numeric = tonumber(value)
    if numeric == nil then
        return minValue
    end
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

function context.collectSpatialAnchorPlayers()
    local players = {}
    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil

    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getX and player.getY then
                players[#players + 1] = player
            end
        end
    end

    if #players == 0 then
        local localPlayer = nil
        if getSpecificPlayer then
            localPlayer = getSpecificPlayer(0)
        elseif getPlayer then
            localPlayer = getPlayer()
        end

        if localPlayer and localPlayer.getX and localPlayer.getY then
            players[#players + 1] = localPlayer
        end
    end

    return players
end

function context.buildSpatialHomeEntry(x, y, z, name, town, county, source)
    local resolvedTown = town
    if DT_GeolocatorSystem.ResolveLocationName and resolvedTown then
        resolvedTown = DT_GeolocatorSystem.ResolveLocationName(resolvedTown)
    end

    local finalName = tostring(name or "Nomadic Route")
    return {
        name = finalName,
        x = math.floor(tonumber(x) or 0),
        y = math.floor(tonumber(y) or 0),
        z = math.floor(tonumber(z) or 0),
        town = resolvedTown or town or "Unknown",
        county = county,
        zone = finalName,
        isSpatial = true,
        spatialSource = source or "fallback",
    }
end

function context.buildLocationCenterEntry(location, label)
    if type(location) ~= "table" then
        return nil
    end

    local centerX = math.floor(((tonumber(location.startX) or 0) + (tonumber(location.endX) or 0)) / 2)
    local centerY = math.floor(((tonumber(location.startY) or 0) + (tonumber(location.endY) or 0)) / 2)
    local town = location.shortName or location.id or "Unknown"
    local name = label or (town ~= "Unknown" and (tostring(town) .. " Route") or "Nomadic Route")
    return context.buildSpatialHomeEntry(centerX, centerY, 0, name, town, location.longName, "location-center")
end

function context.getSpatialRadiusRange(options)
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local minRadius = tonumber(options and options.minRadius) or tonumber(sandbox.IndependentSpawnRadiusMin) or 500
    local maxRadius = tonumber(options and options.maxRadius) or tonumber(sandbox.IndependentSpawnRadiusMax) or 1000

    if options and options.preferUsableRange then
        minRadius = math.min(minRadius, 80)
        maxRadius = math.min(maxRadius, 180)
    end

    minRadius = context.clampNumber(minRadius, 10, 10000)
    maxRadius = context.clampNumber(maxRadius, minRadius + 10, 10000)
    if maxRadius < minRadius then
        maxRadius = minRadius
    end

    return minRadius, maxRadius
end

function context.pickNearbyBuildingForAnchor(anchorX, anchorY, minRadius, maxRadius, targetTown)
    if not DT_GeolocatorSystem.EnsureBuildingsLoaded
        or not DT_GeolocatorSystem.EnsureBuildingsLoaded(false, false) then
        return nil
    end

    local minRadiusSq = minRadius * minRadius
    local candidates = {}
    local nearbyBuildings = nil

    if DT_GeolocatorSystem.GetBuildingsNearPoint then
        nearbyBuildings = DT_GeolocatorSystem.GetBuildingsNearPoint(anchorX, anchorY, maxRadius, targetTown)
    else
        nearbyBuildings = DT_GeolocatorSystem.Buildings or {}
    end

    for _, building in ipairs(nearbyBuildings) do
        local bx = tonumber(building.cx) or tonumber(building.x)
        local by = tonumber(building.cy) or tonumber(building.y)
        if bx and by then
            local dx = bx - anchorX
            local dy = by - anchorY
            local distSq = (dx * dx) + (dy * dy)
            if distSq >= minRadiusSq then
                candidates[#candidates + 1] = building
            end
        end
    end

    if #candidates == 0 then
        return nil
    end

    return candidates[ZombRand(#candidates) + 1]
end

return context
