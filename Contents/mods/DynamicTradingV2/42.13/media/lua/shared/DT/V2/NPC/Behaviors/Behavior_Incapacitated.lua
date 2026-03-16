-- ==============================================================================
-- Behavior_Incapacitated.lua
-- Downed crawl behavior used after the first lethal hit.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local ESCAPE_DIST = 26
local PAUSE_MIN_MS = 900
local PAUSE_MAX_MS = 2200
local NEXT_PAUSE_MIN_MS = 1300
local NEXT_PAUSE_MAX_MS = 3200
local CRAWL_SPEED_MULT = 0.38

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

local function isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell and cell:getGridSquare(x, y, z) or nil
    if not sq then return true end
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
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
    zombie:setVariable("bBecomeCrawler", true)
    zombie:setVariable("bCrawling", true)
    zombie:setVariable("bMoving", moving)
    zombie:setVariable("isMoving", moving)
    zombie:setVariable("Speed", moving and 0.28 or 0.0)
    zombie:setVariable("WalkType", "2")
    zombie:setVariable("DTWalkType", "Crawl")
    zombie:setRunning(false)
end

local function requestEscapeRemoval(zombie, npcData)
    if npcData.removalRequested then return end

    local uuid = npcData.uuid
    local returnTime = getGameTime():getWorldAgeHours() + ZombRand(2, 5)

    npcData.requestedReturnStatus = "Resting"
    npcData.removalRequested = true

    if isClient() then
        sendClientCommand(getPlayer(), "DTNPC", "RemoveNPC", {
            uuid = uuid,
            status = "Away",
            returnTime = returnTime,
            returnStatus = "Resting"
        })
    elseif DTNPCManager then
        DTNPCManager.SetNPCStatus(uuid, "Away", returnTime, "Resting")
    end
end

DTNPCLogic.Behaviors["Incapacitated"] = function(zombie, npcData, target, dist)
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

    local speed = DynamicTrading.GetNPCRunSpeed() * CRAWL_SPEED_MULT
    local nextX = zx + (dx * speed)
    local nextY = zy + (dy * speed)
    local z = zombie:getZ()

    local canMove = isTileSafe(nextX, nextY, z)
    if not canMove then
        if isTileSafe(nextX, zy, z) then
            nextY = zy
            canMove = true
        elseif isTileSafe(zx, nextY, z) then
            nextX = zx
            canMove = true
        end
    end

    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        applyCrawlAnimation(zombie, true)

        if math.abs(dx) > 0.001 or math.abs(dy) > 0.001 then
            zombie:faceLocation(nextX + dx, nextY + dy)
        end
    else
        applyCrawlAnimation(zombie, false)
    end
end
