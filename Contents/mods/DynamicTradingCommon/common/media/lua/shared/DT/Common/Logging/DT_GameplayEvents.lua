-- ==============================================================================
-- DT/Common/Logging/DT_GameplayEvents.lua
-- Unified Event Registry for GameplayLogs family
-- Format: RegisterLogTemplate(id, { EN = "...", PH = "..." }, category)
-- ==============================================================================

local Registry = {}
DynamicTrading = DynamicTrading or {}
DynamicTrading.GameplayEvents = Registry

local Logs = Registry
local reg = DynamicTrading.RegisterLogTemplate

-- Faction Events (1-100)
Logs.RECRUITED = 1
Logs.CONSTRUCTED = 2
Logs.TRADE_STARTED = 3
Logs.FLASH_CASUALTIES = 4
Logs.SHORTAGE_CASUALTIES = 5
Logs.HORDE_CASUALTIES = 6
Logs.HORDE_REPELLED = 7
Logs.STARVATION_DEATHS = 8
Logs.ATTRITION_DEATHS = 9
Logs.STATE_CHANGED = 10
Logs.BUILDING_DAMAGED = 11
Logs.FACTION_DYING = 12
Logs.FACTION_FOUNDED = 13
Logs.LEADERSHIP_TRANSFER = 14
Logs.MEMBER_JOINED = 15
Logs.MEMBER_LEFT = 16
Logs.MEMBER_KICKED = 17
Logs.REP_SIGNIFICANT_CHANGE = 18
Logs.REP_SIGNIFICANT_LOSS = 19
Logs.LARGE_DONATION = 20
Logs.MEMBER_INCAPACITATED_BY_PLAYER = 21
Logs.MEMBER_KILLED_BY_PLAYER = 22

-- Radio / Network Events (101-200)
Logs.SIGNAL_ACQUIRED = 101
Logs.SIGNAL_RELEASED = 102
Logs.SIGNAL_MEMORY_FULL = 103
Logs.TRADE_REP_GAINED = 104
Logs.FACTION_COLLAPSED = 105
Logs.NPC_PROVOKED = 106

-- Registration
reg(Logs.RECRUITED, { EN = "Recruited {1} ({2})" }, "good")
reg(Logs.CONSTRUCTED, { EN = "Constructed {1}" }, "good")
reg(Logs.TRADE_STARTED, { EN = "{1} started a trading run" }, "event")
reg(Logs.FLASH_CASUALTIES, { EN = "Lost {1} members to {2}" }, "bad")
reg(Logs.SHORTAGE_CASUALTIES, { EN = "Lost {1} members to {2} shortage" }, "bad")
reg(Logs.HORDE_CASUALTIES, { EN = "Horde attack! Lost {1} of {2} breached zombies" }, "bad")
reg(Logs.HORDE_REPELLED, { EN = "Repelled a horde of {1} zombies" }, "good")
reg(Logs.STARVATION_DEATHS, { EN = "Lost {1} members to starvation" }, "bad")
reg(Logs.ATTRITION_DEATHS, { EN = "Lost {1} members to illness" }, "bad")
reg(Logs.STATE_CHANGED, { EN = "Status changed: {2} -> {1}" }, "event")
reg(Logs.BUILDING_DAMAGED, { EN = "{1} is deteriorating from neglect" }, "bad")
reg(Logs.FACTION_DYING, { EN = "Colony is on the verge of collapse" }, "bad")
reg(Logs.FACTION_FOUNDED, { EN = "{1} established a formal presence" }, "good")
reg(Logs.LEADERSHIP_TRANSFER, { EN = "{1} has transferred leadership to {2}" }, "event")
reg(Logs.MEMBER_JOINED, { EN = "{1} has joined the colony" }, "good")
reg(Logs.MEMBER_LEFT, { EN = "{1} has left the colony" }, "bad")
reg(Logs.MEMBER_KICKED, { EN = "{1} was expelled from the colony by {2}" }, "bad")
reg(Logs.REP_SIGNIFICANT_CHANGE, { EN = "{1}'s status has improved significantly in the colony" }, "good")
reg(Logs.REP_SIGNIFICANT_LOSS, { EN = "The colony now views {1} with extreme suspicion" }, "bad")
reg(Logs.LARGE_DONATION, { EN = "{1} bolstered the colony's treasury with a major donation" }, "good")
reg(Logs.MEMBER_INCAPACITATED_BY_PLAYER, { EN = "{2} was incapacitated by {1}" }, "bad")
reg(Logs.MEMBER_KILLED_BY_PLAYER, { EN = "{2} was confirmed killed by {1}" }, "bad")

reg(Logs.SIGNAL_ACQUIRED, { EN = "Signal Acquired by {1}: {2} ({3})" }, "good")
reg(Logs.SIGNAL_RELEASED, { EN = "Signal Released: {1} ({2})" }, "event")
reg(Logs.SIGNAL_MEMORY_FULL, { EN = "Signal Memory Full: all locked channels occupied" }, "bad")
reg(Logs.TRADE_REP_GAINED, { EN = "Traded with {1}, gaining reputation with {2}" }, "good")
reg(Logs.FACTION_COLLAPSED, { EN = "Colony {1} has collapsed and was lost to the wasteland" }, "bad")
reg(Logs.NPC_PROVOKED, { EN = "{1} has been provoked and is now hostile" }, "bad")

return Registry
