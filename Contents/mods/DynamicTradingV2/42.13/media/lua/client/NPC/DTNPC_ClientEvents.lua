-- ==============================================================================
-- DTNPC_ClientEvents.lua
-- Event registration and periodic checks for NPCs.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}

function DTNPCClient.OnTick()
    if isServer() and isDedicatedServer() then return end
    
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
            
            if cached and cached.brain then
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
                                print("[DTNPC-Client] Zombie " .. uuid .. " lost visuals, reapplying...")
                            end
                        else
                            needsVisuals = true
                        end
                    else
                        needsVisuals = true
                    end
                    
                    if modData.DTNPCVisualID ~= cached.brain.visualID then
                        needsVisuals = true
                    end
                end
                
                if needsVisuals then
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached.brain)
                    DTNPCClient.ProcessedZombies[uuid] = true
                    reappliedCount = reappliedCount + 1
                else
                    if zombie:isLocal() and modData.IsDTNPC then
                        DTNPCClient.SetLocalControl(uuid, true)
                        
                        local localBrain = modData.DTNPCBrain
                        local serverBrain = cached.brain
                        
                        if localBrain and serverBrain then
                            local changed = false
                            local updates = {}
                            
                            if localBrain.state ~= serverBrain.state then
                                updates.state = localBrain.state
                                changed = true
                            end
                            
                            if localBrain.tasks and serverBrain.tasks then
                                if #localBrain.tasks ~= #serverBrain.tasks then
                                    updates.tasks = localBrain.tasks
                                    changed = true
                                end
                            end
                            
                            if changed then
                                if updates.state then 
                                    serverBrain.state = updates.state
                                    updates.broadcastPosition = true
                                end
                                if updates.tasks then serverBrain.tasks = updates.tasks end
                                
                                sendClientCommand(getPlayer(), "DTNPC", "UpdateNPC", { uuid = uuid, updates = updates })
                                updatedCount = updatedCount + 1
                            end
                        end
                    else
                        DTNPCClient.SetLocalControl(uuid, false)
                    end
                end
            end
        end
    end
    
    if attachedCount > 0 then
        print("[DTNPC-Client] Attached brains to " .. attachedCount .. " new NPCs")
    end
    if reappliedCount > 0 then
        print("[DTNPC-Client] Reapplied visuals to " .. reappliedCount .. " NPCs")
    end
    if updatedCount > 0 then
        print("[DTNPC-Client] Sent " .. updatedCount .. " state updates to server")
    end
end

function DTNPCClient.OnZombieRemoved(zombie)
    if not zombie then return end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID
    
    if uuid and DTNPCClient.ProcessedZombies[uuid] then
        print("[DTNPC-Client] Zombie removed from world: " .. uuid)
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
    end
end

function DTNPCClient.OnZombieUpdate(zombie)
    if not zombie or zombie:isDead() then
        DTNPCClient.OnZombieRemoved(zombie)
    end
end

-- Events will be registered in DTNPC_ClientVisuals.lua to ensure all functions are defined.
