-- ==============================================================================
-- Behavior_Incapacitated.lua
-- Downed crawl behavior used after the first lethal hit.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local ESCAPE_DIST = 26
local TEAMMATE_HELP_RADIUS = 22
local TEAMMATE_STOP_DISTANCE = 1.8
local PAUSE_MIN_MS = 900
local PAUSE_MAX_MS = 2200
local NEXT_PAUSE_MIN_MS = 1300
local NEXT_PAUSE_MAX_MS = 3200
local function getTimeMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end

    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

local function getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

local function findNearestPlayer(zombie)
    local players = DTNPCLogic.GetActivePlayers and DTNPCLogic.GetActivePlayers() or {}
    local bestPlayer = nil
    local bestDist = 9999

    for i = 1, #players do
        local player = players[i]
        if player then
            local dist = getDist(zombie:getX(), zombie:getY(), player:getX(), player:getY())
            if dist < bestDist then
                bestDist = dist
                bestPlayer = player
            end
        end
    end

    return bestPlayer, bestDist
end

local function isPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer") or false
end

local function getNearestPlayerCached(zombie, npcData)
    local runtime = DTNPCLogic and DTNPCLogic.Internal or nil
    local currentTime = runtime and runtime.getTimeMs and runtime.getTimeMs() or getTimeMs()
    if runtime and runtime.UseSenseCache then
        return runtime.UseSenseCache(npcData, "incap_nearest_player", function()
            return findNearestPlayer(zombie)
        end, {
            currentTime = currentTime,
            ttlMs = 250,
            persistent = true,
        })
    end

    return findNearestPlayer(zombie)
end

local function applyCrawlAnimation(zombie, moving)
    DTNPCMobility.SetLocomotionState(zombie, {
        profileKey = DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl",
        moving = moving == true,
        animSpeed = moving and 0.28 or 0.0,
    })
end

local function stopIncapacitatedMovement(zombie, npcData)
    npcData.isMovingState = false
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    else
        zombie:setVariable("bMoving", false)
        zombie:setVariable("isMoving", false)
        zombie:setVariable("Speed", 0.0)
        zombie:setRunning(false)
    end
    applyCrawlAnimation(zombie, false)
end

local function isFriendlyTeammate(sourceData, candidateData)
    if type(sourceData) ~= "table" or type(candidateData) ~= "table" then
        return false
    end
    if candidateData.uuid == nil or sourceData.uuid == candidateData.uuid then
        return false
    end
    if candidateData.incapState == "Active" or tostring(candidateData.state or "") == "Incapacitated" then
        return false
    end
    if tostring(candidateData.status or "") == "Dead" or tonumber(candidateData.deathFinalizedAt) then
        return false
    end
    if candidateData.isHostile == true or candidateData.raidHostileFaction == true then
        return false
    end

    local factionID = tostring(sourceData.factionID or "")
    return factionID ~= "" and factionID == tostring(candidateData.factionID or "")
end

local function getNPCDataForZombie(candidateZombie)
    local modData = candidateZombie and candidateZombie.getModData and candidateZombie:getModData() or nil
    if not modData then
        return nil
    end

    local embeddedData = modData.DTNPC_Data or modData.DTNPCBrain
    local uuid = modData.DTNPC_UUID or (embeddedData and embeddedData.uuid) or nil
    if uuid and DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[tostring(uuid)] then
        return DTNPCManager.Data[tostring(uuid)]
    end
    return embeddedData
end

local function resolveLiveZombieForNPCData(candidateData)
    if type(candidateData) ~= "table" then
        return nil
    end

    local uuid = tostring(candidateData.uuid or "")
    local zombie = nil

    if uuid ~= "" and DTNPCServerCore and DTNPCServerCore.FindZombieByUUID then
        zombie = DTNPCServerCore.FindZombieByUUID(uuid)
    end
    if (not zombie or zombie:isDead()) and uuid ~= "" and DTNPCClient and DTNPCClient.FindZombieByUUID then
        zombie = DTNPCClient.FindZombieByUUID(uuid)
    end

    local bodyInstanceID = candidateData.currentBodyInstanceID
    if (not zombie or zombie:isDead()) and bodyInstanceID and DTNPCServerCore and DTNPCServerCore.FindZombieByBodyInstanceID then
        zombie = DTNPCServerCore.FindZombieByBodyInstanceID(bodyInstanceID)
    end
    if (not zombie or zombie:isDead()) and bodyInstanceID and DTNPCClient and DTNPCClient.FindZombieByBodyInstanceID then
        zombie = DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    if zombie and not zombie:isDead() then
        return zombie
    end

    return nil
end

local function getFactionMemberUUIDs(factionID)
    local safeFactionID = tostring(factionID or "")
    if safeFactionID == "" then
        return nil
    end

    if DynamicTrading_Roster and DynamicTrading_Roster.GetFactionMembers then
        local ok, members = pcall(DynamicTrading_Roster.GetFactionMembers, safeFactionID)
        if ok and type(members) == "table" then
            return members
        end
    end

    local rosterData = ModData and ModData.get and ModData.get("DynamicTrading_Roster") or nil
    local membersByFaction = rosterData and rosterData.FactionMembers or nil
    local members = membersByFaction and membersByFaction[safeFactionID] or nil
    return type(members) == "table" and members or nil
end

local function getTeammateName(teammate)
    if not teammate then
        return nil
    end
    if instanceof and instanceof(teammate, "IsoPlayer") then
        return teammate.getUsername and teammate:getUsername() or nil
    end
    local teammateData = getNPCDataForZombie(teammate)
    return teammateData and teammateData.name or nil
end

local function considerTeammate(zombie, npcData, candidateZombie, best)
    if not candidateZombie or candidateZombie == zombie or candidateZombie:isDead() then
        return best
    end

    local candidateData = getNPCDataForZombie(candidateZombie)
    if not isFriendlyTeammate(npcData, candidateData) then
        return best
    end

    local dz = math.abs((candidateZombie:getZ() or 0) - (zombie:getZ() or 0))
    if dz > 1 then
        return best
    end

    local dx = candidateZombie:getX() - zombie:getX()
    local dy = candidateZombie:getY() - zombie:getY()
    local distSq = (dx * dx) + (dy * dy)
    if distSq > (TEAMMATE_HELP_RADIUS * TEAMMATE_HELP_RADIUS) then
        return best
    end

    if not best or distSq < best.distSq then
        return {
            zombie = candidateZombie,
            distSq = distSq,
        }
    end

    return best
end

local function considerTeammateData(zombie, npcData, candidateData, best)
    if not isFriendlyTeammate(npcData, candidateData) then
        return best
    end

    local candidateZombie = resolveLiveZombieForNPCData(candidateData)
    if not candidateZombie then
        return best
    end

    return considerTeammate(zombie, npcData, candidateZombie, best)
end

local function isFriendlyPlayerTeammate(npcData, player)
    if type(npcData) ~= "table" or not player then
        return false
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return false
    end

    if DTNPCProtect and DTNPCProtect.Internal and DTNPCProtect.Internal.isFriendlyAuthorityPlayer then
        local ok, result = pcall(DTNPCProtect.Internal.isFriendlyAuthorityPlayer, npcData, player)
        if ok and result == true then
            return true
        end
    end

    return false
end

local function considerPlayerTeammate(zombie, npcData, player, best)
    if not player or (player.isDead and player:isDead()) then
        return best
    end
    if not isFriendlyPlayerTeammate(npcData, player) then
        return best
    end

    local dz = math.abs((player:getZ() or 0) - (zombie:getZ() or 0))
    if dz > 1 then
        return best
    end

    local dx = player:getX() - zombie:getX()
    local dy = player:getY() - zombie:getY()
    local distSq = (dx * dx) + (dy * dy)
    if distSq > (TEAMMATE_HELP_RADIUS * TEAMMATE_HELP_RADIUS) then
        return best
    end

    if not best or distSq < best.distSq then
        return {
            zombie = player,
            distSq = distSq,
        }
    end

    return best
end

local function findNearestFriendlyTeammate(zombie, npcData)
    local best = nil
    local bodyCache = DTNPCLogic and DTNPCLogic.Internal and DTNPCLogic.Internal.ForEachCachedBody or nil
    if bodyCache then
        DTNPCLogic.Internal.ForEachCachedBody(function(candidateZombie)
            best = considerTeammate(zombie, npcData, candidateZombie, best)
        end, { localOnly = false, allowRebuild = false })
    end

    local cell = getCell and getCell() or nil
    local zombieList = cell and cell.getZombieList and cell:getZombieList() or nil
    if zombieList then
        for i = 0, zombieList:size() - 1 do
            best = considerTeammate(zombie, npcData, zombieList:get(i), best)
        end
    end

    local players = DTNPCLogic.GetActivePlayers and DTNPCLogic.GetActivePlayers() or {}
    for i = 1, #players do
        best = considerPlayerTeammate(zombie, npcData, players[i], best)
    end

    local managerData = DTNPCManager and DTNPCManager.Data or nil
    local factionMembers = getFactionMemberUUIDs(npcData and npcData.factionID)
    if type(managerData) == "table" and type(factionMembers) == "table" then
        for index = 1, #factionMembers do
            local candidateUUID = tostring(factionMembers[index] or "")
            local candidateData = candidateUUID ~= "" and managerData[candidateUUID] or nil
            if candidateData then
                best = considerTeammateData(zombie, npcData, candidateData, best)
            end
        end
    end

    return best and best.zombie or nil, best and math.sqrt(best.distSq) or 9999
end

local function pushHelpNotice(zombie, npcData, teammate)
    local nowMs = getTimeMs()
    local lastAt = tonumber(npcData.incapHelpNoticeAt) or 0
    if lastAt > 0 and (nowMs - lastAt) < 5500 then
        return false
    end

    npcData.incapHelpNoticeAt = nowMs
    local teammateName = getTeammateName(teammate)
    local line = teammateName and ("Help me, " .. tostring(teammateName) .. "!") or "Help me! I need help!"

    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, "warning", "Chat")
    end
    if zombie and zombie.setHaloNote then
        zombie:setHaloNote(line, 255, 220, 180, 260)
        return true
    end
    return false
end

local function buildAxisFallbackDirection(dirX, dirY)
    local absX = math.abs(tonumber(dirX) or 0)
    local absY = math.abs(tonumber(dirY) or 0)

    if absX >= absY and absX > 0.001 then
        return dirX >= 0 and 1 or -1, 0
    end
    if absY > 0.001 then
        return 0, dirY >= 0 and 1 or -1
    end

    return 0, 0
end

local function requestEscapeRemoval(zombie, npcData)
    if npcData.removalRequested then return end

    local uuid = npcData.uuid
    local returnTime = getGameTime():getWorldAgeHours() + ZombRand(2, 5)

    npcData.requestedReturnStatus = "Resting"
    npcData.removalRequested = true

    if isClient() and not isServer() then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Client suppressed incapacitated escape removal for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " because removal must be server-authoritative"
        )
        return
    elseif DTNPCManager then
        DTNPCManager.SetNPCStatus(uuid, "Away", returnTime, "Resting")
    end
end

DTNPCLogic.Behaviors["Incapacitated"] = function(zombie, npcData, target, dist)
    npcData.isMovingState = false

    if npcData.incapState ~= "Active" then
        npcData.incapState = "Active"
    end

    npcData.isHostile = false
    npcData.master = nil
    npcData.masterID = nil
    zombie:setTarget(nil)
    zombie:setAttackedBy(nil)

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
    end

    local nowMs = getTimeMs()
    if DTNPCHealth and DTNPCHealth.IsReviveHelpActive and DTNPCHealth.IsReviveHelpActive(npcData) then
        npcData.incapStrugglePauseUntil = math.max(tonumber(npcData.incapStrugglePauseUntil) or 0, nowMs + 1000)
        npcData.incapNextPauseAt = math.max(tonumber(npcData.incapNextPauseAt) or 0, nowMs + ZombRand(NEXT_PAUSE_MIN_MS, NEXT_PAUSE_MAX_MS))
        npcData.lastFleeX = nil
        npcData.lastFleeY = nil
        stopIncapacitatedMovement(zombie, npcData)
        return
    end

    if not isPlayerTarget(target) or dist == nil or dist >= 9999 then
        target, dist = getNearestPlayerCached(zombie, npcData)
    end

    local teammate, teammateDist = findNearestFriendlyTeammate(zombie, npcData)
    if teammate and teammateDist and teammateDist < TEAMMATE_HELP_RADIUS then
        pushHelpNotice(zombie, npcData, teammate)
        if teammateDist <= TEAMMATE_STOP_DISTANCE then
            stopIncapacitatedMovement(zombie, npcData)
            return
        end

        local tx = teammate:getX()
        local ty = teammate:getY()
        local zx = zombie:getX()
        local zy = zombie:getY()
        local dx = tx - zx
        local dy = ty - zy
        local len = math.sqrt((dx * dx) + (dy * dy))
        if len > 0.001 then
            dx = dx / len
            dy = dy / len

            local crawlProfile = DTNPCMobility and DTNPCMobility.GetLocomotionProfile
                and DTNPCMobility.GetLocomotionProfile(DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl")
                or nil
            local speed = DynamicTrading.GetNPCRunSpeed() * (tonumber(crawlProfile and crawlProfile.speedMultiplier) or 0.38)
            local moved = DTNPCMobility.MoveByDirection(zombie, npcData, {
                dirX = dx,
                dirY = dy,
                speed = speed,
                staminaMode = "incap_crawl",
                profileKey = DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl",
                blockCounterKey = "incapHelpBlockedTicks",
                stuckTicks = 14,
                allowAxisSlide = false,
                allowObstacleInteract = false,
                allowDamageRetreat = false,
            })
            npcData.isMovingState = moved == true
            applyCrawlAnimation(zombie, moved == true)
            return
        end
    end

    if target and dist > ESCAPE_DIST and dist < 1000 then
        requestEscapeRemoval(zombie, npcData)
        return
    end

    local reviveHoldUntil = tonumber(npcData.reviveAssistHoldUntil) or 0
    if reviveHoldUntil > nowMs then
        npcData.incapStrugglePauseUntil = reviveHoldUntil
        npcData.incapNextPauseAt = math.max(tonumber(npcData.incapNextPauseAt) or 0, reviveHoldUntil + ZombRand(NEXT_PAUSE_MIN_MS, NEXT_PAUSE_MAX_MS))
        npcData.lastFleeX = nil
        npcData.lastFleeY = nil
        stopIncapacitatedMovement(zombie, npcData)
        return
    elseif reviveHoldUntil > 0 then
        npcData.reviveAssistHoldUntil = nil
        npcData.reviveAssistRescuerUUID = nil
    end

    if not npcData.incapNextPauseAt then
        npcData.incapNextPauseAt = nowMs + ZombRand(NEXT_PAUSE_MIN_MS, NEXT_PAUSE_MAX_MS)
    elseif nowMs >= npcData.incapNextPauseAt and not npcData.incapStrugglePauseUntil then
        npcData.incapStrugglePauseUntil = nowMs + ZombRand(PAUSE_MIN_MS, PAUSE_MAX_MS)
        npcData.incapNextPauseAt = nowMs + ZombRand(NEXT_PAUSE_MIN_MS, NEXT_PAUSE_MAX_MS)
    end

    if npcData.incapStrugglePauseUntil and nowMs < npcData.incapStrugglePauseUntil then
        applyCrawlAnimation(zombie, false)
        return
    end

    npcData.incapStrugglePauseUntil = nil

    local dx, dy = 0, 0
    local zx, zy = zombie:getX(), zombie:getY()
    local hasDirection = false

    if target then
        dx = zx - target:getX()
        dy = zy - target:getY()

        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            dx = dx / len
            dy = dy / len
            npcData.lastFleeX = dx
            npcData.lastFleeY = dy
            hasDirection = true
        end
    elseif npcData.lastFleeX then
        dx = npcData.lastFleeX
        dy = npcData.lastFleeY
        hasDirection = true
    end

    if not hasDirection then
        applyCrawlAnimation(zombie, false)
        return
    end

    local crawlProfile = DTNPCMobility and DTNPCMobility.GetLocomotionProfile
        and DTNPCMobility.GetLocomotionProfile(DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl")
        or nil
    local speed = DynamicTrading.GetNPCRunSpeed() * (tonumber(crawlProfile and crawlProfile.speedMultiplier) or 0.38)
    local moved, moveState = DTNPCMobility.MoveByDirection(zombie, npcData, {
        dirX = dx,
        dirY = dy,
        speed = speed,
        staminaMode = "incap_crawl",
        profileKey = DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl",
        blockCounterKey = "incapBlockedTicks",
        stuckTicks = 14,
        allowAxisSlide = false,
        allowObstacleInteract = false,
        allowDamageRetreat = false,
    })

    npcData.isMovingState = moved == true
    if moveState == "exhausted" then
        npcData.incapStrugglePauseUntil = math.max(
            tonumber(npcData.incapStrugglePauseUntil) or 0,
            nowMs + 1800
        )
        npcData.incapNextPauseAt = math.max(
            tonumber(npcData.incapNextPauseAt) or 0,
            nowMs + 2600
        )
        applyCrawlAnimation(zombie, false)
        return
    end
    if not moved then
        local slideX, slideY = buildAxisFallbackDirection(dx, dy)
        if math.abs(slideX) > 0.001 or math.abs(slideY) > 0.001 then
            moved, moveState = DTNPCMobility.MoveByDirection(zombie, npcData, {
                dirX = slideX,
                dirY = slideY,
                speed = speed,
                staminaMode = "incap_crawl",
                profileKey = DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl",
                blockCounterKey = "incapBlockedTicks",
                stuckTicks = 14,
                allowAxisSlide = false,
                allowObstacleInteract = false,
                allowDamageRetreat = false,
            })
            npcData.isMovingState = moved == true
        end
    end

    if not moved then
        applyCrawlAnimation(zombie, false)
    end
end
