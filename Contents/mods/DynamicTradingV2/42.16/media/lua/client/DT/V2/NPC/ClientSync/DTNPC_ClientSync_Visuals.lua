-- ==============================================================================
-- DTNPC_ClientSync_Visuals.lua
-- Visual application and world searching for NPCs.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync
local modules = ClientSync.Modules or {}

ClientSync.Modules = modules

if modules.Visuals then
    return
end

modules.Visuals = true

require "DT/V2/NPC/ClientSync/HealthBars/DTNPC_ClientSync_HealthBars"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient"

local function doesZombieMatchUUID(zombie, uuid)
    if not zombie or zombie:isDead() or not uuid then
        return false
    end

    local modData = zombie:getModData()
    local cached = DTNPCClient.NPCCache and DTNPCClient.NPCCache[uuid]
    local cachedData = cached and cached.npcData or nil
    local bodyInstanceID = zombie:getPersistentOutfitID()
    local expectedBodyInstanceID = cachedData and cachedData.currentBodyInstanceID or nil

    if expectedBodyInstanceID and bodyInstanceID ~= expectedBodyInstanceID then
        local zombieData = (modData and (modData.DTNPC_Data or modData.DTNPCBrain)) or nil
        local zombieVisualID = modData and modData.DTNPCVisualID or nil
        local cachedVisualID = cachedData.visualID
        if not (zombieData and zombieData.uuid == uuid and cachedVisualID and zombieVisualID == cachedVisualID) then
            return false
        end
    end

    if modData and modData.DTNPC_UUID == uuid then
        return true
    end

    local npcData = (modData and (modData.DTNPC_Data or modData.DTNPCBrain)) or nil
    return npcData and npcData.uuid == uuid or false
end

local function scoreZombieForUUID(zombie, uuid)
    if not zombie or zombie:isDead() or not uuid then
        return nil
    end

    local modData = zombie:getModData()
    local cached = DTNPCClient.NPCCache and DTNPCClient.NPCCache[uuid]
    local cachedData = cached and cached.npcData or nil
    local score = 0
    local hasIdentityEvidence = false

    if modData and modData.DTNPC_UUID == uuid then
        score = score + 100
        hasIdentityEvidence = true
    end

    local npcData = (modData and (modData.DTNPC_Data or modData.DTNPCBrain)) or nil
    if npcData and npcData.uuid == uuid then
        score = score + 80
        hasIdentityEvidence = true
    end

    if cachedData and cachedData.visualID and modData and modData.DTNPCVisualID == cachedData.visualID then
        score = score + 40
        hasIdentityEvidence = true
    end

    if not hasIdentityEvidence then
        return nil
    end

    if modData and modData.IsDTNPC then
        score = score + 20
    end

    return score
end

local function removeDuplicateLocalZombies(uuid, keepBodyInstanceID)
    if not uuid then return end

    local cell = getCell()
    if not cell then return end

    local zombieList = cell:getZombieList()
    if not zombieList then return end

    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() and doesZombieMatchUUID(zombie, uuid) then
            local bodyInstanceID = zombie:getPersistentOutfitID()
            if bodyInstanceID ~= keepBodyInstanceID then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
            end
        end
    end
end

function DTNPCClient.ApplyVisualsToNPC(zombie, npcData)
    if not zombie or not npcData then return end
    if isServer() and isDedicatedServer() then return end
    
    local modData = zombie:getModData()
    local uuid = npcData.uuid
    
    local needsVisuals = true
    if npcData.visualID and modData.DTNPCVisualID == npcData.visualID then
        local visuals = zombie:getHumanVisual()
        if visuals then
            local skin = visuals:getSkinTexture()
            if skin then
                local skinStr = tostring(skin)
                if string.find(skinStr, "MaleBody01") or string.find(skinStr, "FemaleBody01") then
                    needsVisuals = false
                end
            end
        end
    end
    
    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid

    if DTNPC and DTNPC.ApplySafetyFlags then
        DTNPC.ApplySafetyFlags(zombie, npcData, { clearPlayerTarget = true })
    elseif DTNPC and DTNPC.ApplyCharacterFlags then
        DTNPC.ApplyCharacterFlags(zombie, npcData)
    end

    if DTNPCClient.TrackNPCForHealthBars then
        DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, zombie:getPersistentOutfitID())
    end
    if DTNPCClient.TrackNPCForAmbientDialogue then
        DTNPCClient.TrackNPCForAmbientDialogue(zombie, npcData, uuid, zombie:getPersistentOutfitID())
    end
    
    -- Ensure npcData is attached even if we don't need to reapply visuals
    if DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(zombie, npcData)
    end

    if not needsVisuals then
        if DTNPC and DTNPC.SyncEquipmentVisuals then
            DTNPC.SyncEquipmentVisuals(zombie, npcData)
        end
        return
    end

    DynamicTrading.Log("DTV2", "NPC", "Visuals", "Applying visuals for: " .. (npcData.name or "Unknown") .. " (UUID: " .. uuid .. ")")
    
    if DTNPC and DTNPC.ApplyVisuals then
        DTNPC.ApplyVisuals(zombie, npcData)
    end
    
    modData.DTNPCVisualID = npcData.visualID
    
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:DoZombieStats()
    end
    
    zombie:resetModelNextFrame()
end

function DTNPCClient.ApplySafetyToMarkedZombie(zombie, npcData)
    if not zombie or zombie:isDead() then return false end

    local modData = zombie:getModData()
    if not modData then return false end

    npcData = npcData or modData.DTNPC_Data or modData.DTNPCBrain
    if not (modData.IsDTNPC or modData.DTNPC_UUID or npcData) then
        return false
    end

    if DTNPC and DTNPC.ApplySafetyFlags then
        DTNPC.ApplySafetyFlags(zombie, npcData, { clearPlayerTarget = true })
        return true
    end
    if DTNPC and DTNPC.ApplyCharacterFlags then
        DTNPC.ApplyCharacterFlags(zombie, npcData)
        return true
    end

    return false
end

function DTNPCClient.FindZombieByUUID(uuid)
    local cell = getCell()
    if not cell then return nil end

    local zombieList = cell:getZombieList()
    if not zombieList then return nil end

    local bestZombie = nil
    local bestScore = nil
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        local score = scoreZombieForUUID(zombie, uuid)
        if score and (not bestScore or score > bestScore) then
            bestZombie = zombie
            bestScore = score
        end
    end

    return bestZombie
end

function DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
    if not bodyInstanceID then return nil end

    local cell = getCell()
    if not cell then return nil end

    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() and zombie:getPersistentOutfitID() == bodyInstanceID then
            return zombie
        end
    end
    
    return nil
end

function DTNPCClient.ReconcilePosition(zombie, serverX, serverY, serverZ)
    if not zombie then return end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID

    if uuid and DTNPCClient.TrackNPCForHealthBars then
        DTNPCClient.TrackNPCForHealthBars(zombie, DTNPC.GetData(zombie), uuid, zombie:getPersistentOutfitID())
    end
    if uuid and DTNPCClient.TrackNPCForAmbientDialogue then
        DTNPCClient.TrackNPCForAmbientDialogue(zombie, DTNPC.GetData(zombie), uuid, zombie:getPersistentOutfitID())
    end
    
    if DTNPCClient.LocalControlled[uuid] then
        return false
    end
    if uuid
        and DTNPC_ClientInterpolation
        and DTNPC_ClientInterpolation.HasFreshState
        and DTNPC_ClientInterpolation.HasFreshState(uuid) then
        return false
    end

    local localX = zombie:getX()
    local localY = zombie:getY()
    local localZ = zombie:getZ()
    
    local dx = math.abs(localX - serverX)
    local dy = math.abs(localY - serverY)
    local dz = math.abs(localZ - serverZ)
    
    local TOLERANCE = 3.0
    
    if dx > TOLERANCE or dy > TOLERANCE or dz > 0 then
        local lerpFactor = 0.2
        zombie:setX(localX + (serverX - localX) * lerpFactor)
        zombie:setY(localY + (serverY - localY) * lerpFactor)
        zombie:setZ(serverZ)
        
        return true
    end
    
    return false
end

DTNPCClient.DoesZombieMatchUUID = doesZombieMatchUUID
DTNPCClient.RemoveDuplicateLocalZombies = removeDuplicateLocalZombies

function DTNPCClient.IsValidNPC(zombie)
    if not zombie then return false end
    
    local modData = zombie:getModData()
    local uuid = modData.DTNPC_UUID
    
    if uuid and DTNPCClient.NPCCache[uuid] then
        return true
    end
    
    if modData.IsDTNPC then
        return true
    end
    
    return false
end

function DTNPCClient.SetLocalControl(uuid, isControlled)
    if uuid then
        DTNPCClient.LocalControlled[uuid] = isControlled
    end
end

-- ==============================================================================
-- 7. EVENT REGISTRATION (Entry Point)
-- ==============================================================================

-- These must be registered after all modules have initialized their DTNPCClient functions.
-- This file is loaded last by DTNPC_ClientSync.lua.

Events.OnTick.Add(DTNPCClient.OnTick)
Events.OnServerCommand.Add(DTNPCClient.OnServerCommand)
Events.OnCreatePlayer.Add(DTNPCClient.RequestInitialSync)
Events.OnGameStart.Add(DTNPCClient.RequestInitialSync)

-- Safety check for non-vanilla event
if Events.OnZombieUpdate then
    Events.OnZombieUpdate.Add(DTNPCClient.OnZombieUpdate)
end
