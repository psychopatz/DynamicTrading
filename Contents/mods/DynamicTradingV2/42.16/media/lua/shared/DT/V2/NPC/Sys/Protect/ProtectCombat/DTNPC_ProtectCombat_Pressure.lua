-- ==============================================================================
-- DTNPC_ProtectCombat_Pressure.lua
-- Shared crowd pressure and combat rhythm helpers for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getPlayerRuntimeID = Internal.getPlayerRuntimeID

Internal.ProtectCombatRhythmResetMs = 4500

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

local function getNearbyZombiePressure(originX, originY, originZ, radius, excludedIDs)
    local zombieList = getCell() and getCell():getZombieList() or nil
    if not zombieList then
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

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC)
                and math.abs((candidate:getZ() or 0) - (originZ or 0)) <= DTNPCProtect.CONFIG.FloorTolerance then
                local candidateID = getZombieRuntimeID(candidate)
                if not (excludedIDs and excludedIDs[candidateID]) then
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
Internal.GetNearbyZombiePressureAt = getNearbyZombiePressure
Internal.ResolveCombatTargetKey = resolveCombatTargetKey
Internal.GetCombatRhythmBucket = getCombatRhythmBucket
Internal.RecordLinkedWorkerCombatAttack = recordLinkedWorkerCombatAttack
Internal.ResetCombatRhythmBucket = resetCombatRhythmBucket
