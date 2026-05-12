require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "MarchRidge",
    mod = "Vanilla",
    isVanilla = true,
    order = 70,
    locations = {
        {
            id = "march_ridge",
            longName = "March Ridge, KY",
            shortName = "March Ridge",
            startX = 9600,
            endX = 10500,
            startY = 12300,
            endY = 13200,
        },
    },
    towns = {
        { name = "March Ridge", minX = 9500, maxX = 11000, minY = 11500, maxY = 13200 },
    },
    counties = {},
    pois = {},
})
