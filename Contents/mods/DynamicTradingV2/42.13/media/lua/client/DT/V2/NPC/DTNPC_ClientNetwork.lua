-- ==============================================================================
-- DTNPC_ClientNetwork.lua
-- Client-side network command handlers for NPC synchronization.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}

print("[DTNPC_ClientNetwork] Loading client interpolation module...")

require "DT/V2/NPC/DTNPC_ClientInterpolation"
print("[DTNPC_ClientNetwork] DTNPC_ClientInterpolation loaded: " .. tostring(DTNPC_ClientInterpolation ~= nil))

-- Guard: Create fallback table with stub functions if module didn't load
if not DTNPC_ClientInterpolation then
    print("[DTNPC_ClientNetwork] WARNING: DTNPC_ClientInterpolation is nil, creating fallback")
    DTNPC_ClientInterpolation = { 
        LastPositions = {},
        UpdateTimes = {},
        RecordUpdate = function(uuid, x, y, z, updateFreq) end,
        GetInterpolatedPosition = function(uuid, zombie) 
            if zombie then return zombie:getX(), zombie:getY(), zombie:getZ() end
            return 0, 0, 0
        end,
        ClearNPC = function(uuid) end,
        ClearAll = function() end,
        GetTrackedCount = function() return 0 end,
        DebugPrint = function() end
    }
end

print("[DTNPC_ClientNetwork] Module loading complete")

function DTNPCClient.OnServerCommand(module, command, args)
    if module ~= "DTNPC" then return end

    if command == "SyncNPC" then
        if not args or not args.uuid or not args.npcData then return end
        
        local uuid = args.uuid
        local outfitID = args.outfitID
        
        print("[DTNPC-Client] Received SyncNPC for: " .. (args.npcData.name or uuid))
        
        DTNPCClient.CacheData(uuid, outfitID, args.npcData)
        
        -- Track position for interpolation
        if args.x and args.y then
            DTNPC_ClientInterpolation.RecordUpdate(uuid, args.x, args.y, args.z or 0)
        end
        
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        
        if not zombie and outfitID then
            zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
        end
        
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, args.npcData)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
            DTNPCClient.ProcessedZombies[uuid] = true
            
            -- Sync reported state
            local cached = DTNPCClient.NPCCache[uuid]
            if cached then
                cached.lastReportedState = {
                    state = args.npcData.state,
                    tasksCount = (args.npcData.tasks and #args.npcData.tasks or 0)
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
        
        -- Track position for interpolation
        if args.x and args.y then
            DTNPC_ClientInterpolation.RecordUpdate(uuid, args.x, args.y, args.z or 0)
        end
        
        if cached and cached.npcData then
            cached.npcData.lastX = math.floor(args.x)
            cached.npcData.lastY = math.floor(args.y)
            cached.npcData.lastZ = math.floor(args.z)
            
            if args.health then cached.npcData.health = args.health end
            if args.state then cached.npcData.state = args.state end
            if args.outfitID then
                DTNPCClient.OutfitIDToUUID[args.outfitID] = uuid
                cached.npcData.currentOutfitID = args.outfitID
            end
            
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            
            if not zombie and args.outfitID then
                zombie = DTNPCClient.FindZombieByOutfitID(args.outfitID)
            end
            
            if zombie then
                -- CRITICAL: Update the modData directly so interaction menus see the change
                local zombieData = DTNPC.GetData(zombie)
                if zombieData then
                    if args.state then zombieData.state = args.state end
                    if args.health then zombieData.health = args.health end
                end

                if not DTNPCClient.LocalControlled[uuid] then
                    DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
                end
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
        local outfitID = args.outfitID
        
        if name == "Unknown" and DTNPCClient.NPCCache[uuid] then
            name = DTNPCClient.NPCCache[uuid].npcData.name or "Unknown"
        end
        
        print("[DTNPC-Client] Received RemoveNPC for: " .. name .. " (" .. uuid .. ")")
        
        -- Clear interpolation data
        DTNPC_ClientInterpolation.ClearNPC(uuid)
        
        -- World Removal: Physically remove the zombie if it exists locally
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if not zombie and outfitID then
            zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
        end
        
        if zombie then
            zombie:removeFromWorld()
            zombie:removeFromSquare()
            print("[DTNPC-Client] SUCCESS: Removed zombie from local world: " .. name)
        end
        
        DTNPCClient.RemoveFromCache(uuid, outfitID)
        return
    end

    if command == "SyncAllNPCs" then
        if not args or not args.npcs then return end
        
        print("[DTNPC-Client] Received SyncAllNPCs. Count: " .. DTNPCClient.GetTableSize(args.npcs))
        
        for uuid, npcData in pairs(args.npcs) do
            local outfitID = npcData.currentOutfitID
            DTNPCClient.CacheData(uuid, outfitID, npcData)
            
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            
            if not zombie and outfitID then
                zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
            end
            
            if zombie then
                DTNPCClient.ApplyVisualsToNPC(zombie, npcData)
                DTNPCClient.ProcessedZombies[uuid] = true
                
                -- Sync reported state
                local cached = DTNPCClient.NPCCache[uuid]
                if cached then
                    cached.lastReportedState = {
                        state = npcData.state,
                        tasksCount = (npcData.tasks and #npcData.tasks or 0)
                    }
                end
            end
        end
        return
    end

    if command == "SyncNearbyNPCs" then
        if not args then return end

        local nearbyCount = 0
        local metadataCount = 0

        for uuid, npcData in pairs(args.nearby or {}) do
            if npcData and npcData.npcData then
                local outfitID = npcData.outfitID
                DTNPCClient.CacheData(uuid, outfitID, npcData.npcData)

                -- Track position for interpolation
                local x = npcData.x or npcData.npcData.lastX
                local y = npcData.y or npcData.npcData.lastY
                local z = npcData.z or npcData.npcData.lastZ or 0
                if x and y then
                    DTNPC_ClientInterpolation.RecordUpdate(uuid, x, y, z)
                end

                local zombie = DTNPCClient.FindZombieByUUID(uuid)
                if not zombie and outfitID then
                    zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
                end

                if zombie then
                    DTNPCClient.ApplyVisualsToNPC(zombie, npcData.npcData)
                    DTNPCClient.ReconcilePosition(zombie, x, y, z)
                    DTNPCClient.ProcessedZombies[uuid] = true
                end

                nearbyCount = nearbyCount + 1
            end
        end

        for uuid, meta in pairs(args.metadata or {}) do
            DTNPCClient.CacheMetadata(uuid, meta)
            metadataCount = metadataCount + 1
        end

        print("[DTNPC-Client] Received SyncNearbyNPCs: nearby=" .. nearbyCount .. ", metadata=" .. metadataCount)
        return
    end
end

function DTNPCClient.RequestInitialSync(playerNum)
    if isServer() and isDedicatedServer() then return end
    if DTNPCClient.hasSyncedOnce then return end
    
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    
    print("[DTNPC-Client] Requesting initial sync for player: " .. player:getUsername())
    sendClientCommand(player, "DTNPC", "RequestNearbySync", {
        x = player:getX(),
        y = player:getY(),
        z = player:getZ(),
        nearRadius = 200,
        metadataRadius = 1000,
    })
    DTNPCClient.hasSyncedOnce = true
end

-- Events will be registered in DTNPC_ClientVisuals.lua to ensure all functions are defined.
