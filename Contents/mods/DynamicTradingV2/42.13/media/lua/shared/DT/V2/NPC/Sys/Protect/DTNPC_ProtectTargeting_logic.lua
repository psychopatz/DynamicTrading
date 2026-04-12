-- ==============================================================================
-- DTNPC_ProtectTargeting_logic.lua
-- Threat scanning and target selection logic for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getPlayerRuntimeID = Internal.getPlayerRuntimeID
local isFriendlyAuthorityPlayer = Internal.isFriendlyAuthorityPlayer

local function upsertZombieCandidate(candidates, candidateMap, entry)
    local key = entry and entry.id
    if not key then
        return
    end

    local index = candidateMap[key]
    if index then
        local existing = candidates[index]
        existing.dist = math.min(existing.dist, entry.dist)
        existing.acquire = existing.acquire or entry.acquire
        existing.keep = existing.keep or entry.keep
        existing.isCurrent = existing.isCurrent or entry.isCurrent
        return
    end

    candidates[#candidates + 1] = entry
    candidateMap[key] = #candidates
end

local function getZombieCandidateCrowdStats(candidates, candidateIndex)
    local radius = tonumber(DTNPCProtect.CONFIG.MeleeCrowdRadius) or 1.8
    local radiusSq = radius * radius
    local candidate = candidates[candidateIndex]
    local count = 0
    local closest = 9999

    if not candidate then
        return 0, closest
    end

    for i = 1, #candidates do
        if i ~= candidateIndex then
            local other = candidates[i]
            local dx = other.x - candidate.x
            local dy = other.y - candidate.y
            local distSq = (dx * dx) + (dy * dy)
            if distSq <= radiusSq then
                local dist = math.sqrt(distSq)
                count = count + 1
                if dist < closest then
                    closest = dist
                end
            end
        end
    end

    return count, closest
end

local function getZombieCandidateScore(candidates, candidateIndex)
    local candidate = candidates[candidateIndex]
    if not candidate then
        return 9999
    end

    local crowdCount, crowdClosest = getZombieCandidateCrowdStats(candidates, candidateIndex)
    candidate.crowdCount = crowdCount
    candidate.crowdClosest = crowdClosest

    local score = candidate.dist
    local crowdPenalty = tonumber(DTNPCProtect.CONFIG.MeleeCrowdPenalty) or 0.8
    local closestPenalty = tonumber(DTNPCProtect.CONFIG.MeleeCrowdClosestPenalty) or 0.7
    score = score + (math.max(0, crowdCount - 1) * crowdPenalty)
    if crowdCount > 0 and crowdClosest <= 0.9 then
        score = score + closestPenalty
    end
    return score
end

local function chooseBestZombieCandidates(candidates, currentTargetID)
    local bestAcquire = nil
    local bestAcquireScore = nil
    local currentKeep = nil
    local currentKeepScore = nil

    for i = 1, #candidates do
        local candidate = candidates[i]
        local score = getZombieCandidateScore(candidates, i)

        if candidate.acquire and (bestAcquireScore == nil or score < bestAcquireScore) then
            bestAcquire = candidate
            bestAcquireScore = score
        end

        if candidate.keep and currentTargetID and candidate.id == currentTargetID then
            currentKeep = candidate
            currentKeepScore = score
        end
    end

    local stickyBias = tonumber(DTNPCProtect.CONFIG.StickyTargetScoreBias) or 0.45
    if currentKeep and (not bestAcquire or currentKeepScore <= (bestAcquireScore + stickyBias)) then
        return currentKeep, bestAcquire
    end

    return nil, bestAcquire
end

local function getThreatPlayers()
    local players = {}

    if DTNPCLogic and DTNPCLogic.GetActivePlayers then
        local snapshot = DTNPCLogic.GetActivePlayers()
        for i = 1, #(snapshot or {}) do
            local player = snapshot[i]
            if player then
                players[#players + 1] = player
            end
        end
        if #players > 0 then
            return players
        end
    end

    local online = getOnlinePlayers and getOnlinePlayers() or nil
    if online then
        for i = 0, online:size() - 1 do
            local player = online:get(i)
            if player then
                players[#players + 1] = player
            end
        end
        if #players > 0 then
            return players
        end
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if player then
        players[1] = player
    end

    return players
end

local function getFactionReputationForPlayer(npcData, player)
    if not npcData or not npcData.factionID or not player then
        return 0
    end
    if not DynamicTrading_Factions or not DynamicTrading_Factions.GetFaction then
        return 0
    end

    local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
    if not faction or type(faction.reputation) ~= "table" then
        return 0
    end

    local username = player.getUsername and player:getUsername() or nil
    if not username or username == "" then
        return 0
    end

    return tonumber(faction.reputation[username]) or 0
end

local function isHostilePlayerForNPC(npcData, player)
    if not npcData or not player or player:isDead() then
        return false
    end

    if isFriendlyAuthorityPlayer and isFriendlyAuthorityPlayer(npcData, player) then
        return false
    end

    local threshold = tonumber(DTNPCProtect.CONFIG.AggressivePlayerRepThreshold)
        or tonumber(DTNPCProtect.CONFIG.HostilePlayerRepThreshold)
        or -10
    return getFactionReputationForPlayer(npcData, player) <= threshold
end

Internal.getThreatPlayers = getThreatPlayers
Internal.getFactionReputationForPlayer = getFactionReputationForPlayer
Internal.isHostilePlayerForNPC = isHostilePlayerForNPC

function DTNPCProtect.SelectNearestThreat(zombie, npcData, radius, anchorTarget, anchorRadius)
    if not zombie then
        return nil, 9999
    end

    DTNPCProtect.EnsureDataDefaults(npcData)

    local searchRadius = tonumber(radius) or DTNPCProtect.CONFIG.ScanRadius
    local keepRadius = searchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus
    local anchorSearchRadius = tonumber(anchorRadius)
    local anchorKeepRadius = anchorSearchRadius and (anchorSearchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus) or nil
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local ax = anchorTarget and anchorTarget.getX and anchorTarget:getX() or nil
    local ay = anchorTarget and anchorTarget.getY and anchorTarget:getY() or nil
    local az = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or nil
    local currentTargetID = npcData.combatTargetID
    local currentTarget = nil
    local currentDistance = 9999
    local currentType = nil
    local nearestTarget = nil
    local nearestDistance = 9999
    local nearestType = nil
    local zombieCandidates = {}
    local zombieCandidateMap = {}

    local function evaluateCandidate(candidate, candidateID, threatType, candidateX, candidateY, candidateZ)
        if not candidateID then
            return
        end

        local dx = candidateX - zx
        local dy = candidateY - zy
        local dist = math.sqrt((dx * dx) + (dy * dy))
        local anchorDist = nil

        if ax ~= nil and ay ~= nil then
            if az ~= nil and math.abs((candidateZ or 0) - az) > DTNPCProtect.CONFIG.FloorTolerance then
                anchorDist = 9999
            else
                local adx = candidateX - ax
                local ady = candidateY - ay
                anchorDist = math.sqrt((adx * adx) + (ady * ady))
            end
        end

        local withinAnchorAcquire = anchorSearchRadius == nil or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
        local withinAnchorKeep = anchorKeepRadius == nil or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

        if currentTargetID and candidateID == currentTargetID and dist <= keepRadius and withinAnchorKeep then
            currentTarget = candidate
            currentDistance = dist
            currentType = threatType
        end

        if withinAnchorAcquire and dist <= searchRadius and dist < nearestDistance then
            nearestTarget = candidate
            nearestDistance = dist
            nearestType = threatType
        end
    end

    local players = getThreatPlayers()
    for i = 1, #players do
        local player = players[i]
        if player
            and not player:isDead()
            and math.abs((player:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance
            and isHostilePlayerForNPC(npcData, player) then
            evaluateCandidate(
                player,
                getPlayerRuntimeID(player),
                "player",
                player:getX(),
                player:getY(),
                player:getZ() or 0
            )
        end
    end

    local zombieList = getCell() and getCell():getZombieList() or nil
    if zombieList then
        for i = 0, zombieList:size() - 1 do
            local candidate = zombieList:get(i)
            if candidate and candidate ~= zombie and not candidate:isDead() then
                local modData = candidate:getModData()
                if not (modData and modData.IsDTNPC) then
                    local candidateZ = candidate:getZ() or 0
                    if math.abs(candidateZ - zz) <= DTNPCProtect.CONFIG.FloorTolerance then
                        local candidateX = candidate:getX()
                        local candidateY = candidate:getY()
                        local dx = candidateX - zx
                        local dy = candidateY - zy
                        local dist = math.sqrt((dx * dx) + (dy * dy))
                        local candidateID = getZombieRuntimeID(candidate)
                        local anchorDist = nil

                        if ax ~= nil and ay ~= nil then
                            if az ~= nil and math.abs(candidateZ - az) > DTNPCProtect.CONFIG.FloorTolerance then
                                anchorDist = 9999
                            else
                                local adx = candidateX - ax
                                local ady = candidateY - ay
                                anchorDist = math.sqrt((adx * adx) + (ady * ady))
                            end
                        end

                        local withinAnchorAcquire = anchorSearchRadius == nil or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
                        local withinAnchorKeep = anchorKeepRadius == nil or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

                        if (dist <= searchRadius and withinAnchorAcquire)
                            or (currentTargetID and candidateID == currentTargetID and dist <= keepRadius and withinAnchorKeep) then
                            upsertZombieCandidate(zombieCandidates, zombieCandidateMap, {
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
                    end
                end
            end
        end
    end

    local currentZombie, nearestZombie = chooseBestZombieCandidates(zombieCandidates, currentTargetID)
    if currentZombie and currentType == nil then
        currentTarget = currentZombie.candidate
        currentDistance = currentZombie.dist
        currentType = "zombie"
    end
    if nearestZombie and nearestZombie.dist < nearestDistance then
        nearestTarget = nearestZombie.candidate
        nearestDistance = nearestZombie.dist
        nearestType = "zombie"
    end

    local chosen = currentTarget or nearestTarget
    local distance = currentTarget and currentDistance or nearestDistance
    local threatType = currentTarget and currentType or nearestType

    if chosen then
        npcData.combatTargetID = threatType == "player" and getPlayerRuntimeID(chosen) or getZombieRuntimeID(chosen)
        npcData.combatTargetType = threatType
        return chosen, distance
    end

    DTNPCProtect.ClearCombatTarget(npcData)
    return nil, 9999
end

function DTNPCProtect.SelectNearestZombie(zombie, npcData, radius, anchorTarget, anchorRadius)
    if not zombie then
        return nil, 9999
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    local isAuthoritativeSide = (not isClient()) or isServer()
    if isAuthoritativeSide and DTNPC_ZombieAggro and DTNPC_ZombieAggro.GetThreatTarget and npcData and npcData.uuid then
        local cachedTarget, cachedDist = DTNPC_ZombieAggro.GetThreatTarget(npcData.uuid)
        if cachedTarget then
            npcData.combatTargetID = getZombieRuntimeID(cachedTarget)
            return cachedTarget, cachedDist
        end
    end

    local searchRadius = tonumber(radius) or DTNPCProtect.CONFIG.ScanRadius
    local keepRadius = searchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus
    local anchorSearchRadius = tonumber(anchorRadius)
    local anchorKeepRadius = anchorSearchRadius and (anchorSearchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus) or nil
    local zombieList = getCell() and getCell():getZombieList() or nil
    if not zombieList then
        DTNPCProtect.ClearCombatTarget(npcData)
        return nil, 9999
    end

    local currentTarget = nil
    local currentDistance = 9999
    local nearestTarget = nil
    local nearestDistance = 9999
    local currentTargetID = npcData.combatTargetID
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local ax = anchorTarget and anchorTarget.getX and anchorTarget:getX() or nil
    local ay = anchorTarget and anchorTarget.getY and anchorTarget:getY() or nil
    local az = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or nil
    local candidates = {}
    local candidateMap = {}

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and candidate ~= zombie and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC) and math.abs((candidate:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance then
                local candidateX = candidate:getX()
                local candidateY = candidate:getY()
                local candidateZ = candidate:getZ() or 0
                local dx = candidateX - zx
                local dy = candidateY - zy
                local dist = math.sqrt((dx * dx) + (dy * dy))
                local candidateID = getZombieRuntimeID(candidate)
                local anchorDist = nil

                if ax ~= nil and ay ~= nil then
                    if az ~= nil and math.abs(candidateZ - az) > DTNPCProtect.CONFIG.FloorTolerance then
                        anchorDist = 9999
                    else
                        local adx = candidateX - ax
                        local ady = candidateY - ay
                        anchorDist = math.sqrt((adx * adx) + (ady * ady))
                    end
                end

                local withinAnchorAcquire = anchorSearchRadius == nil or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
                local withinAnchorKeep = anchorKeepRadius == nil or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

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
            end
        end
    end

    local chosenCurrent, chosenNearest = chooseBestZombieCandidates(candidates, currentTargetID)
    if chosenCurrent then
        currentTarget = chosenCurrent.candidate
        currentDistance = chosenCurrent.dist
    end
    if chosenNearest then
        nearestTarget = chosenNearest.candidate
        nearestDistance = chosenNearest.dist
    end

    local chosen = currentTarget or nearestTarget
    local distance = currentTarget and currentDistance or nearestDistance
    if chosen then
        npcData.combatTargetID = getZombieRuntimeID(chosen)
        return chosen, distance
    end

    DTNPCProtect.ClearCombatTarget(npcData)
    return nil, 9999
end
