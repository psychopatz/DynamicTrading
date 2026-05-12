require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Irvington",
    mod = "Vanilla",
    isVanilla = true,
    order = 180,
    locations = {
        {
            id = "irvington",
            longName = "Irvington, KY",
            shortName = "Irvington",
            startX = 822,
            endX = 3881,
            startY = 12557,
            endY = 15044,
        },
    },
    towns = {
        { name = "Irvington", minX = 822, maxX = 3881, minY = 12557, maxY = 15044 },
    },
    counties = {},
    pois = {},
})
