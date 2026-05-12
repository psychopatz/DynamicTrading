return function(context)
    function DT_GeolocatorSystem.GetBuildingsByTown(value)
        if not DT_GeolocatorSystem.HasBuildingsLoaded() then
            return {}
        end

        context.rebuildDerivedIndices()
        return DT_GeolocatorSystem.BuildingsByTown[context.normalizeIndexKey(value)] or {}
    end

    function DT_GeolocatorSystem.GetBuildingsByCounty(value)
        if not DT_GeolocatorSystem.HasBuildingsLoaded() then
            return {}
        end

        context.rebuildDerivedIndices()
        return DT_GeolocatorSystem.BuildingsByCounty[context.normalizeIndexKey(value)] or {}
    end

    function DT_GeolocatorSystem.GetBuildingsByName(value)
        if not DT_GeolocatorSystem.HasBuildingsLoaded() then
            return {}
        end

        context.rebuildDerivedIndices()
        return DT_GeolocatorSystem.BuildingsByName[context.normalizeIndexKey(value)] or {}
    end

    function DT_GeolocatorSystem.GetBuildingsInBounds(minX, minY, maxX, maxY)
        if not DT_GeolocatorSystem.HasBuildingsLoaded() then
            return {}
        end

        context.rebuildDerivedIndices()

        local results = {}
        local seen = {}
        local startCellX = context.getSpatialCellCoord(minX)
        local endCellX = context.getSpatialCellCoord(maxX)
        local startCellY = context.getSpatialCellCoord(minY)
        local endCellY = context.getSpatialCellCoord(maxY)

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

        context.rebuildDerivedIndices()

        local results = {}
        local seen = {}
        local radius = tonumber(maxRadius) or 0
        local radiusSq = radius * radius
        local normalizedTown = context.normalizeIndexKey(targetTown)
        local minX = tonumber(x) - radius
        local maxX = tonumber(x) + radius
        local minY = tonumber(y) - radius
        local maxY = tonumber(y) + radius
        local startCellX = context.getSpatialCellCoord(minX)
        local endCellX = context.getSpatialCellCoord(maxX)
        local startCellY = context.getSpatialCellCoord(minY)
        local endCellY = context.getSpatialCellCoord(maxY)

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
                                        or context.normalizeIndexKey(building.town) == normalizedTown
                                        or context.normalizeIndexKey(building.county) == normalizedTown
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
end
