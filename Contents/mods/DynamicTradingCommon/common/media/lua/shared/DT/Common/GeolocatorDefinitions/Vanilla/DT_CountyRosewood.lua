require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "CountyRosewood",
    mod = "Vanilla",
    isVanilla = true,
    order = 40,
    locations = {},
    towns = {},
    counties = {
        {
            name = "Rosewood",
            bounds = { minX = 7500, maxX = 8700, minY = 11100, maxY = 12300 },
            towns = { "Rosewood", "Kentucky State Prison", "March Ridge" },
        },
    },
    pois = {},
})
