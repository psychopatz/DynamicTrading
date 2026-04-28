-- ==============================================================================
-- DT/Common/Logging/DT_GameplayEvents.lua
-- Canonical gameplay-log event IDs.
-- Text registration is loaded separately through DT_GameplayLogRegistry.
-- ==============================================================================

local Registry = {}
DynamicTrading = DynamicTrading or {}
DynamicTrading.GameplayEvents = Registry

-- Faction Events (1-100)
Registry.RECRUITED = 1
Registry.CONSTRUCTED = 2
Registry.TRADE_STARTED = 3
Registry.FLASH_CASUALTIES = 4
Registry.SHORTAGE_CASUALTIES = 5
Registry.HORDE_CASUALTIES = 6
Registry.HORDE_REPELLED = 7
Registry.STARVATION_DEATHS = 8
Registry.ATTRITION_DEATHS = 9
Registry.STATE_CHANGED = 10
Registry.BUILDING_DAMAGED = 11
Registry.FACTION_DYING = 12
Registry.FACTION_FOUNDED = 13
Registry.LEADERSHIP_TRANSFER = 14
Registry.MEMBER_JOINED = 15
Registry.MEMBER_LEFT = 16
Registry.MEMBER_KICKED = 17
Registry.REP_SIGNIFICANT_CHANGE = 18
Registry.REP_SIGNIFICANT_LOSS = 19
Registry.LARGE_DONATION = 20
Registry.MEMBER_INCAPACITATED_BY_PLAYER = 21
Registry.MEMBER_KILLED_BY_PLAYER = 22
Registry.FLASH_EVENT_ACTIVATED = 23
Registry.BANDIT_RAID_STARTED = 24

-- Radio / Network Events (101-200)
Registry.SIGNAL_ACQUIRED = 101
Registry.SIGNAL_RELEASED = 102
Registry.SIGNAL_MEMORY_FULL = 103
Registry.TRADE_REP_GAINED = 104
Registry.FACTION_COLLAPSED = 105
Registry.NPC_PROVOKED = 106

if DynamicTrading.GameplayLogs then
	for key, value in pairs(Registry) do
		if type(value) == "number" then
			DynamicTrading.GameplayLogs[key] = value
		end
	end
end

return Registry
