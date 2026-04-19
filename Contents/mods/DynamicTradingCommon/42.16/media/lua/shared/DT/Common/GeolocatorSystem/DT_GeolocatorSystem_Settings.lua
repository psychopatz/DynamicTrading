-- =============================================================================
-- GEOLOCATOR SYSTEM: SETTINGS
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}
DT_GeolocatorSystem.Config = DT_GeolocatorSystem.Config or {}

DT_GeolocatorSystem.Config.Debug = true

DT_GeolocatorSystem.Config.MinBuildingArea = 60
DT_GeolocatorSystem.Config.MinBuildingDimension = 5
DT_GeolocatorSystem.Config.SearchRadius = 50
DT_GeolocatorSystem.Config.MinFactionBaseArea = 150

DT_GeolocatorSystem.Config.PreferredRooms = {
    "livingroom",
    "kitchen",
    "foyer",
    "hall",
    "retail",
    "grocery",
    "office",
    "diner",
    "restaurant",
    "storefront",
}

DT_GeolocatorSystem.Config.BlacklistedRooms = {
    "bathroom",
    "closet",
    "storage",
    "cell",
    "garage",
    "shed",
    "basement",
}