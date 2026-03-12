-- ==============================================================================
-- DTNPC_Spawn.lua
-- Server-side Logic: Spawning, Commands, Summoning, and Multiplayer Sync.
-- FIXED: Use UUID system instead of outfit IDs
-- ==============================================================================

require "DT/V2/NPC/Sys/DTNPC_Generator"

DynamicTrading.Log("DTV2", "NPC", "Init", "Loading optimization modules...")

require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

-- Guard: Create fallback tables with stub functions if modules didn't load
if not DTNPC_DistanceFrequency then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_DistanceFrequency is nil, creating fallback")
    DTNPC_DistanceFrequency = {
        NPCTimers = {},
        GetTierForDistance = function() return 4 end,
        GetUpdateFrequencyForDistance = function() return 6 end,
        InitializeNPC = function() end,
        ShouldUpdateNPC = function() return true end,
        UpdateNPC = function() end,
        RemoveNPC = function() end,
        Clear = function() end,
        GetUpdateStats = function() return {} end
    }
end

if not DTNPC_SpatialHash then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_SpatialHash is nil, creating fallback")
    DTNPC_SpatialHash = {
        Grid = {},
        NPCToCell = {},
        IsInitialized = false,
        RebuildFromRoster = function() end,
        InsertNPC = function() end,
        RemoveNPC = function() end,
        GetNPCsInRadius = function() return {} end,
        GetNearestNPCs = function() return {} end,
        CleanupEmptyCells = function() end,
        Clear = function() end,
        GetGridStats = function() return {} end,
        ClearDirtyFlags = function() end,
        GetDirtyCells = function() return {} end
    }
end

DynamicTrading.Log("DTV2", "NPC", "Init", "Module loading complete")

    DTNPCSpawn = DTNPCSpawn or {}
    
    -- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

    -- ==============================================================================
-- 1. MULTIPLAYER SYNC FUNCTIONS
-- ==============================================================================

DTNPCSpawn.BROADCAST_RANGES = DTNPCSpawn.BROADCAST_RANGES or {
    CLOSE = 200,
    MEDIUM = 350,
    FAR = 500,
}

local function getActivePlayers()
    if DTNPCManager and DTNPCManager.GetActivePlayers then
        return DTNPCManager.GetActivePlayers()
    end

    local players = {}
    local online = getOnlinePlayers()
    if online then
        for i = 0, online:size() - 1 do
            local p = online:get(i)
            if p then table.insert(players, p) end
        end
    end
    return players
end

local function sendToNearbyPlayers(command, data, x, y, z, range)
    local players = getActivePlayers()
    local sent = 0

    for _, player in ipairs(players) do
        local dx = player:getX() - x
        local dy = player:getY() - y
        local dz = player:getZ() - z
        local dist = math.sqrt(dx * dx + dy * dy)

        if math.abs(dz) <= 1 and dist <= range then
            sendServerCommand(player, "DTNPC", command, data)
            sent = sent + 1
        end
    end

    return sent, #players
end

function DTNPCSpawn.SyncToAllClients(zombie, npcData)
    if not zombie or not npcData then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    local uuid = npcData.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        outfitID = outfitID,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        npcData = npcData
    }
    
    if isServer() then
        local sent, total = sendToNearbyPlayers(
            "SyncNPC",
            syncData,
            syncData.x,
            syncData.y,
            syncData.z,
            DTNPCSpawn.BROADCAST_RANGES.MEDIUM
        )
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC: " .. (npcData.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y .. " [" .. sent .. "/" .. total .. " players]")
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC: " .. (npcData.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y)
    end
end

function DTNPCSpawn.SyncToPlayer(player, zombie, npcData)
    if not player or not zombie or not npcData then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    local uuid = npcData.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        outfitID = outfitID,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        npcData = npcData
    }
    
    if isServer() or isClient() then
        sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC to player: " .. (npcData.name or uuid))
end

function DTNPCSpawn.BroadcastPosition(zombie, npcData)
    if not zombie or not npcData then return end
    
    local uuid = npcData.uuid
    
    -- Check if this NPC should update based on distance-based frequency (Phase 2.2)
    local shouldUpdate, tier = DTNPC_DistanceFrequency.ShouldUpdateNPC(uuid)
    if not shouldUpdate then
        return  -- Skip update this tick, will send next tick based on frequency
    end
    
    local posData = {
        uuid = uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        health = zombie:getHealth(),
        state = npcData.state,
        tier = tier  -- Include tier info for client interpolation tuning
    }
    
    if isServer() then
        sendToNearbyPlayers(
            "UpdatePosition",
            posData,
            posData.x,
            posData.y,
            posData.z,
            DTNPCSpawn.BROADCAST_RANGES.CLOSE
        )
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "UpdatePosition", posData)
    end
end

function DTNPCSpawn.NotifyRemoval(uuid, outfitID, name)
    if not uuid then return end
    
    local data = { uuid = uuid, outfitID = outfitID, name = name }
    
    if isServer() then
        sendServerCommand("DTNPC", "RemoveNPC", data)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "RemoveNPC", data)
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Remove", "Notified removal: " .. (name or uuid))
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
    
    DynamicTrading.Log("DTV2", "NPC", "Spawn", "Spawning NPC at: " .. spawnX .. "," .. spawnY .. "," .. z)
    
    local outfitStr = "Naked"
    local femaleChance = 50 
    
    if existingBrain then
        femaleChance = existingBrain.isFemale and 100 or 0
    end
    
    local zombieList = addZombiesInOutfit(spawnX, spawnY, z, 1, outfitStr, femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then 
        DynamicTrading.Log("DTV2", "NPC", "Error", "Failed to spawn zombie at " .. spawnX .. "," .. spawnY)
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
        DynamicTrading.Log("DTV2", "NPC", "Spawn", "Generated new npcData for: " .. npcData.name)
    else
        if not npcData.tasks then npcData.tasks = {} end
        if not npcData.walkSpeed then npcData.walkSpeed = DTNPC.DefaultWalkSpeed end
        if not npcData.runSpeed then npcData.runSpeed = DTNPC.DefaultRunSpeed end
        if not npcData.visualID then npcData.visualID = ZombRand(1000000) end
        
        npcData.state = "Stay"
        npcData.isHostile = false
        DynamicTrading.Log("DTV2", "NPC", "Spawn", "Rehydrated npcData for: " .. npcData.name)
    end
    
    -- Ensure UUID exists
    if not npcData.uuid then
        npcData.uuid = DTNPCManager.GenerateSoulID(npcData.name)
    end
    
    modData.DTNPC_UUID = npcData.uuid

    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)
    
    modData.DTNPCVisualID = npcData.visualID

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, npcData)
    end

    DTNPCSpawn.SyncToAllClients(zombie, npcData)

    DynamicTrading.Log("DTV2", "NPC", "Spawn", "Spawned/Summoned: " .. npcData.name .. " | UUID: " .. npcData.uuid .. " | OutfitID: " .. outfitID)
    
    return zombie, npcData
end

-- ==============================================================================
-- 3. RESPAWN FUNCTION
-- ==============================================================================

function DTNPCSpawn.RespawnNPC(npcData, uuid)
    if not npcData or not npcData.lastX or not npcData.lastY then return end
    
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
                    local tSq = cell:getGridSquare(x + _x, y + _y, z)
                    if tSq and tSq:isFree(false) and not tSq:isSolid() and not tSq:isSolidTrans() then
                        x = x + _x
                        y = y + _y
                        foundSq = tSq
                        break
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
                    local tSq = cell:getGridSquare(x + _x, y + _y, z)
                    if tSq and not tSq:isSolid() and not tSq:isSolidTrans() then
                        x = x + _x
                        y = y + _y
                        foundSq = tSq
                        break
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
    local zombieList = addZombiesInOutfit(x, y, z, 1, "Naked", femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then 
        DynamicTrading.Log("DTV2", "NPC", "Error", "| ERROR: addZombiesInOutfit returned 0 even on found square!")
        return nil
    end

    local zombie = zombieList:get(0)
    local newOutfitID = zombie:getPersistentOutfitID()
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "Respawned with new OutfitID: " .. newOutfitID)
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    
    -- Keep the same UUID
    npcData.uuid = uuid
    
    -- CRITICAL: Generate new visual ID to force clients to reapply visuals
    npcData.visualID = ZombRand(1000000)
    
    -- CRITICAL: Determine state based on status
    local status = npcData.status or "Resting"
    if status == "Trading" then
        npcData.state = "Trading"
    elseif status == "Working" then
        npcData.state = "Guard"
    else
        npcData.state = "Stay"
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "| Mapped Status [" .. status .. "] to Behavior State [" .. npcData.state .. "]")
    
    npcData.master = nil
    npcData.masterID = nil
    
    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)
    
    modData.DTNPCVisualID = npcData.visualID

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(2)
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, npcData)
    end

    -- Force sync to all clients with new visual ID
    DTNPCSpawn.SyncToAllClients(zombie, npcData)

    DynamicTrading.Log("DTV2", "NPC", "Respawn", "Respawned: " .. npcData.name .. " | UUID: " .. uuid .. " | New OutfitID: " .. newOutfitID .. " | New VisualID: " .. npcData.visualID)
    
    return zombie, npcData
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
    
    DynamicTrading.Log("DTV2", "NPC", "Summon", "Summoning NPCs for player: " .. username)
    
    for uuid, npcData in pairs(DTNPCManager.Data) do
        if npcData.master == username then
            local foundObj = DTNPCSpawn.FindZombieByUUID(uuid)
            
            if foundObj then
                table.insert(toTeleport, {zombie = foundObj, npcData = npcData})
                DynamicTrading.Log("DTV2", "NPC", "Summon", "Found existing NPC to teleport: " .. (npcData.name or uuid))
            else
                table.insert(toRecreate, {uuid = uuid, npcData = npcData})
                DynamicTrading.Log("DTV2", "NPC", "Summon", "NPC not found in world, will recreate: " .. (npcData.name or uuid))
            end
        end
    end
    
    for _, data in ipairs(toTeleport) do
        local npc = data.zombie
        local npcData = data.npcData
        
        npc:setX(player:getX() + 1)
        npc:setY(player:getY() + 1)
        npc:setZ(player:getZ())
        npc:setLastX(player:getX())
        npc:setLastY(player:getY())
        
        npcData.lastX = math.floor(npc:getX())
        npcData.lastY = math.floor(npc:getY())
        npcData.lastZ = math.floor(npc:getZ())
        DTNPCSpawn.SyncToAllClients(npc, npcData)
    end
    
    for _, data in ipairs(toRecreate) do
        DTNPCSpawn.RespawnNPC(data.npcData, data.uuid)
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Summon", "Summon complete. Teleported: " .. #toTeleport .. ", Recreated: " .. #toRecreate)
end
