-- ==============================================================================
-- DTNPC_ServerCore_Utilities.lua
-- Helper functions for finding NPCs in the world.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- FINDER FUNCTIONS
-- ==============================================================================

local function getSavedData(uuid)
    local savedData = nil
    if DTNPCManager and DTNPCManager.Data then
        savedData = DTNPCManager.Data[uuid]
    end
    if not savedData and DynamicTrading_Roster and DynamicTrading_Roster.GetSoul then
        savedData = DynamicTrading_Roster.GetSoul(uuid)
    end
    return savedData
end

local function scoreZombieForUUID(zombie, uuid, savedData)
    if not zombie or zombie:isDead() then
        return nil
    end

    local modData = zombie:getModData()
    local score = 0
    local hasIdentityEvidence = false

    if modData.DTNPC_UUID == uuid then
        score = score + 100
        hasIdentityEvidence = true
    end

    local npcData = modData.DTNPC_Data or modData.DTNPCBrain
    if npcData and npcData.uuid == uuid then
        score = score + 80
        hasIdentityEvidence = true
    end

    if savedData and savedData.visualID and modData.DTNPCVisualID == savedData.visualID then
        score = score + 40
        hasIdentityEvidence = true
    end

    if not hasIdentityEvidence then
        return nil
    end

    if modData.IsDTNPC then
        score = score + 20
    end

    return score
end

function DTNPCServerCore.GetZombiesByUUID(uuid, savedData)
    if not uuid then return {} end

    local cell = getCell()
    if not cell then return {} end

    local zombieList = cell:getZombieList()
    if not zombieList then return {} end

    savedData = savedData or getSavedData(uuid)

    local matches = {}
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        local score = scoreZombieForUUID(zombie, uuid, savedData)
        if score then
            table.insert(matches, { zombie = zombie, score = score })
        end
    end

    table.sort(matches, function(a, b)
        if a.score == b.score then
            return a.zombie:getPersistentOutfitID() < b.zombie:getPersistentOutfitID()
        end
        return a.score > b.score
    end)

    return matches
end

function DTNPCServerCore.PruneDuplicateZombies(uuid, savedData, preferredZombie, reason)
    if not uuid then return preferredZombie end

    local matches = DTNPCServerCore.GetZombiesByUUID(uuid, savedData)
    if #matches == 0 then
        return preferredZombie
    end

    local preferred = preferredZombie or matches[1].zombie
    local removed = 0

    for i = 1, #matches do
        local zombie = matches[i].zombie
        if zombie and zombie ~= preferred then
            local duplicateOutfitID = zombie:getPersistentOutfitID()
            zombie:removeFromWorld()
            zombie:removeFromSquare()
            if DTNPCServerCore.NotifyInstanceRemoval then
                DTNPCServerCore.NotifyInstanceRemoval(uuid, duplicateOutfitID)
            end
            removed = removed + 1
        end
    end

    if removed > 0 then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Repair",
            "Pruned " .. removed .. " duplicate zombie(s) for UUID: " .. tostring(uuid) ..
                " (" .. tostring(reason or "duplicate-prune") .. ")"
        )
    end

    return preferred
end

function DTNPCServerCore.FindZombieByUUID(uuid)
    if not uuid then return nil end

    local matches = DTNPCServerCore.GetZombiesByUUID(uuid, getSavedData(uuid))
    return matches[1] and matches[1].zombie or nil
end

function DTNPCServerCore.FindZombieByOutfitID(outfitID)
    if not outfitID then return nil end

    local cell = getCell()
    if not cell then return nil end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() and zombie:getPersistentOutfitID() == outfitID then
            return zombie
        end
    end
    
    return nil
end
