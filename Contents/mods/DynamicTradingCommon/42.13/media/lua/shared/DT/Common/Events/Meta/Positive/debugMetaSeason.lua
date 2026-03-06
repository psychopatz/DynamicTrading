require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- SEASONAL DEBUG: RAINING IN JULY
-- =================================================States currently raining and season month
-- =============================================================================

DynamicTrading.Events.Register("debugMetaSeason", {
    name = "Debug Seasonal Rain",
    sentiment = "Positive",
    type = "seasonal",
    description = "A debug event that activates if it is July (starting month) and raining.",
    condition = function() 
        local gt = getGameTime()
        local isJuly = gt:getMonth() == 6
        local isRaining = getClimateManager():getIsRaining()
        return isJuly and isRaining
    end,
    effects = {
        ["WaterContainer"] = { price = 2.0, vol = 0.5 }
    }
})
