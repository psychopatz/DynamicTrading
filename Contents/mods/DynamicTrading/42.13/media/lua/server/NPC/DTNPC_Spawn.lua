-- ==============================================================================
-- DTNPC_Spawn.lua
-- Server-side Logic: Spawning, Commands, Summoning, and Multiplayer Sync.
-- FIXED: Better position broadcasting and state change handling
-- ==============================================================================

require "NPC/Sys/DTNPC_Generator"

DTNPCSpawn = DTNPCSpawn or {}

-- ==============================================================================
-- 1. MULTIPLAYER SYNC FUNCTIONS
-- ==============================================================================

function DTNPCSpawn.SyncToAllClients(zombie, brain)
    if not zombie or not brain then return end
    if not isServer() then return end
    
    local id = zombie:getPersistentOutfitID()
    local syncData = {
        id = id,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers then
        for i = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(i)
            if player then
                sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
            end
        end
    end
    
    print("[DTNPC] Synced NPC to all clients: " .. (brain.name or id) .. " at " .. syncData.x .. "," .. syncData.y)
end

function DTNPCSpawn.SyncToPlayer(player, zombie, brain)
    if not player or not zombie or not brain then return end
    if not isServer() then return end
    
    local id = zombie:getPersistentOutfitID()
    local syncData = {
        id = id,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
    print("[DTNPC] Synced NPC to player " .. player:getUsername() .. ": " .. (brain.name or id))
end

-- NEW: Lightweight position-only broadcast
function DTNPCSpawn.BroadcastPosition(zombie, brain)
    if not zombie or not brain then return end
    if not isServer() then return end
    
    local id = zombie:getPersistentOutfitID()
    local posData = {
        id = id,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        health = zombie:getHealth(),
        state = brain.state
    }
    
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers then
        for i = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(i)
            if player then
                sendServerCommand(player, "DTNPC", "UpdatePosition", posData)
            end
        end
    end
end

function DTNPCSpawn.NotifyRemoval(id)
    if not id then return end
    if not isServer() then return end
    
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers then
        for i = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(i)
            if player then
                sendServerCommand(player, "DTNPC", "RemoveNPC", { id = id })
            end
        end
    end
    
    print("[DTNPC] Notified all clients of NPC removal: " .. id)
end

-- ==============================================================================
-- 2. SPAWN FUNCTION
-- ==============================================================================

function DTNPCSpawn.SpawnNPC(player, existingBrain, options)
    if not player then return end
    
    options = options or {}
    
    local x, y, z = player:getX(), player:getY(), player:getZ()
    
    -- Pick a safe spawn location
    local spawnX, spawnY = x + 1, y + 1
    local cell = getCell()
    local foundSafe = false
    
    for _x = -2, 2 do
        for _y = -2, 2 do
            local sq = cell:getGridSquare(x + _x, y + _y, z)
            if sq and sq:isFree(false) and not sq:isSolid() and not sq:isSolidTrans() then
                spawnX = x + _x
                spawnY = y + _y
                foundSafe = true
                break
            end
        end
        if foundSafe then break end
    end
    
    print("[DTNPC] Spawning NPC at: " .. spawnX .. "," .. spawnY .. "," .. z)
    
    -- Spawn a naked zombie initially to ensure we have full control over outfit
    local outfitStr = "Naked"
    local femaleChance = 50 
    
    -- If we have an existing brain, match the gender of the zombie to the brain
    if existingBrain then
        femaleChance = existingBrain.isFemale and 100 or 0
    end
    
    local zombieList = addZombiesInOutfit(spawnX, spawnY, z, 1, outfitStr, femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then 
        print("[DTNPC] ERROR: Failed to spawn zombie at " .. spawnX .. "," .. spawnY)
        return 
    end

    local zombie = zombieList:get(0)
    
    local brain = existingBrain
    
    if not brain then
        -- GENERATE NEW BRAIN
        local genOptions = {
            masterName = player:getUsername(),
            masterID = player:getOnlineID(),
            forceMVP = options.forceMVP,
            walkSpeed = options.walkSpeed,
            runSpeed = options.runSpeed
        }
        
        brain = DTNPCGenerator.Generate(genOptions)
        print("[DTNPC] Generated new brain for: " .. brain.name)
    else
        -- REHYDRATE BRAIN
        if not brain.tasks then brain.tasks = {} end
        if not brain.walkSpeed then brain.walkSpeed = DTNPC.DefaultWalkSpeed end
        if not brain.runSpeed then brain.runSpeed = DTNPC.DefaultRunSpeed end
        if not brain.visualID then brain.visualID = ZombRand(1000000) end
        
        -- RESET STATE (Fixes "Spawns Hostile" bug when summoning/respawning)
        brain.state = "Stay"
        brain.isHostile = false
        print("[DTNPC] Rehydrated brain for: " .. brain.name)
    end

    DTNPC.AttachBrain(zombie, brain)
    DTNPC.ApplyVisuals(zombie, brain)

    if DTNPCManager then
        DTNPCManager.Register(zombie, brain)
    end

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)    

    DTNPCSpawn.SyncToAllClients(zombie, brain)

    print("[DTNPC] Spawned/Summoned: " .. brain.name .. " | ID: " .. zombie:getPersistentOutfitID())
    
    return zombie, brain
end

-- ==============================================================================
-- 3. SUMMON FUNCTION
-- ==============================================================================

function DTNPCSpawn.SummonAll(player)
    if not DTNPCManager then return end
    local username = player:getUsername()
    local cell = getCell()
    local toTeleport = {}
    local toRecreate = {}
    
    print("[DTNPC] Summoning NPCs for player: " .. username)
    
    for id, brain in pairs(DTNPCManager.Data) do
        if brain.master == username then
            local foundObj = nil
            local zombieList = cell:getZombieList()
            for i=0, zombieList:size()-1 do
                local z = zombieList:get(i)
                if z:getPersistentOutfitID() == id then
                    foundObj = z
                    break
                end
            end
            
            if foundObj then
                table.insert(toTeleport, foundObj)
                print("[DTNPC] Found existing NPC to teleport: " .. (brain.name or id))
            else
                brain.oldID = id 
                table.insert(toRecreate, brain)
                print("[DTNPC] NPC not found in world, will recreate: " .. (brain.name or id))
            end
        end
    end
    
    for _, npc in ipairs(toTeleport) do
        npc:setX(player:getX() + 1)
        npc:setY(player:getY() + 1)
        npc:setZ(player:getZ())
        npc:setLastX(player:getX())
        npc:setLastY(player:getY())
        
        local brain = DTNPC.GetBrain(npc)
        if brain then
            brain.lastX = math.floor(npc:getX())
            brain.lastY = math.floor(npc:getY())
            brain.lastZ = math.floor(npc:getZ())
            DTNPCSpawn.SyncToAllClients(npc, brain)
        end
    end
    
    for _, brain in ipairs(toRecreate) do
        DTNPCManager.RemoveData(brain.oldID)
        DTNPCSpawn.SpawnNPC(player, brain)
    end
    
    print("[DTNPC] Summon complete. Teleported: " .. #toTeleport .. ", Recreated: " .. #toRecreate)
end

-- ==============================================================================
-- 4. CLIENT COMMAND HANDLER
-- ==============================================================================

local function onClientCommand(module, command, player, args)
    if module ~= "DTNPC" then return end

    if command == "Spawn" then
        print("[DTNPC] Received Spawn command from: " .. player:getUsername())
        DTNPCSpawn.SpawnNPC(player, nil, args)
    end

    if command == "Summon" then
        print("[DTNPC] Received Summon command from: " .. player:getUsername())
        DTNPCSpawn.SummonAll(player)
    end

    if command == "Order" then
        print("[DTNPC] Received Order command from: " .. player:getUsername() .. " | State: " .. (args.state or "Unknown"))
        local square = getCell():getGridSquare(args.x, args.y, args.z)
        if square then
            local movingObjects = square:getMovingObjects()
            for i=0, movingObjects:size()-1 do
                local obj = movingObjects:get(i)
                if instanceof(obj, "IsoZombie") then
                    local brain = DTNPC.GetBrain(obj)
                    if brain then
                        brain.state = args.state
                        brain.tasks = {} 
                        
                        if args.state == "GoTo" then
                           table.insert(brain.tasks, {x = math.floor(args.targetX), y = math.floor(args.targetY), z = math.floor(args.targetZ or 0)})
                           print("[DTNPC] GoTo task added: " .. args.targetX .. "," .. args.targetY)
                        end

                        DTNPC.AttachBrain(obj, brain)
                        if DTNPCManager then DTNPCManager.Register(obj, brain) end
                        
                        -- IMPORTANT: Broadcast position immediately on state change
                        DTNPCSpawn.SyncToAllClients(obj, brain)
                        DTNPCSpawn.BroadcastPosition(obj, brain)
                        break
                    end
                end
            end
        end
    end
    
    if command == "RequestSync" then
        print("[DTNPC] Received RequestSync from: " .. player:getUsername())
        if not DTNPCManager then return end
        
        local cell = getCell()
        if not cell then return end
        
        local zombieList = cell:getZombieList()
        if not zombieList then return end
        
        local syncCount = 0
        for i = 0, zombieList:size() - 1 do
            local zombie = zombieList:get(i)
            if zombie then
                local id = zombie:getPersistentOutfitID()
                local brain = DTNPCManager.Data[id]
                if brain then
                    DTNPCSpawn.SyncToPlayer(player, zombie, brain)
                    syncCount = syncCount + 1
                end
            end
        end
        
        print("[DTNPC] Sent " .. syncCount .. " nearby NPCs to: " .. player:getUsername())
    end

    if command == "RequestFullSync" then
        print("[DTNPC] Received RequestFullSync from: " .. player:getUsername())
        if not DTNPCManager or not DTNPCManager.Data then return end
        
        -- Send the entire database
        sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
        print("[DTNPC] Sent full database (" .. DTNPCManager.GetTableSize(DTNPCManager.Data) .. " NPCs) to: " .. player:getUsername())
    end

    if command == "UpdateNPC" then
        -- Client reporting state change (e.g. finished GoTo)
        if not args.id or not args.updates then return end
        
        print("[DTNPC] Received UpdateNPC for ID: " .. args.id)
        
        local id = args.id
        local serverBrain = DTNPCManager.Data[id]
        
        if serverBrain then
            local shouldBroadcast = args.updates.broadcastPosition or false
            
            -- Apply updates
            for k, v in pairs(args.updates) do
                if k ~= "broadcastPosition" then -- Skip the flag itself
                    print("[DTNPC]   Updating " .. k .. " to " .. tostring(v))
                    serverBrain[k] = v
                end
            end
            
            DTNPCManager.Save()
            
            -- Find zombie to sync back/update server entity
            local cell = getCell()
            if cell then
                local zombieList = cell:getZombieList()
                for i = 0, zombieList:size() - 1 do
                    local z = zombieList:get(i)
                    if z and z:getPersistentOutfitID() == id then
                         DTNPC.AttachBrain(z, serverBrain)
                         DTNPCSpawn.SyncToAllClients(z, serverBrain)
                         
                         -- CRITICAL: Broadcast position when state changes
                         if shouldBroadcast then
                             print("[DTNPC] Broadcasting position due to state change")
                             DTNPCSpawn.BroadcastPosition(z, serverBrain)
                         end
                         
                         print("[DTNPC] Updated and synced NPC to all clients")
                         break
                    end
                end
            end
        else
            print("[DTNPC] WARNING: UpdateNPC for unknown ID: " .. id)
        end
    end

    if command == "RemoveNPC" then
        -- Client reporting NPC exit/death
        if not args.id then return end
        
        print("[DTNPC] Received RemoveNPC for ID: " .. args.id)
        
        if DTNPCManager then
            -- Remove from DB
            DTNPCManager.Data[args.id] = nil
            DTNPCManager.Save()
            
            -- Notify all clients to remove from cache
            DTNPCSpawn.NotifyRemoval(args.id)
            
            -- Try to remove server entity if it exists
            local cell = getCell()
            if cell then
                local zombieList = cell:getZombieList()
                for i = 0, zombieList:size() - 1 do
                    local z = zombieList:get(i)
                    if z and z:getPersistentOutfitID() == args.id then
                         z:removeFromWorld()
                         z:removeFromSquare()
                         print("[DTNPC] Removed NPC from world")
                         break
                    end
                end
            end
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)