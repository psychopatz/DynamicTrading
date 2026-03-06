-- ==============================================================================
-- DTNPC_ServerCore_Spawn.lua
-- Core NPC spawning functionality.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- SPAWN FUNCTION
-- ==============================================================================

function DTNPCServerCore.SpawnNPC(player, existingBrain, options)
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

    DTNPCServerCore.SyncToAllClients(zombie, brain)

    print("[DTNPC] Spawned/Summoned: " .. brain.name .. " | UUID: " .. brain.uuid .. " | OutfitID: " .. outfitID)
    
    return zombie, brain
end
