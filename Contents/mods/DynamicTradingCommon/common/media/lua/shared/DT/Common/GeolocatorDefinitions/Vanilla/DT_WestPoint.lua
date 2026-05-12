require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "WestPoint",
    mod = "Vanilla",
    isVanilla = true,
    order = 130,
    locations = {
        {
            id = "west_point",
            longName = "West Point, KY",
            shortName = "West Point",
            startX = 10800,
            endX = 12600,
            startY = 6600,
            endY = 7500,
        },
    },
    towns = {
        { name = "West Point", minX = 10800, maxX = 12600, minY = 4000, maxY = 7500 },
    },
    counties = {},
    pois = {},
})
