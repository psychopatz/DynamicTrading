-- ==============================================================================
-- DTNPC_ZombieAggro.lua
-- Entrypoint for the isolated zombie-vs-NPC aggro module.
-- Keeps the public API stable while loading feature-focused module files.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

if DTNPC_ZombieAggro.EntryLoaded then
    return
end

DTNPC_ZombieAggro.EntryLoaded = true

require "DT/V2/NPC/Sys/Combat/DTNPC_Combat"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_Shared"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_State"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_Queries"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_Noise"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_Stimulus"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_Damage"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_Leases"
require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro_Debug"
