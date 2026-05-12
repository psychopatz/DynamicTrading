-- ==============================================================================
-- DTNPC_Hostility_AttackSimulation.lua
-- Lightweight contact cues for zombies pressuring DT NPC bodies.
-- ==============================================================================

DTNPCHostility = DTNPCHostility or {}

local Hostility = DTNPCHostility
local Internal = Hostility.Internal or {}

Hostility.Internal = Internal
Hostility.ContactState = Hostility.ContactState or {}

local CONTACT_RADIUS_SQ = 0.64
local CONTACT_HEIGHT_TOLERANCE = 0.5
local CONTACT_ENTRY_EXPIRE_MS = 5000
local CONTACT_CLEANUP_INTERVAL_MS = 10000

local function nowMillis()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end
    return 0
end

local function getZombieRuntimeID(zombie)
    if not zombie then
        return nil
    end
    if zombie.getPersistentOutfitID then
        local outfitID = zombie:getPersistentOutfitID()
        if outfitID and outfitID ~= 0 then
            return "outfit:" .. tostring(outfitID)
        end
    end
    if zombie.getID then
        local objectID = zombie:getID()
        if objectID and objectID ~= 0 then
            return "id:" .. tostring(objectID)
        end
    end
    return tostring(zombie)
end

local function getContactCooldownMs()
    local tickCooldown = DTNPC_ZombieAggro
        and DTNPC_ZombieAggro.CONFIG
        and tonumber(DTNPC_ZombieAggro.CONFIG.HIT_COOLDOWN_TICKS)
        or 20
    return math.max(350, math.floor(tickCooldown * 33))
end

local function playContactCue(zombie)
    if not zombie or zombie:isDead() then
        return
    end

    local soundName = ZombRand(2) == 0 and "ZombieBite" or "ZombieScratch"
    if zombie.playSound then
        zombie:playSound(soundName)
        return
    end

    local square = zombie.getSquare and zombie:getSquare() or nil
    if square and getSoundManager and getSoundManager() then
        getSoundManager():PlayWorldSound(soundName, square, 0, 5, 1.0, false)
    end
end

local function cleanupContactState(currentTime)
    if (Hostility._lastContactCleanupAt or 0) > 0
        and (currentTime - (Hostility._lastContactCleanupAt or 0)) < CONTACT_CLEANUP_INTERVAL_MS then
        return
    end

    Hostility._lastContactCleanupAt = currentTime
    for zombieID, entry in pairs(Hostility.ContactState) do
        if currentTime - (tonumber(entry.lastCueAt) or 0) > CONTACT_ENTRY_EXPIRE_MS then
            Hostility.ContactState[zombieID] = nil
        end
    end
end

local function resolveDTTarget(zombie)
    local target = zombie and zombie:getTarget() or nil
    if not target then
        return nil
    end

    if Internal.HostilityIsBanditsManagedTarget and Internal.HostilityIsBanditsManagedTarget(target) then
        return nil
    end

    local entry = Hostility.GetClientTargetEntry and Hostility.GetClientTargetEntry(target) or nil
    if entry and entry.zombie and not entry.zombie:isDead() then
        return entry.zombie
    end

    if Hostility.UpsertClientTarget and Hostility.UpsertClientTarget(target) then
        entry = Hostility.GetClientTargetEntry and Hostility.GetClientTargetEntry(target) or nil
        if entry and entry.zombie and not entry.zombie:isDead() then
            return entry.zombie
        end
    end

    return nil
end

function Hostility.UpdateAttackSimulation(zombie)
    if Internal.HostilityShouldIgnoreZombieForTargeting
        and Internal.HostilityShouldIgnoreZombieForTargeting(zombie) then
        return
    end

    local target = resolveDTTarget(zombie)
    if not target then
        return
    end

    if target:isDead() then
        if zombie.setEatBodyTarget then
            zombie:setEatBodyTarget(target, true)
        end
        Hostility.RemoveClientTarget(target)
        return
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    local distSq = (dx * dx) + (dy * dy)
    if distSq > CONTACT_RADIUS_SQ or math.abs((target:getZ() or 0) - (zombie:getZ() or 0)) > CONTACT_HEIGHT_TOLERANCE then
        return
    end

    if zombie.isFacingObject and not zombie:isFacingObject(target, 0.35) then
        if zombie.faceThisObject then
            zombie:faceThisObject(target)
        elseif zombie.faceLocation then
            zombie:faceLocation(target:getX(), target:getY())
        end
        return
    end

    local currentTime = nowMillis()
    cleanupContactState(currentTime)

    local zombieID = getZombieRuntimeID(zombie)
    local entry = Hostility.ContactState[zombieID]
    if type(entry) ~= "table" then
        entry = {}
        Hostility.ContactState[zombieID] = entry
    end

    local cooldownMs = getContactCooldownMs()
    if currentTime - (tonumber(entry.lastCueAt) or 0) < cooldownMs then
        return
    end

    entry.lastCueAt = currentTime
    playContactCue(zombie)
end
