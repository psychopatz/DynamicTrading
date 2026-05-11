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
                DTNPCServerCore.NotifyInstanceRemoval(
                    uuid,
                    duplicateOutfitID,
                    DTNPCManager and DTNPCManager.GetPresenceRevision and DTNPCManager.GetPresenceRevision(savedData) or nil
                )
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

function DTNPCServerCore.FindZombieByBodyInstanceID(bodyInstanceID)
    if not bodyInstanceID then return nil end

    local cell = getCell()
    if not cell then return nil end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    local wantedBodyInstanceID = tostring(bodyInstanceID)
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() and tostring(zombie:getPersistentOutfitID()) == wantedBodyInstanceID then
            return zombie
        end
    end
    
    return nil
end

local function getBodyID(zombie)
    return zombie and zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or nil
end

local function getDataUUID(data)
    return type(data) == "table" and data.uuid or nil
end

local function hasDifferentNPCIdentity(modData, uuid)
    if not modData then
        return false
    end

    local wantedUUID = tostring(uuid)
    local modUUID = modData.DTNPC_UUID
    if modUUID and tostring(modUUID) ~= wantedUUID then
        return true
    end

    local embeddedUUID = getDataUUID(modData.DTNPC_Data or modData.DTNPCBrain)
    return embeddedUUID and tostring(embeddedUUID) ~= wantedUUID
end

local function getSavedCoords(savedData)
    if not savedData then
        return nil, nil, nil
    end

    return savedData.lastX or (savedData.homeCoords and savedData.homeCoords.x),
        savedData.lastY or (savedData.homeCoords and savedData.homeCoords.y),
        savedData.lastZ or (savedData.homeCoords and savedData.homeCoords.z) or 0
end

local function getPositionScore(zombie, savedData, radius)
    local sx, sy, sz = getSavedCoords(savedData)
    if not zombie or not sx or not sy then
        return nil
    end

    local dx = zombie:getX() - sx
    local dy = zombie:getY() - sy
    local dz = zombie:getZ() - sz
    local dist = math.sqrt(dx * dx + dy * dy)
    radius = tonumber(radius) or 1.25

    if math.abs(dz) > 1 or dist > radius then
        return nil
    end

    return math.max(1, math.floor((radius - dist) * 20) + 10)
end

local function scoreReusableWorldBody(zombie, uuid, savedData, options)
    if not zombie or zombie:isDead() or not uuid then
        return nil
    end

    if DTNPCManager and DTNPCManager.IsPhysicalWorldStatus then
        local savedStatus = savedData and savedData.status or nil
        if not DTNPCManager.IsPhysicalWorldStatus(savedStatus, savedData) then
            return nil
        end
    end

    local modData = zombie:getModData()
    if hasDifferentNPCIdentity(modData, uuid) then
        return nil
    end

    options = options or {}
    local score = scoreZombieForUUID(zombie, uuid, savedData) or 0
    local hasIdentityEvidence = score > 0
    local bodyID = getBodyID(zombie)
    local bodyIDText = bodyID and tostring(bodyID) or nil

    if savedData then
        if savedData.startupBodyInstanceHint and bodyIDText == tostring(savedData.startupBodyInstanceHint) then
            score = score + 70
            hasIdentityEvidence = true
        end
        if savedData.currentBodyInstanceID and bodyIDText == tostring(savedData.currentBodyInstanceID) then
            score = score + 60
            hasIdentityEvidence = true
        end
    end

    if options.allowPositionalMatch == true then
        local positionScore = getPositionScore(zombie, savedData, options.positionRadius)
        if positionScore then
            score = score + positionScore
        elseif not hasIdentityEvidence then
            return nil
        end
    elseif not hasIdentityEvidence then
        return nil
    end

    return score
end

function DTNPCServerCore.FindReusableWorldBody(uuid, savedData, options)
    if not uuid then return nil end

    local cell = getCell()
    if not cell then return nil end

    local zombieList = cell:getZombieList()
    if not zombieList then return nil end

    savedData = savedData or getSavedData(uuid)

    local matches = {}
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        local score = scoreReusableWorldBody(zombie, uuid, savedData, options)
        if score then
            table.insert(matches, { zombie = zombie, score = score })
        end
    end

    table.sort(matches, function(a, b)
        if a.score == b.score then
            return (tonumber(getBodyID(a.zombie)) or 0) < (tonumber(getBodyID(b.zombie)) or 0)
        end
        return a.score > b.score
    end)

    return matches[1] and matches[1].zombie or nil
end
