-- =============================================================================
-- GEOLOCATOR SYSTEM: LOCATION LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

local function normalizeLocationName(name)
    local value = tostring(name or "")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    value = value:gsub("%s+", " ")
    return value
end

local function normalizeLocationKey(name)
    local value = normalizeLocationName(name):lower()
    value = value:gsub("[^%w]+", "_")
    value = value:gsub("_+", "_")
    value = value:gsub("^_+", "")
    value = value:gsub("_+$", "")
    return value
end

local function clearSequentialTable(target)
    for index = #target, 1, -1 do
        target[index] = nil
    end
end

local function clampNumber(value, minValue, maxValue)
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

local function collectSpatialAnchorPlayers()
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

local function buildSpatialHomeEntry(x, y, z, name, town, county, source)
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

local function buildLocationCenterEntry(location, label)
    if type(location) ~= "table" then
        return nil
    end

    local centerX = math.floor(((tonumber(location.startX) or 0) + (tonumber(location.endX) or 0)) / 2)
    local centerY = math.floor(((tonumber(location.startY) or 0) + (tonumber(location.endY) or 0)) / 2)
    local town = location.shortName or location.id or "Unknown"
    local name = label or (town ~= "Unknown" and (tostring(town) .. " Route") or "Nomadic Route")
    return buildSpatialHomeEntry(centerX, centerY, 0, name, town, location.longName, "location-center")
end

local function getSpatialRadiusRange(options)
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local minRadius = tonumber(options and options.minRadius) or tonumber(sandbox.IndependentSpawnRadiusMin) or 500
    local maxRadius = tonumber(options and options.maxRadius) or tonumber(sandbox.IndependentSpawnRadiusMax) or 1000

    if options and options.preferUsableRange then
        minRadius = math.min(minRadius, 80)
        maxRadius = math.min(maxRadius, 180)
    end

    minRadius = clampNumber(minRadius, 10, 10000)
    maxRadius = clampNumber(maxRadius, minRadius + 10, 10000)
    if maxRadius < minRadius then
        maxRadius = minRadius
    end

    return minRadius, maxRadius
end

local function pickNearbyBuildingForAnchor(anchorX, anchorY, minRadius, maxRadius, targetTown)
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

local function upsertLocation(location)
    if not location then
        return nil
    end

    local shortName = normalizeLocationName(location.shortName or location.longName or location.name)
    if shortName == "" then
        return nil
    end

    local key = normalizeLocationKey(location.id or shortName)
    local existing = DT_GeolocatorSystem.LocationIndex[key]
    if existing then
        existing.shortName = shortName
        existing.longName = normalizeLocationName(location.longName or existing.longName or shortName)
        existing.mod = location.mod or existing.mod or "Dynamic"
        existing.isVanilla = location.isVanilla == true or existing.isVanilla == true
        existing.startX = math.floor(tonumber(location.startX) or tonumber(existing.startX) or 0)
        existing.endX = math.floor(tonumber(location.endX) or tonumber(existing.endX) or 0)
        existing.startY = math.floor(tonumber(location.startY) or tonumber(existing.startY) or 0)
        existing.endY = math.floor(tonumber(location.endY) or tonumber(existing.endY) or 0)
        return existing
    end

    local entry = {
        id = key,
        shortName = shortName,
        longName = normalizeLocationName(location.longName or shortName),
        mod = location.mod or "Dynamic",
        isVanilla = location.isVanilla == true,
        startX = math.floor(tonumber(location.startX) or 0),
        endX = math.floor(tonumber(location.endX) or 0),
        startY = math.floor(tonumber(location.startY) or 0),
        endY = math.floor(tonumber(location.endY) or 0),
    }

    table.insert(DT_GeolocatorSystem.ActiveLocations, entry)
    DT_GeolocatorSystem.LocationIndex[key] = entry
    return entry
end

function DT_GeolocatorSystem.InitCache()
    if DT_GeolocatorSystem.CacheInitialized then
        return
    end

    DT_GeolocatorSystem.ActiveLocations = {}
    DT_GeolocatorSystem.LocationIndex = {}

    for _, location in ipairs(DT_GeolocatorSystem.KnownLocations or {}) do
        upsertLocation(location)
    end

    DT_GeolocatorSystem.CacheInitialized = true
    DynamicTrading.Log(
        "DTCommons",
        "Init",
        "Geolocator",
        "Initialized with " .. tostring(#DT_GeolocatorSystem.ActiveLocations) .. " mapped regions."
    )
end

function DT_GeolocatorSystem.AddLocation(id, longName, modName, startX, startY, endX, endY, shortName)
    DT_GeolocatorSystem.InitCache()
    return upsertLocation({
        id = id,
        longName = longName,
        shortName = shortName or longName,
        mod = modName,
        startX = startX,
        startY = startY,
        endX = endX,
        endY = endY,
        isVanilla = false,
    })
end

function DT_GeolocatorSystem.NormalizeLocationKey(value)
    return normalizeLocationKey(value)
end

function DT_GeolocatorSystem.FindLocationByName(value)
    DT_GeolocatorSystem.InitCache()

    local targetKey = normalizeLocationKey(value)
    if not targetKey then
        return nil
    end

    local locations = DT_GeolocatorSystem.ActiveLocations or {}
    for _, location in ipairs(locations) do
        if normalizeLocationKey(location.id) == targetKey
            or normalizeLocationKey(location.shortName) == targetKey
            or normalizeLocationKey(location.longName) == targetKey then
            return location
        end
    end

    return nil
end

function DT_GeolocatorSystem.ResolveLocationName(value)
    local location = DT_GeolocatorSystem.FindLocationByName(value)
    if location and location.shortName and location.shortName ~= "" then
        return location.shortName
    end

    return value
end

function DT_GeolocatorSystem.CreateSpatialHome(label, options)
    options = type(options) == "table" and options or {}

    local targetTown = options.town
    local resolvedLocation = DT_GeolocatorSystem.FindLocationByName(targetTown)
    local minRadius, maxRadius = getSpatialRadiusRange(options)
    local players = collectSpatialAnchorPlayers()

    if #players > 0 then
        local anchor = players[ZombRand(#players) + 1]
        local anchorX = math.floor(anchor:getX())
        local anchorY = math.floor(anchor:getY())
        local anchorZ = math.floor((anchor.getZ and anchor:getZ()) or 0)
        local building = pickNearbyBuildingForAnchor(anchorX, anchorY, minRadius, maxRadius, targetTown)

        if building then
            local bx = tonumber(building.cx) or tonumber(building.x) or anchorX
            local by = tonumber(building.cy) or tonumber(building.y) or anchorY
            local buildingTown = building.town or (DT_GeolocatorSystem.GetTownName and DT_GeolocatorSystem.GetTownName(bx, by)) or targetTown
            local buildingCounty = building.county or (DT_GeolocatorSystem.GetCountyName and DT_GeolocatorSystem.GetCountyName(bx, by)) or nil
            return buildSpatialHomeEntry(bx, by, 0, building.name or label, buildingTown, buildingCounty, "nearby-building")
        end

        local angle = math.rad(ZombRand(360))
        local radius = minRadius
        if maxRadius > minRadius then
            radius = minRadius + ZombRand(maxRadius - minRadius + 1)
        end
        local x = math.floor(anchorX + (math.cos(angle) * radius))
        local y = math.floor(anchorY + (math.sin(angle) * radius))
        local town = (DT_GeolocatorSystem.GetTownName and DT_GeolocatorSystem.GetTownName(x, y)) or targetTown
        local county = (DT_GeolocatorSystem.GetCountyName and DT_GeolocatorSystem.GetCountyName(x, y)) or nil
        local name = label
        if not name or name == "" then
            local townLabel = (DT_GeolocatorSystem.ResolveLocationName and DT_GeolocatorSystem.ResolveLocationName(town)) or town
            name = townLabel and townLabel ~= "Wilderness" and (tostring(townLabel) .. " Route") or "Nomadic Route"
        end
        return buildSpatialHomeEntry(x, y, anchorZ, name, town, county, "nearby-player")
    end

    if resolvedLocation then
        return buildLocationCenterEntry(resolvedLocation, label)
    end

    if DT_GeolocatorSystem.ActiveLocations and #DT_GeolocatorSystem.ActiveLocations > 0 then
        local fallbackLocation = DT_GeolocatorSystem.ActiveLocations[ZombRand(#DT_GeolocatorSystem.ActiveLocations) + 1]
        return buildLocationCenterEntry(fallbackLocation, label)
    end

    return buildSpatialHomeEntry(0, 0, 0, label or "Nomadic Route", targetTown or "Unknown", nil, "origin-fallback")
end

function DT_GeolocatorSystem.GetLocation(x, y)
    DT_GeolocatorSystem.InitCache()

    if not x or not y then
        return nil
    end

    for i = #DT_GeolocatorSystem.ActiveLocations, 1, -1 do
        local location = DT_GeolocatorSystem.ActiveLocations[i]
        if x >= location.startX and x <= location.endX and y >= location.startY and y <= location.endY then
            return location
        end
    end

    return nil
end

local function addTownZoneLocation(zone)
    if not zone or zone:getType() ~= "TownZone" then
        return nil
    end

    local zoneName = normalizeLocationName(zone:getName() or "Nearby Town")
    if zoneName == "" then
        zoneName = "Nearby Town"
    end

    return DT_GeolocatorSystem.AddLocation(
        normalizeLocationKey(zoneName),
        zoneName,
        "Dynamic",
        zone:getX(),
        zone:getY(),
        zone:getX() + zone:getW(),
        zone:getY() + zone:getH(),
        zoneName
    )
end

function DT_GeolocatorSystem.GetCountyName(x, y)
    local location = DT_GeolocatorSystem.GetLocation(x, y)
    if location and location.longName then
        return location.longName
    end

    for _, county in ipairs(DT_GeolocatorSystem.Counties or {}) do
        if x >= county.bounds.minX and x <= county.bounds.maxX and y >= county.bounds.minY and y <= county.bounds.maxY then
            return county.name
        end
    end

    return "Unknown County"
end

function DT_GeolocatorSystem.GetTownName(x, y)
    local location = DT_GeolocatorSystem.GetLocation(x, y)
    if location and location.shortName then
        return location.shortName
    end

    local world = getWorld and getWorld() or nil
    local metaGrid = world and world:getMetaGrid() or nil
    if metaGrid then
        local zones = metaGrid:getZonesAt(x, y, 0)
        if zones then
            for i = 0, zones:size() - 1 do
                local zone = zones:get(i)
                if zone:getType() == "TownZone" then
                    local dynamicLocation = addTownZoneLocation(zone)
                    if dynamicLocation and dynamicLocation.shortName then
                        return dynamicLocation.shortName
                    end
                    return normalizeLocationName(zone:getName() or "Nearby Town")
                end
            end
        end
    end

    for _, town in ipairs(DT_GeolocatorSystem.Towns or {}) do
        if x >= town.minX and x <= town.maxX and y >= town.minY and y <= town.maxY then
            return town.name
        end
    end

    return "Wilderness"
end

function DT_GeolocatorSystem.ResolveRegionName(x, y, townHint, countyHint)
    local town = normalizeLocationName(townHint)
    if town ~= "" and town ~= "Wilderness" then
        return town
    end

    if x and y then
        local detectedTown = DT_GeolocatorSystem.GetTownName(x, y)
        if detectedTown and detectedTown ~= "" and detectedTown ~= "Wilderness" then
            return detectedTown
        end
    end

    local county = normalizeLocationName(countyHint)
    if county ~= "" and county ~= "Unknown County" then
        return county
    end

    if x and y then
        local detectedCounty = DT_GeolocatorSystem.GetCountyName(x, y)
        if detectedCounty and detectedCounty ~= "Unknown County" then
            return detectedCounty
        end
    end

    return "Uncharted"
end