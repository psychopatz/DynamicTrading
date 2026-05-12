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

local function getLoadoutSignature(loadout)
    loadout = type(loadout) == "table" and loadout or {}
    return table.concat({
        tostring(loadout.rangedWeapon or ""),
        tostring(loadout.rangedAmmoType or ""),
        tostring(math.max(0, tonumber(loadout.ammoCount) or 0)),
        tostring(loadout.meleeWeapon or ""),
        tostring(loadout.bag or ""),
        tostring(loadout.rangedCondition ~= nil and math.max(0, math.floor(tonumber(loadout.rangedCondition) or 0)) or ""),
        tostring(loadout.meleeCondition ~= nil and math.max(0, math.floor(tonumber(loadout.meleeCondition) or 0)) or ""),
    }, "|")
end

local function getSpecialActionSignature(npcData)
    npcData = type(npcData) == "table" and npcData or {}
    return table.concat({
        tostring(npcData._dtSpecialAction or ""),
        tostring(npcData._dtSpecialActionUntil or ""),
        tostring(npcData._dtSpecialActionMode or ""),
        tostring(npcData._dtSpecialActionSeq or ""),
        tostring(npcData._dtFenceActionSeq or ""),
        tostring(npcData._dtReloadUntil or ""),
        tostring(npcData._dtReloadActionSeq or ""),
        tostring(npcData._dtReloadFamily or ""),
        tostring(npcData._dtMagAmmo or ""),
        tostring(npcData._dtMagSize or ""),
    }, "|")
end

function DTNPCClient.OnTick()
    if isServer() and isDedicatedServer() then return end

    if DTNPC_ClientInterpolation and DTNPC_ClientInterpolation.ApplyToTrackedNPCs then
        DTNPC_ClientInterpolation.ApplyToTrackedNPCs()
    end

    DTNPCClient.nearbySyncCheckCounter = (DTNPCClient.nearbySyncCheckCounter or 0) + 1
    if DTNPCClient.nearbySyncCheckCounter >= (DTNPCClient.NEARBY_SYNC_CHECK_RATE or 30) then
        DTNPCClient.nearbySyncCheckCounter = 0
        if DTNPCClient.MaybeRequestNearbySync then
            DTNPCClient.MaybeRequestNearbySync()
        end
    end

    DTNPCClient.hostilityCacheRebuildCounter = (DTNPCClient.hostilityCacheRebuildCounter or 0) + 1
    if DTNPCClient.hostilityCacheRebuildCounter >= 300 then
        DTNPCClient.hostilityCacheRebuildCounter = 0
        if DTNPCHostility and DTNPCHostility.RebuildClientTargetCache then
            DTNPCHostility.RebuildClientTargetCache()
        end
    end

    DTNPCClient.visualCheckCounter = (DTNPCClient.visualCheckCounter or 0) + 1
    if DTNPCClient.visualCheckCounter < DTNPCClient.VISUAL_CHECK_RATE then return end
    DTNPCClient.visualCheckCounter = 0

    local currentMillis = getTimeInMillis()
    for uuid, cached in pairs(DTNPCClient.NPCCache or {}) do
        if cached and cached.awaitingWorldZombieSince then
            local bodyInstanceID = cached.npcData and cached.npcData.currentBodyInstanceID or nil
            local zombie = DTNPCClient.FindZombieByUUID and DTNPCClient.FindZombieByUUID(uuid) or nil
            if not zombie and bodyInstanceID and DTNPCClient.FindZombieByBodyInstanceID then
                zombie = DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
            end

            if zombie then
                cached.awaitingWorldZombieSince = nil
                cached.awaitingWorldZombieLoggedAt = nil
                DynamicTrading.Log(
                    "DTV2",
                    "NPC",
                    "Sync",
                    "Delayed live zombie resolved uuid=" .. tostring(uuid)
                        .. " bodyInstanceID=" .. tostring(bodyInstanceID)
                )
            elseif currentMillis - cached.awaitingWorldZombieSince >= 3000 then
                local lastLoggedAt = tonumber(cached.awaitingWorldZombieLoggedAt) or 0
                if lastLoggedAt == 0 or currentMillis - lastLoggedAt >= 3000 then
                    cached.awaitingWorldZombieLoggedAt = currentMillis
                    DynamicTrading.Log(
                        "DTV2",
                        "NPC",
                        "Warn",
                        "Still waiting for live zombie after SyncNPC uuid=" .. tostring(uuid)
                            .. " bodyInstanceID=" .. tostring(bodyInstanceID)
                            .. " waitMs=" .. tostring(currentMillis - cached.awaitingWorldZombieSince)
                            .. " name=" .. tostring(cached.npcData and (cached.npcData.name or uuid) or uuid)
                            .. " customCurrent=" .. tostring(cached.npcData and cached.npcData.combatHealth and cached.npcData.combatHealth.current or nil)
                            .. " customMax=" .. tostring(cached.npcData and cached.npcData.combatHealth and cached.npcData.combatHealth.max or nil)
                    )
                end
            end
        end
    end

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
            local cached = nil

            if not uuid then
                local bodyInstanceID = zombie:getPersistentOutfitID()
                uuid = DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID]
                if uuid then
                    modData.DTNPC_UUID = uuid
                end
            end

            cached = DTNPCClient.NPCCache[uuid]
            if DTNPCClient.ApplySafetyToMarkedZombie then
                DTNPCClient.ApplySafetyToMarkedZombie(zombie, cached and cached.npcData or nil)
            end

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

                    if DTNPC and DTNPC.SyncEquipmentVisuals then
                        DTNPC.SyncEquipmentVisuals(zombie, cached.npcData)
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
                                    tasksCount = (localData.tasks and #localData.tasks or 0),
                                    loadoutSignature = getLoadoutSignature(localData.loadout),
                                    specialActionSignature = getSpecialActionSignature(localData),
                                    combatOrder = localData.combatOrder,
                                    guardCombatOrder = localData.guardCombatOrder,
                                    protectNoticeSerial = localData.protectNoticeSerial or 0,
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

                            local currentLoadoutSignature = getLoadoutSignature(localData.loadout)
                            if currentLoadoutSignature ~= cached.lastReportedState.loadoutSignature then
                                updates.loadout = localData.loadout
                                cached.lastReportedState.loadoutSignature = currentLoadoutSignature
                                changed = true
                            end

                            local currentSpecialActionSignature = getSpecialActionSignature(localData)
                            if currentSpecialActionSignature ~= cached.lastReportedState.specialActionSignature then
                                updates._dtSpecialAction = localData._dtSpecialAction
                                updates._dtSpecialActionUntil = localData._dtSpecialActionUntil
                                updates._dtSpecialActionMode = localData._dtSpecialActionMode
                                updates._dtSpecialActionSeq = localData._dtSpecialActionSeq
                                updates._dtFenceActionSeq = localData._dtFenceActionSeq
                                updates._dtReloadUntil = localData._dtReloadUntil
                                updates._dtReloadActionSeq = localData._dtReloadActionSeq
                                updates._dtReloadFamily = localData._dtReloadFamily
                                updates._dtMagAmmo = localData._dtMagAmmo
                                updates._dtMagSize = localData._dtMagSize
                                updates.broadcastPosition = true
                                cached.lastReportedState.specialActionSignature = currentSpecialActionSignature
                                changed = true
                            end

                            if localData.combatOrder ~= cached.lastReportedState.combatOrder then
                                updates.combatOrder = localData.combatOrder
                                cached.lastReportedState.combatOrder = localData.combatOrder
                                changed = true
                            end

                            if localData.guardCombatOrder ~= cached.lastReportedState.guardCombatOrder then
                                updates.guardCombatOrder = localData.guardCombatOrder
                                updates.guardAttackMode = localData.guardAttackMode
                                cached.lastReportedState.guardCombatOrder = localData.guardCombatOrder
                                changed = true
                            end

                            local currentNoticeSerial = localData.protectNoticeSerial or 0
                            if currentNoticeSerial ~= cached.lastReportedState.protectNoticeSerial then
                                updates.protectNoticeSerial = currentNoticeSerial
                                updates.protectNoticeText = localData.protectNoticeText
                                updates.protectNoticeSentiment = localData.protectNoticeSentiment
                                updates.protectNoticeDialogueStatus = localData.protectNoticeDialogueStatus
                                updates.protectNoticeDialogueState = localData.protectNoticeDialogueState
                                cached.lastReportedState.protectNoticeSerial = currentNoticeSerial
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

    if DTNPCHostility and DTNPCHostility.RemoveClientTarget then
        DTNPCHostility.RemoveClientTarget(zombie)
    end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID
    
    if uuid and DTNPCClient.ProcessedZombies[uuid] then
        DynamicTrading.Log("DTV2", "NPC", "Client", "Zombie removed from world: " .. uuid)
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
    end
end

local function getForcedProfileKey(npcData)
    local profileKey = npcData and npcData._dtLocomotionProfileKey or nil
    if profileKey and profileKey ~= "" then
        return tostring(profileKey)
    end

    if npcData and tostring(npcData.state or "") == "Incapacitated" then
        return DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl"
    end

    if npcData
        and tostring(npcData.state or "") == "Departure"
        and tostring(npcData.healthState or "") == "Weakened" then
        return DTNPCHealth and DTNPCHealth.WEAKENED_CROUCH_PROFILE_KEY or "weakened_crouch"
    end

    return nil
end

local function enforceRemoteLocomotionProfile(zombie, npcData)
    if not zombie or type(npcData) ~= "table" or not DTNPCMobility or not DTNPCMobility.GetLocomotionProfile then
        return
    end

    local profileKey = getForcedProfileKey(npcData)
    if not profileKey then
        return
    end

    local profile = DTNPCMobility.GetLocomotionProfile(profileKey)
    if type(profile) ~= "table" then
        return
    end

    local moving = npcData.isMovingState == true
    local dtWalkType = tostring(profile.dtWalkType or "")

    zombie:setVariable("DTNPC", true)
    zombie:setVariable("bMoving", moving)
    zombie:setVariable("isMoving", moving)
    zombie:setVariable("DTWalkType", dtWalkType)
    zombie:setVariable("WalkType", profile.walkType ~= nil and tostring(profile.walkType) or "")

    if profile.crawl == true then
        zombie:setVariable("bBecomeCrawler", false)
        zombie:setVariable("bCrawling", false)
        zombie:setVariable("FallOnFront", false)
        zombie:setVariable("DTNPCMoveAnim", moving and "Crawl" or "")
        return
    end

    if moving then
        zombie:setVariable("DTNPCMoveAnim", dtWalkType ~= "" and dtWalkType or "Walk")
    elseif dtWalkType == "SneakWalk" then
        zombie:setVariable("DTNPCMoveAnim", "")
    end

    if dtWalkType ~= "" and zombie.setWalkType then
        pcall(zombie.setWalkType, zombie, dtWalkType)
    end
end

function DTNPCClient.OnZombieUpdate(zombie)
    if not zombie or zombie:isDead() then
        DTNPCClient.OnZombieRemoved(zombie)
        return
    end

    local modData = zombie:getModData()
    local isDTNPCBody = modData and (modData.IsDTNPC == true or modData.DTNPC_UUID ~= nil)
    local isBanditBody = zombie:getVariableBoolean("Bandit")

    if DTNPCClient.ApplySafetyToMarkedZombie then
        DTNPCClient.ApplySafetyToMarkedZombie(zombie)
    end

    if isDTNPCBody and DTNPCHostility and DTNPCHostility.UpsertClientTarget then
        local npcData = modData and (modData.DTNPC_Data or modData.DTNPCBrain) or nil
        DTNPCHostility.UpsertClientTarget(zombie, npcData)
        enforceRemoteLocomotionProfile(zombie, npcData)
    end

    -- Proactive NPC interactions (Doors/Windows)
    if DTNPCMobility and DTNPCMobility.UpdateProactiveInteractions then
        local uuid = modData and modData.DTNPC_UUID
        local cached = uuid and DTNPCClient.NPCCache and DTNPCClient.NPCCache[uuid]
        local npcData = cached and cached.npcData or (modData and (modData.DTNPC_Data or modData.DTNPCBrain))
        
        if npcData then
            DTNPCMobility.UpdateProactiveInteractions(zombie, npcData)
        end
    end

    -- Zombie-NPC Hostility (Targeting and Attack Simulation)
    if DTNPCHostility then
        if not isDTNPCBody and not isBanditBody then
            if DTNPCHostility.UpdateZombieTargeting then
                DTNPCHostility.UpdateZombieTargeting(zombie)
            end
            if DTNPCHostility.UpdateAttackSimulation then
                DTNPCHostility.UpdateAttackSimulation(zombie)
            end
        end
    end
end

-- Events will be registered in DTNPC_ClientSync_Visuals.lua after all sync functions are defined.
