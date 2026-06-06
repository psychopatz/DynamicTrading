-- ==============================================================================
-- DTNPC_Hostility_ZombieTargeting.lua
-- DT-only cached zombie targeting toward Dynamic Trading NPC bodies.
-- ==============================================================================

DTNPCHostility = DTNPCHostility or {}

local Hostility = DTNPCHostility
local Internal = Hostility.Internal or {}

Hostility.Internal = Internal
Hostility.ClientCache = Hostility.ClientCache or {
    entriesByUUID = {},
    entriesByBodyID = {},
    spatialIndex = (DTNPCSpatialCache and DTNPCSpatialCache.New and DTNPCSpatialCache.New({
        cellSize = 8,
    })) or nil,
    lastRebuildAt = 0,
    needsFullRebuild = true,
}

local CACHE_CELL_SIZE = 8
local FLOOR_TOLERANCE = 1
local TARGET_RADIUS = 10
local KEEP_RADIUS = 12
local PLAYER_STICKY_DIST_SQ = 25.0

local function nowMillis()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end
    return 0
end

local function isObject(value)
    local valueType = type(value)
    return valueType == "userdata" or valueType == "table"
end

local function getZombieModData(zombie)
    if not zombie or not zombie.getModData then
        return nil
    end
    return zombie:getModData()
end

local function getZombieBodyID(zombie)
    if not zombie then
        return nil
    end
    if zombie.getPersistentOutfitID then
        local outfitID = zombie:getPersistentOutfitID()
        if outfitID and outfitID ~= 0 then
            return tostring(outfitID)
        end
    end
    if zombie.getID then
        local objectID = zombie:getID()
        if objectID and objectID ~= 0 then
            return "id:" .. tostring(objectID)
        end
    end
    return nil
end

local function getFloorTolerance()
    if DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.FloorTolerance then
        return tonumber(DTNPCProtect.CONFIG.FloorTolerance) or FLOOR_TOLERANCE
    end
    return FLOOR_TOLERANCE
end

local function getAcquireRadius()
    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.CONFIG and DTNPC_ZombieAggro.CONFIG.ACQUIRE_RADIUS then
        return tonumber(DTNPC_ZombieAggro.CONFIG.ACQUIRE_RADIUS) or TARGET_RADIUS
    end
    return TARGET_RADIUS
end

local function getKeepRadius()
    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.CONFIG and DTNPC_ZombieAggro.CONFIG.KEEP_RADIUS then
        return tonumber(DTNPC_ZombieAggro.CONFIG.KEEP_RADIUS) or KEEP_RADIUS
    end
    return KEEP_RADIUS
end

local function isBanditsManagedTarget(target)
    if not target then
        return false
    end
    if target.getVariableBoolean and target:getVariableBoolean("Bandit") then
        return true
    end
    if DTModPatchesBandits and DTModPatchesBandits.IsBanditsNPC then
        return DTModPatchesBandits.IsBanditsNPC(target) == true
    end
    return false
end

local function isDTNPCBody(zombie)
    local modData = getZombieModData(zombie)
    return modData and (modData.IsDTNPC == true or modData.DTNPC_UUID ~= nil) or false
end

local function shouldIgnoreZombieForTargeting(zombie)
    if not zombie or zombie:isDead() then
        return true
    end
    if zombie.getVariableBoolean and zombie:getVariableBoolean("Bandit") then
        return true
    end
    return isDTNPCBody(zombie)
end

local function isAttackableClientTarget(zombie, npcData)
    if not zombie or zombie:isDead() or isBanditsManagedTarget(zombie) then
        return false, nil
    end

    local modData = getZombieModData(zombie)
    npcData = npcData or (modData and (modData.DTNPC_Data or modData.DTNPCBrain)) or nil

    if not (modData and (modData.IsDTNPC == true or modData.DTNPC_UUID ~= nil or npcData ~= nil)) then
        return false, nil
    end

    if not npcData then
        return true, nil
    end

    if npcData.status == "Dead" or npcData.status == "Away" then
        return false, npcData
    end
    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return false, npcData
    end
    if npcData.state == "Departure" then
        return false, npcData
    end

    return true, npcData
end

local function ensureSpatialIndex()
    local cache = Hostility.ClientCache
    if DTNPCSpatialCache and DTNPCSpatialCache.New and not cache.spatialIndex then
        cache.spatialIndex = DTNPCSpatialCache.New({
            cellSize = CACHE_CELL_SIZE,
        })
    end
    return cache.spatialIndex
end

local function clearEntryReferences(entry)
    if not entry then
        return
    end

    local cache = Hostility.ClientCache
    local spatialIndex = ensureSpatialIndex()
    if entry.uuid then
        cache.entriesByUUID[entry.uuid] = nil
    end
    if entry.bodyID then
        cache.entriesByBodyID[entry.bodyID] = nil
    end
    if spatialIndex and entry.uuid then
        DTNPCSpatialCache.Remove(spatialIndex, entry.uuid)
    end
end

local function attachEntry(entry)
    if not entry then
        return
    end

    local cache = Hostility.ClientCache
    local spatialIndex = ensureSpatialIndex()
    if entry.uuid then
        cache.entriesByUUID[entry.uuid] = entry
    end
    if entry.bodyID then
        cache.entriesByBodyID[entry.bodyID] = entry
    end
    if spatialIndex and entry.uuid then
        DTNPCSpatialCache.Upsert(spatialIndex, entry.uuid, entry)
    end
end

function Hostility.GetClientTargetEntry(target)
    if not target then
        return nil
    end

    local cache = Hostility.ClientCache
    local modData = getZombieModData(target)
    local uuid = modData and modData.DTNPC_UUID or nil
    if uuid and cache.entriesByUUID[uuid] then
        return cache.entriesByUUID[uuid]
    end

    local bodyID = getZombieBodyID(target)
    if bodyID and cache.entriesByBodyID[bodyID] then
        return cache.entriesByBodyID[bodyID]
    end

    return nil
end

function Hostility.RemoveClientTarget(zombieOrUUID)
    local entry = nil

    if isObject(zombieOrUUID) then
        entry = Hostility.GetClientTargetEntry(zombieOrUUID)
    elseif type(zombieOrUUID) == "string" then
        entry = Hostility.ClientCache.entriesByUUID[zombieOrUUID]
            or Hostility.ClientCache.entriesByBodyID[zombieOrUUID]
    end

    if not entry then
        return false
    end

    clearEntryReferences(entry)
    return true
end

function Hostility.UpsertClientTarget(zombie, npcData)
    local valid, resolvedData = isAttackableClientTarget(zombie, npcData)
    if not valid then
        Hostility.RemoveClientTarget(zombie)
        return false
    end

    npcData = resolvedData or npcData
    local modData = getZombieModData(zombie)
    local uuid = npcData and npcData.uuid or (modData and modData.DTNPC_UUID) or nil
    if not uuid then
        return false
    end

    local bodyID = getZombieBodyID(zombie)
    local cache = Hostility.ClientCache
    local entry = cache.entriesByUUID[uuid]
        or (bodyID and cache.entriesByBodyID[bodyID])
        or {}

    clearEntryReferences(entry)

    local x = zombie:getX()
    local y = zombie:getY()
    entry.uuid = uuid
    entry.bodyID = bodyID
    entry.zombie = zombie
    entry.npcData = npcData
    entry.x = x
    entry.y = y
    entry.z = zombie:getZ()
    entry.updatedAt = nowMillis()

    attachEntry(entry)
    cache.needsFullRebuild = false
    return true
end

function Hostility.RebuildClientTargetCache()
    local cache = Hostility.ClientCache
    local spatialIndex = ensureSpatialIndex()
    cache.entriesByUUID = {}
    cache.entriesByBodyID = {}
    if spatialIndex then
        DTNPCSpatialCache.Clear(spatialIndex)
        spatialIndex.needsFullRebuild = false
    end

    local count = 0
    local cell = getCell and getCell() or nil
    local zombieList = cell and cell:getZombieList() or nil
    if zombieList then
        for i = 0, zombieList:size() - 1 do
            local zombie = zombieList:get(i)
            if Hostility.UpsertClientTarget(zombie) then
                count = count + 1
            end
        end
    end

    cache.lastRebuildAt = nowMillis()
    cache.needsFullRebuild = false
    return count
end

local function maybeRebuildClientCache(force)
    local cache = Hostility.ClientCache
    if force == true or cache.needsFullRebuild == true then
        Hostility.RebuildClientTargetCache()
    end
end

function Hostility.FindNearestClientTarget(zombie, radius)
    if shouldIgnoreZombieForTargeting(zombie) then
        return nil, 9999
    end

    maybeRebuildClientCache(false)

    local safeRadius = math.max(0.25, tonumber(radius) or getAcquireRadius())
    local radiusSq = safeRadius * safeRadius
    local floorTolerance = getFloorTolerance()
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local spatialIndex = ensureSpatialIndex()
    if not spatialIndex then
        return nil, 9999
    end

    local bestEntry, bestDistance = DTNPCSpatialCache.FindNearest(
        spatialIndex,
        zx,
        zy,
        zz,
        safeRadius,
        {
            floorTolerance = floorTolerance,
            predicate = function(entry)
                local candidate = entry and entry.zombie or nil
                if not candidate or candidate:isDead() then
                    Hostility.RemoveClientTarget(entry and (entry.uuid or entry.bodyID) or nil)
                    return false
                end
                local entryValid = isAttackableClientTarget(candidate, entry.npcData)
                if entryValid ~= true then
                    Hostility.RemoveClientTarget(entry and (entry.uuid or entry.bodyID) or nil)
                    return false
                end
                local dx = candidate:getX() - zx
                local dy = candidate:getY() - zy
                local distSq = (dx * dx) + (dy * dy)
                return distSq <= radiusSq
            end,
        }
    )

    return bestEntry, bestDistance or 9999
end

local function setZombieNoLungeAttack(zombie, enabled)
    if zombie and zombie.setVariable then
        zombie:setVariable("NoLungeAttack", enabled == true)
    end
end

local function isVeryCloseLivePlayerTarget(zombie, target)
    if not zombie or not target or not instanceof or not instanceof(target, "IsoPlayer") then
        return false
    end
    if target.getVariableBoolean and target:getVariableBoolean("Bandit") then
        return false
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return ((dx * dx) + (dy * dy)) < PLAYER_STICKY_DIST_SQ
end

local function getRetainedTargetEntry(zombie, target)
    if not target then
        return nil, 9999
    end

    local entry = Hostility.GetClientTargetEntry(target)
    if not entry or not entry.zombie or entry.zombie:isDead() then
        return nil, 9999
    end

    local keepRadius = getKeepRadius()
    local dx = entry.zombie:getX() - zombie:getX()
    local dy = entry.zombie:getY() - zombie:getY()
    local distSq = (dx * dx) + (dy * dy)
    if distSq > (keepRadius * keepRadius) then
        return nil, 9999
    end

    if math.abs((entry.zombie:getZ() or 0) - (zombie:getZ() or 0)) > getFloorTolerance() then
        return nil, 9999
    end

    return entry, math.sqrt(distSq)
end

function Hostility.UpdateZombieTargeting(zombie)
    if shouldIgnoreZombieForTargeting(zombie) then
        return
    end

    local target = zombie:getTarget()
    if isBanditsManagedTarget(target) then
        return
    end

    if isVeryCloseLivePlayerTarget(zombie, target) then
        setZombieNoLungeAttack(zombie, false)
        return
    end

    local retainedEntry, retainedDist = getRetainedTargetEntry(zombie, target)
    local selectedEntry = retainedEntry
    local selectedDist = retainedDist

    if not selectedEntry then
        selectedEntry, selectedDist = Hostility.FindNearestClientTarget(zombie, getAcquireRadius())
    end

    if not selectedEntry or not selectedEntry.zombie then
        setZombieNoLungeAttack(zombie, false)
        return
    end

    local targetZombie = selectedEntry.zombie
    if targetZombie and zombie.pathToLocation then
        zombie:pathToLocation(targetZombie:getX(), targetZombie:getY(), targetZombie:getZ())
    elseif targetZombie and zombie.pathToCharacter then
        zombie:pathToCharacter(targetZombie)
    end
    if zombie.setTarget then
        zombie:setTarget(nil)
    end

    setZombieNoLungeAttack(zombie, selectedDist <= getKeepRadius())
end

Internal.HostilityIsBanditsManagedTarget = isBanditsManagedTarget
Internal.HostilityMaybeRebuildClientCache = maybeRebuildClientCache
Internal.HostilityShouldIgnoreZombieForTargeting = shouldIgnoreZombieForTargeting
