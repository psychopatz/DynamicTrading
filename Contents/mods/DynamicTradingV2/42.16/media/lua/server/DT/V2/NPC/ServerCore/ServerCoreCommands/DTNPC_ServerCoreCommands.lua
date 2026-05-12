-- ==============================================================================
-- DTNPC_ServerCoreCommands.lua
-- Entry point for DTNPC server command modules.
-- Loads command submodules in explicit order and registers the network handler.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

if DTNPCServerCoreCommands.EntryLoaded then
    return
end

DTNPCServerCoreCommands.EntryLoaded = true

require "DT/V1/Manager"

require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_Shared"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_Debug"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_SyncRepair"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_SpawnSummon"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_Orders"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_Revive"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_TraderVisit"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_SyncRequests"
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands_Maintenance"

local function onClientCommand(module, command, player, args)
    if module ~= "DTNPC" then
        return
    end

    local handlers = DTNPCServerCoreCommands.Handlers or nil
    local handler = handlers and handlers[command] or nil
    if handler then
        return handler(player, args or {})
    end
end

DTNPCServerCoreCommands.OnClientCommand = onClientCommand
Events.OnClientCommand.Add(onClientCommand)
