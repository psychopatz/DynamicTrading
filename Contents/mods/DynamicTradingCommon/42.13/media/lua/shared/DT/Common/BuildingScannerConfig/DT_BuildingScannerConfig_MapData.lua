-- =============================================================================
-- BUILDING SCANNER CONFIG: MAP DATA
-- =============================================================================

DTM = DTM or {}

DTM.Counties = {
    {
        name = "Louisville",
        bounds = {minX = 12000, maxX = 14500, minY = 1000, maxY = 4000},
        towns = {"Louisville"}
    },
    {
        name = "Muldraugh",
        bounds = {minX = 10500, maxX = 13000, minY = 6600, maxY = 9500},
        towns = {"Muldraugh"}
    },
    {
        name = "Riverside",
        bounds = {minX = 6000, maxX = 7500, minY = 5000, maxY = 6500},
        towns = {"Riverside"}
    },
    {
        name = "West Point",
        bounds = {minX = 11000, maxX = 12500, minY = 4000, maxY = 5500},
        towns = {"West Point"}
    },
    {
        name = "Rosewood",
        bounds = {minX = 7500, maxX = 8500, minY = 11000, maxY = 12000},
        towns = {"Rosewood"}
    },
    {
        name = "March Ridge",
        bounds = {minX = 9500, maxX = 11000, minY = 11500, maxY = 13000},
        towns = {"March Ridge"}
    }
}

DTM.Towns = {
    {name = "Muldraugh", minX = 10500, maxX = 13000, minY = 6600, maxY = 9500},
    {name = "Rosewood", minX = 7500, maxX = 8500, minY = 11000, maxY = 12000},
    {name = "Riverside", minX = 6000, maxX = 7500, minY = 5000, maxY = 6500},
    {name = "West Point", minX = 11000, maxX = 12500, minY = 4000, maxY = 5500},
    {name = "Louisville", minX = 12000, maxX = 14500, minY = 1000, maxY = 4000},
    {name = "March Ridge", minX = 9500, maxX = 11000, minY = 11500, maxY = 13000}
}
