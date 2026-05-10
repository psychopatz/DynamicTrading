-- ==============================================================================
-- DTNPC_ClientSync.lua
-- Entry point for client sync modules.
-- Loads client sync modules in explicit dependency order.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

if ClientSync.EntryLoaded then
    return
end

ClientSync.EntryLoaded = true
ClientSync.Modules = ClientSync.Modules or {}

require "DT/V2/NPC/ClientSync/DTNPC_ClientSync_Cache"
require "DT/V2/NPC/ClientSync/DTNPC_ClientSync_Interpolation"
require "DT/V2/NPC/ClientSync/DTNPC_ClientSync_VanillaPatches"
require "DT/V2/NPC/ClientSync/HealthBars/DTNPC_ClientSync_HealthBars"
require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSync_Network"
require "DT/V2/NPC/ClientSync/DTNPC_ClientSync_Events"
require "DT/V2/NPC/ClientSync/DTNPC_ClientSync_Visuals"
require "DT/V2/NPC/Bandits/DTNPC_Bandits"
require "DT/V2/mod-patches/bandits/DTModPatches_Bandits_Client"
