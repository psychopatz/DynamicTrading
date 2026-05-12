require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "CountyLouisville",
    mod = "Vanilla",
    isVanilla = true,
    order = 10,
    locations = {},
    towns = {},
    counties = {
        {
            name = "Louisville",
            bounds = { minX = 11700, maxX = 14500, minY = 1000, maxY = 4500 },
            towns = { "Louisville", "Valley Station" },
        },
    },
    pois = {},
})
