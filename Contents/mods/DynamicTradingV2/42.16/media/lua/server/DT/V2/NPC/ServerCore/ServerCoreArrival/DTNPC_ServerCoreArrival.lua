-- ==============================================================================
-- DTNPC_ServerCoreArrival.lua
-- Entry point for DTNPC server arrival modules.
-- Loads submodules in explicit order.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreArrival = DTNPCServerCoreArrival or {}
DTNPCServerCoreArrival.Internal = DTNPCServerCoreArrival.Internal or {}

if isClient() and not isServer() then return end

if DTNPCServerCoreArrival.EntryLoaded then
    return
end

DTNPCServerCoreArrival.EntryLoaded = true

require "DT/V2/NPC/ServerCore/ServerCoreArrival/DTNPC_ServerCoreArrival_Shared"
require "DT/V2/NPC/ServerCore/ServerCoreArrival/DTNPC_ServerCoreArrival_Targeting"
require "DT/V2/NPC/ServerCore/ServerCoreArrival/DTNPC_ServerCoreArrival_State"
require "DT/V2/NPC/ServerCore/ServerCoreArrival/DTNPC_ServerCoreArrival_Materialize"
require "DT/V2/NPC/ServerCore/ServerCoreArrival/DTNPC_ServerCoreArrival_Pending"
