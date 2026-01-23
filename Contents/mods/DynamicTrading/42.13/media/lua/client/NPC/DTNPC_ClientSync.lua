-- ==============================================================================
-- DTNPC_ClientSync.lua
-- Client-side Logic: Receives NPC data from server and manages local cache.
-- FIXED: Relaxed validity check and proper sync timing
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.NPCCache = {}
DTNPCClient.ProcessedZombies = {}
DTNPCClient.LocalControlled = {}

-- ==============================================================================
-- 1. CACHE MANAGEMENT
-- ==============================================================================

function DTNPCClient.GetBrain(zombie)
    if not zombie then return nil end
    
    local id = zombie:getPersistentOutfitID()
    if id and DTNPCClient.NPCCache[id] then
        return DTNPCClient.NPCCache[id].brain
    end
    
    local modData = zombie:getModData()
    if modData and modData.DTNPCBrain then
        return modData.DTNPCBrain
    end
    
    return nil
end

function DTNPCClient.CacheBrain(id, brain)
    if not id or not brain then return end
    
    DTNPCClient.NPCCache[id] = {
        brain = brain,
        lastSync = getTimestampMs()
    }
    
    print("[DTNPC-Client] Cached brain for: " .. (brain.name or id))
end

function DTNPCClient.RemoveFromCache(id)
    if id then
        DTNPCClient.NPCCache[id] = nil
        DTNPCClient.ProcessedZombies[id] = nil
        DTNPCClient.LocalControlled[id] = nil
        print("[DTNPC-Client] Removed from cache: " .. id)
    end
end

-- ==============================================================================
-- 2. VISUAL APPLICATION
-- ==============================================================================

function DTNPCClient.ApplyVisualsToNPC(zombie, brain)
    if not zombie or not brain then return end
    if isServer() then return end
    
    local modData = zombie:getModData()
    local id = zombie:getPersistentOutfitID()
    
    -- Check if visuals need updating
    if brain.visualID and modData.DTNPCVisualID == brain.visualID then
        return -- Already applied
    end

    print("[DTNPC-Client] Applying visuals for: " .. (brain.name or "Unknown") .. " (ID: " .. id .. ")")

    -- First, mark as NPC BEFORE applying visuals
    modData.IsDTNPC = true
    
    -- Attach brain to modData BEFORE applying visuals
    if DTNPC and DTNPC.AttachBrain then
        DTNPC.AttachBrain(zombie, brain)
    end
    
    -- Apply visuals using shared function
    if DTNPC and DTNPC.ApplyVisuals then
        DTNPC.ApplyVisuals(zombie, brain)
    end
    
    -- Mark as applied
    modData.DTNPCVisualID = brain.visualID
    
    -- Ensure useless flag is set
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:DoZombieStats()
    end
    
    -- Force model refresh
    zombie:resetModelNextFrame()
end

function DTNPCClient.FindZombieByID(id)
    local cell = getCell()
    if not cell then return nil end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and zombie:getPersistentOutfitID() == id then
            return zombie
        end
    end
    
    return nil
end

-- Position reconciliation with tolerance
function DTNPCClient.ReconcilePosition(zombie, serverX, serverY, serverZ)
    if not zombie then return end
    
    local id = zombie:getPersistentOutfitID()
    
    -- Don't reconcile if we control this NPC
    if DTNPCClient.LocalControlled[id] then
        return false
    end
    
    local localX = zombie:getX()
    local localY = zombie:getY()
    local localZ = zombie:getZ()
    
    local dx = math.abs(localX - serverX)
    local dy = math.abs(localY - serverY)
    local dz = math.abs(localZ - serverZ)
    
    -- Tolerance threshold: 3 tiles
    local TOLERANCE = 3.0
    
    if dx > TOLERANCE or dy > TOLERANCE or dz > 0 then
        -- Smooth interpolation
        local lerpFactor = 0.2
        zombie:setX(localX + (serverX - localX) * lerpFactor)
        zombie:setY(localY + (serverY - localY) * lerpFactor)
        zombie:setZ(serverZ)
        
        return true
    end
    
    return false
end

-- RELAXED validity check - only check if it has IsDTNPC flag
-- Don't require brain or useless state yet, as those are applied during sync
function DTNPCClient.IsValidNPC(zombie)
    if not zombie then return false end
    
    local modData = zombie:getModData()
    
    -- Only requirement: Must have the IsDTNPC flag OR we have cached data for it
    local id = zombie:getPersistentOutfitID()
    
    -- If we have cached brain data for this ID, it's valid
    if id and DTNPCClient.NPCCache[id] then
        return true
    end
    
    -- Otherwise check modData flag
    if modData.IsDTNPC then
        return true
    end
    
    return false
end

function DTNPCClient.SetLocalControl(id, isControlled)
    if id then
        DTNPCClient.LocalControlled[id] = isControlled
    end
end

-- ==============================================================================
-- 3. SERVER COMMAND HANDLER
-- ==============================================================================

local function onServerCommand(module, command, args)
    if module ~= "DTNPC" then return end

    if command == "SyncNPC" then
        if not args or not args.id or not args.brain then return end
        
        print("[DTNPC-Client] Received SyncNPC for: " .. (args.brain.name or args.id))
        
        -- Cache the brain data FIRST
        DTNPCClient.CacheBrain(args.id, args.brain)
        
        -- Try to find zombie
        local zombie = DTNPCClient.FindZombieByID(args.id)
        if zombie then
            -- APPLY VISUALS IMMEDIATELY - don't check IsValidNPC first
            -- because the zombie won't be "valid" until we apply the visuals!
            DTNPCClient.ApplyVisualsToNPC(zombie, args.brain)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
            DTNPCClient.ProcessedZombies[args.id] = true
            print("[DTNPC-Client] Applied visuals to zombie: " .. args.id)
        else
            -- Zombie not loaded yet, cache will be applied when it appears
            print("[DTNPC-Client] Zombie not in world yet, cached for later: " .. args.id)
        end
        return
    end

    if command == "UpdatePosition" then
        if not args or not args.id then return end
        
        local cached = DTNPCClient.NPCCache[args.id]
        if cached and cached.brain then
            -- Update cached position
            cached.brain.lastX = math.floor(args.x)
            cached.brain.lastY = math.floor(args.y)
            cached.brain.lastZ = math.floor(args.z)
            
            if args.health then cached.brain.health = args.health end
            if args.state then cached.brain.state = args.state end
            
            -- Find and reconcile zombie position (only if not locally controlled)
            local zombie = DTNPCClient.FindZombieByID(args.id)
            if zombie and not DTNPCClient.LocalControlled[args.id] then
                DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
            end
        end
        return
    end

    if command == "RemoveNPC" then
        if not args or not args.id then return end
        print("[DTNPC-Client] Received RemoveNPC for: " .. args.id)
        DTNPCClient.RemoveFromCache(args.id)
        return
    end

    if command == "SyncAllNPCs" then
        if not args or not args.npcs then return end
        
        print("[DTNPC-Client] Received SyncAllNPCs. Count: " .. DTNPCClient.GetTableSize(args.npcs))
        
        for id, brain in pairs(args.npcs) do
            DTNPCClient.CacheBrain(id, brain)
            
            local zombie = DTNPCClient.FindZombieByID(id)
            if zombie then
                -- Apply visuals immediately without validity check
                DTNPCClient.ApplyVisualsToNPC(zombie, brain)
                DTNPCClient.ProcessedZombies[id] = true
            end
        end
        return
    end
end

Events.OnServerCommand.Add(onServerCommand)

-- ==============================================================================
-- 4. PERIODIC VISUAL CHECK & BRAIN ATTACHMENT
-- ==============================================================================

local VISUAL_CHECK_RATE = 60 -- Check every ~1 second
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
            local id = zombie:getPersistentOutfitID()
            local cached = DTNPCClient.NPCCache[id]
            local modData = zombie:getModData()
            
            -- If we have cached data for this zombie
            if cached and cached.brain then
                
                -- Check if visuals need application/reapplication
                if not DTNPCClient.ProcessedZombies[id] or modData.DTNPCVisualID ~= cached.brain.visualID then
                    -- Apply visuals
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached.brain)
                    DTNPCClient.ProcessedZombies[id] = true
                    
                    if modData.DTNPCVisualID ~= cached.brain.visualID then
                        reappliedCount = reappliedCount + 1
                    else
                        attachedCount = attachedCount + 1
                    end
                else
                    -- Already processed, check if we control this NPC
                    if zombie:isLocal() and modData.IsDTNPC then
                        DTNPCClient.SetLocalControl(id, true)
                        
                        local localBrain = modData.DTNPCBrain
                        local serverBrain = cached.brain
                        
                        if localBrain and serverBrain then
                            local changed = false
                            local updates = {}
                            
                            -- Track state changes
                            if localBrain.state ~= serverBrain.state then
                                updates.state = localBrain.state
                                changed = true
                            end
                            
                            -- Check for task completion
                            if localBrain.tasks and serverBrain.tasks then
                                if #localBrain.tasks ~= #serverBrain.tasks then
                                    updates.tasks = localBrain.tasks
                                    changed = true
                                end
                            end
                            
                            if changed then
                                -- Update cache immediately
                                if updates.state then 
                                    serverBrain.state = updates.state
                                    updates.broadcastPosition = true
                                end
                                if updates.tasks then serverBrain.tasks = updates.tasks end
                                
                                sendClientCommand(getPlayer(), "DTNPC", "UpdateNPC", { id = id, updates = updates })
                                updatedCount = updatedCount + 1
                            end
                        end
                    else
                        DTNPCClient.SetLocalControl(id, false)
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
    
    local id = zombie:getPersistentOutfitID()
    if id and DTNPCClient.ProcessedZombies[id] then
        print("[DTNPC-Client] Zombie removed from world: " .. id)
        DTNPCClient.ProcessedZombies[id] = nil
        DTNPCClient.LocalControlled[id] = nil
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