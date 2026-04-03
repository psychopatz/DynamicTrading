-- =============================================================================
-- BUILDING SCANNER CONFIG: DEBUG LOGIC
-- =============================================================================

DTM = DTM or {}

function DTM.Log(message)
    if DTM.Config.Debug then
        DynamicTrading.Log("DTCommons", "Mapping", "Debug", message)
    end
end
