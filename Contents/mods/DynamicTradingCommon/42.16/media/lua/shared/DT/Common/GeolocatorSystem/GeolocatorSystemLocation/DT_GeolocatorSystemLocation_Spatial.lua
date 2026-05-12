return function(context)
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
        local minRadius, maxRadius = context.getSpatialRadiusRange(options)
        local players = context.collectSpatialAnchorPlayers()

        if #players > 0 then
            local anchor = players[ZombRand(#players) + 1]
            local anchorX = math.floor(anchor:getX())
            local anchorY = math.floor(anchor:getY())
            local anchorZ = math.floor((anchor.getZ and anchor:getZ()) or 0)
            local building = context.pickNearbyBuildingForAnchor(anchorX, anchorY, minRadius, maxRadius, targetTown)

            if building then
                local bx = tonumber(building.cx) or tonumber(building.x) or anchorX
                local by = tonumber(building.cy) or tonumber(building.y) or anchorY
                local buildingTown = building.town or (DT_GeolocatorSystem.GetTownName and DT_GeolocatorSystem.GetTownName(bx, by)) or targetTown
                local buildingCounty = building.county or (DT_GeolocatorSystem.GetCountyName and DT_GeolocatorSystem.GetCountyName(bx, by)) or nil
                return context.buildSpatialHomeEntry(bx, by, 0, building.name or label, buildingTown, buildingCounty, "nearby-building")
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
            return context.buildSpatialHomeEntry(x, y, anchorZ, name, town, county, "nearby-player")
        end

        if resolvedLocation then
            return context.buildLocationCenterEntry(resolvedLocation, label)
        end

        if DT_GeolocatorSystem.ActiveLocations and #DT_GeolocatorSystem.ActiveLocations > 0 then
            local fallbackLocation = DT_GeolocatorSystem.ActiveLocations[ZombRand(#DT_GeolocatorSystem.ActiveLocations) + 1]
            return context.buildLocationCenterEntry(fallbackLocation, label)
        end

        return context.buildSpatialHomeEntry(0, 0, 0, label or "Nomadic Route", targetTown or "Unknown", nil, "origin-fallback")
    end
end
