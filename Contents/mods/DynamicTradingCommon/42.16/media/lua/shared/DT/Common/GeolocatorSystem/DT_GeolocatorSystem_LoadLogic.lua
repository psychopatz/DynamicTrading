-- =============================================================================
-- GEOLOCATOR SYSTEM: LOAD LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.LoadState = DT_GeolocatorSystem.LoadState or {
    status = "idle",
    source = nil,
    startedAtMs = nil,
    lastDurationMs = nil,
    lastBuildingCount = 0,
}

local INDEX_SCHEMA_VERSION = 1
local SPATIAL_HASH_CELL_SIZE = 300

local function normalizeIndexKey(value)
    if DT_GeolocatorSystem.NormalizeLocationKey then
        return DT_GeolocatorSystem.NormalizeLocationKey(value)
    end

    if value == nil then
        return nil
    end

    local normalized = tostring(value):lower()
    normalized = normalized:gsub(",%s*ky$", "")
    normalized = normalized:gsub("%s+ky$", "")
    normalized = normalized:gsub("[^%w]", "")
    if normalized == "" then
        return nil
    end

    return normalized
end

local function getClockMs()
    if getTimestampMs then
        return getTimestampMs()
    end

    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor(gameTime:getWorldAgeHours() * 3600000)
    end

    return nil
end

local function resetMapTable(target)
    if type(target) ~= "table" then
        return
    end

    for key in pairs(target) do
        target[key] = nil
    end
end

local function appendIndexedBuilding(index, key, building)
    local normalizedKey = normalizeIndexKey(key)
    if not normalizedKey then
        return
    end

    local bucket = index[normalizedKey]
    if not bucket then
        bucket = {}
        index[normalizedKey] = bucket
    end
    bucket[#bucket + 1] = building
end

local function getSpatialCellCoord(value)
    return math.floor((tonumber(value) or 0) / SPATIAL_HASH_CELL_SIZE)
end

local function getSpatialCellKey(x, y)
    return tostring(getSpatialCellCoord(x)) .. "," .. tostring(getSpatialCellCoord(y))
end

local function rebuildDerivedIndices()
    if (DT_GeolocatorSystem.IndexSchemaVersion or 0) == INDEX_SCHEMA_VERSION
        and DT_GeolocatorSystem.IndexVersion == DT_GeolocatorSystem.BuildVersion then
        return
    end

    DT_GeolocatorSystem.BuildingLookup = DT_GeolocatorSystem.BuildingLookup or {}
    DT_GeolocatorSystem.BuildingsByTown = DT_GeolocatorSystem.BuildingsByTown or {}
    DT_GeolocatorSystem.BuildingsByCounty = DT_GeolocatorSystem.BuildingsByCounty or {}
    DT_GeolocatorSystem.BuildingsByName = DT_GeolocatorSystem.BuildingsByName or {}
    DT_GeolocatorSystem.SpatialHash = DT_GeolocatorSystem.SpatialHash or {}

    resetMapTable(DT_GeolocatorSystem.BuildingLookup)
    resetMapTable(DT_GeolocatorSystem.BuildingsByTown)
    resetMapTable(DT_GeolocatorSystem.BuildingsByCounty)
    resetMapTable(DT_GeolocatorSystem.BuildingsByName)
    resetMapTable(DT_GeolocatorSystem.SpatialHash)

    for _, building in ipairs(DT_GeolocatorSystem.Buildings or {}) do
        DT_GeolocatorSystem.BuildingLookup[tostring(building.x) .. "," .. tostring(building.y)] = building
        appendIndexedBuilding(DT_GeolocatorSystem.BuildingsByTown, building.town, building)
        appendIndexedBuilding(DT_GeolocatorSystem.BuildingsByCounty, building.county, building)
        appendIndexedBuilding(DT_GeolocatorSystem.BuildingsByName, building.name, building)

        local spatialKey = getSpatialCellKey(building.cx or building.x, building.cy or building.y)
        local bucket = DT_GeolocatorSystem.SpatialHash[spatialKey]
        if not bucket then
            bucket = {}
            DT_GeolocatorSystem.SpatialHash[spatialKey] = bucket
        end
        bucket[#bucket + 1] = building
    end

    DT_GeolocatorSystem.IndexSchemaVersion = INDEX_SCHEMA_VERSION
    DT_GeolocatorSystem.IndexVersion = DT_GeolocatorSystem.BuildVersion
end

local function rebuildBuildingLookup()
    rebuildDerivedIndices()
end

local function setBuildings(buildings)
    DT_GeolocatorSystem.Buildings = buildings or {}
    DT_GeolocatorSystem.BuildVersion = (DT_GeolocatorSystem.BuildVersion or 0) + 1
    DT_GeolocatorSystem.RegionCandidatesDirty = true
    rebuildBuildingLookup()
end

local function hasAnyEntries(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    for _, _ in pairs(tbl) do
        return true
    end

    return false
end

local function getBuildingModData()
    return ModData.getOrCreate(DT_GeolocatorSystem.MOD_DATA_KEY or "DT_Buildings")
end

function DT_GeolocatorSystem.HasBuildingsLoaded()
    return type(DT_GeolocatorSystem.Buildings) == "table" and #DT_GeolocatorSystem.Buildings > 0
end

function DT_GeolocatorSystem.GetLoadState()
    return DT_GeolocatorSystem.LoadState
end

function DT_GeolocatorSystem.CanScanBuildings()
    local world = getWorld and getWorld() or nil
    local metaGrid = world and world:getMetaGrid() or nil
    if not metaGrid then
        return false
    end

    local buildings = metaGrid:getBuildings()
    return buildings ~= nil and buildings:size() > 0
end

function DT_GeolocatorSystem.PersistBuildings()
    if not DT_GeolocatorSystem.HasBuildingsLoaded or not DT_GeolocatorSystem.HasBuildingsLoaded() then
        return false
    end

    local modData = getBuildingModData()
    modData.locations = DT_GeolocatorSystem.Buildings
    modData.indexSchemaVersion = INDEX_SCHEMA_VERSION
    ModData.transmit(DT_GeolocatorSystem.MOD_DATA_KEY or "DT_Buildings")
    return true
end

function DT_GeolocatorSystem.ReplaceBuildings(buildings, persistToModData)
    if type(buildings) ~= "table" or #buildings == 0 then
        return false
    end

    setBuildings(buildings)
    if persistToModData then
        DT_GeolocatorSystem.PersistBuildings()
    end
    return true
end

function DT_GeolocatorSystem.EnsureBuildingsLoaded(allowScan, persistToModData)
    if DT_GeolocatorSystem.InitCache then
        DT_GeolocatorSystem.InitCache()
    end

    local loadState = DT_GeolocatorSystem.LoadState or {}
    if DT_GeolocatorSystem.HasBuildingsLoaded and DT_GeolocatorSystem.HasBuildingsLoaded() then
        if not hasAnyEntries(DT_GeolocatorSystem.BuildingLookup)
            or DT_GeolocatorSystem.IndexVersion ~= DT_GeolocatorSystem.BuildVersion then
            rebuildBuildingLookup()
        end
        loadState.status = "ready"
        loadState.lastBuildingCount = #(DT_GeolocatorSystem.Buildings or {})
        return true
    end

    if loadState.status == "loading" then
        return false
    end

    local startedAtMs = getClockMs()
    loadState.status = "loading"
    loadState.source = nil
    loadState.startedAtMs = startedAtMs

    local modData = getBuildingModData()
    if modData and type(modData.locations) == "table" and #modData.locations > 0 then
        setBuildings(modData.locations)
        loadState.status = "ready"
        loadState.source = "moddata"
        loadState.lastBuildingCount = #DT_GeolocatorSystem.Buildings
        if startedAtMs then
            loadState.lastDurationMs = math.max(0, (getClockMs() or startedAtMs) - startedAtMs)
        end
        DynamicTrading.Log("DTCommons", "Mapping", "Init", "Loaded " .. #DT_GeolocatorSystem.Buildings .. " buildings from ModData.")
        return true
    end

    if not allowScan then
        loadState.status = "idle"
        return false
    end

    if not DT_GeolocatorSystem.CanScanBuildings or not DT_GeolocatorSystem.CanScanBuildings() then
        loadState.status = "idle"
        DynamicTrading.Log("DTCommons", "Mapping", "Warn", "Building scan requested before world building data was ready.")
        return false
    end

    local scanned = DT_GeolocatorSystem.ScanForBuildings and DT_GeolocatorSystem.ScanForBuildings() or nil
    if type(scanned) ~= "table" or #scanned == 0 then
        loadState.status = "idle"
        DynamicTrading.Log("DTCommons", "Mapping", "Warn", "Building scan returned no results; cache remains uninitialized.")
        return false
    end

    setBuildings(scanned)
    loadState.status = "ready"
    loadState.source = "scan"
    loadState.lastBuildingCount = #DT_GeolocatorSystem.Buildings
    if startedAtMs then
        loadState.lastDurationMs = math.max(0, (getClockMs() or startedAtMs) - startedAtMs)
    end
    if persistToModData then
        DT_GeolocatorSystem.PersistBuildings()
    end
    DynamicTrading.Log(
        "DTCommons",
        "Mapping",
        "Init",
        "Geolocator ready via " .. tostring(loadState.source) .. " with " .. tostring(loadState.lastBuildingCount)
            .. " buildings in " .. tostring(loadState.lastDurationMs or "?") .. " ms."
    )
    return true
end

function DT_GeolocatorSystem.LoadBuildings()
    return DT_GeolocatorSystem.EnsureBuildingsLoaded(true, false)
end

function DT_GeolocatorSystem.GetBuildingsByTown(value)
    if not DT_GeolocatorSystem.HasBuildingsLoaded() then
        return {}
    end

    rebuildDerivedIndices()
    return DT_GeolocatorSystem.BuildingsByTown[normalizeIndexKey(value)] or {}
end

function DT_GeolocatorSystem.GetBuildingsByCounty(value)
    if not DT_GeolocatorSystem.HasBuildingsLoaded() then
        return {}
    end

    rebuildDerivedIndices()
    return DT_GeolocatorSystem.BuildingsByCounty[normalizeIndexKey(value)] or {}
end

function DT_GeolocatorSystem.GetBuildingsByName(value)
    if not DT_GeolocatorSystem.HasBuildingsLoaded() then
        return {}
    end

    rebuildDerivedIndices()
    return DT_GeolocatorSystem.BuildingsByName[normalizeIndexKey(value)] or {}
end

function DT_GeolocatorSystem.GetBuildingsInBounds(minX, minY, maxX, maxY)
    if not DT_GeolocatorSystem.HasBuildingsLoaded() then
        return {}
    end

    rebuildDerivedIndices()

    local results = {}
    local seen = {}
    local startCellX = getSpatialCellCoord(minX)
    local endCellX = getSpatialCellCoord(maxX)
    local startCellY = getSpatialCellCoord(minY)
    local endCellY = getSpatialCellCoord(maxY)

    for cellX = startCellX, endCellX do
        for cellY = startCellY, endCellY do
            local bucket = DT_GeolocatorSystem.SpatialHash[tostring(cellX) .. "," .. tostring(cellY)] or nil
            if bucket then
                for _, building in ipairs(bucket) do
                    if not seen[building] then
                        local bx = tonumber(building.cx) or tonumber(building.x)
                        local by = tonumber(building.cy) or tonumber(building.y)
                        if bx and by and bx >= minX and bx <= maxX and by >= minY and by <= maxY then
                            seen[building] = true
                            results[#results + 1] = building
                        end
                    end
                end
            end
        end
    end

    return results
end

function DT_GeolocatorSystem.GetBuildingsNearPoint(x, y, maxRadius, targetTown)
    if not DT_GeolocatorSystem.HasBuildingsLoaded() then
        return {}
    end

    rebuildDerivedIndices()

    local results = {}
    local seen = {}
    local radius = tonumber(maxRadius) or 0
    local radiusSq = radius * radius
    local normalizedTown = normalizeIndexKey(targetTown)
    local minX = tonumber(x) - radius
    local maxX = tonumber(x) + radius
    local minY = tonumber(y) - radius
    local maxY = tonumber(y) + radius
    local startCellX = getSpatialCellCoord(minX)
    local endCellX = getSpatialCellCoord(maxX)
    local startCellY = getSpatialCellCoord(minY)
    local endCellY = getSpatialCellCoord(maxY)

    for cellX = startCellX, endCellX do
        for cellY = startCellY, endCellY do
            local bucket = DT_GeolocatorSystem.SpatialHash[tostring(cellX) .. "," .. tostring(cellY)] or nil
            if bucket then
                for _, building in ipairs(bucket) do
                    if not seen[building] then
                        local bx = tonumber(building.cx) or tonumber(building.x)
                        local by = tonumber(building.cy) or tonumber(building.y)
                        if bx and by then
                            local dx = bx - x
                            local dy = by - y
                            local distSq = (dx * dx) + (dy * dy)
                            if distSq <= radiusSq then
                                local matchesTown = (not normalizedTown)
                                    or normalizeIndexKey(building.town) == normalizedTown
                                    or normalizeIndexKey(building.county) == normalizedTown
                                if matchesTown then
                                    seen[building] = true
                                    results[#results + 1] = building
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return results
end

local function normalizeText(value)
    local text = tostring(value or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    text = text:gsub("%s+", " ")
    return text
end

local function lowerText(value)
    return normalizeText(value):lower()
end

local function isUnknownRegion(name)
    local normalized = normalizeText(name)
    return normalized == "" or normalized == "Wilderness" or normalized == "Unknown County" or normalized == "Uncharted"
end

local function addUniqueRegion(results, seen, name)
    local normalized = normalizeText(name)
    if isUnknownRegion(normalized) then
        return
    end

    local key = lowerText(normalized)
    if key == "" or seen[key] then
        return
    end

    seen[key] = true
    table.insert(results, normalized)
end

local function buildBaseResult(building, regionName)
    return {
        name = DT_GeolocatorSystem.GetBuildingUniqueName(building),
        coords = {
            x = building.cx or building.x,
            y = building.cy or building.y,
            z = 0,
        },
        town = regionName,
        county = building.county,
        area = building.area,
        details = building.details,
    }
end

local function collectLegacySeedTowns(results, seen)
    if type(DT_FactionLocations) ~= "table" then
        return
    end

    for townName, locations in pairs(DT_FactionLocations) do
        if type(locations) == "table" and #locations > 0 then
            addUniqueRegion(results, seen, townName)
        end
    end
end

function DT_GeolocatorSystem.MarkLocationCachesDirty()
    DT_GeolocatorSystem.RegionCandidatesDirty = true
    DT_GeolocatorSystem.BuildVersion = (DT_GeolocatorSystem.BuildVersion or 0) + 1
    DT_GeolocatorSystem.IndexVersion = nil
end

function DT_GeolocatorSystem.IsValidFactionBase(building)
    if not building then
        return false
    end

    local area = tonumber(building.area) or 0
    if area < (DT_GeolocatorSystem.Config.MinFactionBaseArea or 150) then
        return false
    end

    local details = building.details or {}
    local primaryRoom = lowerText(details.primaryRoom or building.name)
    for _, blacklistedRoom in ipairs(DT_GeolocatorSystem.Config.BlacklistedRooms or {}) do
        if primaryRoom == lowerText(blacklistedRoom) then
            return false
        end
    end

    return true
end

function DT_GeolocatorSystem.GetBuildingUniqueName(building)
    local x = math.floor(tonumber(building and (building.cx or building.x)) or 0)
    local y = math.floor(tonumber(building and (building.cy or building.y)) or 0)
    local baseName = normalizeText(building and (building.name or (building.details and building.details.primaryRoom)) or "")

    if baseName == "" or baseName == "Building" or baseName == "unknown" then
        local region = DT_GeolocatorSystem.ResolveRegionName(
            building and (building.cx or building.x),
            building and (building.cy or building.y),
            building and building.town,
            building and building.county
        )
        if not isUnknownRegion(region) then
            baseName = region .. " Outpost"
        else
            baseName = "Dynamic Outpost"
        end
    end

    return string.format("%s (%d,%d)", baseName, x, y)
end

function DT_GeolocatorSystem.RefreshRegionCache()
    if not DT_GeolocatorSystem.RegionCandidatesDirty then
        return
    end

    DT_GeolocatorSystem.RegionCandidates = {}
    DT_GeolocatorSystem.LoadBuildings()

    for _, building in ipairs(DT_GeolocatorSystem.Buildings or {}) do
        building.town = normalizeText(building.town)
        building.county = normalizeText(building.county)

        if isUnknownRegion(building.town) then
            building.town = DT_GeolocatorSystem.ResolveRegionName(building.cx or building.x, building.cy or building.y, nil, building.county)
        end
        if building.county == "" then
            building.county = DT_GeolocatorSystem.GetCountyName(building.cx or building.x, building.cy or building.y)
        end

        if DT_GeolocatorSystem.IsValidFactionBase(building) then
            local regionName = DT_GeolocatorSystem.ResolveRegionName(building.cx or building.x, building.cy or building.y, building.town, building.county)
            local candidates = DT_GeolocatorSystem.RegionCandidates[regionName]
            if not candidates then
                candidates = {}
                DT_GeolocatorSystem.RegionCandidates[regionName] = candidates
            end
            table.insert(candidates, building)
        end
    end

    DT_GeolocatorSystem.RegionCandidatesDirty = false
end

function DT_GeolocatorSystem.GetAvailableFactionBases(targetTown, takenLocations)
    DT_GeolocatorSystem.RefreshRegionCache()

    local requestedTown = normalizeText(targetTown)
    local results = {}
    local occupied = takenLocations or {}

    local function tryInsertBuilding(building)
        local regionName = DT_GeolocatorSystem.ResolveRegionName(building.cx or building.x, building.cy or building.y, building.town, building.county)
        local matchesTarget = requestedTown == ""
            or regionName == requestedTown
            or normalizeText(building.town) == requestedTown
            or normalizeText(building.county) == requestedTown

        if not matchesTarget then
            return
        end

        local uniqueName = DT_GeolocatorSystem.GetBuildingUniqueName(building)
        if occupied[uniqueName] then
            return
        end

        table.insert(results, buildBaseResult(building, regionName))
    end

    for _, building in ipairs(DT_GeolocatorSystem.Buildings or {}) do
        if DT_GeolocatorSystem.IsValidFactionBase(building) then
            tryInsertBuilding(building)
        end
    end

    if #results == 0 then
        local minArea = DT_GeolocatorSystem.Config.MinFactionBaseArea or 150
        for _, building in ipairs(DT_GeolocatorSystem.Buildings or {}) do
            if (tonumber(building.area) or 0) >= minArea then
                tryInsertBuilding(building)
            end
        end
    end

    table.sort(results, function(a, b)
        if (a.area or 0) ~= (b.area or 0) then
            return (a.area or 0) > (b.area or 0)
        end
        return tostring(a.name) < tostring(b.name)
    end)

    return results
end

function DT_GeolocatorSystem.GetSeedTowns()
    DT_GeolocatorSystem.RefreshRegionCache()

    local results = {}
    local seen = {}
    for regionName, candidates in pairs(DT_GeolocatorSystem.RegionCandidates or {}) do
        if not isUnknownRegion(regionName) and type(candidates) == "table" and #candidates > 0 then
            addUniqueRegion(results, seen, regionName)
        end
    end

    collectLegacySeedTowns(results, seen)

    if #results == 0 then
        for _, building in ipairs(DT_GeolocatorSystem.Buildings or {}) do
            local regionName = DT_GeolocatorSystem.ResolveRegionName(building.cx or building.x, building.cy or building.y, building.town, building.county)
            addUniqueRegion(results, seen, regionName)
        end
    end

    table.sort(results)
    return results
end