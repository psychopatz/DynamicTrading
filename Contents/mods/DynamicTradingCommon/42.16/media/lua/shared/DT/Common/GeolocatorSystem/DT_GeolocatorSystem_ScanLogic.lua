-- =============================================================================
-- GEOLOCATOR SYSTEM: SCAN LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

function DT_GeolocatorSystem.ScanForBuildings()
    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "STARTING DETAILED BUILDING SCAN WITH GEOLOCATOR MAPPING...")

    local world = getWorld and getWorld() or nil
    local metaGrid = world and world:getMetaGrid() or nil
    if not metaGrid then
        return {}
    end

    local buildings = metaGrid:getBuildings()
    local results = {}
    local minArea = DT_GeolocatorSystem.Config.MinBuildingArea

    for i = 0, buildings:size() - 1 do
        local def = buildings:get(i)
        local width = def:getW()
        local height = def:getH()
        local area = width * height

        if area >= minArea then
            local x = def:getX()
            local y = def:getY()
            local centerX = math.floor(x + (width / 2))
            local centerY = math.floor(y + (height / 2))
            local details = DT_GeolocatorSystem.GetBuildingDetails(def)
            local town = DT_GeolocatorSystem.GetTownName(centerX, centerY)
            local county = DT_GeolocatorSystem.GetCountyName(centerX, centerY)

            table.insert(results, {
                x = x,
                y = y,
                w = width,
                h = height,
                cx = centerX,
                cy = centerY,
                area = area,
                name = details.primaryRoom or "Building",
                town = town,
                county = county,
                details = details,
            })
        end
    end

    DT_GeolocatorSystem.RegionCandidatesDirty = true
    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "SCAN COMPLETE. Found " .. #results .. " buildings accurately geolocated.")
    return results
end