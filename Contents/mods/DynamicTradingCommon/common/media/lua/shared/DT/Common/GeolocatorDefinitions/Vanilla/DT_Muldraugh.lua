require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Muldraugh",
    mod = "Vanilla",
    isVanilla = true,
    order = 60,
    locations = {
        {
            id = "muldraugh",
            longName = "Muldraugh, KY",
            shortName = "Muldraugh",
            startX = 10500,
            endX = 11100,
            startY = 9000,
            endY = 10800,
        },
    },
    towns = {
        { name = "Muldraugh", minX = 10500, maxX = 13000, minY = 6600, maxY = 9500 },
    },
    counties = {},
    pois = {},
})
