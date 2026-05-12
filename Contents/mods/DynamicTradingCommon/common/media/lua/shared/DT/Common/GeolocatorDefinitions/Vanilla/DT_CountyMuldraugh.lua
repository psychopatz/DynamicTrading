require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "CountyMuldraugh",
    mod = "Vanilla",
    isVanilla = true,
    order = 20,
    locations = {},
    towns = {},
    counties = {
        {
            name = "Muldraugh",
            bounds = { minX = 10500, maxX = 13000, minY = 6600, maxY = 10800 },
            towns = { "Muldraugh", "West Point" },
        },
    },
    pois = {},
})
