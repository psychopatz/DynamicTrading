local Registry = {}
-- Ensure GameplayLogs is loaded first
require "DT/Common/Logging/DT_GameplayLogs"

local Logs = DynamicTrading.GameplayLogs

-- Faction Event Specific Enums (1-100)
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

-- Register templates dynamically into the GameplayLogs pool
Logs.RegisterTemplate(Logs.RECRUITED, "Recruited {1} ({2})", "good")
Logs.RegisterTemplate(Logs.CONSTRUCTED, "Constructed {1}", "good")
Logs.RegisterTemplate(Logs.TRADE_STARTED, "{1} started a trading run", "event")
Logs.RegisterTemplate(Logs.FLASH_CASUALTIES, "Lost {1} members to {2}", "bad")
Logs.RegisterTemplate(Logs.SHORTAGE_CASUALTIES, "Lost {1} members to {2} shortage", "bad")
Logs.RegisterTemplate(Logs.HORDE_CASUALTIES, "Horde attack! Lost {1} of {2} breached zombies", "bad")
Logs.RegisterTemplate(Logs.HORDE_REPELLED, "Repelled a horde of {1} zombies", "good")
Logs.RegisterTemplate(Logs.STARVATION_DEATHS, "Lost {1} members to starvation", "bad")
Logs.RegisterTemplate(Logs.ATTRITION_DEATHS, "Lost {1} members to illness", "bad")
Logs.RegisterTemplate(Logs.STATE_CHANGED, "Status changed: {2} -> {1}", "event")
Logs.RegisterTemplate(Logs.BUILDING_DAMAGED, "{1} is deteriorating from neglect", "bad")
Logs.RegisterTemplate(Logs.FACTION_DYING, "Colony is on the verge of collapse", "bad")
Logs.RegisterTemplate(Logs.FACTION_FOUNDED, "{1} established a formal presence", "good")

return Registry
