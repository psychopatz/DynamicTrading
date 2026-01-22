-- ==============================================================================
-- DTNPC_ClientSync.lua
-- Client-side Logic: Receives NPC data from server and manages local cache.
-- FIXED: Prevents ghost duplicates and improves position reconciliation
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.NPCCache = {}
DTNPCClient.ProcessedZombies = {} -- Track which zombies we've already processed

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
    if brain.visualID and modData.DTNPCVisualID == brain.visualID then
        -- Skip if visuals are already correct to prevent flickering/shuffling
        return 
    end

    print("[DTNPC-Client] Applying visuals for: " .. (brain.name or "Unknown"))

    if DTNPC and DTNPC.ApplyVisuals then
        DTNPC.ApplyVisuals(zombie, brain)
    end
    
    if DTNPC and DTNPC.AttachBrain then
        DTNPC.AttachBrain(zombie, brain)
    end
    
    modData.DTNPCVisualID = brain.visualID
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

-- NEW: Position reconciliation with tolerance
function DTNPCClient.ReconcilePosition(zombie, serverX, serverY, serverZ)
    if not zombie then return end
    
    local localX = zombie:getX()
    local localY = zombie:getY()
    local localZ = zombie:getZ()
    
    local dx = math.abs(localX - serverX)
    local dy = math.abs(localY - serverY)
    local dz = math.abs(localZ - serverZ)
    
    -- Tolerance threshold: 5 tiles
    local TOLERANCE = 5.0
    
    if dx > TOLERANCE or dy > TOLERANCE or dz > 0 then
        print("[DTNPC-Client] Position mismatch detected. Local: " .. math.floor(localX) .. "," .. math.floor(localY) .. " Server: " .. math.floor(serverX) .. "," .. math.floor(serverY))
        print("[DTNPC-Client] Correcting position (delta: " .. math.floor(dx) .. "," .. math.floor(dy) .. ")")
        
        -- Smooth interpolation instead of hard snap
        local lerpFactor = 0.3 -- 30% towards server position per update
        zombie:setX(localX + (serverX - localX) * lerpFactor)
        zombie:setY(localY + (serverY - localY) * lerpFactor)
        zombie:setZ(serverZ)
        
        return true
    end
    
    return false
end

-- NEW: Check if zombie is actually an NPC (prevents claiming regular zombies)
function DTNPCClient.IsValidNPC(zombie)
    if not zombie then return false end
    
    local modData = zombie:getModData()
    
    -- Must have the IsDTNPC flag set
    if not modData.IsDTNPC then return false end
    
    -- Must have a brain attached
    if not modData.DTNPCBrain then return false end
    
    -- Must be useless (our NPCs are always useless)
    if not zombie:isUseless() then return false end
    
    return true
end

-- ==============================================================================
-- 3. SERVER COMMAND HANDLER
-- ==============================================================================

local function onServerCommand(module, command, args)
    if module ~= "DTNPC" then return end

    if command == "SyncNPC" then
        if not args or not args.id or not args.brain then return end
        
        print("[DTNPC-Client] Received SyncNPC for: " .. (args.brain.name or args.id))
        
        DTNPCClient.CacheBrain(args.id, args.brain)
        
        local zombie = DTNPCClient.FindZombieByID(args.id)
        if zombie then
            -- Only apply if it's a valid NPC
            if DTNPCClient.IsValidNPC(zombie) then
                DTNPCClient.ApplyVisualsToNPC(zombie, args.brain)
                DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
                DTNPCClient.ProcessedZombies[args.id] = true
            else
                print("[DTNPC-Client] WARNING: Zombie found but not a valid NPC: " .. args.id)
            end
        else
            print("[DTNPC-Client] WARNING: Zombie not found for ID: " .. args.id)
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
            
            -- Find and reconcile zombie position
            local zombie = DTNPCClient.FindZombieByID(args.id)
            if zombie then
                -- Only reconcile if this client doesn't own the zombie
                if not zombie:isLocal() then
                    DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
                end
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
            if zombie and DTNPCClient.IsValidNPC(zombie) then
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

local VISUAL_CHECK_RATE = 120 -- Increased to 120 ticks (~2 seconds) for performance
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
    local updatedCount = 0
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local id = zombie:getPersistentOutfitID()
            local cached = DTNPCClient.NPCCache[id]
            local modData = zombie:getModData()
            
            -- CRITICAL FIX: Only process if we have cached data AND zombie is marked as NPC
            if cached and cached.brain and modData.IsDTNPC then
                
                -- Skip if already processed to prevent duplicates
                if DTNPCClient.ProcessedZombies[id] then
                    
                    -- Only watch state changes if we're the authority (local zombie)
                    if zombie:isLocal() then
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
                                -- Update cache immediately to prevent spam
                                if updates.state then 
                                    serverBrain.state = updates.state
                                    print("[DTNPC-Client] State changed for " .. (localBrain.name or id) .. ": " .. updates.state)
                                    
                                    -- IMPORTANT: Broadcast position on state change
                                    updates.broadcastPosition = true
                                end
                                if updates.tasks then serverBrain.tasks = updates.tasks end
                                
                                sendClientCommand(getPlayer(), "DTNPC", "UpdateNPC", { id = id, updates = updates })
                                updatedCount = updatedCount + 1
                            end
                        end
                    end
                    
                else
                    -- First time seeing this zombie - attach brain
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached.brain)
                    DTNPCClient.ProcessedZombies[id] = true
                    attachedCount = attachedCount + 1
                end
            end
        end
    end
    
    if attachedCount > 0 then
        print("[DTNPC-Client] Attached brains to " .. attachedCount .. " NPCs")
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
    sendClientCommand(player, "DTNPC", "RequestSync", {})
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