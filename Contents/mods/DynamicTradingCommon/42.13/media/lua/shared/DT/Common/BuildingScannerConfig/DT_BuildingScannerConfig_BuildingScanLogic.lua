-- =============================================================================
-- BUILDING SCANNER CONFIG: BUILDING SCAN LOGIC
-- =============================================================================

DTM = DTM or {}

function DTM.ScanForBuildings()
    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "STARTING DETAILED BUILDING SCAN WITH COUNTY MAPPING...")
    local metaGrid = getWorld():getMetaGrid()
    if not metaGrid then
        return {}
    end

    local buildings = metaGrid:getBuildings()
    local potentialTradingPosts = {}
    local minArea = DTM.Config.MinBuildingArea

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
            local buildingDetails = DTM.GetBuildingDetails(def)
            local town = DTM.GetTownName(centerX, centerY)
            local county = DTM.GetCountyName(centerX, centerY)

            table.insert(potentialTradingPosts, {
                x = x,
                y = y,
                w = width,
                h = height,
                cx = centerX,
                cy = centerY,
                area = area,
                name = buildingDetails.primaryRoom or "Building",
                town = town,
                county = county,
                details = buildingDetails
            })
        end
    end

    DynamicTrading.Log("DTCommons", "Mapping", "Scanner", "SCAN COMPLETE. Found " .. #potentialTradingPosts .. " buildings across multiple counties.")
    return potentialTradingPosts
end
