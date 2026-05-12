return function(context)
    local function addTownZoneLocation(zone)
        if not zone then
            return nil
        end

        local zoneType = zone.getType and zone:getType() or zone.type
        if zoneType ~= "TownZone" then
            return nil
        end

        local zoneName = context.normalizeLocationName((zone.getName and zone:getName()) or zone.name or "Nearby Town")
        if zoneName == "" then
            zoneName = "Nearby Town"
        end

        local x = tonumber((zone.getX and zone:getX()) or zone.x)
        local y = tonumber((zone.getY and zone:getY()) or zone.y)
        local width = tonumber((zone.getW and zone:getW()) or (zone.getWidth and zone:getWidth()) or zone.w) or 0
        local height = tonumber((zone.getH and zone:getH()) or (zone.getHeight and zone:getHeight()) or zone.h) or 0
        if x == nil or y == nil then
            return nil
        end

        return DT_GeolocatorSystem.AddLocation(
            context.normalizeLocationKey(zoneName),
            zoneName,
            "Dynamic",
            x,
            y,
            x + width,
            y + height,
            zoneName
        )
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

    function DT_GeolocatorSystem.GetCountyName(x, y)
        if DT_GeolocatorSystem.EnsureRegionRegistryBuilt then
            DT_GeolocatorSystem.EnsureRegionRegistryBuilt()
        end

        local location = DT_GeolocatorSystem.GetLocation(x, y)
        if location and location.longName then
            return location.longName
        end

        local registry = DT_GeolocatorSystem.Registry or {}
        for _, county in ipairs(registry.Counties or {}) do
            if x >= county.bounds.minX and x <= county.bounds.maxX and y >= county.bounds.minY and y <= county.bounds.maxY then
                return county.name
            end
        end

        return "Unknown County"
    end

    function DT_GeolocatorSystem.GetTownName(x, y)
        if DT_GeolocatorSystem.EnsureRegionRegistryBuilt then
            DT_GeolocatorSystem.EnsureRegionRegistryBuilt()
        end

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
                    local zoneType = zone and ((zone.getType and zone:getType()) or zone.type) or nil
                    if zoneType == "TownZone" then
                        local dynamicLocation = addTownZoneLocation(zone)
                        if dynamicLocation and dynamicLocation.shortName then
                            return dynamicLocation.shortName
                        end
                        return context.normalizeLocationName(((zone and zone.getName) and zone:getName()) or zone.name or "Nearby Town")
                    end
                end
            end
        end

        local registry = DT_GeolocatorSystem.Registry or {}
        for _, town in ipairs(registry.Towns or {}) do
            if x >= town.minX and x <= town.maxX and y >= town.minY and y <= town.maxY then
                return town.name
            end
        end

        return "Wilderness"
    end

    function DT_GeolocatorSystem.ResolveRegionName(x, y, townHint, countyHint)
        local town = context.normalizeLocationName(townHint)
        if town ~= "" and town ~= "Wilderness" then
            return town
        end

        if x and y then
            local detectedTown = DT_GeolocatorSystem.GetTownName(x, y)
            if detectedTown and detectedTown ~= "" and detectedTown ~= "Wilderness" then
                return detectedTown
            end
        end

        local county = context.normalizeLocationName(countyHint)
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
end
