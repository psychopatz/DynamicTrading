-- ==============================================================================
-- DTNPC_ClientSync.lua
-- Client-side Logic: Receives NPC data from server and manages local cache.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.NPCCache = {}

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
end

function DTNPCClient.RemoveFromCache(id)
    if id then
        DTNPCClient.NPCCache[id] = nil
    end
end

-- ==============================================================================
-- 2. VISUAL APPLICATION
-- ==============================================================================

function DTNPCClient.ApplyVisualsToNPC(zombie, brain)
    if not zombie or not brain then return end
    if isServer() then return end
    
    -- 1. Check if visuals were ALREADY applied to this specific OBJECT instance
    -- (zombie.DTNPC_VisualsID is a local Lua field, not synced/saved, so it resets on load)
    if zombie.DTNPC_VisualsID == brain.visualID then
        return 
    end

    if DTNPC and DTNPC.ApplyVisuals then
        DTNPC.ApplyVisuals(zombie, brain)
    end
    
    if DTNPC and DTNPC.AttachBrain then
        DTNPC.AttachBrain(zombie, brain)
    end
    
    zombie.DTNPC_VisualsID = brain.visualID
    
    -- Also update ModData for logic checks (LastVisualID stays in ModData)
    zombie:getModData().LastVisualID = brain.visualID
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

-- ==============================================================================
-- 3. SERVER COMMAND HANDLER
-- ==============================================================================

local function onServerCommand(module, command, args)
    if module ~= "DTNPC" then return end

    if command == "SyncNPC" then
        if not args or not args.id or not args.brain then return end
        
        DTNPCClient.CacheBrain(args.id, args.brain)
        
        local zombie = DTNPCClient.FindZombieByID(args.id)
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, args.brain)
        end
        return
    end

    if command == "RemoveNPC" then
        if not args or not args.id then return end
        DTNPCClient.RemoveFromCache(args.id)
        return
    end

    if command == "SyncAllNPCs" then
        if not args or not args.npcs then return end
        
        for id, brain in pairs(args.npcs) do
            DTNPCClient.CacheBrain(id, brain)
            
            local zombie = DTNPCClient.FindZombieByID(id)
            if zombie then
                DTNPCClient.ApplyVisualsToNPC(zombie, brain)
            end
        end
        return
    end
end

Events.OnServerCommand.Add(onServerCommand)

-- ==============================================================================
-- 4. PERIODIC VISUAL CHECK & BRAIN ATTACHMENT
-- ==============================================================================

local VISUAL_CHECK_RATE = 20 -- Check every ~0.3 seconds (was 60)
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
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local id = zombie:getPersistentOutfitID()
            local cached = DTNPCClient.NPCCache[id]
            local modData = zombie:getModData()
            
            -- 1. Attach Brain if missing (Server -> Client Sync)
            if cached and cached.brain then
                -- Check if object needs visual application (using local instance flag)
                if not modData.IsDTNPC or zombie.DTNPC_VisualsID ~= cached.brain.visualID then
                    modData.DTNPCBrain = cached.brain
                    modData.IsDTNPC = true
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached.brain)
                else
                    -- 2. State Watcher (Client -> Server Sync)
                    -- If local logic changed the state (e.g. finished Moving), sync back to server
                    local localBrain = modData.DTNPCBrain
                    local serverBrain = cached.brain
                    
                    if localBrain and serverBrain then
                         local changed = false
                         local updates = {}
                         
                         if localBrain.state ~= serverBrain.state then
                             updates.state = localBrain.state
                             changed = true
                         end
                         
                         -- Simple check for task completion (active to empty)
                         if localBrain.tasks and serverBrain.tasks then
                             if #localBrain.tasks ~= #serverBrain.tasks then
                                  updates.tasks = localBrain.tasks
                                  changed = true
                             end
                         end
                         
                         if changed and zombie:isLocal() then -- Only Authority sends updates
                             -- Update cache immediately to stop spam
                             if updates.state then serverBrain.state = updates.state end
                             if updates.tasks then serverBrain.tasks = updates.tasks end
                             
                             sendClientCommand(getPlayer(), "DTNPC", "UpdateNPC", { id = id, updates = updates })
                         end
                    end
                end
            elseif modData.IsDTNPC then
                -- 3. BRAIN MISSING! We see modData.IsDTNPC but have no cached brain.
                -- Request it from server. (Throttled by timestamp)
                if not zombie.lastBrainRequest or (getTimestampMs() - zombie.lastBrainRequest > 5000) then
                    zombie.lastBrainRequest = getTimestampMs()
                    sendClientCommand(getPlayer(), "DTNPC", "RequestBrain", { id = id })
                    -- print("[DTNPC] Identified unknown NPC " .. tostring(id) .. ". Requesting brain...")
                end
            end
        end
    end
end

Events.OnTick.Add(onTick)

-- ==============================================================================
-- 5. REQUEST SYNC ON JOIN
-- ==============================================================================

local function onPlayerCreated(playerNum)
    if not isClient() then return end
    
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    
    sendClientCommand(player, "DTNPC", "RequestSync", {})
end

Events.OnCreatePlayer.Add(onPlayerCreated)
