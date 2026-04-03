-- ==============================================================================
-- DTNPC_ClientSync_Events.lua
-- Event registration and periodic checks for NPCs.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync
local modules = ClientSync.Modules or {}

ClientSync.Modules = modules

if modules.Events then
    return
end

modules.Events = true

function DTNPCClient.OnTick()
    if isServer() and isDedicatedServer() then return end

    DTNPCClient.nearbySyncCheckCounter = (DTNPCClient.nearbySyncCheckCounter or 0) + 1
    if DTNPCClient.nearbySyncCheckCounter >= (DTNPCClient.NEARBY_SYNC_CHECK_RATE or 30) then
        DTNPCClient.nearbySyncCheckCounter = 0
        if DTNPCClient.MaybeRequestNearbySync then
            DTNPCClient.MaybeRequestNearbySync()
        end
    end

    DTNPCClient.visualCheckCounter = (DTNPCClient.visualCheckCounter or 0) + 1
    if DTNPCClient.visualCheckCounter < DTNPCClient.VISUAL_CHECK_RATE then return end
    DTNPCClient.visualCheckCounter = 0
    
    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    local attachedCount = 0
    local reappliedCount = 0
    local updatedCount = 0
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local modData = zombie:getModData()
            local uuid = modData.DTNPC_UUID
            
            if not uuid then
                local outfitID = zombie:getPersistentOutfitID()
                uuid = DTNPCClient.OutfitIDToUUID[outfitID]
                if uuid then
                    modData.DTNPC_UUID = uuid
                end
            end
            
            local cached = DTNPCClient.NPCCache[uuid]
            
            if cached and cached.npcData then
                local needsVisuals = false
                
                if not DTNPCClient.ProcessedZombies[uuid] then
                    needsVisuals = true
                else
                    local visuals = zombie:getHumanVisual()
                    if visuals then
                        local skin = visuals:getSkinTexture()
                        if skin then
                            local skinStr = tostring(skin)
                            if not (string.find(skinStr, "MaleBody01") or string.find(skinStr, "FemaleBody01")) then
                                needsVisuals = true
                                DynamicTrading.Log("DTV2", "NPC", "Visuals", "Zombie " .. uuid .. " lost visuals, reapplying...")
                            end
                        else
                            needsVisuals = true
                        end
                    else
                        needsVisuals = true
                    end
                    
                    if modData.DTNPCVisualID ~= cached.npcData.visualID then
                        needsVisuals = true
                    end
                end
                
                if needsVisuals then
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached.npcData)
                    DTNPCClient.ProcessedZombies[uuid] = true
                    reappliedCount = reappliedCount + 1
                    attachedCount = attachedCount + 1
                else
                    -- Brain might not be in modData yet if ApplyVisualsToNPC returned early
                    if not DTNPC.GetData(zombie) then
                        DTNPCClient.ApplyVisualsToNPC(zombie, cached.npcData)
                    end

                    if zombie:isLocal() and modData.IsDTNPC then
                        DTNPCClient.SetLocalControl(uuid, true)
                        
                        local localData = DTNPC.GetData(zombie)
                        
                        if localData then
                            local changed = false
                            local updates = {}
                            
                            -- Initialize last reported state if missing
                            if not cached.lastReportedState then 
                                cached.lastReportedState = {
                                    state = localData.state,
                                    tasksCount = (localData.tasks and #localData.tasks or 0)
                                }
                            end
                            
                            -- Detect state change
                            if localData.state ~= cached.lastReportedState.state then
                                updates.state = localData.state
                                cached.lastReportedState.state = localData.state
                                changed = true
                            end
                            
                            -- Detect tasks change
                            local currentTasksCount = (localData.tasks and #localData.tasks or 0)
                            if currentTasksCount ~= cached.lastReportedState.tasksCount then
                                updates.tasks = localData.tasks
                                cached.lastReportedState.tasksCount = currentTasksCount
                                changed = true
                            end
                            
                            if changed then
                                -- Broadcast position if state changed
                                if updates.state then updates.broadcastPosition = true end
                                
                                sendClientCommand(getPlayer(), "DTNPC", "UpdateNPC", { uuid = uuid, updates = updates })
                                updatedCount = updatedCount + 1
                                DynamicTrading.Log("DTV2", "NPC", "Sync", "Syncing behavioral change for " .. (localData.name or uuid) .. ": " .. (updates.state or "tasks updated"))
                            end
                        end
                    else
                        DTNPCClient.SetLocalControl(uuid, false)
                        -- Reset reported state when not local to force fresh sync if we regain control
                        cached.lastReportedState = nil
                    end
                end
            end
        end
    end
    
    if attachedCount > 0 then
        DynamicTrading.Log("DTV2", "NPC", "Client", "Attached npcDatas to " .. attachedCount .. " new NPCs")
    end
    if reappliedCount > 0 then
        DynamicTrading.Log("DTV2", "NPC", "Visuals", "Reapplied visuals to " .. reappliedCount .. " NPCs")
    end
    if updatedCount > 0 then
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent " .. updatedCount .. " state updates to server")
    end
end

function DTNPCClient.OnZombieRemoved(zombie)
    if not zombie then return end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID
    
    if uuid and DTNPCClient.ProcessedZombies[uuid] then
        DynamicTrading.Log("DTV2", "NPC", "Client", "Zombie removed from world: " .. uuid)
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
    end
end

function DTNPCClient.OnZombieUpdate(zombie)
    if not zombie or zombie:isDead() then
        DTNPCClient.OnZombieRemoved(zombie)
    end
end

-- Events will be registered in DTNPC_ClientSync_Visuals.lua after all sync functions are defined.
