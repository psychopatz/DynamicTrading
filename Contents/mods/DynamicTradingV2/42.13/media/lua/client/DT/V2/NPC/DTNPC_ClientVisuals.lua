-- ==============================================================================
-- DTNPC_ClientVisuals.lua
-- Visual application and world searching for NPCs.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}

require "DT/V2/NPC/DTNPC_HealthBars"
require "DT/V2/NPC/Ambient/DTNPC_AmbientDialogue"

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

function DTNPCClient.FindZombieByUUID(uuid)
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

function DTNPCClient.FindZombieByOutfitID(outfitID)
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
-- This file (Visuals.lua) loads last alphabetically.

Events.OnTick.Add(DTNPCClient.OnTick)
Events.OnServerCommand.Add(DTNPCClient.OnServerCommand)
Events.OnCreatePlayer.Add(DTNPCClient.RequestInitialSync)

-- Safety check for non-vanilla event
if Events.OnZombieUpdate then
    Events.OnZombieUpdate.Add(DTNPCClient.OnZombieUpdate)
end
