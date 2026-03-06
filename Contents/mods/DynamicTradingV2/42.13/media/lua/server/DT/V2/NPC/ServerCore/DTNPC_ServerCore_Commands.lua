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

local function onClientCommand(module, command, player, args)
    if module ~= "DTNPC" then return end

    if command == "Spawn" then
        print("[DTNPC] Received Spawn command from: " .. player:getUsername())
        DTNPCServerCore.SpawnNPC(player, nil, args)
    end

    if command == "Summon" then
        print("[DTNPC] Received Summon command from: " .. player:getUsername())
        DTNPCServerCore.SummonAll(player)
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
                        
                        brain.requestedReturnStatus = args.returnStatus
                        
                        if args.state == "Follow" or args.state == "Flee" then
                            brain.master = player:getUsername()
                            brain.masterID = isClient() and player:getOnlineID() or 0
                            print("[DTNPC] Master assigned for " .. args.state .. " order: " .. brain.master)
                        elseif args.state == "GoTo" then
                           table.insert(brain.tasks, {x = args.targetX, y = args.targetY, z = args.targetZ or 0})
                           print("[DTNPC] GoTo task added: " .. args.targetX .. "," .. args.targetY .. "," .. (args.targetZ or 0))
                        end

                        DTNPC.AttachBrain(obj, brain)
                        if DTNPCManager then DTNPCManager.Register(obj, brain) end
                        
                        DTNPCServerCore.SyncToAllClients(obj, brain)
                        DTNPCServerCore.BroadcastPosition(obj, brain)
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
                        DTNPCServerCore.SyncToPlayer(player, zombie, brain)
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
            
            local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            if zombie then
                DTNPC.AttachBrain(zombie, serverBrain)
                DTNPCServerCore.SyncToAllClients(zombie, serverBrain)
                
                if shouldBroadcast then
                    print("[DTNPC] Broadcasting position due to state change")
                    DTNPCServerCore.BroadcastPosition(zombie, serverBrain)
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
            
            local zombie = DTNPCServerCore.FindZombieByUUID(args.uuid)
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
