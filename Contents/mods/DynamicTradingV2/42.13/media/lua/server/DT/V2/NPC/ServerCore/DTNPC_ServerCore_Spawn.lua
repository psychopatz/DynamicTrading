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
    
    DynamicTrading.Log("DTV2", "NPC", "Logic", "Spawning NPC at: " .. spawnX .. "," .. spawnY .. "," .. z)
    
    local outfitStr = "Naked"
    local femaleChance = 50 
    
    if existingBrain then
        femaleChance = existingBrain.isFemale and 100 or 0
    end
    
    local zombieList = addZombiesInOutfit(spawnX, spawnY, z, 1, outfitStr, femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then 
        DynamicTrading.Log("DTV2", "NPC", "Logic", "ERROR: Failed to spawn zombie at " .. spawnX .. "," .. spawnY)
        return 
    end

    local zombie = zombieList:get(0)
    local outfitID = zombie:getPersistentOutfitID()
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    
    local npcData = existingBrain
    
    if not npcData then
        local genOptions = {
            masterName = player:getUsername(),
            masterID = player:getOnlineID(),
            forceMVP = options.forceMVP,
            walkSpeed = options.walkSpeed,
            runSpeed = options.runSpeed
        }
        
        npcData = DTNPCGenerator.Generate(genOptions)
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Generated new npcData for: " .. npcData.name)
    else
        if not npcData.tasks then npcData.tasks = {} end
        if not npcData.walkSpeed then npcData.walkSpeed = DTNPC.DefaultWalkSpeed end
        if not npcData.runSpeed then npcData.runSpeed = DTNPC.DefaultRunSpeed end
        if not npcData.visualID then npcData.visualID = ZombRand(1000000) end
        
        npcData.state = "Stay"
        npcData.isHostile = false
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Rehydrated npcData for: " .. npcData.name)
    end
    
    -- Ensure UUID exists
    if not npcData.uuid then
        npcData.uuid = DTNPCManager.GenerateSoulID(npcData.name)
    end
    
    modData.DTNPC_UUID = npcData.uuid

    DTNPC.AttachBrain(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)
    
    modData.DTNPCVisualID = npcData.visualID

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, npcData)
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)

    DynamicTrading.Log("DTV2", "NPC", "Logic", "Spawned/Summoned: " .. npcData.name .. " | UUID: " .. npcData.uuid .. " | OutfitID: " .. outfitID)
    
    return zombie, npcData
end
