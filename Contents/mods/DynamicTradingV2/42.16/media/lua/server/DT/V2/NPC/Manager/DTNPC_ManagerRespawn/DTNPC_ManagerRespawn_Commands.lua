-- ==============================================================================
-- DTNPC_ManagerRespawn_Commands.lua
-- Client command handlers for respawn-related operations.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

local function onClientCommand(module, command, player, args)
    if module ~= "DynamicTrading_V2" then return end
    
    if command == "ForceTradeMission" then
        local uuid = args.uuid
        if uuid then
            DynamicTrading.Log("DTV2", "NPC", "Admin", "Admin/Debug Force Trade Mission for: " .. uuid)
            DTNPCManager.StartTradeMission(uuid, true)
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)

DynamicTrading.Log("DTV2", "Init", "NPC", "DTNPC_ManagerRespawn_Commands Loaded successfully")
