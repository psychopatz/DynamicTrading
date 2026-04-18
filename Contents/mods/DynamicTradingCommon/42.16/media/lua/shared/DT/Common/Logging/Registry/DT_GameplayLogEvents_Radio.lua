DynamicTrading = DynamicTrading or {}

local Events = DynamicTrading.GameplayEvents
local register = DynamicTrading.RegisterGameplayLogEvent

if not Events or not register then
    return
end

register(Events.SIGNAL_ACQUIRED, {
    category = "good",
    templates = {
        EN = "Signal Acquired by {1}: {2} ({3})"
    }
})

register(Events.SIGNAL_RELEASED, {
    category = "event",
    templates = {
        EN = "Signal Released: {1} ({2})"
    }
})

register(Events.SIGNAL_MEMORY_FULL, {
    category = "bad",
    templates = {
        EN = "Signal Memory Full: all locked channels occupied"
    }
})

register(Events.TRADE_REP_GAINED, {
    category = "good",
    templates = {
        EN = "Traded with {1}, gaining reputation with {2}"
    }
})

register(Events.FACTION_COLLAPSED, {
    category = "bad",
    templates = {
        EN = "Colony {1} has collapsed and was lost to the wasteland"
    }
})

register(Events.NPC_PROVOKED, {
    category = "bad",
    templates = {
        EN = "{1} has been provoked and is now hostile"
    }
})