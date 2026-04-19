-- =============================================================================
-- GEOLOCATOR SYSTEM: ROAD SCAN LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

function DT_GeolocatorSystem.ScanForRoads()
    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "SCANNING FOR ROADS (GRID SAMPLING)...")

    local world = getWorld and getWorld() or nil
    local metaGrid = world and world:getMetaGrid() or nil
    if not metaGrid then
        return {}
    end

    local roadPoints = {}
    local zonesFound = 0
    local uniqueZoneTypes = {}
    local minX = 3000
    local maxX = 15000
    local minY = 3000
    local maxY = 15000
    local step = 50

    local roadTypes = {
        ["Road"] = true,
        ["Street"] = true,
        ["Highway"] = true,
        ["Path"] = true,
        ["Trail"] = true,
        ["ZoneRoad"] = true,
        ["Paved"] = true,
        ["Driveway"] = true,
        ["Parking"] = true,
        ["Nav"] = true,
        ["ForagingNav"] = true,
    }

    for x = minX, maxX, step do
        for y = minY, maxY, step do
            local zones = metaGrid:getZonesAt(x, y, 0)
            if zones then
                for i = 0, zones:size() - 1 do
                    local zone = zones:get(i)
                    local zoneType = zone:getType()

                    if not uniqueZoneTypes[zoneType] then
                        uniqueZoneTypes[zoneType] = true
                        if DT_GeolocatorSystem.Config.Debug then
                            DynamicTrading.Log("DTCommons", "Mapping", "Debug", "Found new zone type: " .. tostring(zoneType))
                        end
                    end

                    if roadTypes[zoneType]
                        or string.find(string.lower(zoneType), "road")
                        or string.find(string.lower(zoneType), "street") then
                        table.insert(roadPoints, {
                            x = x,
                            y = y,
                            cx = x,
                            cy = y,
                            name = "Road (" .. zoneType .. ")",
                            town = DT_GeolocatorSystem.GetTownName(x, y),
                            county = DT_GeolocatorSystem.GetCountyName(x, y),
                            area = DT_GeolocatorSystem.GetZoneArea(zone),
                            details = {
                                roomCount = 0,
                                uniqueRooms = { "Road" },
                                isAlarmed = false,
                                visited = false,
                                id = -1,
                            },
                        })
                        zonesFound = zonesFound + 1
                        break
                    end
                end
            end
        end
    end

    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "ROAD SCAN COMPLETE. Found " .. zonesFound .. " road locations.")
    return roadPoints
end