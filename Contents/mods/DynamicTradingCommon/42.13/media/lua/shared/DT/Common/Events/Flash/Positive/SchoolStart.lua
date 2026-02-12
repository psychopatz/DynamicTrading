require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: EDUCATION INITIATIVE
-- =============================================================================

DynamicTrading.Events.Register("SchoolStart", {
    name = "Education Initiative",
    type = "flash",
    description = "Communities are rebuilding schools.",
    canSpawn = function() return true end,
    effects = {
        ["Scholastic"] = { price = 2.5, vol = 0.2 },
        ["Literature"] = { price = 1.5 },
        ["SkillBook"] = { price = 1.5 },
        ["Paper"] = { price = 2.0 }
    },
    inject = { ["Scholastic"] = 4 }
})
