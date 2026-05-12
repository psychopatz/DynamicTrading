require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "MarchRidgeBunker",
    mod = "Vanilla",
    isVanilla = true,
    order = 10,
    locations = {
        {
            id = "marchridge_bunker",
            longName = "Bunker, March Ridge, KY",
            shortName = "March Ridge Bunker",
            startX = 9902,
            endX = 9950,
            startY = 12589,
            endY = 12662,
        },
    },
    towns = {},
    counties = {},
    pois = {},
})
