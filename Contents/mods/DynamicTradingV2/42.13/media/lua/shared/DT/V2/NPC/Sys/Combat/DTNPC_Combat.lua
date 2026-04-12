-- ==============================================================================
-- DTNPC_Combat.lua
-- Entry point for shared combat support subsystems.
-- ==============================================================================

DTNPCCombat = DTNPCCombat or {}

if DTNPCCombat.EntryLoaded then
    return
end

DTNPCCombat.EntryLoaded = true

require "DT/V2/NPC/Sys/Combat/DTNPC_CombatPresence"
require "DT/V2/NPC/Sys/Combat/DTNPC_CombatEvasion"
