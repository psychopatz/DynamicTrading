require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Dixie",
    mod = "Vanilla",
    isVanilla = true,
    order = 20,
    locations = {
        {
            id = "dixie",
            longName = "Dixie, KY",
            shortName = "Dixie",
            startX = 5400,
            endX = 5700,
            startY = 9300,
            endY = 9900,
        },
    },
    towns = {
        { name = "Dixie", minX = 5400, maxX = 5700, minY = 9300, maxY = 9900 },
    },
    counties = {},
    pois = {},
})
