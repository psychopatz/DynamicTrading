-- ==============================================================================
-- DTNPC_Spawn.lua
-- Server-side Logic: Spawning, Commands, Summoning, and Multiplayer Sync.
-- FIXED: Use UUID system instead of outfit IDs
-- ==============================================================================

require "DT/V2/NPC/Sys/DTNPC_Generator"

print("[DTNPC_Spawn] Loading optimization modules...")

require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
print("[DTNPC_Spawn] DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"
print("[DTNPC_Spawn] DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

-- Guard: Create fallback tables with stub functions if modules didn't load
if not DTNPC_DistanceFrequency then
    print("[DTNPC_Spawn] WARNING: DTNPC_DistanceFrequency is nil, creating fallback")
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
    print("[DTNPC_Spawn] WARNING: DTNPC_SpatialHash is nil, creating fallback")
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

print("[DTNPC_Spawn] Module loading complete")

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
        print("[DTNPC] Synced NPC: " .. (npcData.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y .. " [" .. sent .. "/" .. total .. " players]")
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
        print("[DTNPC] Synced NPC: " .. (npcData.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y)
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
    
    print("[DTNPC] Synced NPC to player: " .. (npcData.name or uuid))
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
    
    print("[DTNPC] Notified removal: " .. (name or uuid))
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
        print("[DTNPC] Generated new npcData for: " .. npcData.name)
    else
        if not npcData.tasks then npcData.tasks = {} end
        if not npcData.walkSpeed then npcData.walkSpeed = DTNPC.DefaultWalkSpeed end
        if not npcData.runSpeed then npcData.runSpeed = DTNPC.DefaultRunSpeed end
        if not npcData.visualID then npcData.visualID = ZombRand(1000000) end
        
        npcData.state = "Stay"
        npcData.isHostile = false
        print("[DTNPC] Rehydrated npcData for: " .. npcData.name)
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

    print("[DTNPC] Spawned/Summoned: " .. npcData.name .. " | UUID: " .. npcData.uuid .. " | OutfitID: " .. outfitID)
    
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
    
    print("[DTNPC] | Targeted Square: " .. x .. "," .. y .. "," .. z)
    
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    
    -- EXTREME SPAWN SEARCH (15 Tile Radius, 2 Passes)
    local foundSq = nil
    
    -- Pass 1: Perfect Square (Not Solid, Free, Not Nil)
    if sq and sq:isFree(false) and not sq:isSolid() and not sq:isSolidTrans() then
        foundSq = sq
    else
        if not sq then print("[DTNPC] | Target chunk not fully loaded (sq is nil). Searching wider...") end
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
        print("[DTNPC] | No perfect square found. Searching for any non-solid square...")
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
        print("[DTNPC] | SUCCESS: Found suitable square at " .. x .. "," .. y)
    else
        print("[DTNPC] | ERROR: Extreme search failed. Chunk likely UNLOADED or area is blocked. Skipping spawn attempt.")
        return nil
    end
    
    local femaleChance = npcData.isFemale and 100 or 0
    local zombieList = addZombiesInOutfit(x, y, z, 1, "Naked", femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then 
        print("[DTNPC] | ERROR: addZombiesInOutfit returned 0 even on found square!")
        return nil
    end

    local zombie = zombieList:get(0)
    local newOutfitID = zombie:getPersistentOutfitID()
    
    print("[DTNPC] Respawned with new OutfitID: " .. newOutfitID)
    
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
    
    print("[DTNPC] | Mapped Status [" .. status .. "] to Behavior State [" .. npcData.state .. "]")
    
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

    print("[DTNPC] Respawned: " .. npcData.name .. " | UUID: " .. uuid .. " | New OutfitID: " .. newOutfitID .. " | New VisualID: " .. npcData.visualID)
    
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
    
    print("[DTNPC] Summoning NPCs for player: " .. username)
    
    for uuid, npcData in pairs(DTNPCManager.Data) do
        if npcData.master == username then
            local foundObj = DTNPCSpawn.FindZombieByUUID(uuid)
            
            if foundObj then
                table.insert(toTeleport, {zombie = foundObj, npcData = npcData})
                print("[DTNPC] Found existing NPC to teleport: " .. (npcData.name or uuid))
            else
                table.insert(toRecreate, {uuid = uuid, npcData = npcData})
                print("[DTNPC] NPC not found in world, will recreate: " .. (npcData.name or uuid))
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
    
    print("[DTNPC] Summon complete. Teleported: " .. #toTeleport .. ", Recreated: " .. #toRecreate)
end

-- ==============================================================================
-- 5. CLIENT COMMAND HANDLER
-- ==============================================================================

local function onClientCommand(module, command, player, args)
    if module ~= "DTNPC" then return end

    local function countTable(t)
        local count = 0
        for _ in pairs(t or {}) do count = count + 1 end
        return count
    end

    local function resolveFactionName(factionID)
        if not factionID then return "Independent" end
        local factions = ModData.get("DynamicTrading_Factions")
        if factions and factions.Factions and factions.Factions[factionID] then
            local f = factions.Factions[factionID]
            return f.name or f.displayName or factionID
        end
        return factionID
    end

    local function buildMetadataEntry(uuid, soul)
        return {
            uuid = uuid,
            name = soul.name,
            archetypeID = soul.archetypeID or "General",
            factionID = soul.factionID or "Independent",
            factionName = resolveFactionName(soul.factionID),
            isFemale = soul.isFemale,
            identitySeed = soul.identitySeed or 1,
            status = soul.status or "Unknown",
            lastX = soul.lastX or (soul.homeCoords and soul.homeCoords.x),
            lastY = soul.lastY or (soul.homeCoords and soul.homeCoords.y),
            lastZ = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0,
        }
    end

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
                    local npcData = DTNPC.GetData(obj)
                    if npcData then
                        npcData.state = args.state
                        npcData.tasks = {} 
                        
                        npcData.anchorX = nil
                        npcData.anchorY = nil
                        npcData.anchorZ = nil
                        
                        npcData.requestedReturnStatus = args.returnStatus
                        
                        if args.state == "Follow" or args.state == "Flee" then
                            npcData.master = player:getUsername()
                            npcData.masterID = isClient() and player:getOnlineID() or 0
                            print("[DTNPC] Master assigned for " .. args.state .. " order: " .. npcData.master)
                        elseif args.state == "GoTo" then
                           table.insert(npcData.tasks, {x = args.targetX, y = args.targetY, z = args.targetZ or 0})
                           print("[DTNPC] GoTo task added: " .. args.targetX .. "," .. args.targetY .. "," .. (args.targetZ or 0))
                        end

                        DTNPC.AttachData(obj, npcData)
                        if DTNPCManager then DTNPCManager.Register(obj, npcData) end
                        
                        DTNPCSpawn.SyncToAllClients(obj, npcData)
                        DTNPCSpawn.BroadcastPosition(obj, npcData)
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
                    local npcData = DTNPCManager.Data[uuid]
                    if npcData then
                        DTNPCSpawn.SyncToPlayer(player, zombie, npcData)
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

    if command == "RequestNearbySync" then
        if not player then return end

        local px = args and args.x or player:getX()
        local py = args and args.y or player:getY()
        local pz = args and args.z or player:getZ()
        local nearRadius = args and args.nearRadius or 200
        local metadataRadius = args and args.metadataRadius or 1000

        local nearby = {}
        local metadata = {}

        local roster = ModData.get("DynamicTrading_Roster")
        local souls = roster and roster.Souls or nil

        if souls then
            for uuid, soul in pairs(souls) do
                local sx = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
                local sy = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
                local sz = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0

                if sx and sy and math.abs((pz or 0) - sz) <= 1 then
                    local dx = px - sx
                    local dy = py - sy
                    local dist = math.sqrt(dx * dx + dy * dy)

                    if dist <= nearRadius then
                        local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
                        local zombie = DTNPCSpawn.FindZombieByUUID(uuid)
                        if npcData and zombie then
                            nearby[uuid] = {
                                uuid = uuid,
                                outfitID = zombie:getPersistentOutfitID(),
                                x = zombie:getX(),
                                y = zombie:getY(),
                                z = zombie:getZ(),
                                npcData = npcData,
                            }
                        else
                            metadata[uuid] = buildMetadataEntry(uuid, soul)
                        end
                    elseif dist <= metadataRadius then
                        metadata[uuid] = buildMetadataEntry(uuid, soul)
                    end
                end
            end
        end

        sendServerCommand(player, "DTNPC", "SyncNearbyNPCs", {
            nearby = nearby,
            metadata = metadata,
            nearRadius = nearRadius,
            metadataRadius = metadataRadius,
        })

        print("[DTNPC] Sent tiered sync to " .. player:getUsername() .. ": nearby=" .. countTable(nearby) .. ", metadata=" .. countTable(metadata))
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
                DTNPC.AttachData(zombie, serverBrain)
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
        if not args.uuid then 
            print("[DTNPC] ERROR: RemoveNPC received with no UUID!")
            return 
        end
        
        print("[DTNPC] Received RemoveNPC request for UUID: " .. args.uuid .. " (Status: " .. (args.status or "nil") .. ")")
        
        if DTNPCManager then
            local name = "Unknown"
            if DTNPCManager.Data[args.uuid] then
                name = DTNPCManager.Data[args.uuid].name or "Unknown"
                DTNPCManager.RemoveData(args.uuid, args.status, args.returnTime, args.returnStatus)
                print("[DTNPC] SUCCESS: Removed NPC data from database: " .. name .. " (" .. args.uuid .. ")")
            else
                print("[DTNPC] WARNING: UUID " .. args.uuid .. " not found in database for removal.")
                -- Even if not in Manager, we might want to update Roster status if provided
                if DynamicTrading_Roster and args.status then
                    DynamicTrading_Roster.UpdateSoulStatus(args.uuid, args.status, args.returnTime, args.returnStatus)
                end
            end
            
            local zombie = DTNPCSpawn.FindZombieByUUID(args.uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                print("[DTNPC] SUCCESS: Removed NPC from world: " .. args.uuid)
            else
                print("[DTNPC] INFO: NPC " .. args.uuid .. " not found in local world (may already be unloaded).")
            end
        else
            print("[DTNPC] ERROR: DTNPCManager not available for removal!")
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)
