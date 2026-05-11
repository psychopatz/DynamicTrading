-- ==============================================================================
-- DTNPC_ServerCoreCommands_SpawnSummon.lua
-- Spawn and summon command handlers for DTNPC server commands.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Handlers = DTNPCServerCoreCommands.Handlers

Handlers.Spawn = function(player, args)
    DynamicTrading.Log("DTV2", "NPC", "Command", "Received Spawn command from: " .. player:getUsername())

    local archetypeID = args.occupation or "General"
    if DynamicTrading.Manager and DynamicTrading.Manager.SpawnTraderWithArchetype then
        local trader = DynamicTrading.Manager.SpawnTraderWithArchetype(archetypeID, {
            factionID = "Independent",
            forceFaction = true,
            homeCoords = { x = player:getX(), y = player:getY(), z = player:getZ() },
            discoverForPlayer = player
        })

        if trader and trader.id then
            DynamicTrading.Log("DTV2", "NPC", "Debug", "Spawned actual trader Soul [" .. tostring(trader.id) .. "]. Forcing physical spawn...")
            if DTNPCManager and DTNPCManager.CheckRosterSpawns then
                DTNPCManager.CheckRosterSpawns()
            end
        end
        return
    end

    DTNPCServerCore.SpawnNPC(player, nil, args)
end

Handlers.Summon = function(player)
    DynamicTrading.Log("DTV2", "NPC", "Command", "Received Summon command from: " .. player:getUsername())
    DTNPCServerCore.SummonAll(player)
end
