-- =============================================================================
-- GEOLOCATOR SYSTEM: DEBUG LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

function DT_GeolocatorSystem.Log(message)
    if DT_GeolocatorSystem.Config.Debug then
        DynamicTrading.Log("DTCommons", "Mapping", "Debug", message)
    end
end