require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "CountyKnoxCountry",
    mod = "Vanilla",
    isVanilla = true,
    order = 205,
    locations = {},
    towns = {},
    counties = {
        {
            name = "Knox Country",
            bounds = { minX = 1, maxX = 3894, minY = 5115, maxY = 15044 },
            towns = { "Brandenburg", "Echo Creek", "Ekron", "Irvington" },
        },
    },
    pois = {},
})
