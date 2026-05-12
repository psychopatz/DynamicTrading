return function(context)
    function context.appendIndexedBuilding(index, key, building)
        local normalizedKey = context.normalizeIndexKey(key)
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

    function context.getSpatialCellCoord(value)
        return math.floor((tonumber(value) or 0) / context.SPATIAL_HASH_CELL_SIZE)
    end

    function context.getSpatialCellKey(x, y)
        return tostring(context.getSpatialCellCoord(x)) .. "," .. tostring(context.getSpatialCellCoord(y))
    end

    function context.rebuildDerivedIndices()
        if (DT_GeolocatorSystem.IndexSchemaVersion or 0) == context.INDEX_SCHEMA_VERSION
            and DT_GeolocatorSystem.IndexVersion == DT_GeolocatorSystem.BuildVersion then
            return
        end

        DT_GeolocatorSystem.BuildingLookup = DT_GeolocatorSystem.BuildingLookup or {}
        DT_GeolocatorSystem.BuildingsByTown = DT_GeolocatorSystem.BuildingsByTown or {}
        DT_GeolocatorSystem.BuildingsByCounty = DT_GeolocatorSystem.BuildingsByCounty or {}
        DT_GeolocatorSystem.BuildingsByName = DT_GeolocatorSystem.BuildingsByName or {}
        DT_GeolocatorSystem.SpatialHash = DT_GeolocatorSystem.SpatialHash or {}

        context.resetMapTable(DT_GeolocatorSystem.BuildingLookup)
        context.resetMapTable(DT_GeolocatorSystem.BuildingsByTown)
        context.resetMapTable(DT_GeolocatorSystem.BuildingsByCounty)
        context.resetMapTable(DT_GeolocatorSystem.BuildingsByName)
        context.resetMapTable(DT_GeolocatorSystem.SpatialHash)

        for _, building in ipairs(DT_GeolocatorSystem.Buildings or {}) do
            DT_GeolocatorSystem.BuildingLookup[tostring(building.x) .. "," .. tostring(building.y)] = building
            context.appendIndexedBuilding(DT_GeolocatorSystem.BuildingsByTown, building.town, building)
            context.appendIndexedBuilding(DT_GeolocatorSystem.BuildingsByCounty, building.county, building)
            context.appendIndexedBuilding(DT_GeolocatorSystem.BuildingsByName, building.name, building)

            local spatialKey = context.getSpatialCellKey(building.cx or building.x, building.cy or building.y)
            local bucket = DT_GeolocatorSystem.SpatialHash[spatialKey]
            if not bucket then
                bucket = {}
                DT_GeolocatorSystem.SpatialHash[spatialKey] = bucket
            end
            bucket[#bucket + 1] = building
        end

        DT_GeolocatorSystem.IndexSchemaVersion = context.INDEX_SCHEMA_VERSION
        DT_GeolocatorSystem.IndexVersion = DT_GeolocatorSystem.BuildVersion
    end

    function context.rebuildBuildingLookup()
        context.rebuildDerivedIndices()
    end

    function context.setBuildings(buildings)
        DT_GeolocatorSystem.Buildings = buildings or {}
        DT_GeolocatorSystem.BuildVersion = (DT_GeolocatorSystem.BuildVersion or 0) + 1
        DT_GeolocatorSystem.RegionCandidatesDirty = true
        context.rebuildBuildingLookup()
    end

    function context.hasAnyEntries(tbl)
        if type(tbl) ~= "table" then
            return false
        end

        for _, _ in pairs(tbl) do
            return true
        end

        return false
    end
end
