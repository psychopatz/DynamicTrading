-- ==============================================================================
-- Behavior_Incapacitated.lua
-- Downed crawl behavior used after the first lethal hit.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local ESCAPE_DIST = 26
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

local function applyCrawlAnimation(zombie, moving)
    DTNPCMobility.SetLocomotionState(zombie, {
        profileKey = DTNPCHealth and DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl",
        moving = moving == true,
        animSpeed = moving and 0.28 or 0.0,
    })
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

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
    end

    if not target or dist >= 9999 then
        target, dist = findNearestPlayer(zombie)
    end

    if target and dist > ESCAPE_DIST and dist < 1000 then
        requestEscapeRemoval(zombie, npcData)
        return
    end

    local nowMs = getTimeMs()
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
        applyCrawlAnimation(zombie, false)
    end
end
