-- =============================================================================
-- GEOLOCATOR SYSTEM: MAP DATA
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.Counties = {
    {
        name = "Louisville",
        bounds = { minX = 11700, maxX = 14500, minY = 1000, maxY = 4500 },
        towns = { "Louisville", "Valley Station" },
    },
    {
        name = "Muldraugh",
        bounds = { minX = 10500, maxX = 13000, minY = 6600, maxY = 10800 },
        towns = { "Muldraugh", "West Point" },
    },
    {
        name = "Riverside",
        bounds = { minX = 5100, maxX = 7500, minY = 5000, maxY = 6500 },
        towns = { "Riverside", "Riverside Trailer Park", "Scenic Grove Mobile Home Park" },
    },
    {
        name = "Rosewood",
        bounds = { minX = 7500, maxX = 8700, minY = 11100, maxY = 12300 },
        towns = { "Rosewood", "Kentucky State Prison", "March Ridge" },
    },
    {
        name = "Knox Country",
        bounds = { minX = 1, maxX = 3894, minY = 5115, maxY = 15044 },
        towns = { "Brandenburg", "Echo Creek", "Ekron", "Irvington" },
    },
}

DT_GeolocatorSystem.Towns = {
    { name = "Muldraugh", minX = 10500, maxX = 13000, minY = 6600, maxY = 9500 },
    { name = "Rosewood", minX = 7500, maxX = 8500, minY = 11000, maxY = 12000 },
    { name = "Riverside", minX = 6000, maxX = 7500, minY = 5000, maxY = 6500 },
    { name = "West Point", minX = 10800, maxX = 12600, minY = 4000, maxY = 7500 },
    { name = "Louisville", minX = 11700, maxX = 14500, minY = 1000, maxY = 4500 },
    { name = "March Ridge", minX = 9500, maxX = 11000, minY = 11500, maxY = 13200 },
    { name = "Dixie", minX = 5400, maxX = 5700, minY = 9300, maxY = 9900 },
    { name = "Doe Valley", minX = 6600, maxX = 6900, minY = 9900, maxY = 10200 },
    { name = "Fallas Lake", minX = 6900, maxX = 7500, minY = 8100, maxY = 8700 },
    { name = "Valley Station", minX = 12300, maxX = 13200, minY = 4500, maxY = 6300 },
    { name = "Echo Creek", minX = 3365, maxX = 3894, minY = 10854, maxY = 11394 },
    { name = "Ekron", minX = 1, maxX = 1150, minY = 9221, maxY = 10477 },
    { name = "Scenic Grove Mobile Home Park", minX = 5248, maxX = 5634, minY = 5840, maxY = 6140 },
    { name = "Brandenburg", minX = 798, maxX = 3090, minY = 5115, maxY = 7484 },
    { name = "Irvington", minX = 822, maxX = 3881, minY = 12557, maxY = 15044 },
}