-- ==============================================================================
-- Server command router for client-side network sync modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network
local Handlers = Network.Handlers or {}

Network.Modules = Network.Modules or {}
Network.Helpers = Network.Helpers or {}
Network.Handlers = Handlers

if Network.Modules.CommandRouter then
    return
end

Network.Modules.CommandRouter = true

function DTNPCClient.OnServerCommand(module, command, args)
    if module ~= "DTNPC" then
        return
    end

    if command == "SyncNPC" then
        if Handlers.HandleSyncNPC then
            Handlers.HandleSyncNPC(args)
        end
        return
    end

    if command == "UpdatePosition" then
        if Handlers.HandleUpdatePosition then
            Handlers.HandleUpdatePosition(args)
        end
        return
    end

    if command == "RemoveNPC" then
        if Handlers.HandleRemoveNPC then
            Handlers.HandleRemoveNPC(args)
        end
        return
    end

    if command == "RemoveNPCInstance" then
        if Handlers.HandleRemoveNPCInstance then
            Handlers.HandleRemoveNPCInstance(args)
        end
        return
    end

    if command == "SyncAllNPCs" then
        if Handlers.HandleSyncAllNPCs then
            Handlers.HandleSyncAllNPCs(args)
        end
        return
    end

    if command == "SyncNearbyNPCs" then
        if Handlers.HandleSyncNearbyNPCs then
            Handlers.HandleSyncNearbyNPCs(args)
        end
        return
    end

    if command == "LootSearchSync" then
        if DTNPCLootSearchClient and DTNPCLootSearchClient.HandleSync then
            DTNPCLootSearchClient.HandleSync(args)
        end
        return
    end
end

-- Events will be registered in DTNPC_ClientSync_Visuals.lua after all sync functions are defined.
