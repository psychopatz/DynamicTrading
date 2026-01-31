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
            
            -- Sync reported state
            local cached = DTNPCClient.NPCCache[uuid]
            if cached then
                cached.lastReportedState = {
                    state = args.brain.state,
                    tasksCount = (args.brain.tasks and #args.brain.tasks or 0)
                }
            end
            
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
            
            -- Sync reported state if state was provided
            if args.state then
                cached.lastReportedState = cached.lastReportedState or {}
                cached.lastReportedState.state = args.state
            end
        end
        return
    end

    if command == "RemoveNPC" then
        if not args or not args.uuid then return end
        
        local uuid = args.uuid
        local name = args.name or "Unknown"
        
        if name == "Unknown" and DTNPCClient.NPCCache[uuid] then
            name = DTNPCClient.NPCCache[uuid].brain.name or "Unknown"
        end
        
        print("[DTNPC-Client] Received RemoveNPC for: " .. name .. " (" .. uuid .. ")")
        DTNPCClient.RemoveFromCache(uuid, args.outfitID)
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
                
                -- Sync reported state
                local cached = DTNPCClient.NPCCache[uuid]
                if cached then
                    cached.lastReportedState = {
                        state = brain.state,
                        tasksCount = (brain.tasks and #brain.tasks or 0)
                    }
                end
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
