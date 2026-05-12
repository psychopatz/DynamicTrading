require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "RiversideTrailerPark",
    mod = "Vanilla",
    isVanilla = true,
    order = 90,
    locations = {
        {
            id = "riverside_trailer_park",
            longName = "Riverside Trailer Park, KY",
            shortName = "Riverside Trailer Park",
            startX = 5100,
            endX = 5400,
            startY = 5700,
            endY = 6300,
        },
    },
    towns = {},
    counties = {},
    pois = {},
})
