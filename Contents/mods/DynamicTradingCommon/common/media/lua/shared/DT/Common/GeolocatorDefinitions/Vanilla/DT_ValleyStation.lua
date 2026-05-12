require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "ValleyStation",
    mod = "Vanilla",
    isVanilla = true,
    order = 120,
    locations = {
        {
            id = "valley_station",
            longName = "Valley Station, KY",
            shortName = "Valley Station",
            startX = 12300,
            endX = 13200,
            startY = 4500,
            endY = 6300,
        },
    },
    towns = {
        { name = "Valley Station", minX = 12300, maxX = 13200, minY = 4500, maxY = 6300 },
    },
    counties = {},
    pois = {},
})
