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

local HOSTILE_NPC_ENGAGE_LINES = {
    "Hostile survivor. Engaging.",
    "Eyes on an armed hostile.",
    "That one is after us. Moving in.",
}

local THREAT_LOST_LINES = {
    "Threat lost. Coming back.",
    "No clear target. Returning.",
    "Area looks clear. Back to you.",
}

local function nowMillisSafe()
    if Internal.nowMillis then
        return Internal.nowMillis()
    end
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

local function chooseLine(lines)
    if not lines or #lines == 0 then
        return nil
    end
    return lines[1 + ZombRand(#lines)]
end

local function pushThrottledCompanionNotice(zombie, npcData, key, lines, sentiment, cooldownMs, targetID)
    if not zombie or not npcData or not DTNPCProtect.PushCompanionNotice then
        return false
    end

    local nowMs = nowMillisSafe()
    local timeKey = key .. "At"
    local targetKey = key .. "TargetID"
    local lastAt = tonumber(npcData[timeKey]) or 0
    if targetID ~= nil and npcData[targetKey] == targetID and lastAt > 0 and (nowMs - lastAt) < cooldownMs then
        return false
    end
    if targetID == nil and lastAt > 0 and (nowMs - lastAt) < cooldownMs then
        return false
    end

    local line = chooseLine(lines)
    if not line then
        return false
    end

    npcData[timeKey] = nowMs
    npcData[targetKey] = targetID
    return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, sentiment or "warning")
end

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

local function getDTNPCDataFromZombie(zombie)
    local modData = zombie and zombie.getModData and zombie:getModData() or nil
    if not (modData and modData.IsDTNPC == true) then
        return nil, nil
    end

    local targetData = modData.DTNPC_Data or modData.DTNPCBrain
    local uuid = modData.DTNPC_UUID or (targetData and targetData.uuid)
    if (not targetData) and uuid and DTNPCManager and DTNPCManager.Data then
        targetData = DTNPCManager.Data[uuid]
    end
    return targetData, uuid
end

local function isCompanionLike(npcData)
    if not npcData then
        return false
    end
    return tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
        or npcData.linkedWorkerID ~= nil
        or npcData.masterID ~= nil
        or (npcData.master and tostring(npcData.master) ~= "")
end

local function isBanditLike(npcData)
    return npcData
        and (npcData.isBandit == true
            or npcData.banditGroupID ~= nil
            or npcData.raidHostileFaction == true
            or tostring(npcData.factionID or "") == "Bandits")
end

local function shareOwnerOrMaster(left, right)
    if not left or not right then
        return false
    end

    local leftID = left.masterID or left.ownerOnlineID
    local rightID = right.masterID or right.ownerOnlineID
    if leftID ~= nil and rightID ~= nil and tonumber(leftID) == tonumber(rightID) then
        return true
    end

    local leftName = left.master or left.ownerUsername or left.dcCompanionOwner
    local rightName = right.master or right.ownerUsername or right.dcCompanionOwner
    return leftName ~= nil
        and rightName ~= nil
        and tostring(leftName) ~= ""
        and tostring(leftName) == tostring(rightName)
end

local function targetIsHostileToOwner(npcData, targetData)
    if not npcData or not targetData then
        return false
    end

    local ownerID = npcData.masterID or npcData.ownerOnlineID
    if ownerID ~= nil and targetData.lastPlayerAttackerOnlineID ~= nil
        and tonumber(ownerID) == tonumber(targetData.lastPlayerAttackerOnlineID) then
        return true
    end

    local ownerName = npcData.master or npcData.ownerUsername or npcData.dcCompanionOwner
    if ownerName ~= nil and tostring(ownerName) ~= ""
        and targetData.lastPlayerAttackerUsername ~= nil
        and tostring(ownerName) == tostring(targetData.lastPlayerAttackerUsername) then
        return true
    end

    return false
end

local function isDTNPCHostileToNPC(npcData, targetData)
    if not npcData or not targetData then
        return false
    end
    if targetData.incapState == "Active" or targetData.state == "Incapacitated" then
        return false
    end
    if shareOwnerOrMaster(npcData, targetData) then
        return false
    end

    if isCompanionLike(npcData) and targetData.isHostile == true then
        return true
    end
    if isCompanionLike(npcData) and targetIsHostileToOwner(npcData, targetData) then
        return true
    end
    if isBanditLike(targetData) and not isBanditLike(npcData) then
        return true
    end
    if isBanditLike(npcData) and isCompanionLike(targetData) then
        return true
    end
    if targetData.isHostile == true and targetData.combatTargetID then
        return true
    end

    local leftFaction = tostring(npcData.factionID or "")
    local rightFaction = tostring(targetData.factionID or "")
    if leftFaction ~= "" and rightFaction ~= "" and leftFaction ~= rightFaction then
        if targetData.raidHostileFaction == true or npcData.raidHostileFaction == true then
            return true
        end
    end

    return false
end

Internal.getThreatPlayers = getThreatPlayers
Internal.getFactionReputationForPlayer = getFactionReputationForPlayer
Internal.isHostilePlayerForNPC = isHostilePlayerForNPC
Internal.isDTNPCHostileToNPC = isDTNPCHostileToNPC

local function getObjectSquare(object)
    return object and object.getSquare and object:getSquare() or nil
end

local function getSquareRoom(square)
    return square and square.getRoom and square:getRoom() or nil
end

local function getSquareDistanceSq(a, b)
    if not a or not b then
        return 9999
    end

    local ax = a.getX and a:getX() or 0
    local ay = a.getY and a:getY() or 0
    local bx = b.getX and b:getX() or 0
    local by = b.getY and b:getY() or 0
    local dx = ax - bx
    local dy = ay - by
    return (dx * dx) + (dy * dy)
end

local function tryLosUtil(observerSquare, targetSquare)
    if not LosUtil or not observerSquare or not targetSquare then
        return nil
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return nil
    end

    local ox = observerSquare.getX and observerSquare:getX() or nil
    local oy = observerSquare.getY and observerSquare:getY() or nil
    local oz = observerSquare.getZ and observerSquare:getZ() or 0
    local tx = targetSquare.getX and targetSquare:getX() or nil
    local ty = targetSquare.getY and targetSquare:getY() or nil
    local tz = targetSquare.getZ and targetSquare:getZ() or 0
    if ox == nil or oy == nil or tx == nil or ty == nil then
        return nil
    end

    local method = LosUtil.lineClear
    if type(method) ~= "function" then
        return nil
    end

    local ok, result = pcall(method, cell, ox, oy, oz, tx, ty, tz, false)
    if not ok then
        ok, result = pcall(method, LosUtil, cell, ox, oy, oz, tx, ty, tz, false)
    end
    if not ok then
        return nil
    end

    if result == true then
        return true
    end
    if result == false then
        return false
    end

    local text = tostring(result or "")
    if string.find(text, "Blocked", 1, true) or string.find(text, "ClosedDoor", 1, true) then
        return false
    end
    if string.find(text, "Clear", 1, true) then
        return true
    end

    return nil
end

local function hasLineOfSight(observer, target)
    if not observer or not target then
        return false
    end

    if observer.CanSee then
        local ok, canSee = pcall(observer.CanSee, observer, target)
        if ok and canSee == true then
            return true
        end
    end

    local observerSquare = getObjectSquare(observer)
    local targetSquare = getObjectSquare(target)
    local losResult = tryLosUtil(observerSquare, targetSquare)
    if losResult ~= nil then
        return losResult == true
    end

    local observerRoom = getSquareRoom(observerSquare)
    local targetRoom = getSquareRoom(targetSquare)
    if observerRoom and targetRoom and observerRoom ~= targetRoom then
        return false
    end
    if (observerRoom ~= nil) ~= (targetRoom ~= nil) and getSquareDistanceSq(observerSquare, targetSquare) > 4.84 then
        return false
    end

    return true
end

function DTNPCProtect.SelectNearestThreat(zombie, npcData, radius, anchorTarget, anchorRadius)
    if not zombie then
        return nil, 9999
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    if DTNPCProtect.IsHostileChasePaused and DTNPCProtect.IsHostileChasePaused(npcData) then
        DTNPCProtect.ClearCombatTarget(npcData)
        return nil, 9999
    end

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
    local hostileNPCTarget = nil
    local hostileNPCDistance = 9999
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

        if threatType == "dtnpc"
            and withinAnchorAcquire
            and dist <= searchRadius
            and dist < hostileNPCDistance then
            hostileNPCTarget = candidate
            hostileNPCDistance = dist
        end
    end

    local players = getThreatPlayers()
    for i = 1, #players do
        local player = players[i]
        if player
            and not player:isDead()
            and math.abs((player:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance
            and isHostilePlayerForNPC(npcData, player)
            and hasLineOfSight(zombie, player) then
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
                if modData and modData.IsDTNPC == true then
                    local targetNPCData, targetUUID = getDTNPCDataFromZombie(candidate)
                    if targetNPCData
                        and targetUUID
                        and targetUUID ~= npcData.uuid
                        and isDTNPCHostileToNPC(npcData, targetNPCData)
                        and hasLineOfSight(zombie, candidate) then
                        local candidateZ = candidate:getZ() or 0
                        if math.abs(candidateZ - zz) <= DTNPCProtect.CONFIG.FloorTolerance then
                            evaluateCandidate(
                                candidate,
                                "dtnpc:" .. tostring(targetUUID),
                                "dtnpc",
                                candidate:getX(),
                                candidate:getY(),
                                candidateZ
                            )
                        end
                    end
                elseif not (modData and modData.IsDTNPC) and hasLineOfSight(zombie, candidate) then
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

    local chosen = currentTarget or hostileNPCTarget or nearestTarget
    local distance = currentTarget and currentDistance
        or (hostileNPCTarget and hostileNPCDistance or nearestDistance)
    local threatType = currentTarget and currentType
        or (hostileNPCTarget and "dtnpc" or nearestType)

    if chosen then
        local chosenDTNPCData, chosenDTNPCUUID = nil, nil
        if threatType == "dtnpc" then
            chosenDTNPCData, chosenDTNPCUUID = getDTNPCDataFromZombie(chosen)
        end
        local previousTargetID = npcData.combatTargetID
        local chosenTargetID = threatType == "player" and getPlayerRuntimeID(chosen)
            or threatType == "dtnpc" and ("dtnpc:" .. tostring(chosenDTNPCUUID or (chosenDTNPCData and chosenDTNPCData.uuid) or getZombieRuntimeID(chosen)))
            or getZombieRuntimeID(chosen)
        npcData.combatTargetID = chosenTargetID
        npcData.combatTargetType = threatType
        if threatType == "dtnpc" and chosenTargetID ~= previousTargetID then
            pushThrottledCompanionNotice(
                zombie,
                npcData,
                "combatHostileNPCNotice",
                HOSTILE_NPC_ENGAGE_LINES,
                "warning",
                8000,
                chosenTargetID
            )
        end
        return chosen, distance
    end

    if npcData.combatTargetID ~= nil then
        pushThrottledCompanionNotice(
            zombie,
            npcData,
            "combatThreatLostNotice",
            THREAT_LOST_LINES,
            "neutral",
            9000,
            nil
        )
    end

    DTNPCProtect.ClearCombatTarget(npcData)
    return nil, 9999
end

DTNPCProtect.HasLineOfSight = hasLineOfSight
DTNPCProtect.IsDTNPCHostileToNPC = isDTNPCHostileToNPC

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
        elseif cachedTarget and hasLineOfSight(zombie, cachedTarget) then
            cachedTargetID = getZombieRuntimeID(cachedTarget)
        else
            cachedTarget = nil
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

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and candidate ~= zombie and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC)
                and math.abs((candidate:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance
                and hasLineOfSight(zombie, candidate) then
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
