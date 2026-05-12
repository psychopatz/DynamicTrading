-- =============================================================================
-- GEOLOCATOR SYSTEM: RUNTIME DATA
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.MOD_DATA_KEY = "DT_Buildings"
DT_GeolocatorSystem.ActiveLocations = DT_GeolocatorSystem.ActiveLocations or {}
DT_GeolocatorSystem.LocationIndex = DT_GeolocatorSystem.LocationIndex or {}
DT_GeolocatorSystem.RegionCandidates = DT_GeolocatorSystem.RegionCandidates or {}
DT_GeolocatorSystem.RegionCandidatesDirty = true
DT_GeolocatorSystem.CacheInitialized = DT_GeolocatorSystem.CacheInitialized or false
DT_GeolocatorSystem.PendingRegionDefinitions = DT_GeolocatorSystem.PendingRegionDefinitions or {}
DT_GeolocatorSystem.Registry = DT_GeolocatorSystem.Registry or {
    Version = 0,
    Locations = {},
    Towns = {},
    Counties = {},
    POIs = {},
    RegisteredDefinitions = {},
    RegisteredRevision = 0,
    BuiltRevision = -1,
}
