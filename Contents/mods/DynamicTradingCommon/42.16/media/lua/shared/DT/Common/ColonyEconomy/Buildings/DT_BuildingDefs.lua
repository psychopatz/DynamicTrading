-- ==============================================================================
-- ColonyEconomy/Buildings/DT_BuildingDefs.lua
-- Definition table for all colony infrastructure buildings.
-- ==============================================================================

local BuildingDefs = {
    Headquarters = {
        name = "Headquarters",
        description = "Administrative center. Its level gates the maximum level of all other buildings.",
        icon = "ui/Buildings/DC_Headquarters.png",
        archetype = nil, -- Any soul can work here
        capacity = 1,
        baseHp = 100,
        hpPerLevel = 25,
        buildDays = 3,
        materialsCost = 150
    },
    Greenhouse = {
        name = "Greenhouse",
        description = "Agricultural center. Consumes 10 water to produce 1 food per worker.",
        icon = "ui/Buildings/DC_Greenhouse.png",
        archetype = "Farmer",
        capacity = 2,
        baseHp = 100,
        hpPerLevel = 20,
        buildDays = 3,
        materialsCost = 100
    },
    WaterGenerator = {
        name = "Water Generator",
        description = "Provides clean water for the colony and farming operations.",
        icon = "ui/Buildings/DT_WaterCollector.png",
        archetype = "Engineer",
        capacity = 1,
        baseHp = 80,
        hpPerLevel = 15,
        buildDays = 3,
        materialsCost = 80
    },
    ElectricityGenerator = {
        name = "Electricity Generator",
        description = "Provides operational fuel and power for the colony.",
        icon = "ui/Buildings/DT_PowerGenerator.png",
        archetype = "Engineer",
        capacity = 1,
        baseHp = 80,
        hpPerLevel = 15,
        buildDays = 3,
        materialsCost = 120
    },
    Workshop = {
        name = "Workshop",
        description = "Industrial center. Produces ammo and provides a global 20% production boost.",
        icon = "ui/Buildings/DC_Workshop.png",
        archetype = "Craftsman",
        capacity = 2,
        baseHp = 100,
        hpPerLevel = 20,
        buildDays = 3,
        materialsCost = 90
    },
    Laboratory = {
        name = "Laboratory",
        description = "Medical science facility. Produces medicine over time.",
        icon = "ui/Buildings/DC_Laboratory.png",
        archetype = "Medic",
        capacity = 1,
        baseHp = 80,
        hpPerLevel = 10,
        buildDays = 3,
        materialsCost = 100
    },
    Infirmary = {
        name = "Infirmary",
        description = "Medical care center. Provides flat passive HP regeneration to colony souls.",
        icon = "ui/Buildings/DC_Infirmary.png",
        archetype = "Doctor",
        capacity = 1,
        baseHp = 80,
        hpPerLevel = 10,
        buildDays = 3,
        materialsCost = 60
    },
    Barracks = {
        name = "Barracks",
        description = "Housing center. Doubles recruitment speed and increases max population cap.",
        icon = "ui/Buildings/DC_Barracks.png",
        archetype = "Guard",
        capacity = 2,
        baseHp = 100,
        hpPerLevel = 25,
        buildDays = 3,
        materialsCost = 70
    },
    Barricade = {
        name = "Barricade",
        description = "Defense perimeter. Absorbs zombie horde damage when ammo is depleted.",
        icon = "ui/Buildings/DC_Barricade.png",
        archetype = nil,
        capacity = 1,
        baseHp = 200,
        hpPerLevel = 100,
        buildDays = 3,
        materialsCost = 50
    }
}

return BuildingDefs
