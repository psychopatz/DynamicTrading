require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: GRID COLLAPSE
-- =============================================================================

DynamicTrading.Events.Register("PowerFail", {
    name = "Grid Collapse",
    type = "meta", 
    description = "The power grid is dead. Generators and fuel are critical.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > (SandboxVars.ElecShutModifier or 14)
    end,
    effects = {
        ["Electronics"] = { price = 2.0 },
        ["Fuel"] = { price = 3.0, vol = 0.5 },
        ["Light"] = { price = 1.5 },
        ["Generator"] = { price = 4.0, vol = 0.1 },
        ["Battery"] = { price = 2.5 }
    }
})
