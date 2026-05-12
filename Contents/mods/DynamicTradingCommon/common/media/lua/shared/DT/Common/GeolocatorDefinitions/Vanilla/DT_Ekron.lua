require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Ekron",
    mod = "Vanilla",
    isVanilla = true,
    order = 150,
    locations = {
        {
            id = "ekron",
            longName = "Ekron, KY",
            shortName = "Ekron",
            startX = 1,
            endX = 1150,
            startY = 9221,
            endY = 10477,
        },
    },
    towns = {
        { name = "Ekron", minX = 1, maxX = 1150, minY = 9221, maxY = 10477 },
    },
    counties = {},
    pois = {},
})
