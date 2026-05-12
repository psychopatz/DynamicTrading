-- ==============================================================================
-- DTNPC_ProtectTargeting_ZombieSelection.lua
-- Zombie-only target selection for DTNPC protect behavior.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getZombieRuntimeID = Internal.getZombieRuntimeID
local hasLineOfSight = Internal.HasLineOfSight
local upsertZombieCandidate = Internal.UpsertZombieCandidate
local chooseBestZombieCandidates = Internal.ChooseBestZombieCandidates

local function getAnchorDistance(candidateX, candidateY, candidateZ, ax, ay, az)
    if ax == nil or ay == nil then
        return nil
    end
    if az ~= nil and math.abs(candidateZ - az) > DTNPCProtect.CONFIG.FloorTolerance then
        return 9999
    end

    local adx = candidateX - ax
    local ady = candidateY - ay
    return math.sqrt((adx * adx) + (ady * ady))
end

function DTNPCProtect.SelectNearestZombie(zombie, npcData, radius, anchorTarget, anchorRadius)
    if not zombie then
        return nil, 9999
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    local cachedTarget = nil
    local cachedDist = 9999
    local cachedTargetID = nil
    local isAuthoritativeSide = (not isClient()) or isServer()
    if isAuthoritativeSide and DTNPC_ZombieAggro and DTNPC_ZombieAggro.GetThreatTarget and npcData and npcData.uuid then
        cachedTarget, cachedDist = DTNPC_ZombieAggro.GetThreatTarget(npcData.uuid)
        if cachedTarget and cachedTarget.isDead and cachedTarget:isDead() then
            cachedTarget = nil
        elseif cachedTarget and hasLineOfSight and hasLineOfSight(zombie, cachedTarget) then
            cachedTargetID = getZombieRuntimeID(cachedTarget)
        else
            cachedTarget = nil
        end
    end

    local searchRadius = tonumber(radius) or DTNPCProtect.CONFIG.ScanRadius
    local keepRadius = searchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus
    local anchorSearchRadius = tonumber(anchorRadius)
    local anchorKeepRadius = anchorSearchRadius and (anchorSearchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus) or nil
    local zombieIndex = DTNPCProtect.GetZombieSpatialIndex and DTNPCProtect.GetZombieSpatialIndex(false) or nil
    if not zombieIndex then
        DTNPCProtect.ClearCombatTarget(npcData)
        return nil, 9999
    end

    local currentTarget = nil
    local currentDistance = 9999
    local nearestTarget = nil
    local nearestDistance = 9999
    local currentTargetID = npcData.combatTargetID or cachedTargetID
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local ax = anchorTarget and anchorTarget.getX and anchorTarget:getX() or nil
    local ay = anchorTarget and anchorTarget.getY and anchorTarget:getY() or nil
    local az = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or nil
    local candidates = {}
    local candidateMap = {}
    local immediateRadius = tonumber(DTNPCProtect.CONFIG.MeleeImmediateThreatRadius) or 2.2
    local stickyBreak = tonumber(DTNPCProtect.CONFIG.MeleeImmediateThreatStickyBreak) or 0.65
    local immediateTarget = nil
    local immediateDistance = 9999

    local queryRadius = math.max(searchRadius, keepRadius, immediateRadius)
    DTNPCSpatialCache.ForEachNearby(zombieIndex, zx, zy, queryRadius, function(entry, key)
        local candidate = entry and entry.candidate or nil
        if not candidate or candidate == zombie or candidate:isDead() then
            if key then
                DTNPCSpatialCache.Remove(zombieIndex, key)
            end
            return false
        end
        if math.abs((candidate:getZ() or 0) - zz) > DTNPCProtect.CONFIG.FloorTolerance then
            return false
        end
        if not (hasLineOfSight and hasLineOfSight(zombie, candidate)) then
            return false
        end

        local candidateX = candidate:getX()
        local candidateY = candidate:getY()
        local candidateZ = candidate:getZ() or 0
        local dx = candidateX - zx
        local dy = candidateY - zy
        local dist = math.sqrt((dx * dx) + (dy * dy))
        local candidateID = getZombieRuntimeID(candidate)
        local anchorDist = getAnchorDistance(candidateX, candidateY, candidateZ, ax, ay, az)
        local withinAnchorAcquire = anchorSearchRadius == nil
            or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
        local withinAnchorKeep = anchorKeepRadius == nil
            or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

        if withinAnchorAcquire and dist <= immediateRadius and dist < immediateDistance then
            immediateTarget = candidate
            immediateDistance = dist
        end

        if (dist <= searchRadius and withinAnchorAcquire)
            or (currentTargetID and candidateID == currentTargetID and dist <= keepRadius and withinAnchorKeep) then
            upsertZombieCandidate(candidates, candidateMap, {
                candidate = candidate,
                id = candidateID,
                x = candidateX,
                y = candidateY,
                z = candidateZ,
                dist = dist,
                acquire = dist <= searchRadius and withinAnchorAcquire,
                keep = currentTargetID and candidateID == currentTargetID and dist <= keepRadius and withinAnchorKeep or false,
                isCurrent = currentTargetID and candidateID == currentTargetID or false,
            })
        end

        return false
    end)

    local chosenCurrent, chosenNearest = chooseBestZombieCandidates(candidates, currentTargetID)
    if chosenCurrent then
        currentTarget = chosenCurrent.candidate
        currentDistance = chosenCurrent.dist
    end
    if chosenNearest then
        nearestTarget = chosenNearest.candidate
        nearestDistance = chosenNearest.dist
    end

    if not immediateTarget and nearestTarget and nearestDistance <= immediateRadius then
        if not currentTarget or currentDistance > (nearestDistance + stickyBreak) then
            immediateTarget = nearestTarget
            immediateDistance = nearestDistance
        end
    elseif immediateTarget and currentTarget and currentDistance <= (immediateDistance + stickyBreak) then
        immediateTarget = nil
        immediateDistance = 9999
    end

    local chosen = immediateTarget or currentTarget or nearestTarget
    local distance = immediateTarget and immediateDistance
        or (currentTarget and currentDistance or nearestDistance)
    if cachedTarget and not immediateTarget then
        if not chosen and cachedDist <= searchRadius then
            chosen = cachedTarget
            distance = cachedDist
        elseif chosen and cachedDist <= immediateRadius and cachedDist + stickyBreak < distance then
            chosen = cachedTarget
            distance = cachedDist
        end
    end
    if chosen then
        npcData.combatTargetID = getZombieRuntimeID(chosen)
        return chosen, distance
    end

    DTNPCProtect.ClearCombatTarget(npcData)
    return nil, 9999
end
