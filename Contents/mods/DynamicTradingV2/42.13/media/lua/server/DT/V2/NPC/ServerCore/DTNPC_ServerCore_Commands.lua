-- ==============================================================================
-- DTNPC_ServerCore_Commands.lua
-- Client command handler for all NPC network operations.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- CLIENT COMMAND HANDLER
-- ==============================================================================

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
        returnTime = soul.returnTime,
        lastX = soul.lastX or (soul.homeCoords and soul.homeCoords.x),
        lastY = soul.lastY or (soul.homeCoords and soul.homeCoords.y),
        lastZ = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0,
    }
end

local function onClientCommand(module, command, player, args)
    if module ~= "DTNPC" then return end

    if command == "Spawn" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received Spawn command from: " .. player:getUsername())
        DTNPCServerCore.SpawnNPC(player, nil, args)
    end

    if command == "Summon" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received Summon command from: " .. player:getUsername())
        DTNPCServerCore.SummonAll(player)
    end

    if command == "Order" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received Order command from: " .. player:getUsername() .. " | State: " .. (args.state or "Unknown"))
        local square = getCell():getGridSquare(args.x, args.y, args.z)
        if square then
            local movingObjects = square:getMovingObjects()
            for i=0, movingObjects:size()-1 do
                local obj = movingObjects:get(i)
                if instanceof(obj, "IsoZombie") then
                    local npcData = DTNPC.GetBrain(obj)
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
                            DynamicTrading.Log("DTV2", "NPC", "Order", "Master assigned for " .. args.state .. " order: " .. npcData.master)
                        elseif args.state == "GoTo" then
                           table.insert(npcData.tasks, {x = args.targetX, y = args.targetY, z = args.targetZ or 0})
                           DynamicTrading.Log("DTV2", "NPC", "Order", "GoTo task added: " .. args.targetX .. "," .. args.targetY .. "," .. (args.targetZ or 0))
                        end

                        DTNPC.AttachBrain(obj, npcData)
                        if DTNPCManager then DTNPCManager.Register(obj, npcData) end
                        
                        DTNPCServerCore.SyncToAllClients(obj, npcData)
                        DTNPCServerCore.BroadcastPosition(obj, npcData)
                        break
                    end
                end
            end
        end
    end
    
    if command == "RequestSync" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received RequestSync from: " .. player:getUsername())
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
                        DTNPCServerCore.SyncToPlayer(player, zombie, npcData)
                        syncCount = syncCount + 1
                    end
                end
            end
        end
        
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent " .. syncCount .. " nearby NPCs to: " .. player:getUsername())
    end

    if command == "RequestFullSync" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received RequestFullSync from: " .. player:getUsername())
        if not DTNPCManager or not DTNPCManager.Data then return end
        
        sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent full database (" .. DTNPCManager.GetTableSize(DTNPCManager.Data) .. " NPCs) to: " .. player:getUsername())
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
                        local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
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

        DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent tiered sync to " .. player:getUsername() .. ": nearby=" .. countTable(nearby) .. ", metadata=" .. countTable(metadata))
    end

    if command == "UpdateNPC" then
        if not args.uuid or not args.updates then return end
        
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received UpdateNPC for UUID: " .. args.uuid)
        
        local uuid = args.uuid
        local serverBrain = DTNPCManager.Data[uuid]
        
        if serverBrain then
            local shouldBroadcast = args.updates.broadcastPosition or false
            
            for k, v in pairs(args.updates) do
                if k ~= "broadcastPosition" then
                    DynamicTrading.Log("DTV2", "NPC", "Update", "  Updating " .. k .. " to " .. tostring(v))
                    serverBrain[k] = v
                end
            end
            
            DTNPCManager.Save()
            
            local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            if zombie then
                DTNPC.AttachBrain(zombie, serverBrain)
                DTNPCServerCore.SyncToAllClients(zombie, serverBrain)
                
                if shouldBroadcast then
                    DynamicTrading.Log("DTV2", "NPC", "Update", "Broadcasting position due to state change")
                    DTNPCServerCore.BroadcastPosition(zombie, serverBrain)
                end
                
                DynamicTrading.Log("DTV2", "NPC", "Update", "Updated and synced NPC to all clients")
            end
        else
            DynamicTrading.Log("DTV2", "NPC", "Warn", "UpdateNPC for unknown UUID: " .. uuid)
        end
    end

    if command == "RemoveNPC" then
        if not args.uuid then 
            DynamicTrading.Log("DTV2", "NPC", "Error", "RemoveNPC received with no UUID!")
            return 
        end
        
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Received RemoveNPC request for UUID: " .. args.uuid .. " (Status: " .. (args.status or "nil") .. ")")
        
        if DTNPCManager then
            local name = "Unknown"
            if DTNPCManager.Data[args.uuid] then
                name = DTNPCManager.Data[args.uuid].name or "Unknown"
                DTNPCManager.RemoveData(args.uuid, args.status, args.returnTime, args.returnStatus)
                DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed NPC data from database: " .. name .. " (" .. args.uuid .. ")")
            else
                DynamicTrading.Log("DTV2", "NPC", "Warn", "UUID " .. args.uuid .. " not found in database for removal.")
                -- Even if not in Manager, we might want to update Roster status if provided
                if DynamicTrading_Roster and args.status then
                    DynamicTrading_Roster.UpdateSoulStatus(args.uuid, args.status, args.returnTime, args.returnStatus)
                end
            end
            
            local zombie = DTNPCServerCore.FindZombieByUUID(args.uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed NPC from world: " .. args.uuid)
            else
                DynamicTrading.Log("DTV2", "NPC", "Remove", "INFO: NPC " .. args.uuid .. " not found in local world (may already be unloaded).")
            end
        else
            DynamicTrading.Log("DTV2", "NPC", "Error", "DTNPCManager not available for removal!")
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)
