-- ==============================================================================
-- DTNPC_ClientSync_Network.lua
-- Client-side network command handlers for NPC synchronization.
-- ==============================================================================

require "DT/Common/Reputation/DT_Reputation"

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync
local modules = ClientSync.Modules or {}

ClientSync.Modules = modules

if modules.Network then
    return
end

modules.Network = true

DynamicTrading.Log("DTV2", "NPC", "Init", "Loading client interpolation module...")

require "DT/V2/NPC/ClientSync/DTNPC_ClientSync_Interpolation"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_ClientInterpolation loaded: " .. tostring(DTNPC_ClientInterpolation ~= nil))

-- Guard: Create fallback table with stub functions if module didn't load
if not DTNPC_ClientInterpolation then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_ClientInterpolation is nil, creating fallback")
    DTNPC_ClientInterpolation = { 
        LastPositions = {},
        UpdateTimes = {},
        RecordUpdate = function(uuid, x, y, z, updateFreq) end,
        GetInterpolatedPosition = function(uuid, zombie) 
            if zombie then return zombie:getX(), zombie:getY(), zombie:getZ() end
            return 0, 0, 0
        end,
        ClearNPC = function(uuid) end,
        ClearAll = function() end,
        GetTrackedCount = function() return 0 end,
        DebugPrint = function() end
    }
end

DynamicTrading.Log("DTV2", "NPC", "Init", "Module loading complete")

local function getLocalPlayer(playerNum)
    if type(playerNum) == "number" then
        local indexedPlayer = getSpecificPlayer(playerNum)
        if indexedPlayer then
            return indexedPlayer
        end
    end

    local defaultPlayer = getSpecificPlayer(0)
    if defaultPlayer then
        return defaultPlayer
    end

    if getPlayer then
        return getPlayer()
    end

    return nil
end

local function getNowMillis()
    if getTimeInMillis then
        return getTimeInMillis()
    end

    return os.time() * 1000
end

function DTNPCClient.QueueNearbySync(reason, resetState)
    if isServer() and isDedicatedServer() then return end

    if resetState and DTNPCClient.ResetSessionState then
        DTNPCClient.ResetSessionState(reason or "queued-nearby-sync")
    else
        DTNPCClient.PendingNearbySyncReason = tostring(reason or "queued-nearby-sync")
    end
end

function DTNPCClient.SendNearbySyncRequest(player, reason)
    if not isClient() then return false end

    player = player or getLocalPlayer(0)
    if not player then
        DTNPCClient.PendingNearbySyncReason = tostring(reason or DTNPCClient.PendingNearbySyncReason or "missing-player")
        return false
    end

    local px = player:getX()
    local py = player:getY()
    local pz = player:getZ()

    sendClientCommand(player, "DTNPC", "RequestNearbySync", {
        x = px,
        y = py,
        z = pz,
        nearRadius = DTNPCClient.NEARBY_SYNC_NEAR_RADIUS or 350,
        metadataRadius = DTNPCClient.NEARBY_SYNC_METADATA_RADIUS or 1000,
    })

    DTNPCClient.LastNearbySyncX = px
    DTNPCClient.LastNearbySyncY = py
    DTNPCClient.LastNearbySyncZ = pz
    DTNPCClient.LastNearbySyncTime = getNowMillis()
    DTNPCClient.PendingNearbySyncReason = nil
    DTNPCClient.hasSyncedOnce = true

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Requested nearby sync (" .. tostring(reason or "periodic") .. ") for player: " .. player:getUsername())
    return true
end

function DTNPCClient.MaybeRequestNearbySync()
    if not isClient() then return end

    local player = getLocalPlayer(0)
    if not player then return end

    local now = getNowMillis()
    local lastSyncTime = DTNPCClient.LastNearbySyncTime or 0
    local elapsed = now - lastSyncTime
    local minInterval = DTNPCClient.NEARBY_SYNC_MIN_INTERVAL_MS or 4000
    local staleInterval = DTNPCClient.NEARBY_SYNC_STALE_INTERVAL_MS or 15000

    if DTNPCClient.PendingNearbySyncReason then
        if elapsed >= 500 then
            DTNPCClient.SendNearbySyncRequest(player, DTNPCClient.PendingNearbySyncReason)
        end
        return
    end

    if not DTNPCClient.hasSyncedOnce then
        if elapsed >= 500 then
            DTNPCClient.SendNearbySyncRequest(player, "first-nearby-sync")
        end
        return
    end

    local lastX = DTNPCClient.LastNearbySyncX
    local lastY = DTNPCClient.LastNearbySyncY
    local lastZ = DTNPCClient.LastNearbySyncZ

    if lastX == nil or lastY == nil or lastZ == nil then
        if elapsed >= 500 then
            DTNPCClient.SendNearbySyncRequest(player, "sync-position-missing")
        end
        return
    end

    local dx = player:getX() - lastX
    local dy = player:getY() - lastY
    local dz = player:getZ() - lastZ
    local dist = math.sqrt(dx * dx + dy * dy)
    local moveThreshold = DTNPCClient.NEARBY_SYNC_MOVE_THRESHOLD or 45

    if elapsed >= staleInterval then
        DTNPCClient.SendNearbySyncRequest(player, "stale-refresh")
        return
    end

    if elapsed >= minInterval and (dist >= moveThreshold or math.abs(dz) >= 1) then
        DTNPCClient.SendNearbySyncRequest(player, "movement-refresh")
    end
end

function DTNPCClient.OnServerCommand(module, command, args)
    if module ~= "DTNPC" then return end

    if command == "SyncNPC" then
        if not args or not args.uuid or not args.npcData then return end
        
        local uuid = args.uuid
        local outfitID = args.outfitID
        
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncNPC for: " .. (args.npcData.name or uuid))
        
        DTNPCClient.CacheData(uuid, outfitID, args.npcData)
        if DTNPCClient.TrackNPCForHealthBars then
            DTNPCClient.TrackNPCForHealthBars(nil, args.npcData, uuid, outfitID)
        end
        if DTNPCClient.TrackNPCForAmbientDialogue then
            DTNPCClient.TrackNPCForAmbientDialogue(nil, args.npcData, uuid, outfitID)
        end
        
        -- Track position for interpolation
        if args.x and args.y then
            DTNPC_ClientInterpolation.RecordUpdate(uuid, args.x, args.y, args.z or 0)
        end
        
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        
        if not zombie and outfitID then
            zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
        end
        
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, args.npcData)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
            DTNPCClient.ProcessedZombies[uuid] = true
            
            -- Sync reported state
            local cached = DTNPCClient.NPCCache[uuid]
            if cached then
                cached.lastReportedState = {
                    state = args.npcData.state,
                    tasksCount = (args.npcData.tasks and #args.npcData.tasks or 0)
                }
            end
            
            DynamicTrading.Log("DTV2", "NPC", "Sync", "Applied visuals to zombie: " .. uuid)
        else
            DynamicTrading.Log("DTV2", "NPC", "Sync", "Zombie not in world yet, cached for later: " .. uuid)
        end
        return
    end

    if command == "UpdatePosition" then
        if not args or not args.uuid then return end
        
        local uuid = args.uuid
        local cached = DTNPCClient.NPCCache[uuid]
        
        -- Track position for interpolation
        if args.x and args.y then
            DTNPC_ClientInterpolation.RecordUpdate(uuid, args.x, args.y, args.z or 0)
        end
        
        if cached and cached.npcData then
            cached.npcData.lastX = math.floor(args.x)
            cached.npcData.lastY = math.floor(args.y)
            cached.npcData.lastZ = math.floor(args.z)
            
            if args.health then cached.npcData.health = args.health end
            if args.state then cached.npcData.state = args.state end
            if args.status then cached.npcData.status = args.status end
            if args.outfitID then
                DTNPCClient.OutfitIDToUUID[args.outfitID] = uuid
                cached.npcData.currentOutfitID = args.outfitID
            end
            
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            
            if not zombie and args.outfitID then
                zombie = DTNPCClient.FindZombieByOutfitID(args.outfitID)
            end
            
            if zombie then
                -- CRITICAL: Update the modData directly so interaction menus see the change
                local zombieData = DTNPC.GetData(zombie)
                if zombieData then
                    if args.state then zombieData.state = args.state end
                    if args.health then zombieData.health = args.health end
                    if args.status then zombieData.status = args.status end
                end

                if not DTNPCClient.LocalControlled[uuid] then
                    DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
                end
            end
            
            -- Sync reported state if state was provided
            if args.state then
                cached.lastReportedState = cached.lastReportedState or {}
                cached.lastReportedState.state = args.state
            end
        end

        if DTNPCClient.TrackNPCForHealthBars then
            DTNPCClient.TrackNPCForHealthBars(nil, cached and cached.npcData or nil, uuid, args.outfitID)
        end
        if DTNPCClient.TrackNPCForAmbientDialogue then
            DTNPCClient.TrackNPCForAmbientDialogue(nil, cached and cached.npcData or nil, uuid, args.outfitID)
        end
        if args.health and DTNPCClient.MarkNPCCombatForHealthBars then
            DTNPCClient.MarkNPCCombatForHealthBars(uuid, nil, cached and cached.npcData or nil, args.outfitID)
        end
        return
    end

    if command == "RemoveNPC" then
        if not args or not args.uuid then return end
        
        local uuid = args.uuid
        local name = args.name or "Unknown"
        local outfitID = args.outfitID
        local cachedEntry = DTNPCClient.NPCCache[uuid]
        local factionID = cachedEntry and cachedEntry.npcData and cachedEntry.npcData.factionID or nil
        
        if name == "Unknown" and DTNPCClient.NPCCache[uuid] then
            name = DTNPCClient.NPCCache[uuid].npcData.name or "Unknown"
        end
        
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Received RemoveNPC for: " .. name .. " (" .. uuid .. ")")
        
        -- Clear interpolation data
        DTNPC_ClientInterpolation.ClearNPC(uuid)
        
        -- World Removal: Physically remove the zombie if it exists locally
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if not zombie and outfitID then
            zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
        end

        if DT_Reputation then
            local reason = args.removalReason
            if reason == "Incapacitated" then
                DT_Reputation.ApplyIncapPenalty(uuid, factionID)
            elseif reason == "Dead" then
                if factionID and factionID ~= "Independent" then
                    DT_Reputation.TryApplyKillPenalty(
                        uuid,
                        factionID,
                        zombie,
                        args.killerUsername,
                        args.killerOnlineID
                    )
                end
            end
        end
        
        if zombie then
            zombie:removeFromWorld()
            zombie:removeFromSquare()
            DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed zombie from local world: " .. name)
        end
        
        DTNPCClient.RemoveFromCache(uuid, outfitID)

        if DT_V2_RadarManager then
            if DT_V2_RadarManager.ClientRoster and DT_V2_RadarManager.ClientRoster.Souls then
                DT_V2_RadarManager.ClientRoster.Souls[uuid] = nil
            end
            DT_V2_RadarManager.FoundTraders[uuid] = nil
        end

        if DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Traders then
            DynamicTrading_Client.Cache.Traders[uuid] = nil
        end

        if DT_V2_RadarWindow and DT_V2_RadarWindow.instance and DT_V2_RadarWindow.instance.refresh then
            DT_V2_RadarWindow.instance:refresh()
        end
        return
    end

    if command == "SyncAllNPCs" then
        if not args or not args.npcs then return end
        
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncAllNPCs. Count: " .. DTNPCClient.GetTableSize(args.npcs))
        
        for uuid, npcData in pairs(args.npcs) do
            local outfitID = npcData.currentOutfitID
            DTNPCClient.CacheData(uuid, outfitID, npcData)
            if DTNPCClient.TrackNPCForHealthBars then
                DTNPCClient.TrackNPCForHealthBars(nil, npcData, uuid, outfitID)
            end
            if DTNPCClient.TrackNPCForAmbientDialogue then
                DTNPCClient.TrackNPCForAmbientDialogue(nil, npcData, uuid, outfitID)
            end
            
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            
            if not zombie and outfitID then
                zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
            end
            
            if zombie then
                DTNPCClient.ApplyVisualsToNPC(zombie, npcData)
                DTNPCClient.ProcessedZombies[uuid] = true
                
                -- Sync reported state
                local cached = DTNPCClient.NPCCache[uuid]
                if cached then
                    cached.lastReportedState = {
                        state = npcData.state,
                        tasksCount = (npcData.tasks and #npcData.tasks or 0)
                    }
                end
            end
        end
        return
    end

    if command == "SyncNearbyNPCs" then
        if not args then return end

        local nearbyCount = 0
        local metadataCount = 0

        for uuid, npcData in pairs(args.nearby or {}) do
            if npcData and npcData.npcData then
                local outfitID = npcData.outfitID
                DTNPCClient.CacheData(uuid, outfitID, npcData.npcData)
                if DTNPCClient.TrackNPCForHealthBars then
                    DTNPCClient.TrackNPCForHealthBars(nil, npcData.npcData, uuid, outfitID)
                end
                if DTNPCClient.TrackNPCForAmbientDialogue then
                    DTNPCClient.TrackNPCForAmbientDialogue(nil, npcData.npcData, uuid, outfitID)
                end

                -- Track position for interpolation
                local x = npcData.x or npcData.npcData.lastX
                local y = npcData.y or npcData.npcData.lastY
                local z = npcData.z or npcData.npcData.lastZ or 0
                if x and y then
                    DTNPC_ClientInterpolation.RecordUpdate(uuid, x, y, z)
                end

                local zombie = DTNPCClient.FindZombieByUUID(uuid)
                if not zombie and outfitID then
                    zombie = DTNPCClient.FindZombieByOutfitID(outfitID)
                end

                if zombie then
                    DTNPCClient.ApplyVisualsToNPC(zombie, npcData.npcData)
                    DTNPCClient.ReconcilePosition(zombie, x, y, z)
                    DTNPCClient.ProcessedZombies[uuid] = true
                end

                nearbyCount = nearbyCount + 1
            end
        end

        for uuid, meta in pairs(args.metadata or {}) do
            if DT_V2_RadarManager and DT_V2_RadarManager.OnMetadataReceived then
                DT_V2_RadarManager.OnMetadataReceived(uuid, meta)
            else
                DTNPCClient.CacheMetadata(uuid, meta)
            end
            metadataCount = metadataCount + 1
        end

        DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncNearbyNPCs: nearby=" .. nearbyCount .. ", metadata=" .. metadataCount)
        return
    end
end

function DTNPCClient.RequestInitialSync(playerNum)
    if isServer() and isDedicatedServer() then return end

    DTNPCClient.QueueNearbySync("initial-sync", true)

    local player = getLocalPlayer(playerNum)
    if player then
        DTNPCClient.SendNearbySyncRequest(player, "initial-sync")
    else
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Queued initial nearby sync until player is ready")
    end
end

-- Events will be registered in DTNPC_ClientSync_Visuals.lua after all sync functions are defined.
