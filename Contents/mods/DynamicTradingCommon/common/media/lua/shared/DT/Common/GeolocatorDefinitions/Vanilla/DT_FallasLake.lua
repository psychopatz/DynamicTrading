require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "FallasLake",
    mod = "Vanilla",
    isVanilla = true,
    order = 40,
    locations = {
        {
            id = "fallas_lake",
            longName = "Fallas Lake, KY",
            shortName = "Fallas Lake",
            startX = 6900,
            endX = 7500,
            startY = 8100,
            endY = 8700,
        },
    },
    towns = {
        { name = "Fallas Lake", minX = 6900, maxX = 7500, minY = 8100, maxY = 8700 },
    },
    counties = {},
    pois = {},
})
