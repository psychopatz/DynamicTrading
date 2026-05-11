-- ==============================================================================
-- DTNPC_ServerCoreCommands_Maintenance.lua
-- Maintenance and integration handlers for DTNPC server commands.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Handlers = DTNPCServerCoreCommands.Handlers

Handlers.ReportWeaponHit = function(player, args)
    if DTNPCLifecycle and DTNPCLifecycle.HandleReportWeaponHit then
        DTNPCLifecycle.HandleReportWeaponHit(player, args)
    end
end

Handlers.UpdateNPC = function(player, args)
    if not args.uuid or not args.updates then
        return
    end

    DynamicTrading.Log("DTV2", "NPC", "Command", "Received UpdateNPC for UUID: " .. args.uuid)

    if DTNPCServerCore and DTNPCServerCore.UpdateNPCByUUID then
        local changed, updatedNPC = DTNPCServerCore.UpdateNPCByUUID(
            args.uuid,
            args.updates,
            args.updates.broadcastPosition or false
        )
        if changed and updatedNPC then
            DynamicTrading.Log("DTV2", "NPC", "Update", "Updated and synced NPC via control module: " .. tostring(updatedNPC.name or args.uuid))
        elseif not updatedNPC then
            DynamicTrading.Log("DTV2", "NPC", "Warn", "UpdateNPC for unknown UUID: " .. args.uuid)
        end
        return
    end

    local uuid = args.uuid
    local serverBrain = DTNPCManager.Data[uuid]

    if serverBrain then
        local shouldBroadcast = args.updates.broadcastPosition or false

        for key, value in pairs(args.updates) do
            if key ~= "broadcastPosition" then
                DynamicTrading.Log("DTV2", "NPC", "Update", "  Updating " .. key .. " to " .. tostring(value))
                serverBrain[key] = value
            end
        end

        DTNPCManager.Save()

        local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
        if zombie then
            DTNPC.AttachData(zombie, serverBrain)
            DTNPCServerCore.SyncToAllClients(zombie, serverBrain)

            if shouldBroadcast then
                DynamicTrading.Log("DTV2", "NPC", "Update", "Broadcasting position due to state change")
                DTNPCServerCore.BroadcastPosition(zombie, serverBrain)
            end

            DynamicTrading.Log("DTV2", "NPC", "Update", "Updated and synced NPC to all clients")
        end
    else
        DynamicTrading.Log("DTV2", "NPC", "Warn", "UpdateNPC for unknown UUID: " .. uuid)
    end
end

Handlers.LootSearchOpen = function(player, args)
    if DTNPCLootSearchServer and DTNPCLootSearchServer.Open then
        DTNPCLootSearchServer.Open(player, args or {})
    end
end

Handlers.LootSearchCollect = function(player, args)
    if DTNPCLootSearchServer and DTNPCLootSearchServer.Collect then
        DTNPCLootSearchServer.Collect(player, args or {})
    end
end

Handlers.RemoveNPC = function(player, args)
    if not args.uuid then
        DynamicTrading.Log("DTV2", "NPC", "Error", "RemoveNPC received with no UUID!")
        return
    end

    DynamicTrading.Log("DTV2", "NPC", "Remove", "Received RemoveNPC request for UUID: " .. args.uuid .. " (Status: " .. (args.status or "nil") .. ")")

    if not DTNPCManager then
        DynamicTrading.Log("DTV2", "NPC", "Error", "DTNPCManager not available for removal!")
        return
    end

    local name = "Unknown"
    if DTNPCManager.Data[args.uuid] then
        name = DTNPCManager.Data[args.uuid].name or "Unknown"
        DTNPCManager.RemoveData(args.uuid, args.status, args.returnTime, args.returnStatus)
        DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed NPC data from database: " .. name .. " (" .. args.uuid .. ")")
    else
        DynamicTrading.Log("DTV2", "NPC", "Warn", "UUID " .. args.uuid .. " not found in database for removal.")
        if DynamicTrading_Roster and args.status then
            DynamicTrading_Roster.UpdateSoulStatus(args.uuid, args.status, args.returnTime, args.returnStatus)
        end
    end

    local zombie = DTNPCServerCore.FindZombieByUUID(args.uuid)
    if zombie and not (args.status == "Dead" and args.preserveCorpse == true) then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed NPC from world: " .. args.uuid)
    elseif zombie and args.status == "Dead" and args.preserveCorpse == true then
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Preserved dead NPC body in world: " .. args.uuid)
    else
        DynamicTrading.Log("DTV2", "NPC", "Remove", "INFO: NPC " .. args.uuid .. " not found in local world (may already be unloaded).")
    end
end
