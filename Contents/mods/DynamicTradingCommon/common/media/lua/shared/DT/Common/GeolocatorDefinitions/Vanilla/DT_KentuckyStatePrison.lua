require "DT/Common/GeolocatorDefinitions/DT_GeolocatorDefinitions"

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.RegisterRegionDefinition({
    id = "KentuckyStatePrison",
    mod = "Vanilla",
    isVanilla = true,
    order = 110,
    locations = {
        {
            id = "kentucky_state_prison",
            longName = "Kentucky State Prison, KY",
            shortName = "Kentucky State Prison",
            startX = 7500,
            endX = 7840,
            startY = 11800,
            endY = 12000,
        },
    },
    towns = {},
    counties = {},
    pois = {},
})
