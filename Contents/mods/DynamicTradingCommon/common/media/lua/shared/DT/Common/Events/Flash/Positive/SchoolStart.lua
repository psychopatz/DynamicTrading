require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: EDUCATION INITIATIVE
-- =============================================================================

DynamicTrading.Events.Register("SchoolStart", {
    name = "School Supplies Demand",
    sentiment = "Positive",
    type = "flash",
    description = "Communities are rebuilding schools.",
    canSpawn = function() return true end,
    system = { passiveIncomeMult = 1.1 },
    effects = {
        ["Literature.Book"] = { price = 2.5, vol = 0.2 },
        ["Literature"] = { price = 1.5 },
        ["Literature.SkillBook"] = { price = 1.5 },
        ["Resource.Material.Paper"] = { price = 2.0 }
    },
    inject = { ["Literature.SkillBook"] = 4 },
    factionImpact = {
        stabilityAdd = 5
    }
})
