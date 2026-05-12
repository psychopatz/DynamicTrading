require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "EchoCreek",
    mod = "Vanilla",
    isVanilla = true,
    order = 140,
    locations = {
        {
            id = "echo_creek",
            longName = "Echo Creek, KY",
            shortName = "Echo Creek",
            startX = 3365,
            endX = 3894,
            startY = 10854,
            endY = 11394,
        },
    },
    towns = {
        { name = "Echo Creek", minX = 3365, maxX = 3894, minY = 10854, maxY = 11394 },
    },
    counties = {},
    pois = {},
})
