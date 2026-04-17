require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: PHARMACY RAID
-- =============================================================================

DynamicTrading.Events.Register("HospitalFound", {
    name = "Hospital Discovered",
    sentiment = "Positive",
    type = "flash",
    description = "A hospital was looted. Meds are cheap.",
    canSpawn = function() return true end,
    system = { autoBuyPriceMult = 0.6 },
    effects = {
        ["Medical"] = { price = 0.3, vol = 5.0 },
        ["Medical.General.Pills"] = { price = 0.4, vol = 4.0 },
        ["Theme.Clinical"] = { price = 0.5 }
    },
    inject = { ["Medical"] = 8 },
    factionImpact = {
        stockpileAdd = { meds = 500 }
    }
})
