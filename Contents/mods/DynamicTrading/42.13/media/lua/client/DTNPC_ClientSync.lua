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
    
    if DTNPC and DTNPC.ApplyVisuals then
        DTNPC.ApplyVisuals(zombie, brain)
    end
    
    if DTNPC and DTNPC.AttachBrain then
        DTNPC.AttachBrain(zombie, brain)
    end
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
            
            if cached and cached.brain then
                -- Always attach brain to moddata so debug menu shows it
                local modData = zombie:getModData()
                if not modData.IsDTNPC then
                    modData.DTNPCBrain = cached.brain
                    modData.IsDTNPC = true
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached.brain)
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
