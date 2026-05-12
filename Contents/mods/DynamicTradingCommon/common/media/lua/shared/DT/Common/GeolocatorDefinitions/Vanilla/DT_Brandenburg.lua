require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "Brandenburg",
    mod = "Vanilla",
    isVanilla = true,
    order = 170,
    locations = {
        {
            id = "brandenburg",
            longName = "Brandenburg, KY",
            shortName = "Brandenburg",
            startX = 798,
            endX = 3090,
            startY = 5115,
            endY = 7484,
        },
    },
    towns = {
        { name = "Brandenburg", minX = 798, maxX = 3090, minY = 5115, maxY = 7484 },
    },
    counties = {},
    pois = {},
})
