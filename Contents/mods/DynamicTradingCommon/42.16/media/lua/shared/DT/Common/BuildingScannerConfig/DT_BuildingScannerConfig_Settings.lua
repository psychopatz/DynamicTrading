-- =============================================================================
-- BUILDING SCANNER CONFIG: SETTINGS
-- =============================================================================

DTM = DTM or {}
DTM.Config = DTM.Config or {}

DTM.Config.Debug = true

DTM.Config.MinBuildingArea = 60
DTM.Config.MinBuildingDimension = 5
DTM.Config.SearchRadius = 50

DTM.Config.PreferredRooms = {
    "livingroom",
    "kitchen",
    "foyer",
    "hall",
    "retail",
    "grocery",
    "office",
    "diner",
    "restaurant",
    "storefront"
}

DTM.Config.BlacklistedRooms = {
    "bathroom",
    "closet",
    "storage",
    "cell",
    "garage",
    "shed",
    "basement"
}
