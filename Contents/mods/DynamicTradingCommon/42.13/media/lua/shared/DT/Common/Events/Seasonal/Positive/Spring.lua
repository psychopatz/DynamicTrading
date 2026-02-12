-- =============================================================================
-- SEASONAL POSITIVE: SPRING THAW
-- =============================================================================

DynamicTrading.Events.Register("Spring", {
    name = "Spring Thaw ",
    type = "meta",
    description = "The frost has melted. Rain is frequent, and planting season has begun.",
    condition = function() 
        if not (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowSeasonalEvents) then return false end
        return ClimateManager:getInstance():getSeasonName() == "Spring" 
    end,
    effects = {
        ["Farming"] = { price = 2.0, vol = 0.5 },   -- Everyone needs seeds NOW
        ["Water"] = { price = 0.2, vol = 3.0 },     -- Rain collectors are full
        ["Fish"] = { price = 0.8, vol = 2.0 },      -- Rivers are active
        ["Clothing"] = { price = 1.2 }              -- Waterproof gear needed
    },
    inject = { ["Farming"] = 5 }
})
