-- ==============================================================================
-- DTNPC_ZombieAggro_Stimulus.lua
-- Lightweight zombie nudges toward recent NPC combat without polluting threat caches.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

local Internal = DTNPC_ZombieAggro._internal
local runtime = Internal.runtime

local function nowMillis()
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

local function getSearchRadius()
    if DTNPCCombat and DTNPCCombat.GetMaxZombieAttractRadius then
        return math.max(
            DTNPC_ZombieAggro.CONFIG.ACQUIRE_RADIUS,
            tonumber(DTNPCCombat.GetMaxZombieAttractRadius()) or DTNPC_ZombieAggro.CONFIG.ACQUIRE_RADIUS
        )
    end

    return DTNPC_ZombieAggro.CONFIG.ACQUIRE_RADIUS
end

local function findNearestStimulus(zombie)
    if not zombie then
        return nil
    end

    local rt = runtime()
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local currentTime = nowMillis()
    local searchRadius = getSearchRadius()
    local bestEntry = nil
    local bestScore = nil
    local keys = Internal.getNeighborKeys and Internal.getNeighborKeys(zx, zy, searchRadius) or {}

    for i = 1, #keys do
        local bucket = rt.AttackableNPCGrid[keys[i]]
        if bucket then
            for _, entry in pairs(bucket) do
                if entry
                    and entry.zombie
                    and not entry.zombie:isDead()
                    and math.abs((entry.z or 0) - (zz or 0)) <= DTNPC_ZombieAggro.CONFIG.FLOOR_TOLERANCE then
                    local presence = DTNPCCombat and DTNPCCombat.GetPresence and DTNPCCombat.GetPresence(entry.npcData, currentTime) or nil
                    if presence and (tonumber(presence.radius) or 0) > 0 then
                        local dx = entry.x - zx
                        local dy = entry.y - zy
                        local distSq = (dx * dx) + (dy * dy)
                        local radius = tonumber(presence.radius) or 0
                        if distSq <= (radius * radius) then
                            local score = distSq / math.max(1.0, tonumber(presence.priority) or 1.0)
                            if bestScore == nil or score < bestScore then
                                bestScore = score
                                bestEntry = entry
                            end
                        end
                    end
                end
            end
        end
    end

    return bestEntry
end

function DTNPC_ZombieAggro.OnZombieProvoked(targetZombie, npcZombie)
    if not targetZombie or targetZombie:isDead() or not npcZombie then
        return false
    end

    if targetZombie.clearAggroList then
        targetZombie:clearAggroList()
    end
    if targetZombie.setTurnAlertedValues then
        targetZombie:setTurnAlertedValues(0, 0)
    end
    if targetZombie.setTargetSeenTime then
        targetZombie:setTargetSeenTime(60)
    end
    if targetZombie.pathToLocation then
        targetZombie:pathToLocation(npcZombie:getX(), npcZombie:getY(), npcZombie:getZ())
    end
    if targetZombie.faceLocation then
        targetZombie:faceLocation(npcZombie:getX(), npcZombie:getY())
    end

    return true
end

function DTNPC_ZombieAggro.ApplyCombatStimuli()
    local cell = getCell and getCell() or nil
    local zombieList = cell and cell:getZombieList() or nil
    if not zombieList then
        return
    end

    local rt = runtime()

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() then
            local modData = zombie:getModData()
            if not (modData and modData.IsDTNPC) then
                local zombieID = Internal.getZombieRuntimeID and Internal.getZombieRuntimeID(zombie) or nil
                if not (zombieID and rt.ZombieLeases[zombieID]) then
                    local entry = findNearestStimulus(zombie)
                    if entry then
                        if zombie.pathToLocation then
                            zombie:pathToLocation(entry.x, entry.y, entry.z)
                        end
                        if zombie.faceLocation then
                            zombie:faceLocation(entry.x, entry.y)
                        end
                        if zombie.setTargetSeenTime then
                            zombie:setTargetSeenTime(45)
                        end
                    end
                end
            end
        end
    end
end
