-- ==============================================================================
-- DTNPC_Spawn.lua
-- Server-side Logic: Spawning, Commands, Summoning, and Multiplayer Sync.
-- FIXED: Use UUID system instead of outfit IDs
-- ==============================================================================

require "NPC/Sys/DTNPC_Generator"

DTNPCSpawn = DTNPCSpawn or {}

-- ==============================================================================
-- 1. MULTIPLAYER SYNC FUNCTIONS
-- ==============================================================================

function DTNPCSpawn.SyncToAllClients(zombie, brain)
    if not zombie or not brain then return end
    if not isServer() then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    local uuid = brain.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = brain.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        outfitID = outfitID,
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
    
    print("[DTNPC] Synced NPC to all clients: " .. (brain.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y)
end

function DTNPCSpawn.SyncToPlayer(player, zombie, brain)
    if not player or not zombie or not brain then return end
    if not isServer() then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    local uuid = brain.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = brain.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        outfitID = outfitID,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
    print("[DTNPC] Synced NPC to player " .. player:getUsername() .. ": " .. (brain.name or uuid))
end

function DTNPCSpawn.BroadcastPosition(zombie, brain)
    if not zombie or not brain then return end
    if not isServer() then return end
    
    local uuid = brain.uuid
    local posData = {
        uuid = uuid,
        outfitID = zombie:getPersistentOutfitID(),
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

function DTNPCSpawn.NotifyRemoval(uuid, outfitID)
    if not uuid then return end
    if not isServer() then return end
    
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers then
        for i = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(i)
            if player then
                sendServerCommand(player, "DTNPC", "RemoveNPC", { uuid = uuid, outfitID = outfitID })
            end
        end
    end
    
    print("[DTNPC] Notified all clients of NPC removal: " .. uuid)
end

-- ==============================================================================
-- 2. SPAWN FUNCTION
-- ==============================================================================

function DTNPCSpawn.SpawnNPC(player, existingBrain, options)
    if not player then return end
    
    options = options or {}
    
    local x, y, z = player:getX(), player:getY(), player:getZ()
    
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
    local outfitID = zombie:getPersistentOutfitID()
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    
    local brain = existingBrain
    
    if not brain then
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
        if not brain.tasks then brain.tasks = {} end
        if not brain.walkSpeed then brain.walkSpeed = DTNPC.DefaultWalkSpeed end
        if not brain.runSpeed then brain.runSpeed = DTNPC.DefaultRunSpeed end
        if not brain.visualID then brain.visualID = ZombRand(1000000) end
        
        brain.state = "Stay"
        brain.isHostile = false
        print("[DTNPC] Rehydrated brain for: " .. brain.name)
    end
    
    -- Ensure UUID exists
    if not brain.uuid then
        brain.uuid = DTNPCManager.GenerateUUID()
    end
    
    modData.DTNPC_UUID = brain.uuid

    DTNPC.AttachBrain(zombie, brain)
    DTNPC.ApplyVisuals(zombie, brain)
    
    modData.DTNPCVisualID = brain.visualID

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, brain)
    end

    DTNPCSpawn.SyncToAllClients(zombie, brain)

    print("[DTNPC] Spawned/Summoned: " .. brain.name .. " | UUID: " .. brain.uuid .. " | OutfitID: " .. outfitID)
    
    return zombie, brain
end

-- ==============================================================================
-- 3. RESPAWN FUNCTION
-- ==============================================================================

function DTNPCSpawn.RespawnNPC(brain, uuid)
    if not brain or not brain.lastX or not brain.lastY then return end
    
    local x = brain.lastX
    local y = brain.lastY
    local z = brain.lastZ or 0
    
    print("[DTNPC] Respawning NPC: " .. (brain.name or uuid) .. " at " .. x .. "," .. y .. "," .. z)
    
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    
    if not sq or not sq:isFree(false) then
        for _x = -2, 2 do
            for _y = -2, 2 do
                sq = cell:getGridSquare(x + _x, y + _y, z)
                if sq and sq:isFree(false) and not sq:isSolid() and not sq:isSolidTrans() then
                    x = x + _x
                    y = y + _y
                    break
                end
            end
        end
    end
    
    local femaleChance = brain.isFemale and 100 or 0
    local zombieList = addZombiesInOutfit(x, y, z, 1, "Naked", femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then 
        print("[DTNPC] ERROR: Failed to respawn NPC")
        return 
    end

    local zombie = zombieList:get(0)
    local newOutfitID = zombie:getPersistentOutfitID()
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    
    -- Keep the same UUID
    brain.uuid = uuid
    
    DTNPC.AttachBrain(zombie, brain)
    DTNPC.ApplyVisuals(zombie, brain)
    
    modData.DTNPCVisualID = brain.visualID

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, brain)
    end

    DTNPCSpawn.SyncToAllClients(zombie, brain)

    print("[DTNPC] Respawned: " .. brain.name .. " | UUID: " .. uuid .. " | New OutfitID: " .. newOutfitID)
    
    return zombie, brain
end

function DTNPCSpawn.FindZombieByUUID(uuid)
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

function DTNPCSpawn.FindZombieByOutfitID(outfitID)
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

-- ==============================================================================
-- 4. SUMMON FUNCTION
-- ==============================================================================

function DTNPCSpawn.SummonAll(player)
    if not DTNPCManager then return end
    local username = player:getUsername()
    local cell = getCell()
    local toTeleport = {}
    local toRecreate = {}
    
    print("[DTNPC] Summoning NPCs for player: " .. username)
    
    for uuid, brain in pairs(DTNPCManager.Data) do
        if brain.master == username then
            local foundObj = DTNPCSpawn.FindZombieByUUID(uuid)
            
            if foundObj then
                table.insert(toTeleport, {zombie = foundObj, brain = brain})
                print("[DTNPC] Found existing NPC to teleport: " .. (brain.name or uuid))
            else
                table.insert(toRecreate, {uuid = uuid, brain = brain})
                print("[DTNPC] NPC not found in world, will recreate: " .. (brain.name or uuid))
            end
        end
    end
    
    for _, data in ipairs(toTeleport) do
        local npc = data.zombie
        local brain = data.brain
        
        npc:setX(player:getX() + 1)
        npc:setY(player:getY() + 1)
        npc:setZ(player:getZ())
        npc:setLastX(player:getX())
        npc:setLastY(player:getY())
        
        brain.lastX = math.floor(npc:getX())
        brain.lastY = math.floor(npc:getY())
        brain.lastZ = math.floor(npc:getZ())
        DTNPCSpawn.SyncToAllClients(npc, brain)
    end
    
    for _, data in ipairs(toRecreate) do
        DTNPCSpawn.RespawnNPC(data.brain, data.uuid)
    end
    
    print("[DTNPC] Summon complete. Teleported: " .. #toTeleport .. ", Recreated: " .. #toRecreate)
end

-- ==============================================================================
-- 5. CLIENT COMMAND HANDLER
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
                        
                        brain.anchorX = nil
                        brain.anchorY = nil
                        brain.anchorZ = nil
                        
                        if args.state == "GoTo" then
                           table.insert(brain.tasks, {x = args.targetX, y = args.targetY, z = args.targetZ or 0})
                           print("[DTNPC] GoTo task added: " .. args.targetX .. "," .. args.targetY .. "," .. (args.targetZ or 0))
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
                local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
                if uuid then
                    local brain = DTNPCManager.Data[uuid]
                    if brain then
                        DTNPCSpawn.SyncToPlayer(player, zombie, brain)
                        syncCount = syncCount + 1
                    end
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
        if not args.uuid or not args.updates then return end
        
        print("[DTNPC] Received UpdateNPC for UUID: " .. args.uuid)
        
        local uuid = args.uuid
        local serverBrain = DTNPCManager.Data[uuid]
        
        if serverBrain then
            local shouldBroadcast = args.updates.broadcastPosition or false
            
            for k, v in pairs(args.updates) do
                if k ~= "broadcastPosition" then
                    print("[DTNPC]   Updating " .. k .. " to " .. tostring(v))
                    serverBrain[k] = v
                end
            end
            
            DTNPCManager.Save()
            
            local zombie = DTNPCSpawn.FindZombieByUUID(uuid)
            if zombie then
                DTNPC.AttachBrain(zombie, serverBrain)
                DTNPCSpawn.SyncToAllClients(zombie, serverBrain)
                
                if shouldBroadcast then
                    print("[DTNPC] Broadcasting position due to state change")
                    DTNPCSpawn.BroadcastPosition(zombie, serverBrain)
                end
                
                print("[DTNPC] Updated and synced NPC to all clients")
            end
        else
            print("[DTNPC] WARNING: UpdateNPC for unknown UUID: " .. uuid)
        end
    end

    if command == "RemoveNPC" then
        if not args.uuid then return end
        
        print("[DTNPC] Received RemoveNPC for UUID: " .. args.uuid)
        
        if DTNPCManager then
            DTNPCManager.RemoveData(args.uuid)
            
            local zombie = DTNPCSpawn.FindZombieByUUID(args.uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                print("[DTNPC] Removed NPC from world")
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