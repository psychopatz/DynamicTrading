-- =============================================================================
-- BUILDING SCANNER CONFIG: WILDERNESS SCAN LOGIC
-- =============================================================================

DTM = DTM or {}

function DTM.ScanForWilderness()
    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "SCANNING FOR WILDERNESS (GRID SAMPLING)...")
    local metaGrid = getWorld():getMetaGrid()
    if not metaGrid then
        return {}
    end

    local wildernessPoints = {}
    local zonesFound = 0

    local minX = 3000
    local maxX = 15000
    local minY = 3000
    local maxY = 15000
    local step = 300

    for x = minX, maxX, step do
        for y = minY, maxY, step do
            local zones = metaGrid:getZonesAt(x, y, 0)
            if zones then
                for i = 0, zones:size() - 1 do
                    local zone = zones:get(i)
                    local zoneType = zone:getType()

                    if zoneType == "Forest" or zoneType == "DeepForest" or zoneType == "Meadow"
                        or zoneType == "Vegetation" or zoneType == "Farm" then
                        local town = DTM.GetTownName(x, y)
                        local county = DTM.GetCountyName(x, y)

                        if town == "Wilderness" then
                            table.insert(wildernessPoints, {
                                x = x,
                                y = y,
                                cx = x,
                                cy = y,
                                name = zoneType,
                                town = "Wilderness",
                                county = county,
                                area = DTM.GetZoneArea(zone),
                                details = {
                                    roomCount = 0,
                                    uniqueRooms = {zoneType},
                                    isAlarmed = false,
                                    visited = false,
                                    id = -1
                                }
                            })
                            zonesFound = zonesFound + 1
                            break
                        end
                    end
                end
            end
        end
    end

    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "WILDERNESS SCAN COMPLETE. Found " .. zonesFound .. " natural locations.")
    return wildernessPoints
end
