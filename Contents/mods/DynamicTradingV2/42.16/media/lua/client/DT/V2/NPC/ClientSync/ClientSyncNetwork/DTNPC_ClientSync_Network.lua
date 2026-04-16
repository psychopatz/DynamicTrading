-- ==============================================================================
-- DTNPC_ClientSync_Network.lua
-- Entry point for client-side network sync modules.
-- Loads modules in explicit dependency order.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Modules = ClientSync.Modules or {}
ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network

Network.Modules = Network.Modules or {}
Network.Helpers = Network.Helpers or {}
Network.Handlers = Network.Handlers or {}

if Network.EntryLoaded then
    return
end

Network.EntryLoaded = true
ClientSync.Modules.Network = true

require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSyncNetwork_Bootstrap"
require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSyncNetwork_Helpers"
require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSyncNetwork_RequestFlow"
require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSyncNetwork_CommandSync"
require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSyncNetwork_CommandUpdate"
require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSyncNetwork_CommandRemove"
require "DT/V2/NPC/LootSearch/DTNPC_LootSearch_Client"
require "DT/V2/NPC/ClientSync/ClientSyncNetwork/DTNPC_ClientSyncNetwork_CommandRouter"
