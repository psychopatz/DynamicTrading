-- ==============================================================================
-- DTNPC_ProtectTargeting_ThreatSelection.lua
-- Mixed threat scanning and target selection for DTNPC protect behavior.
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
local hasLineOfSight = Internal.HasLineOfSight
local upsertZombieCandidate = Internal.UpsertZombieCandidate
local chooseBestZombieCandidates = Internal.ChooseBestZombieCandidates
local pushTargetingFlavorNotice = Internal.PushTargetingFlavorNotice
local pushTargetingEncounterNotice = Internal.PushTargetingEncounterNotice

local function getAnchorDistance(candidateX, candidateY, candidateZ, ax, ay, az)
    if ax == nil or ay == nil then
        return nil
    end
    if az ~= nil and math.abs((candidateZ or 0) - az) > DTNPCProtect.CONFIG.FloorTolerance then
        return 9999
    end

    local adx = candidateX - ax
    local ady = candidateY - ay
    return math.sqrt((adx * adx) + (ady * ady))
end

local function buildBanditsTargetID(candidate)
    return DTModPatchesBandits
        and DTModPatchesBandits.BuildBanditsCombatTargetID
        and DTModPatchesBandits.BuildBanditsCombatTargetID(candidate)
        or getZombieRuntimeID(candidate)
end

function DTNPCProtect.SelectNearestThreat(zombie, npcData, radius, anchorTarget, anchorRadius, preferDTNPCsOverZombies)
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
    local hostileNPCType = nil
    local zombieCandidates = {}
    local zombieCandidateMap = {}
    local immediateRadius = tonumber(DTNPCProtect.CONFIG.MeleeImmediateThreatRadius) or 2.2
    local stickyBreak = tonumber(DTNPCProtect.CONFIG.MeleeImmediateThreatStickyBreak) or 0.65
    local immediateTarget = nil
    local immediateDistance = 9999
    local immediateType = nil

    local function evaluateCandidate(candidate, candidateID, threatType, candidateX, candidateY, candidateZ)
        if not candidateID then
            return
        end

        local dx = candidateX - zx
        local dy = candidateY - zy
        local dist = math.sqrt((dx * dx) + (dy * dy))
        local anchorDist = getAnchorDistance(candidateX, candidateY, candidateZ, ax, ay, az)
        local withinAnchorAcquire = anchorSearchRadius == nil or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
        local withinAnchorKeep = anchorKeepRadius == nil or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

        if currentTargetID and candidateID == currentTargetID and dist <= keepRadius and withinAnchorKeep then
            currentTarget = candidate
            currentDistance = dist
            currentType = threatType
        end

        if withinAnchorAcquire and dist <= immediateRadius and dist < immediateDistance then
            immediateTarget = candidate
            immediateDistance = dist
            immediateType = threatType
        end

        if withinAnchorAcquire and dist <= searchRadius and dist < nearestDistance then
            nearestTarget = candidate
            nearestDistance = dist
            nearestType = threatType
        end

        if (threatType == "dtnpc" or threatType == "bandits")
            and withinAnchorAcquire
            and dist <= searchRadius
            and dist < hostileNPCDistance then
            hostileNPCTarget = candidate
            hostileNPCDistance = dist
            hostileNPCType = threatType
        end
    end

    local players = getThreatPlayers and getThreatPlayers() or {}
    for i = 1, #players do
        local player = players[i]
        if player
            and not player:isDead()
            and math.abs((player:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance
            and isHostilePlayerForNPC
            and isHostilePlayerForNPC(npcData, player)
            and hasLineOfSight
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

    local cell = getCell and getCell() or nil
    local zombieList = cell and cell:getZombieList() or nil
    if zombieList then
        for i = 0, zombieList:size() - 1 do
            local candidate = zombieList:get(i)
            if candidate and candidate ~= zombie and not candidate:isDead() then
                local candidateZ = candidate:getZ() or 0
                if math.abs(candidateZ - zz) <= DTNPCProtect.CONFIG.FloorTolerance then
                    local candidateX = candidate:getX()
                    local candidateY = candidate:getY()
                    local dx = candidateX - zx
                    local dy = candidateY - zy
                    local distSq = (dx * dx) + (dy * dy)
                    local withinRelevantRadius = distSq <= (keepRadius * keepRadius)
                    local modData = candidate:getModData()

                    if modData and modData.IsDTNPC == true and withinRelevantRadius then
                        local targetNPCData = nil
                        local targetUUID = nil
                        if getDTNPCDataFromZombie then
                            targetNPCData, targetUUID = getDTNPCDataFromZombie(candidate)
                        end
                        if targetNPCData
                            and targetUUID
                            and targetUUID ~= npcData.uuid
                            and isDTNPCHostileToNPC
                            and isDTNPCHostileToNPC(npcData, targetNPCData)
                            and hasLineOfSight
                            and hasLineOfSight(zombie, candidate) then
                            evaluateCandidate(
                                candidate,
                                "dtnpc:" .. tostring(targetUUID),
                                "dtnpc",
                                candidateX,
                                candidateY,
                                candidateZ
                            )
                        end
                    elseif withinRelevantRadius
                        and DTModPatchesBandits
                        and DTModPatchesBandits.ShouldBanditsNPCBeHostileToDTNPC
                        and DTModPatchesBandits.ShouldBanditsNPCBeHostileToDTNPC(candidate, npcData)
                        and hasLineOfSight
                        and hasLineOfSight(zombie, candidate) then
                        evaluateCandidate(
                            candidate,
                            buildBanditsTargetID(candidate),
                            "bandits",
                            candidateX,
                            candidateY,
                            candidateZ
                        )
                    elseif not (modData and modData.IsDTNPC)
                        and withinRelevantRadius
                        and hasLineOfSight
                        and hasLineOfSight(zombie, candidate) then
                        local dist = math.sqrt(distSq)
                        local candidateID = getZombieRuntimeID(candidate)
                        local anchorDist = getAnchorDistance(candidateX, candidateY, candidateZ, ax, ay, az)
                        local withinAnchorAcquire = anchorSearchRadius == nil
                            or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
                        local withinAnchorKeep = anchorKeepRadius == nil
                            or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

                        if withinAnchorAcquire and dist <= immediateRadius and dist < immediateDistance then
                            immediateTarget = candidate
                            immediateDistance = dist
                            immediateType = "zombie"
                        end

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

    if not immediateTarget and nearestTarget and nearestDistance <= immediateRadius then
        if not currentTarget or currentDistance > (nearestDistance + stickyBreak) then
            immediateTarget = nearestTarget
            immediateDistance = nearestDistance
            immediateType = nearestType
        end
    elseif immediateTarget and currentTarget and currentDistance <= (immediateDistance + stickyBreak) then
        immediateTarget = nil
        immediateDistance = 9999
        immediateType = nil
    end

    local shouldSwitchFromZombie = preferDTNPCsOverZombies == true
        and currentType == "zombie"
        and hostileNPCTarget ~= nil

    local effectiveCurrentTarget = shouldSwitchFromZombie and nil or currentTarget
    local effectiveCurrentType = shouldSwitchFromZombie and nil or currentType
    local effectiveCurrentDistance = shouldSwitchFromZombie and 9999 or currentDistance

    local chosen = immediateTarget or effectiveCurrentTarget or hostileNPCTarget or nearestTarget
    local distance = immediateTarget and immediateDistance
        or (effectiveCurrentTarget and effectiveCurrentDistance
            or (hostileNPCTarget and hostileNPCDistance or nearestDistance))
    local threatType = immediateTarget and immediateType
        or (effectiveCurrentTarget and effectiveCurrentType
            or (hostileNPCTarget and hostileNPCType or nearestType))

    if chosen then
        local chosenDTNPCData = nil
        local chosenDTNPCUUID = nil
        if threatType == "dtnpc" and getDTNPCDataFromZombie then
            chosenDTNPCData, chosenDTNPCUUID = getDTNPCDataFromZombie(chosen)
        end

        local previousTargetID = npcData.combatTargetID
        local chosenTargetID = threatType == "player" and getPlayerRuntimeID(chosen)
            or threatType == "dtnpc" and ("dtnpc:" .. tostring(
                chosenDTNPCUUID or (chosenDTNPCData and chosenDTNPCData.uuid) or getZombieRuntimeID(chosen)
            ))
            or threatType == "bandits" and buildBanditsTargetID(chosen)
            or getZombieRuntimeID(chosen)
        npcData.combatTargetID = chosenTargetID
        npcData.combatTargetType = threatType
        if (threatType == "dtnpc" or threatType == "bandits") and chosenTargetID ~= previousTargetID then
            pushTargetingEncounterNotice(
                zombie,
                npcData,
                "combatHostileNPCNotice",
                threatType,
                "warning",
                8000,
                chosenTargetID
            )
        end
        return chosen, distance
    end

    if npcData.combatTargetID ~= nil then
        pushTargetingFlavorNotice(
            zombie,
            npcData,
            "combatThreatLostNotice",
            "ProtectTargetingThreatLost",
            "neutral",
            9000,
            nil
        )
    end

    DTNPCProtect.ClearCombatTarget(npcData)
    return nil, 9999
end
