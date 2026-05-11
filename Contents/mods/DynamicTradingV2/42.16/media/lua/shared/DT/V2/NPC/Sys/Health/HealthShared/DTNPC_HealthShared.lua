-- ==============================================================================
-- DTNPC_HealthShared.lua
-- Entry point for split DT NPC health shared modules.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

if not isServer() then
    pcall(require, "DT/Common/Reputation/DT_Reputation")
end

if DTNPCHealth.SharedEntryLoaded then
    return
end

DTNPCHealth.SharedEntryLoaded = true

require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_Runtime"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_Network"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_SpawnSafety"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_Ownership"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_Bandage"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_CombatAuthority"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_Persistence"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared_Incapacitation"
