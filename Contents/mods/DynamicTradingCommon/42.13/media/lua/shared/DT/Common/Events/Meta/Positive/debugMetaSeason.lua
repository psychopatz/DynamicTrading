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
        if not gt then return false end
        
        local isJuly = gt:getMonth() == 6
        
        local cm = getClimateManager()
        if not cm then return false end
        
        local isRaining = cm:getIsRaining()
        return isJuly and isRaining
    end,
    effects = {
        ["WaterContainer"] = { price = 2.0, vol = 0.5 }
    }
})
