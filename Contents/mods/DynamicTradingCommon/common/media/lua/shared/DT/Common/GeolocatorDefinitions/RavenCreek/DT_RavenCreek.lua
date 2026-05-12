require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "RavenCreek",
    mod = "Raven Creek B42",
    isVanilla = false,
    order = 1000,
    activation = {
        modIDs = { "RavenCreekB42" },
        mapFolders = { "Raven Creek B42" },
        worldMaps = { "Raven Creek B42" },
    },
    locations = {
        {
            id = "raven_creek",
            longName = "Raven Creek B42, KY",
            shortName = "Raven Creek",
            startX = 4200,
            endX = 7800,
            startY = 15300,
            endY = 21000,
        },
    },
    towns = {
        { name = "Raven Creek", minX = 4200, maxX = 7800, minY = 15300, maxY = 21000 },
    },
    counties = {
        {
            name = "Raven Creek",
            bounds = { minX = 4200, maxX = 7800, minY = 15300, maxY = 21000 },
            towns = { "Raven Creek" },
        },
    },
    pois = {},
})
