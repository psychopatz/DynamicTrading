-- ==============================================================================
-- DTNPC_ClientNetwork.lua
-- Client-side network command handlers for NPC synchronization.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}

function DTNPCClient.OnServerCommand(module, command, args)
    if module ~= "DTNPC" then return end

    if command == "SyncNPC" then
        if not args or not args.uuid or not args.brain then return end
        
        local uuid = args.uuid
        local outfitID = args.outfitID
        
        print("[DTNPC-Client] Received SyncNPC for: " .. (args.brain.name or uuid))
        
        DTNPCClient.CacheBrain(uuid, outfitID, args.brain)
        
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        
        if not zombie and outfitID then
            zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
        end
        
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, args.brain)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
            DTNPCClient.ProcessedZombies[uuid] = true
            print("[DTNPC-Client] Applied visuals to zombie: " .. uuid)
        else
            print("[DTNPC-Client] Zombie not in world yet, cached for later: " .. uuid)
        end
        return
    end

    if command == "UpdatePosition" then
        if not args or not args.uuid then return end
        
        local uuid = args.uuid
        local cached = DTNPCClient.NPCCache[uuid]
        
        if cached and cached.brain then
            cached.brain.lastX = math.floor(args.x)
            cached.brain.lastY = math.floor(args.y)
            cached.brain.lastZ = math.floor(args.z)
            
            if args.health then cached.brain.health = args.health end
            if args.state then cached.brain.state = args.state end
            if args.outfitID then
                DTNPCClient.OutfitIDToUUID[args.outfitID] = uuid
                cached.brain.currentOutfitID = args.outfitID
            end
            
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            
            if not zombie and args.outfitID then
                zombie = DTNPCClient.FindZombieByOutfitID(args.outfitID)
            end
            
            if zombie and not DTNPCClient.LocalControlled[uuid] then
                DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
            end
        end
        return
    end

    if command == "RemoveNPC" then
        if not args or not args.uuid then return end
        print("[DTNPC-Client] Received RemoveNPC for: " .. args.uuid)
        DTNPCClient.RemoveFromCache(args.uuid, args.outfitID)
        return
    end

    if command == "SyncAllNPCs" then
        if not args or not args.npcs then return end
        
        print("[DTNPC-Client] Received SyncAllNPCs. Count: " .. DTNPCClient.GetTableSize(args.npcs))
        
        for uuid, brain in pairs(args.npcs) do
            local outfitID = brain.currentOutfitID
            DTNPCClient.CacheBrain(uuid, outfitID, brain)
            
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            
            if not zombie and outfitID then
                zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
            end
            
            if zombie then
                DTNPCClient.ApplyVisualsToNPC(zombie, brain)
                DTNPCClient.ProcessedZombies[uuid] = true
            end
        end
        return
    end
end

function DTNPCClient.RequestInitialSync(playerNum)
    if isServer() and isDedicatedServer() then return end
    if DTNPCClient.hasSyncedOnce then return end
    
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    
    print("[DTNPC-Client] Requesting initial sync for player: " .. player:getUsername())
    sendClientCommand(player, "DTNPC", "RequestFullSync", {})
    DTNPCClient.hasSyncedOnce = true
end

-- Events will be registered in DTNPC_ClientVisuals.lua to ensure all functions are defined.
