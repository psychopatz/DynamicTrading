DT_GeolocatorSystem = DT_GeolocatorSystem or {}
DT_GeolocatorSystem.Registry = DT_GeolocatorSystem.Registry or {}

local Registry = DT_GeolocatorSystem.Registry

local function normalizeKey(value)
    if Registry.NormalizeRegistryKey then
        return Registry.NormalizeRegistryKey(value)
    end

    local text = tostring(value or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    text = text:gsub("%s+", " ")
    text = text:lower()
    text = text:gsub("[^%w]+", "_")
    text = text:gsub("^_+", "")
    text = text:gsub("_+$", "")
    return text
end

local function cloneArray(values)
    local result = {}
    for _, value in ipairs(values or {}) do
        result[#result + 1] = value
    end
    return result
end

local function copyLocation(definition, location)
    return {
        id = normalizeKey(location.id or location.shortName or location.longName),
        longName = location.longName or location.shortName or definition.name,
        shortName = location.shortName or location.longName or definition.name,
        mod = location.mod or definition.mod,
        isVanilla = location.isVanilla == true or definition.isVanilla == true,
        startX = math.floor(tonumber(location.startX) or 0),
        endX = math.floor(tonumber(location.endX) or 0),
        startY = math.floor(tonumber(location.startY) or 0),
        endY = math.floor(tonumber(location.endY) or 0),
        regionID = definition.id,
    }
end

local function copyTown(definition, town)
    return {
        id = normalizeKey(town.id or town.name or definition.name),
        name = town.name or definition.name,
        mod = town.mod or definition.mod,
        isVanilla = town.isVanilla == true or definition.isVanilla == true,
        minX = math.floor(tonumber(town.minX) or 0),
        maxX = math.floor(tonumber(town.maxX) or 0),
        minY = math.floor(tonumber(town.minY) or 0),
        maxY = math.floor(tonumber(town.maxY) or 0),
        regionID = definition.id,
    }
end

local function copyCounty(definition, county)
    return {
        id = normalizeKey(county.id or county.name or definition.name),
        name = county.name or definition.name,
        mod = county.mod or definition.mod,
        isVanilla = county.isVanilla == true or definition.isVanilla == true,
        bounds = {
            minX = math.floor(tonumber(county.bounds and county.bounds.minX) or 0),
            maxX = math.floor(tonumber(county.bounds and county.bounds.maxX) or 0),
            minY = math.floor(tonumber(county.bounds and county.bounds.minY) or 0),
            maxY = math.floor(tonumber(county.bounds and county.bounds.maxY) or 0),
        },
        towns = cloneArray(county.towns or {}),
        regionID = definition.id,
    }
end

local function copyPOI(definition, poi)
    return {
        id = normalizeKey(poi.id or poi.name or definition.name),
        name = poi.name or definition.name,
        type = poi.type or "POI",
        town = poi.town,
        county = poi.county,
        mod = poi.mod or definition.mod,
        isVanilla = poi.isVanilla == true or definition.isVanilla == true,
        x = tonumber(poi.x) or 0,
        y = tonumber(poi.y) or 0,
        z = tonumber(poi.z) or 0,
        startX = tonumber(poi.startX),
        endX = tonumber(poi.endX),
        startY = tonumber(poi.startY),
        endY = tonumber(poi.endY),
        metadata = type(poi.metadata) == "table" and poi.metadata or nil,
        regionID = definition.id,
    }
end

local function sortDefinitions(a, b)
    if (a.order or 1000) ~= (b.order or 1000) then
        return (a.order or 1000) < (b.order or 1000)
    end
    return tostring(a.id) < tostring(b.id)
end

local function buildWorldMapSet()
    local result = {}
    local world = getWorld and getWorld() or nil
    local currentMap = world and world:getMap() or nil
    local normalize = DT_GeolocatorSystem.NormalizeGeolocatorRegistryKey or normalizeKey

    for token in tostring(currentMap or ""):gmatch("[^;]+") do
        local key = normalize(token)
        if key ~= "" then
            result[key] = true
        end
    end

    return result
end

local function containsActivatedMod(modID)
    local activated = getActivatedMods and getActivatedMods() or nil
    if not activated or not modID or modID == "" then
        return false
    end

    if activated.contains and activated:contains(modID) then
        return true
    end

    for i = 0, (activated.size and activated:size() or 0) - 1 do
        if tostring(activated:get(i)) == tostring(modID) then
            return true
        end
    end

    return false
end

local function eachCollectionValue(values, callback)
    if not values or type(callback) ~= "function" then
        return
    end

    if type(values) == "table" then
        for _, value in ipairs(values) do
            callback(value)
        end
        return
    end

    if values.size and values.get then
        local size = tonumber(values:size()) or 0
        for i = 0, size - 1 do
            callback(values:get(i))
        end
    end
end

local function hasActivatedWorldMap(definition, worldMaps)
    if not worldMaps or #worldMaps == 0 then
        return false
    end

    local normalize = DT_GeolocatorSystem.NormalizeGeolocatorRegistryKey or normalizeKey
    local activation = definition and definition.activation or {}
    local modIDs = activation.modIDs or {}
    local activeMaps = buildWorldMapSet()
    for _, worldMap in ipairs(worldMaps) do
        if activeMaps[normalize(worldMap)] then
            return true
        end
    end

    if #modIDs == 0 or not getMapFoldersForMod then
        return false
    end

    for _, modID in ipairs(modIDs) do
        local folders = getMapFoldersForMod(modID) or {}
        local matched = false
        eachCollectionValue(folders, function(folder)
            if activeMaps[normalize(folder)] then
                matched = true
            end
        end)
        if matched then
            return true
        end
    end

    return false
end

local function isDefinitionActive(definition)
    local activation = definition.activation or {}
    if activation.always == true then
        return true
    end

    if hasActivatedWorldMap(definition, activation.worldMaps or {}) then
        return true
    end

    if hasActivatedWorldMap(definition, activation.mapFolders or {}) then
        return true
    end

    for _, modID in ipairs(activation.modIDs or {}) do
        if containsActivatedMod(modID) then
            return true
        end
    end

    return false
end

function DT_GeolocatorSystem.BuildRegionRegistry(force)
    if not force and Registry.BuiltRevision == Registry.RegisteredRevision then
        return Registry
    end

    local registered = Registry.RegisteredDefinitions or {}
    table.sort(registered, sortDefinitions)
    Registry._DefinitionIndex = {}
    for index, definition in ipairs(registered) do
        Registry._DefinitionIndex[definition.id] = index
    end

    local locations = {}
    local towns = {}
    local counties = {}
    local pois = {}
    local seenLocations = {}
    local seenTowns = {}
    local seenCounties = {}
    local seenPOIs = {}

    for _, definition in ipairs(registered) do
        if isDefinitionActive(definition) then
        for _, location in ipairs(definition.locations or {}) do
            local entry = copyLocation(definition, location)
            if entry.id ~= "" and not seenLocations[entry.id] then
                seenLocations[entry.id] = true
                locations[#locations + 1] = entry
            end
        end

        for _, town in ipairs(definition.towns or {}) do
            local entry = copyTown(definition, town)
            if entry.id ~= "" and not seenTowns[entry.id] then
                seenTowns[entry.id] = true
                towns[#towns + 1] = entry
            end
        end

        for _, county in ipairs(definition.counties or {}) do
            local entry = copyCounty(definition, county)
            if entry.id ~= "" and not seenCounties[entry.id] then
                seenCounties[entry.id] = true
                counties[#counties + 1] = entry
            end
        end

        for _, poi in ipairs(definition.pois or {}) do
            local entry = copyPOI(definition, poi)
            if entry.id ~= "" and not seenPOIs[entry.id] then
                seenPOIs[entry.id] = true
                pois[#pois + 1] = entry
            end
        end
        end
    end

    Registry.Locations = locations
    Registry.Towns = towns
    Registry.Counties = counties
    Registry.POIs = pois
    Registry.Version = (tonumber(Registry.Version) or 0) + 1
    Registry.BuiltRevision = Registry.RegisteredRevision

    DT_GeolocatorSystem.ActiveLocations = {}
    DT_GeolocatorSystem.LocationIndex = {}
    DT_GeolocatorSystem.CacheInitialized = false
    DT_GeolocatorSystem.RegionCandidates = {}

    if DT_GeolocatorSystem.MarkLocationCachesDirty then
        DT_GeolocatorSystem.MarkLocationCachesDirty()
    else
        DT_GeolocatorSystem.RegionCandidatesDirty = true
        DT_GeolocatorSystem.BuildVersion = (tonumber(DT_GeolocatorSystem.BuildVersion) or 0) + 1
        DT_GeolocatorSystem.IndexVersion = nil
    end

    return Registry
end

function DT_GeolocatorSystem.EnsureRegionRegistryBuilt()
    return DT_GeolocatorSystem.BuildRegionRegistry(false)
end

return DT_GeolocatorSystem.BuildRegionRegistry
