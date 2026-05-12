require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Rosewood",
    mod = "Vanilla",
    isVanilla = true,
    order = 100,
    locations = {
        {
            id = "rosewood",
            longName = "Rosewood, KY",
            shortName = "Rosewood",
            startX = 7900,
            endX = 8700,
            startY = 11100,
            endY = 12300,
        },
    },
    towns = {
        { name = "Rosewood", minX = 7500, maxX = 8500, minY = 11000, maxY = 12000 },
    },
    counties = {},
    pois = {},
})
