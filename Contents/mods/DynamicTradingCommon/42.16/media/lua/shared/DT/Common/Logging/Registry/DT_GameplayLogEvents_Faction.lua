DynamicTrading = DynamicTrading or {}

local Events = DynamicTrading.GameplayEvents
local register = DynamicTrading.RegisterGameplayLogEvent

if not Events or not register then
    return
end

register(Events.RECRUITED, {
    category = "good",
    templates = {
        EN = "Recruited {1} ({2})"
    }
})

register(Events.CONSTRUCTED, {
    category = "good",
    templates = {
        EN = "Constructed {1}"
    }
})

register(Events.TRADE_STARTED, {
    category = "event",
    templates = {
        EN = "{1} started a trading run"
    }
})

register(Events.FLASH_CASUALTIES, {
    category = "bad",
    templates = {
        EN = "Lost {1} members to {2}"
    }
})

register(Events.SHORTAGE_CASUALTIES, {
    category = "bad",
    templates = {
        EN = "Lost {1} members to {2} shortage"
    }
})

register(Events.HORDE_CASUALTIES, {
    category = "bad",
    templates = {
        EN = "Horde attack! Lost {1} of {2} breached zombies"
    }
})

register(Events.HORDE_REPELLED, {
    category = "good",
    templates = {
        EN = "Repelled a horde of {1} zombies"
    }
})

register(Events.STARVATION_DEATHS, {
    category = "bad",
    templates = {
        EN = "Lost {1} members to starvation"
    }
})

register(Events.ATTRITION_DEATHS, {
    category = "bad",
    templates = {
        EN = "Lost {1} members to illness"
    }
})

register(Events.STATE_CHANGED, {
    category = "event",
    templates = {
        EN = "Status changed: {2} -> {1}"
    }
})

register(Events.BUILDING_DAMAGED, {
    category = "bad",
    templates = {
        EN = "{1} is deteriorating from neglect"
    }
})

register(Events.FACTION_DYING, {
    category = "bad",
    templates = {
        EN = "Colony is on the verge of collapse"
    }
})

register(Events.FACTION_FOUNDED, {
    category = "good",
    templates = {
        EN = "{1} established a formal presence"
    }
})

register(Events.LEADERSHIP_TRANSFER, {
    category = "event",
    templates = {
        EN = "{1} has transferred leadership to {2}"
    }
})

register(Events.MEMBER_JOINED, {
    category = "good",
    templates = {
        EN = "{1} has joined the colony"
    }
})

register(Events.MEMBER_LEFT, {
    category = "bad",
    templates = {
        EN = "{1} has left the colony"
    }
})

register(Events.MEMBER_KICKED, {
    category = "bad",
    templates = {
        EN = "{1} was expelled from the colony by {2}"
    }
})

register(Events.REP_SIGNIFICANT_CHANGE, {
    category = "good",
    templates = {
        EN = "{1}'s status has improved significantly in the colony"
    }
})

register(Events.REP_SIGNIFICANT_LOSS, {
    category = "bad",
    templates = {
        EN = "The colony now views {1} with extreme suspicion"
    }
})

register(Events.LARGE_DONATION, {
    category = "good",
    templates = {
        EN = "{1} bolstered the colony's treasury with a major donation"
    }
})

register(Events.MEMBER_INCAPACITATED_BY_PLAYER, {
    category = "bad",
    templates = {
        EN = "{2} was incapacitated by {1}"
    }
})

register(Events.MEMBER_KILLED_BY_PLAYER, {
    category = "bad",
    templates = {
        EN = "{2} was confirmed killed by {1}"
    }
})

register(Events.FLASH_EVENT_ACTIVATED, {
    category = "event",
    templates = {
        EN = "Flash event activated: {1}"
    }
})

register(Events.BANDIT_RAID_STARTED, {
    category = "event",
    templates = {
        EN = "{1} started a raiding run"
    }
})
