require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Louisville",
    mod = "Vanilla",
    isVanilla = true,
    order = 50,
    locations = {
        {
            id = "louisville",
            longName = "Louisville, KY",
            shortName = "Louisville",
            startX = 11700,
            endX = 14100,
            startY = 1200,
            endY = 4500,
        },
    },
    towns = {
        { name = "Louisville", minX = 11700, maxX = 14500, minY = 1000, maxY = 4500 },
    },
    counties = {},
    pois = {},
})
