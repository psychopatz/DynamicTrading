require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Riverside",
    mod = "Vanilla",
    isVanilla = true,
    order = 80,
    locations = {
        {
            id = "riverside",
            longName = "Riverside, KY",
            shortName = "Riverside",
            startX = 5700,
            endX = 6900,
            startY = 5100,
            endY = 5700,
        },
    },
    towns = {
        { name = "Riverside", minX = 6000, maxX = 7500, minY = 5000, maxY = 6500 },
    },
    counties = {},
    pois = {},
})
