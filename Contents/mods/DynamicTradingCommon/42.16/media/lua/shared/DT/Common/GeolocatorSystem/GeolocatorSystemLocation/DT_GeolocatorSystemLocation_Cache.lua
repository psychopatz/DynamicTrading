return function(context)
    local function upsertLocation(location)
        if not location then
            return nil
        end

        local shortName = context.normalizeLocationName(location.shortName or location.longName or location.name)
        if shortName == "" then
            return nil
        end

        local key = context.normalizeLocationKey(location.id or shortName)
        local existing = DT_GeolocatorSystem.LocationIndex[key]
        if existing then
            existing.shortName = shortName
            existing.longName = context.normalizeLocationName(location.longName or existing.longName or shortName)
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
            longName = context.normalizeLocationName(location.longName or shortName),
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
        if DT_GeolocatorSystem.EnsureRegionRegistryBuilt then
            DT_GeolocatorSystem.EnsureRegionRegistryBuilt()
        end

        if DT_GeolocatorSystem.CacheInitialized then
            return
        end

        DT_GeolocatorSystem.ActiveLocations = {}
        DT_GeolocatorSystem.LocationIndex = {}

        local registry = DT_GeolocatorSystem.Registry or {}
        for _, location in ipairs(registry.Locations or {}) do
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
        return context.normalizeLocationKey(value)
    end

    function DT_GeolocatorSystem.FindLocationByName(value)
        DT_GeolocatorSystem.InitCache()

        local targetKey = context.normalizeLocationKey(value)
        if not targetKey then
            return nil
        end

        local locations = DT_GeolocatorSystem.ActiveLocations or {}
        for _, location in ipairs(locations) do
            if context.normalizeLocationKey(location.id) == targetKey
                or context.normalizeLocationKey(location.shortName) == targetKey
                or context.normalizeLocationKey(location.longName) == targetKey then
                return location
            end
        end

        return nil
    end
end
