require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "CountyRiverside",
    mod = "Vanilla",
    isVanilla = true,
    order = 30,
    locations = {},
    towns = {},
    counties = {
        {
            name = "Riverside",
            bounds = { minX = 5100, maxX = 7500, minY = 5000, maxY = 6500 },
            towns = { "Riverside", "Riverside Trailer Park", "Scenic Grove Mobile Home Park" },
        },
    },
    pois = {},
})
