DT_GeolocatorSystem = DT_GeolocatorSystem or {}
DT_GeolocatorSystem.Registry = DT_GeolocatorSystem.Registry or {}

local Registry = DT_GeolocatorSystem.Registry

Registry.Version = tonumber(Registry.Version) or 0
Registry.Locations = Registry.Locations or {}
Registry.Towns = Registry.Towns or {}
Registry.Counties = Registry.Counties or {}
Registry.POIs = Registry.POIs or {}
Registry.RegisteredDefinitions = Registry.RegisteredDefinitions or {}
Registry._DefinitionIndex = Registry._DefinitionIndex or {}
Registry.RegisteredRevision = tonumber(Registry.RegisteredRevision) or 0
Registry.BuiltRevision = tonumber(Registry.BuiltRevision) or -1

local function normalizeKey(value)
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

local function normalizeDefinition(definition)
    if type(definition) ~= "table" then
        return nil
    end

    local id = normalizeKey(definition.id or definition.name)
    if id == "" then
        return nil
    end

    local activation = definition.activation
    local normalizedActivation = {
        always = definition.isVanilla == true,
        modIDs = {},
        mapFolders = {},
        worldMaps = {},
    }

    if type(activation) == "table" then
        normalizedActivation.always = activation.always == true or normalizedActivation.always

        for _, modID in ipairs(activation.modIDs or {}) do
            normalizedActivation.modIDs[#normalizedActivation.modIDs + 1] = tostring(modID)
        end
        for _, mapFolder in ipairs(activation.mapFolders or {}) do
            normalizedActivation.mapFolders[#normalizedActivation.mapFolders + 1] = tostring(mapFolder)
        end
        for _, worldMap in ipairs(activation.worldMaps or {}) do
            normalizedActivation.worldMaps[#normalizedActivation.worldMaps + 1] = tostring(worldMap)
        end
    end

    return {
        id = id,
        name = tostring(definition.name or definition.id or id),
        mod = definition.mod or "Dynamic",
        isVanilla = definition.isVanilla == true,
        order = tonumber(definition.order) or 1000,
        activation = normalizedActivation,
        locations = type(definition.locations) == "table" and definition.locations or {},
        towns = type(definition.towns) == "table" and definition.towns or {},
        counties = type(definition.counties) == "table" and definition.counties or {},
        pois = type(definition.pois) == "table" and definition.pois or {},
    }
end

local function storeDefinition(normalized)
    if not normalized then
        return nil
    end

    local definitionIndex = Registry._DefinitionIndex
    local registered = Registry.RegisteredDefinitions
    local existingIndex = definitionIndex[normalized.id]

    if existingIndex then
        registered[existingIndex] = normalized
    else
        registered[#registered + 1] = normalized
        definitionIndex[normalized.id] = #registered
    end

    Registry.RegisteredRevision = Registry.RegisteredRevision + 1
    Registry.BuiltRevision = -1

    return normalized
end

function DT_GeolocatorSystem.RegisterRegionDefinition(definition)
    return storeDefinition(normalizeDefinition(definition))
end

Registry.NormalizeRegistryKey = normalizeKey
DT_GeolocatorSystem.NormalizeGeolocatorRegistryKey = normalizeKey

for _, pendingDefinition in ipairs(DT_GeolocatorSystem.PendingRegionDefinitions or {}) do
    storeDefinition(normalizeDefinition(pendingDefinition))
end

DT_GeolocatorSystem.PendingRegionDefinitions = {}

return Registry
