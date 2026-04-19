-- =============================================================================
-- GEOLOCATOR SYSTEM: LOAD LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

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

function DT_GeolocatorSystem.MarkLocationCachesDirty()
    DT_GeolocatorSystem.RegionCandidatesDirty = true
end

function DT_GeolocatorSystem.LoadBuildings()
    DT_GeolocatorSystem.InitCache()

    if DT_GeolocatorSystem.Buildings and DT_GeolocatorSystem.BuildingLookup then
        return true
    end

    local modData = ModData.getOrCreate(DT_GeolocatorSystem.MOD_DATA_KEY)
    if modData and modData.locations then
        DT_GeolocatorSystem.Buildings = modData.locations
        DynamicTrading.Log("DTCommons", "Mapping", "Init", "Loaded " .. #DT_GeolocatorSystem.Buildings .. " buildings from ModData.")
    else
        DT_GeolocatorSystem.Buildings = DT_GeolocatorSystem.ScanForBuildings()
    end

    DT_GeolocatorSystem.BuildingLookup = {}
    for _, building in ipairs(DT_GeolocatorSystem.Buildings) do
        DT_GeolocatorSystem.BuildingLookup[building.x .. "," .. building.y] = building
    end

    DT_GeolocatorSystem.RegionCandidatesDirty = true
    return true
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

    for _, building in ipairs(DT_GeolocatorSystem.Buildings or {}) do
        if DT_GeolocatorSystem.IsValidFactionBase(building) then
            local regionName = DT_GeolocatorSystem.ResolveRegionName(building.cx or building.x, building.cy or building.y, building.town, building.county)
            local matchesTarget = requestedTown == ""
                or regionName == requestedTown
                or normalizeText(building.town) == requestedTown
                or normalizeText(building.county) == requestedTown

            if matchesTarget then
                local uniqueName = DT_GeolocatorSystem.GetBuildingUniqueName(building)
                if not occupied[uniqueName] then
                    table.insert(results, {
                        name = uniqueName,
                        coords = {
                            x = building.cx or building.x,
                            y = building.cy or building.y,
                            z = 0,
                        },
                        town = regionName,
                        county = building.county,
                        area = building.area,
                        details = building.details,
                    })
                end
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
    for regionName, candidates in pairs(DT_GeolocatorSystem.RegionCandidates or {}) do
        if not isUnknownRegion(regionName) and type(candidates) == "table" and #candidates > 0 then
            table.insert(results, regionName)
        end
    end

    table.sort(results)
    return results
end