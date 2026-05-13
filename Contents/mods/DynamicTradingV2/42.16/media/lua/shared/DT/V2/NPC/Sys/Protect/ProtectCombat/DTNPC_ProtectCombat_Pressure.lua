-- ==============================================================================
-- DTNPC_ProtectCombat_Pressure.lua
-- Shared crowd pressure and combat rhythm helpers for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getPlayerRuntimeID = Internal.getPlayerRuntimeID
local getThreatPlayers = Internal.GetThreatPlayers
local isHostilePlayerForNPC = Internal.IsHostilePlayerForNPC
local getDTNPCDataFromZombie = Internal.GetDTNPCDataFromZombie
local isDTNPCHostileToNPC = Internal.IsDTNPCHostileToNPC

Internal.ProtectCombatRhythmResetMs = 4500

local ZOMBIE_SCAN_CACHE_REBUILD_MS = 150

local function rollInt(minValue, maxValue)
    local safeMin = math.floor(tonumber(minValue) or 0)
    local safeMax = math.floor(tonumber(maxValue) or safeMin)
    if safeMax < safeMin then
        safeMax = safeMin
    end
    if safeMax <= safeMin then
        return safeMin
    end
    return safeMin + ZombRand((safeMax - safeMin) + 1)
end

local function getTimeMs()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function ensureZombieSpatialIndex()
    Internal.ProtectZombieSpatialIndex = Internal.ProtectZombieSpatialIndex or (
        DTNPCSpatialCache and DTNPCSpatialCache.New and DTNPCSpatialCache.New({
            cellSize = 8,
        })
    ) or nil

    return Internal.ProtectZombieSpatialIndex
end

local function isZombieSpatialCandidate(candidate)
    if not candidate or candidate:isDead() then
        return false
    end

    local modData = candidate:getModData()
    return not (modData and modData.IsDTNPC)
end

local function rebuildZombieSpatialIndex(force)
    local index = ensureZombieSpatialIndex()
    if not index then
        return nil
    end

    local currentTime = getTimeMs()
    if force ~= true
        and index.lastRebuildAt
        and index.lastRebuildAt > 0
        and (currentTime - index.lastRebuildAt) < ZOMBIE_SCAN_CACHE_REBUILD_MS then
        return index
    end

    DTNPCSpatialCache.Clear(index)
    index.needsFullRebuild = false

    local cell = getCell and getCell() or nil
    local zombieList = cell and cell:getZombieList() or nil
    if zombieList then
        for i = 0, zombieList:size() - 1 do
            local candidate = zombieList:get(i)
            if isZombieSpatialCandidate(candidate) then
                local candidateID = getZombieRuntimeID(candidate)
                if candidateID then
                    DTNPCSpatialCache.Upsert(index, candidateID, {
                        candidate = candidate,
                        x = candidate:getX(),
                        y = candidate:getY(),
                        z = candidate:getZ() or 0,
                    })
                end
            end
        end
    end

    index.lastRebuildAt = currentTime
    return index
end

local function getNearbyZombiePressure(originX, originY, originZ, radius, excludedIDs)
    local index = rebuildZombieSpatialIndex(false)
    if not index then
        return {
            count = 0,
            closest = 9999,
            centerX = originX,
            centerY = originY,
        }
    end

    local safeRadius = math.max(0.25, tonumber(radius) or DTNPCProtect.CONFIG.MeleeCrowdDangerRadius or 2.4)
    local radiusSq = safeRadius * safeRadius
    local count = 0
    local closest = 9999
    local weightedX = 0
    local weightedY = 0
    local totalWeight = 0

    DTNPCSpatialCache.ForEachNearby(index, originX, originY, safeRadius, function(entry, key)
        local candidate = entry and entry.candidate or nil
        if not candidate or candidate:isDead() then
            DTNPCSpatialCache.Remove(index, key)
            return false
        end
        if math.abs((candidate:getZ() or 0) - (originZ or 0)) > DTNPCProtect.CONFIG.FloorTolerance then
            return false
        end
        if excludedIDs and excludedIDs[key] then
            return false
        end

        local dx = candidate:getX() - originX
        local dy = candidate:getY() - originY
        local distSq = (dx * dx) + (dy * dy)
        if distSq <= radiusSq then
            local dist = math.sqrt(distSq)
            local weight = 1 / math.max(0.25, dist)
            count = count + 1
            closest = math.min(closest, dist)
            weightedX = weightedX + (candidate:getX() * weight)
            weightedY = weightedY + (candidate:getY() * weight)
            totalWeight = totalWeight + weight
        end

        return false
    end)

    return {
        count = count,
        closest = closest,
        centerX = totalWeight > 0 and (weightedX / totalWeight) or originX,
        centerY = totalWeight > 0 and (weightedY / totalWeight) or originY,
    }
end

local function getNearbyHostilePressure(originX, originY, originZ, radius, npcData, excludedIDs)
    local safeRadius = math.max(0.25, tonumber(radius) or DTNPCProtect.CONFIG.MeleeCrowdDangerRadius or 2.4)
    local radiusSq = safeRadius * safeRadius
    local count = 0
    local closest = 9999
    local weightedX = 0
    local weightedY = 0
    local totalWeight = 0

    if npcData and getThreatPlayers and isHostilePlayerForNPC then
        local players = getThreatPlayers() or {}
        for i = 1, #players do
            local player = players[i]
            if player
                and not player:isDead()
                and math.abs((player:getZ() or 0) - (originZ or 0)) <= DTNPCProtect.CONFIG.FloorTolerance
                and isHostilePlayerForNPC(npcData, player) then
                local candidateID = getPlayerRuntimeID and getPlayerRuntimeID(player) or tostring(player)
                if not (excludedIDs and excludedIDs[candidateID]) then
                    local dx = player:getX() - originX
                    local dy = player:getY() - originY
                    local distSq = (dx * dx) + (dy * dy)
                    if distSq <= radiusSq then
                        local dist = math.sqrt(distSq)
                        local weight = 1 / math.max(0.25, dist)
                        count = count + 1
                        closest = math.min(closest, dist)
                        weightedX = weightedX + (player:getX() * weight)
                        weightedY = weightedY + (player:getY() * weight)
                        totalWeight = totalWeight + weight
                    end
                end
            end
        end
    end

    local zombieList = getCell and getCell() and getCell():getZombieList() or nil
    if zombieList and npcData then
        for i = 0, zombieList:size() - 1 do
            local candidate = zombieList:get(i)
            if candidate and not candidate:isDead() then
                local candidateZ = candidate:getZ() or 0
                if math.abs(candidateZ - (originZ or 0)) <= DTNPCProtect.CONFIG.FloorTolerance then
                    local modData = candidate:getModData()
                    local candidateID = nil
                    local hostile = false

                    if modData and modData.IsDTNPC == true then
                        local targetData = nil
                        local targetUUID = nil
                        if getDTNPCDataFromZombie then
                            targetData, targetUUID = getDTNPCDataFromZombie(candidate)
                        end
                        if targetData and targetUUID and targetUUID ~= npcData.uuid and isDTNPCHostileToNPC then
                            hostile = isDTNPCHostileToNPC(npcData, targetData) == true
                            candidateID = "dtnpc:" .. tostring(targetUUID)
                        end
                    elseif DTModPatchesBandits
                        and DTModPatchesBandits.ShouldBanditsNPCBeHostileToDTNPC
                        and DTModPatchesBandits.ShouldBanditsNPCBeHostileToDTNPC(candidate, npcData) then
                        hostile = true
                        candidateID = DTModPatchesBandits.BuildBanditsCombatTargetID
                            and DTModPatchesBandits.BuildBanditsCombatTargetID(candidate)
                            or getZombieRuntimeID(candidate)
                    end

                    if hostile and candidateID and not (excludedIDs and excludedIDs[candidateID]) then
                        local dx = candidate:getX() - originX
                        local dy = candidate:getY() - originY
                        local distSq = (dx * dx) + (dy * dy)
                        if distSq <= radiusSq then
                            local dist = math.sqrt(distSq)
                            local weight = 1 / math.max(0.25, dist)
                            count = count + 1
                            closest = math.min(closest, dist)
                            weightedX = weightedX + (candidate:getX() * weight)
                            weightedY = weightedY + (candidate:getY() * weight)
                            totalWeight = totalWeight + weight
                        end
                    end
                end
            end
        end
    end

    return {
        count = count,
        closest = closest,
        centerX = totalWeight > 0 and (weightedX / totalWeight) or originX,
        centerY = totalWeight > 0 and (weightedY / totalWeight) or originY,
    }
end

function DTNPCProtect.GetNearbyZombiePressure(zombie, radius, excludedIDs)
    if not zombie then
        return {
            count = 0,
            closest = 9999,
            centerX = 0,
            centerY = 0,
        }
    end

    return getNearbyZombiePressure(zombie:getX(), zombie:getY(), zombie:getZ(), radius, excludedIDs)
end

function DTNPCProtect.RebuildZombieSpatialIndex(force)
    return rebuildZombieSpatialIndex(force == true)
end

function DTNPCProtect.GetZombieSpatialIndex(force)
    return rebuildZombieSpatialIndex(force == true)
end

function DTNPCProtect.GetNearbyHostilePressure(zombie, npcData, radius, excludedIDs)
    if not zombie or not npcData then
        return {
            count = 0,
            closest = 9999,
            centerX = zombie and zombie:getX() or 0,
            centerY = zombie and zombie:getY() or 0,
        }
    end

    return getNearbyHostilePressure(zombie:getX(), zombie:getY(), zombie:getZ(), radius, npcData, excludedIDs)
end

local function resolveCombatTargetKey(target)
    if not target then
        return nil
    end
    if instanceof and instanceof(target, "IsoPlayer") then
        return getPlayerRuntimeID and getPlayerRuntimeID(target) or tostring(target)
    end
    return getZombieRuntimeID and getZombieRuntimeID(target) or tostring(target)
end

local function getCombatRhythmBucket(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local rhythm = type(npcData._combatRhythm) == "table" and npcData._combatRhythm or {}
    npcData._combatRhythm = rhythm

    if type(rhythm.flavorTimes) ~= "table" then
        rhythm.flavorTimes = {}
    end

    return rhythm
end

local function recordLinkedWorkerCombatAttack(npcData, attackType)
    if not npcData or not npcData.linkedWorkerID then
        return false
    end

    local colony = type(DC_Colony) == "table" and DC_Colony or nil
    local companion = colony and type(colony.Companion) == "table" and colony.Companion or nil
    if not companion or type(companion.RecordCombatAttack) ~= "function" then
        return false
    end

    local ok = pcall(function()
        companion.RecordCombatAttack(npcData.linkedWorkerID, npcData, attackType, {
            source = "DTNPCProtect",
        })
    end)

    return ok == true
end

local function resetCombatRhythmBucket(rhythm)
    if not rhythm then
        return
    end

    rhythm.targetKey = nil
    rhythm.attackType = nil
    rhythm.burstCount = 0
    rhythm.burstLimit = nil
    rhythm.recoveryUntil = 0
    rhythm.recoveryDistance = nil
    rhythm.lastAttackAt = 0
end

Internal.ProtectCombatRollInt = rollInt
Internal.RebuildZombieSpatialIndex = rebuildZombieSpatialIndex
Internal.GetZombieSpatialIndex = ensureZombieSpatialIndex
Internal.GetNearbyZombiePressureAt = getNearbyZombiePressure
Internal.GetNearbyHostilePressureAt = getNearbyHostilePressure
Internal.ResolveCombatTargetKey = resolveCombatTargetKey
Internal.GetCombatRhythmBucket = getCombatRhythmBucket
Internal.RecordLinkedWorkerCombatAttack = recordLinkedWorkerCombatAttack
Internal.ResetCombatRhythmBucket = resetCombatRhythmBucket
