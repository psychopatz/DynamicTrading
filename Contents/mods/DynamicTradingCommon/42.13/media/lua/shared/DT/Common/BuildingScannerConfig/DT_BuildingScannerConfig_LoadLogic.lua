-- =============================================================================
-- BUILDING SCANNER CONFIG: LOAD LOGIC
-- =============================================================================

DTM = DTM or {}

function DTM.LoadBuildings()
    if DTM.Buildings and DTM.BuildingLookup then
        return true
    end

    local modData = ModData.getOrCreate("DT_Buildings")
    if modData and modData.locations then
        DTM.Buildings = modData.locations
        DynamicTrading.Log("DTCommons", "Mapping", "Init", "Loaded " .. #DTM.Buildings .. " buildings from ModData.")
    else
        DTM.Buildings = DTM.ScanForBuildings()
    end

    DTM.BuildingLookup = {}
    for _, building in ipairs(DTM.Buildings) do
        DTM.BuildingLookup[building.x .. "," .. building.y] = building
    end

    return true
end
