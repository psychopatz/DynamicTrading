require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META DEBUG: TIME WISE (Day 1+)
-- =============================================================================

DynamicTrading.Events.Register("debugMetaTimeWise", {
    name = "Debug Time Event",
    sentiment = "Positive",
    type = "meta",
    description = "A debug event that activates starting from Day 1.",
    condition = function() 
        return math.floor(GameTime:getInstance():getDaysSurvived()) >= 1
    end,
    effects = {
        ["Junk"] = { price = 0.5, vol = 2.0 }
    }
})
