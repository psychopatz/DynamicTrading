-- ==============================================================================
-- DTNPC_Needs.lua
-- Entry point for autonomous DT NPC maintenance evaluators.
-- ==============================================================================

DTNPCNeeds = DTNPCNeeds or {}
DTNPCNeeds.Internal = DTNPCNeeds.Internal or {}

if DTNPCNeeds.EntryLoaded then
    return
end

DTNPCNeeds.EntryLoaded = true

require "DT/V2/NPC/Sys/Needs/DTNPC_Needs_Core"
require "DT/V2/NPC/Sys/Needs/DTNPC_Needs_Evaluators"
