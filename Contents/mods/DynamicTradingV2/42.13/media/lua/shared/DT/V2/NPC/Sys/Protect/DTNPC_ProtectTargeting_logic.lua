-- ==============================================================================
-- DTNPC_ProtectTargeting_logic.lua
-- Threat scanning and target selection logic for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getPlayerRuntimeID = Internal.getPlayerRuntimeID

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

    local threshold = tonumber(DTNPCProtect.CONFIG.HostilePlayerRepThreshold) or -40
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
                if not (modData and modData.IsDTNPC)
                    and math.abs((candidate:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance then
                    evaluateCandidate(
                        candidate,
                        getZombieRuntimeID(candidate),
                        "zombie",
                        candidate:getX(),
                        candidate:getY(),
                        candidate:getZ() or 0
                    )
                end
            end
        end
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

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and candidate ~= zombie and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC) and math.abs((candidate:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance then
                local dx = candidate:getX() - zx
                local dy = candidate:getY() - zy
                local dist = math.sqrt((dx * dx) + (dy * dy))
                local candidateID = getZombieRuntimeID(candidate)
                local anchorDist = nil

                if ax ~= nil and ay ~= nil then
                    if az ~= nil and math.abs((candidate:getZ() or 0) - az) > DTNPCProtect.CONFIG.FloorTolerance then
                        anchorDist = 9999
                    else
                        local adx = candidate:getX() - ax
                        local ady = candidate:getY() - ay
                        anchorDist = math.sqrt((adx * adx) + (ady * ady))
                    end
                end

                local withinAnchorAcquire = anchorSearchRadius == nil or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
                local withinAnchorKeep = anchorKeepRadius == nil or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

                if currentTargetID and candidateID == currentTargetID and dist <= keepRadius and withinAnchorKeep then
                    currentTarget = candidate
                    currentDistance = dist
                end

                if withinAnchorAcquire and dist <= searchRadius and dist < nearestDistance then
                    nearestTarget = candidate
                    nearestDistance = dist
                end
            end
        end
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
