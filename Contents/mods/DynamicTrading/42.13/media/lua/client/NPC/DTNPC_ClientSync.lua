-- ==============================================================================
-- DTNPC_ClientSync.lua
-- Client-side Logic: Receives NPC data from server and manages local cache.
-- FIXED: Use UUID system for proper tracking across respawns
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.NPCCache = {} -- Now keyed by UUID
DTNPCClient.OutfitIDToUUID = {} -- Maps outfit IDs to UUIDs
DTNPCClient.ProcessedZombies = {} -- Tracks which zombies have had visuals applied
DTNPCClient.LocalControlled = {} -- Tracks locally controlled NPCs

-- ==============================================================================
-- 1. CACHE MANAGEMENT
-- ==============================================================================

function DTNPCClient.GetBrain(zombie)
    if not zombie then return nil end
    
    -- First check modData for direct brain
    local modData = zombie:getModData()
    if modData and modData.DTNPCBrain then
        return modData.DTNPCBrain
    end
    
    -- Try to find by UUID
    local uuid = modData.DTNPC_UUID
    if uuid and DTNPCClient.NPCCache[uuid] then
        return DTNPCClient.NPCCache[uuid].brain
    end
    
    -- Fallback to outfit ID
    local outfitID = zombie:getPersistentOutfitID()
    uuid = DTNPCClient.OutfitIDToUUID[outfitID]
    if uuid and DTNPCClient.NPCCache[uuid] then
        return DTNPCClient.NPCCache[uuid].brain
    end
    
    return nil
end

function DTNPCClient.CacheBrain(uuid, outfitID, brain)
    if not uuid or not brain then return end
    
    DTNPCClient.NPCCache[uuid] = {
        brain = brain,
        lastSync = getTimestampMs()
    }
    
    if outfitID then
        DTNPCClient.OutfitIDToUUID[outfitID] = uuid
    end
    
    print("[DTNPC-Client] Cached brain for: " .. (brain.name or uuid) .. " (UUID: " .. uuid .. ")")
end

function DTNPCClient.RemoveFromCache(uuid, outfitID)
    if uuid then
        DTNPCClient.NPCCache[uuid] = nil
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
        print("[DTNPC-Client] Removed from cache: " .. uuid)
    end
    
    if outfitID then
        DTNPCClient.OutfitIDToUUID[outfitID] = nil
    end
end

-- ==============================================================================
-- 2. VISUAL APPLICATION
-- ==============================================================================

function DTNPCClient.ApplyVisualsToNPC(zombie, brain)
    if not zombie or not brain then return end
    if isServer() then return end
    
    local modData = zombie:getModData()
    local uuid = brain.uuid
    
    if brain.visualID and modData.DTNPCVisualID == brain.visualID then
        return
    end

    print("[DTNPC-Client] Applying visuals for: " .. (brain.name or "Unknown") .. " (UUID: " .. uuid .. ")")

    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    
    if DTNPC and DTNPC.AttachBrain then
        DTNPC.AttachBrain(zombie, brain)
    end
    
    if DTNPC and DTNPC.ApplyVisuals then
        DTNPC.ApplyVisuals(zombie, brain)
    end
    
    modData.DTNPCVisualID = brain.visualID
    
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:DoZombieStats()
    end
    
    zombie:resetModelNextFrame()
end

function DTNPCClient.FindZombieByUUID(uuid)
    local cell = getCell()
    if not cell then return nil end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local modData = zombie:getModData()
            if modData.DTNPC_UUID == uuid then
                return zombie
            end
        end
    end
    
    return nil
end

function DTNPCClient.FindZombieByOutfitID(outfitID)
    local cell = getCell()
    if not cell then return nil end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and zombie:getPersistentOutfitID() == outfitID then
            return zombie
        end
    end
    
    return nil
end

function DTNPCClient.ReconcilePosition(zombie, serverX, serverY, serverZ)
    if not zombie then return end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID
    
    if DTNPCClient.LocalControlled[uuid] then
        return false
    end
    
    local localX = zombie:getX()
    local localY = zombie:getY()
    local localZ = zombie:getZ()
    
    local dx = math.abs(localX - serverX)
    local dy = math.abs(localY - serverY)
    local dz = math.abs(localZ - serverZ)
    
    local TOLERANCE = 3.0
    
    if dx > TOLERANCE or dy > TOLERANCE or dz > 0 then
        local lerpFactor = 0.2
        zombie:setX(localX + (serverX - localX) * lerpFactor)
        zombie:setY(localY + (serverY - localY) * lerpFactor)
        zombie:setZ(serverZ)
        
        return true
    end
    
    return false
end

function DTNPCClient.IsValidNPC(zombie)
    if not zombie then return false end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID
    
    if uuid and DTNPCClient.NPCCache[uuid] then
        return true
    end
    
    if modData.IsDTNPC then
        return true
    end
    
    return false
end

function DTNPCClient.SetLocalControl(uuid, isControlled)
    if uuid then
        DTNPCClient.LocalControlled[uuid] = isControlled
    end
end

-- ==============================================================================
-- 3. SERVER COMMAND HANDLER
-- ==============================================================================

local function onServerCommand(module, command, args)
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

Events.OnServerCommand.Add(onServerCommand)

-- ==============================================================================
-- 4. PERIODIC VISUAL CHECK & BRAIN ATTACHMENT
-- ==============================================================================

local VISUAL_CHECK_RATE = 60
local visualCheckCounter = 0

local function onTick()
    if isServer() then return end
    if not isClient() then return end
    
    visualCheckCounter = visualCheckCounter + 1
    if visualCheckCounter < VISUAL_CHECK_RATE then return end
    visualCheckCounter = 0
    
    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    local attachedCount = 0
    local reappliedCount = 0
    local updatedCount = 0
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local modData = zombie:getModData()
            local uuid = modData.DTNPC_UUID
            
            if not uuid then
                local outfitID = zombie:getPersistentOutfitID()
                uuid = DTNPCClient.OutfitIDToUUID[outfitID]
                if uuid then
                    modData.DTNPC_UUID = uuid
                end
            end
            
            local cached = DTNPCClient.NPCCache[uuid]
            
            if cached and cached.brain then
                
                if not DTNPCClient.ProcessedZombies[uuid] or modData.DTNPCVisualID ~= cached.brain.visualID then
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached.brain)
                    DTNPCClient.ProcessedZombies[uuid] = true
                    
                    if modData.DTNPCVisualID ~= cached.brain.visualID then
                        reappliedCount = reappliedCount + 1
                    else
                        attachedCount = attachedCount + 1
                    end
                else
                    if zombie:isLocal() and modData.IsDTNPC then
                        DTNPCClient.SetLocalControl(uuid, true)
                        
                        local localBrain = modData.DTNPCBrain
                        local serverBrain = cached.brain
                        
                        if localBrain and serverBrain then
                            local changed = false
                            local updates = {}
                            
                            if localBrain.state ~= serverBrain.state then
                                updates.state = localBrain.state
                                changed = true
                            end
                            
                            if localBrain.tasks and serverBrain.tasks then
                                if #localBrain.tasks ~= #serverBrain.tasks then
                                    updates.tasks = localBrain.tasks
                                    changed = true
                                end
                            end
                            
                            if changed then
                                if updates.state then 
                                    serverBrain.state = updates.state
                                    updates.broadcastPosition = true
                                end
                                if updates.tasks then serverBrain.tasks = updates.tasks end
                                
                                sendClientCommand(getPlayer(), "DTNPC", "UpdateNPC", { uuid = uuid, updates = updates })
                                updatedCount = updatedCount + 1
                            end
                        end
                    else
                        DTNPCClient.SetLocalControl(uuid, false)
                    end
                end
            end
        end
    end
    
    if attachedCount > 0 then
        print("[DTNPC-Client] Attached brains to " .. attachedCount .. " new NPCs")
    end
    if reappliedCount > 0 then
        print("[DTNPC-Client] Reapplied visuals to " .. reappliedCount .. " NPCs")
    end
    if updatedCount > 0 then
        print("[DTNPC-Client] Sent " .. updatedCount .. " state updates to server")
    end
end

Events.OnTick.Add(onTick)

-- ==============================================================================
-- 5. REQUEST SYNC ON JOIN
-- ==============================================================================

local hasSyncedOnce = false

local function onPlayerCreated(playerNum)
    if not isClient() then return end
    if hasSyncedOnce then return end
    
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    
    print("[DTNPC-Client] Requesting initial sync for player: " .. player:getUsername())
    sendClientCommand(player, "DTNPC", "RequestFullSync", {})
    hasSyncedOnce = true
end

Events.OnCreatePlayer.Add(onPlayerCreated)

-- ==============================================================================
-- 6. CLEANUP ON ZOMBIE REMOVAL
-- ==============================================================================

local function onZombieRemoved(zombie)
    if not zombie then return end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID
    
    if uuid and DTNPCClient.ProcessedZombies[uuid] then
        print("[DTNPC-Client] Zombie removed from world: " .. uuid)
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
    end
end

Events.OnZombieUpdate.Add(function(zombie)
    if not zombie or zombie:isDead() then
        onZombieRemoved(zombie)
    end
end)

-- ==============================================================================
-- 7. UTILITIES
-- ==============================================================================

function DTNPCClient.GetTableSize(t)
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end