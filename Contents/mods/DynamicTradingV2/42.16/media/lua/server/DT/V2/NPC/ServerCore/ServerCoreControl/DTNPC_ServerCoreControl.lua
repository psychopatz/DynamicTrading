-- ==============================================================================
-- DTNPC_ServerCoreControl.lua
-- Entry point for DTNPC server control modules.
-- Loads submodules in explicit order.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreControl = DTNPCServerCoreControl or {}
DTNPCServerCoreControl.Internal = DTNPCServerCoreControl.Internal or {}

if isClient() and not isServer() then return end

if DTNPCServerCoreControl.EntryLoaded then
    return
end

DTNPCServerCoreControl.EntryLoaded = true

require "DT/V2/NPC/ServerCore/ServerCoreControl/DTNPC_ServerCoreControl_ArrivalSquares"
require "DT/V2/NPC/ServerCore/ServerCoreControl/DTNPC_ServerCoreControl_DataAccess"
require "DT/V2/NPC/ServerCore/ServerCoreControl/DTNPC_ServerCoreControl_SpawnHelpers"
require "DT/V2/NPC/ServerCore/ServerCoreControl/DTNPC_ServerCoreControl_Updates"
require "DT/V2/NPC/ServerCore/ServerCoreControl/DTNPC_ServerCoreControl_Orders"
