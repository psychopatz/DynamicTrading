require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: NETWORK FRAGMENTATION
-- =============================================================================

DynamicTrading.Events.Register("SignalDecay", {
    name = "Network Fragmentation",
    sentiment = "Negative",
    type = "meta",
    description = "Repeater towers are failing. Signals are rare, but survivors are veterans.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 365
    end,
    system = {
        scanChance = 0.7,   -- -30% Chance to find a signal
        traderLimit = 0.8,  -- -20% Total Traders
        globalStock = 1.5   -- But the traders you find have +50% loot (Veterans)
    },
    effects = {
        ["Communication"] = { price = 2.0 },        -- High quality radios needed
        ["Quality.Luxury"] = { price = 1.5 }                -- Veterans trade in high value items
    },
    factionImpact = {
        stabilityAdd = -2
    }
})
