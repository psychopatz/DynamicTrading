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
    
    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Spawn",
        "SpawnNPC request player=" .. tostring(player:getUsername())
            .. " existingBrain=" .. tostring(existingBrain ~= nil)
            .. " spawnAt=" .. tostring(spawnX) .. "," .. tostring(spawnY) .. "," .. tostring(z)
            .. " foundSafe=" .. tostring(foundSafe)
    )
    
    local outfitStr = "Naked"
    local femaleChance = 50 
    
    if existingBrain then
        femaleChance = existingBrain.isFemale and 100 or 0
    end
    
    local startIncapacitated = existingBrain and existingBrain.incapState == "Active" or false
    local spawnAsCrawler = false
    local fallOnFront = false
    local knockedDown = false
    local invulnerable = true
    local zombieList = addZombiesInOutfit(
        spawnX,
        spawnY,
        z,
        1,
        outfitStr,
        femaleChance,
        spawnAsCrawler,
        fallOnFront,
        false,
        knockedDown,
        invulnerable,
        false,
        1
    )
    
    if not zombieList or zombieList:size() == 0 then 
        DynamicTrading.Log("DTV2", "NPC", "Logic", "ERROR: Failed to spawn zombie at " .. spawnX .. "," .. spawnY)
        return 
    end

    local zombie = zombieList:get(0)
    local bodyInstanceID = zombie:getPersistentOutfitID()
    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Spawn",
        "SpawnNPC body created bodyInstanceID=" .. tostring(bodyInstanceID)
            .. " onlineID=" .. tostring(zombie:getOnlineID())
    )
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    
    local npcData = existingBrain
    
    if not npcData then
        local genOptions = {
            masterName = player:getUsername(),
            masterID = player:getOnlineID(),
            forceMVP = options.forceMVP
        }
        
        npcData = DTNPCGenerator.Generate(genOptions)
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Generated new npcData for: " .. npcData.name)
    else
        if not npcData.tasks then npcData.tasks = {} end
        npcData.walkSpeed = nil
        npcData.runSpeed = nil
        if not npcData.visualID then npcData.visualID = ZombRand(1000000) end
        
        npcData.state = startIncapacitated and "Incapacitated" or "Idle"
        npcData.isHostile = false
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Rehydrated npcData for: " .. npcData.name)
    end
    
    -- Ensure UUID exists
    if not npcData.uuid then
        npcData.uuid = DTNPCManager.GenerateSoulID(npcData.name)
    end

    if DTNPCManager and DTNPCManager.BumpPresenceRevision then
        DTNPCManager.BumpPresenceRevision(npcData)
    end
    
    modData.DTNPC_UUID = npcData.uuid

    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)

    if startIncapacitated then
        zombie:setVariable("bBecomeCrawler", false)
        zombie:setVariable("bCrawling", false)
        zombie:setVariable("FallOnFront", false)
        zombie:setVariable("bMoving", false)
        zombie:setVariable("isMoving", false)
        zombie:setVariable("DTNPCMoveAnim", "")
        zombie:setVariable("DTNPCAnimSpeed", 0.0)
        zombie:setVariable("MovementSpeed", 0.0)
        zombie:setVariable("WalkSpeed", 0.0)
        zombie:setVariable("RunSpeed", 0.0)
        zombie:setVariable("Speed", 0.0)
        zombie:setVariable("WalkType", "")
        zombie:setVariable("DTWalkType", "Crawl")
    end
    
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPCPresenceRevision = npcData.presenceRevision

    zombie:setUseless(true) 
    zombie:DoZombieStats()
    if DTNPCHealth and DTNPCHealth.InitializeForSpawn then
        DTNPCHealth.InitializeForSpawn(zombie, npcData, {
            resetCurrent = false,
            deferNetworkSafeBuffer = isServer(),
            spawnReason = "server_spawn",
        })
    else
        zombie:setHealth(2)
    end
    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Spawn",
        "SpawnNPC initialized health name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " engineHealth=" .. tostring(zombie:getHealth())
            .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
            .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
            .. " deferredBuffer=" .. tostring(npcData.combatHealth and npcData.combatHealth.deferredSpawnBufferTarget or nil)
    )
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, npcData)
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Spawn",
        "SpawnNPC complete name=" .. tostring(npcData.name)
            .. " uuid=" .. tostring(npcData.uuid)
            .. " bodyInstanceID=" .. tostring(bodyInstanceID)
            .. " pos=" .. tostring(math.floor(zombie:getX())) .. "," .. tostring(math.floor(zombie:getY())) .. "," .. tostring(math.floor(zombie:getZ()))
    )
    
    return zombie, npcData
end
