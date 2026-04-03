-- ==============================================================================
-- DTNPC_ServerCore_Respawn.lua
-- NPC respawning logic with advanced location search.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- RESPAWN FUNCTION
-- ==============================================================================

function DTNPCServerCore.RespawnNPC(npcData, uuid)
    if not npcData or not npcData.lastX or not npcData.lastY then return end

    uuid = uuid or npcData.uuid
    local previousOutfitID = npcData.currentOutfitID
    if uuid then
        local existingZombie = DTNPCServerCore.FindZombieByUUID(uuid)
        if existingZombie then
            if DTNPCServerCore.PruneDuplicateZombies then
                existingZombie = DTNPCServerCore.PruneDuplicateZombies(uuid, npcData, existingZombie, "respawn-guard")
            end

            if DTNPCManager and DTNPCManager.ReclaimZombie then
                return DTNPCManager.ReclaimZombie(existingZombie, npcData, "respawn-guard"), npcData
            end

            return existingZombie, npcData
        end
    end
    
    local x = npcData.lastX
    local y = npcData.lastY
    local z = npcData.lastZ or 0
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "| Targeted Square: " .. x .. "," .. y .. "," .. z)
    
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    
    -- EXTREME SPAWN SEARCH (15 Tile Radius, 2 Passes)
    local foundSq = nil
    
    -- Pass 1: Perfect Square (Not Solid, Free, Not Nil)
    if sq and sq:isFree(false) and not sq:isSolid() and not sq:isSolidTrans() then
        foundSq = sq
    else
        if not sq then DynamicTrading.Log("DTV2", "NPC", "Respawn", "| Target chunk not fully loaded (sq is nil). Searching wider...") end
        for radius = 1, 15 do
            for _x = -radius, radius do
                for _y = -radius, radius do
                    if math.abs(_x) == radius or math.abs(_y) == radius then
                        local tSq = cell:getGridSquare(x + _x, y + _y, z)
                        if tSq and tSq:isFree(false) and not tSq:isSolid() and not tSq:isSolidTrans() then
                            x = x + _x
                            y = y + _y
                            foundSq = tSq
                            break
                        end
                    end
                end
                if foundSq then break end
            end
            if foundSq then break end
        end
    end
    
    -- Pass 2: Tolerable Square (Not Solid, but maybe has objects/blocked)
    if not foundSq then
        DynamicTrading.Log("DTV2", "NPC", "Respawn", "| No perfect square found. Searching for any non-solid square...")
        for radius = 1, 15 do
            for _x = -radius, radius do
                for _y = -radius, radius do
                    if math.abs(_x) == radius or math.abs(_y) == radius then
                        local tSq = cell:getGridSquare(x + _x, y + _y, z)
                        if tSq and not tSq:isSolid() and not tSq:isSolidTrans() then
                            x = x + _x
                            y = y + _y
                            foundSq = tSq
                            break
                        end
                    end
                end
                if foundSq then break end
            end
            if foundSq then break end
        end
    end
    
    if foundSq then
        DynamicTrading.Log("DTV2", "NPC", "Respawn", "| SUCCESS: Found suitable square at " .. x .. "," .. y)
    else
        DynamicTrading.Log("DTV2", "NPC", "Error", "| ERROR: Extreme search failed. Chunk likely UNLOADED or area is blocked. Skipping spawn attempt.")
        return nil
    end
    
    local femaleChance = npcData.isFemale and 100 or 0
    local spawnAsCrawler = npcData.incapState == "Active"
    local fallOnFront = spawnAsCrawler
    local knockedDown = spawnAsCrawler
    local zombieList = addZombiesInOutfit(
        x,
        y,
        z,
        1,
        "Naked",
        femaleChance,
        spawnAsCrawler,
        fallOnFront,
        false,
        knockedDown,
        false,
        false,
        1
    )
    
    if not zombieList or zombieList:size() == 0 then 
        DynamicTrading.Log("DTV2", "NPC", "Error", "| ERROR: addZombiesInOutfit returned 0 even on found square!")
        return nil
    end

    local zombie = zombieList:get(0)
    local newOutfitID = zombie:getPersistentOutfitID()
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "Respawned with new OutfitID: " .. newOutfitID)

    if previousOutfitID and previousOutfitID ~= newOutfitID and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, previousOutfitID)
    end
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    
    -- Keep the same UUID
    npcData.uuid = uuid
    
    -- Keep the saved appearance stable across legitimate body recovery.
    if not npcData.visualID or npcData.visualID == 0 then
        npcData.visualID = ZombRand(1000000)
    end
    
    -- CRITICAL: Determine state based on status
    local status = npcData.status or "Resting"
    if npcData.incapState == "Active" then
        npcData.state = "Incapacitated"
    elseif status == "Trading" then
        npcData.state = "Trading"
    elseif status == "Working" then
        npcData.state = "Guard"
    else
        npcData.state = "Idle"
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "| Mapped Status [" .. status .. "] to Behavior State [" .. npcData.state .. "]")
    
    npcData.master = nil
    npcData.masterID = nil
    
    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)

    if spawnAsCrawler then
        zombie:setVariable("bBecomeCrawler", true)
        zombie:setVariable("bCrawling", true)
    end
    
    modData.DTNPCVisualID = npcData.visualID

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, npcData)
    end

    -- Force sync to all clients with new visual ID
    DTNPCServerCore.SyncToAllClients(zombie, npcData)

    DynamicTrading.Log("DTV2", "NPC", "Respawn", "Respawned: " .. npcData.name .. " | UUID: " .. uuid .. " | New OutfitID: " .. newOutfitID .. " | VisualID: " .. npcData.visualID)
    
    return zombie, npcData
end
