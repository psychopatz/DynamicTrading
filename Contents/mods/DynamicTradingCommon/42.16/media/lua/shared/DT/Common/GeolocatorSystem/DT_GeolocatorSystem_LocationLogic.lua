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