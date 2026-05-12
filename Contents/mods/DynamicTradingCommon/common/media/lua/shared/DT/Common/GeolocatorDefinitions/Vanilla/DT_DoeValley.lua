require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "DoeValley",
    mod = "Vanilla",
    isVanilla = true,
    order = 30,
    locations = {
        {
            id = "doe_valley",
            longName = "Doe Valley, KY",
            shortName = "Doe Valley",
            startX = 6600,
            endX = 6900,
            startY = 9900,
            endY = 10200,
        },
    },
    towns = {
        { name = "Doe Valley", minX = 6600, maxX = 6900, minY = 9900, maxY = 10200 },
    },
    counties = {},
    pois = {},
})
