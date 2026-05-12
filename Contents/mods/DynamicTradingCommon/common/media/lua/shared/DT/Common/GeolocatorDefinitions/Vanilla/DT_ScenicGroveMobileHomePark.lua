require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "ScenicGroveMobileHomePark",
    mod = "Vanilla",
    isVanilla = true,
    order = 160,
    locations = {
        {
            id = "scenic_grove_mobile_home_park",
            longName = "Scenic Grove Mobile Home Park, KY",
            shortName = "Scenic Grove Mobile Home Park",
            startX = 5248,
            endX = 5634,
            startY = 5840,
            endY = 6140,
        },
    },
    towns = {
        { name = "Scenic Grove Mobile Home Park", minX = 5248, maxX = 5634, minY = 5840, maxY = 6140 },
    },
    counties = {},
    pois = {},
})
