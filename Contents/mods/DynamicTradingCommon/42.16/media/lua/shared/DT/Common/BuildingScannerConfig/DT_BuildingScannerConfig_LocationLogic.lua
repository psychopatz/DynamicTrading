-- =============================================================================
-- BUILDING SCANNER CONFIG: LOCATION LOGIC
-- =============================================================================

DTM = DTM or {}

function DTM.GetCountyName(x, y)
    for _, county in ipairs(DTM.Counties) do
        if x >= county.bounds.minX and x <= county.bounds.maxX
            and y >= county.bounds.minY and y <= county.bounds.maxY then
            return county.name
        end
    end

    return "Unknown County"
end

function DTM.GetTownName(x, y)
    for _, town in ipairs(DTM.Towns) do
        if x >= town.minX and x <= town.maxX
            and y >= town.minY and y <= town.maxY then
            return town.name
        end
    end

    local metaGrid = getWorld():getMetaGrid()
    if metaGrid then
        local zones = metaGrid:getZonesAt(x, y, 0)
        if zones then
            for i = 0, zones:size() - 1 do
                local zone = zones:get(i)
                if zone:getType() == "TownZone" then
                    return zone:getName() or "Nearby Town"
                end
            end
        end
    end

    return "Wilderness"
end
