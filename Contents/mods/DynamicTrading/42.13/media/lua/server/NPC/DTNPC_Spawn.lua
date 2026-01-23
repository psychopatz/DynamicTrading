-- ==============================================================================
-- DTNPC_Spawn.lua
-- Server-side Logic: Spawning, Commands, Summoning, and Multiplayer Sync.
-- FIXED: Proper spawn sequence to prevent validation failures
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
    
    -- Ensure modData is set up properly
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = brain.visualID
    
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
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = brain.visualID
    
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
    
    -- Spawn naked zombie
    local outfitStr = "Naked"
    local femaleChance = 50 
    
    if existingBrain then
        femaleChance = existingBrain.isFemale and 100 or 0
    end
    
    local zombieList = addZombiesInOutfit(spawnX, spawnY, z, 1, outfitStr, femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then 
        print("[DTNPC] ERROR: Failed to spawn zombie at " .. spawnX .. "," .. spawnY)
        return 
    end

    local zombie = zombieList:get(0)
    local id = zombie:getPersistentOutfitID()
    
    -- CRITICAL: Mark as NPC IMMEDIATELY to prevent duplicate spawns
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    
    local brain = existingBrain
    
    if not brain then
        -- Generate new brain
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
        -- Rehydrate brain
        if not brain.tasks then brain.tasks = {} end
        if not brain.walkSpeed then brain.walkSpeed = DTNPC.DefaultWalkSpeed end
        if not brain.runSpeed then brain.runSpeed = DTNPC.DefaultRunSpeed end
        if not brain.visualID then brain.visualID = ZombRand(1000000) end
        
        -- Reset state
        brain.state = "Stay"
        brain.isHostile = false
        print("[DTNPC] Rehydrated brain for: " .. brain.name)
    end

    -- Attach brain BEFORE applying visuals
    DTNPC.AttachBrain(zombie, brain)
    
    -- Apply visuals on server
    DTNPC.ApplyVisuals(zombie, brain)
    
    -- Set visual ID in modData
    modData.DTNPCVisualID = brain.visualID

    -- Set zombie properties
    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)
    
    -- Force model refresh
    zombie:resetModelNextFrame()

    -- Register with manager AFTER everything is set up
    if DTNPCManager then
        DTNPCManager.Register(zombie, brain)
    end

    -- Sync to all clients
    DTNPCSpawn.SyncToAllClients(zombie, brain)

    print("[DTNPC] Spawned/Summoned: " .. brain.name .. " | ID: " .. id)
    
    return zombie, brain
end

function DTNPCSpawn.FindZombieByID(id)
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
                        
                        -- Clear anchor when changing state
                        brain.anchorX = nil
                        brain.anchorY = nil
                        brain.anchorZ = nil
                        
                        if args.state == "GoTo" then
                           table.insert(brain.tasks, {x = math.floor(args.targetX), y = math.floor(args.targetY), z = math.floor(args.targetZ or 0)})
                           print("[DTNPC] GoTo task added: " .. args.targetX .. "," .. args.targetY)
                        end

                        DTNPC.AttachBrain(obj, brain)
                        if DTNPCManager then DTNPCManager.Register(obj, brain) end
                        
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
        
        sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
        print("[DTNPC] Sent full database (" .. DTNPCManager.GetTableSize(DTNPCManager.Data) .. " NPCs) to: " .. player:getUsername())
    end

    if command == "UpdateNPC" then
        if not args.id or not args.updates then return end
        
        print("[DTNPC] Received UpdateNPC for ID: " .. args.id)
        
        local id = args.id
        local serverBrain = DTNPCManager.Data[id]
        
        if serverBrain then
            local shouldBroadcast = args.updates.broadcastPosition or false
            
            for k, v in pairs(args.updates) do
                if k ~= "broadcastPosition" then
                    print("[DTNPC]   Updating " .. k .. " to " .. tostring(v))
                    serverBrain[k] = v
                end
            end
            
            DTNPCManager.Save()
            
            local cell = getCell()
            if cell then
                local zombieList = cell:getZombieList()
                for i = 0, zombieList:size() - 1 do
                    local z = zombieList:get(i)
                    if z and z:getPersistentOutfitID() == id then
                         DTNPC.AttachBrain(z, serverBrain)
                         DTNPCSpawn.SyncToAllClients(z, serverBrain)
                         
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
        if not args.id then return end
        
        print("[DTNPC] Received RemoveNPC for ID: " .. args.id)
        
        if DTNPCManager then
            DTNPCManager.Data[args.id] = nil
            DTNPCManager.Save()
            
            DTNPCSpawn.NotifyRemoval(args.id)
            
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

function DTNPCManager.GetTableSize(t)
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end