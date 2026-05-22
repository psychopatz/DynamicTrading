-- ==============================================================================
-- DTNPC_MobilityNavigation.lua
-- Same-floor square routing and route-aware recovery for teleported DT movement.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

local SQRT2 = 1.41421356237

local function logNavigation(npcData, message)
    if not DynamicTrading or not DynamicTrading.Log then
        return
    end

    local label = tostring(npcData and npcData.name or npcData and npcData.uuid or "Unknown")
    DynamicTrading.Log("DTV2", "NPC", "Nav", label .. " " .. tostring(message or ""))
end

local function buildPointTarget(x, y, z)
    return {
        getX = function()
            return x
        end,
        getY = function()
            return y
        end,
        getZ = function()
            return z
        end,
    }
end

local function tileCenter(value)
    return math.floor(tonumber(value) or 0) + 0.5
end

local function clampInteger(value, minimum)
    return math.max(minimum or 0, math.floor(tonumber(value) or 0))
end

local function getRouteState(npcData, create)
    if type(npcData) ~= "table" then
        return nil
    end

    local route = npcData._dtRoute
    if type(route) ~= "table" and create then
        route = {}
        npcData._dtRoute = route
    end
    return route
end

local function getBlockedTransitions(npcData, create)
    if type(npcData) ~= "table" then
        return nil
    end

    local blocked = npcData._dtRouteBlockedUntil
    if type(blocked) ~= "table" and create then
        blocked = {}
        npcData._dtRouteBlockedUntil = blocked
    end
    return blocked
end

local function clearExpiredBlockedTransitions(npcData)
    local blocked = getBlockedTransitions(npcData, false)
    if type(blocked) ~= "table" then
        return
    end

    local currentTime = Internal.getTimeMs()
    for key, entry in pairs(blocked) do
        local untilTime = type(entry) == "table" and tonumber(entry.untilTime) or tonumber(entry)
        if untilTime == nil or untilTime <= currentTime then
            blocked[key] = nil
        end
    end
end

local function getNodeKey(x, y)
    return tostring(x) .. ":" .. tostring(y)
end

local function getEdgeKey(fromX, fromY, toX, toY)
    return table.concat({
        tostring(fromX),
        tostring(fromY),
        tostring(toX),
        tostring(toY),
    }, ":")
end

local function noteBlockedTransition(npcData, fromX, fromY, toX, toY, penalty, durationMs)
    local blocked = getBlockedTransitions(npcData, true)
    if type(blocked) ~= "table" then
        return
    end

    local currentTime = Internal.getTimeMs()
    local edgeKey = getEdgeKey(fromX, fromY, toX, toY)
    blocked[edgeKey] = {
        untilTime = currentTime + math.max(500, math.floor(tonumber(durationMs) or 1100)),
        penalty = math.max(0.5, tonumber(penalty) or 1.2),
    }
end

local function getBlockedTransitionPenalty(npcData, fromX, fromY, toX, toY)
    local blocked = getBlockedTransitions(npcData, false)
    if type(blocked) ~= "table" then
        return 0
    end

    local entry = blocked[getEdgeKey(fromX, fromY, toX, toY)]
    if type(entry) ~= "table" then
        return 0
    end

    local untilTime = tonumber(entry.untilTime) or 0
    if untilTime <= Internal.getTimeMs() then
        blocked[getEdgeKey(fromX, fromY, toX, toY)] = nil
        return 0
    end

    return math.max(0, tonumber(entry.penalty) or 0)
end

local function clearRoutePath(route)
    if type(route) ~= "table" then
        return
    end

    route.nodes = nil
    route.pathSignature = nil
    route.nextWaypointX = nil
    route.nextWaypointY = nil
    route.nextWaypointZ = nil
end

function Mobility.ResetRoute(npcData, preserveBlocked)
    if type(npcData) ~= "table" then
        return
    end

    npcData._dtRoute = nil
    npcData._dtRouteIndex = nil
    npcData._dtRouteBuiltAt = nil
    npcData._dtRouteFailCount = nil
    npcData._dtRouteLastProgressAt = nil
    if preserveBlocked ~= true then
        npcData._dtRouteBlockedUntil = nil
    end
end

local function getNavigationProfile(profileKey)
    local profiles = Constants.NAVIGATION_PROFILES or {}
    local key = tostring(profileKey or "")
    return profiles[key] or profiles.default or {
        plannerRadius = 20,
        routeTTL = 1200,
        repathTargetShift = 2.0,
        waypointArrivalRadius = 0.35,
        goalSearchRadius = 2,
        blockedRepathCount = 2,
        snapAfterFailures = 4,
        maxRouteSnapDistance = 3.2,
        maxRouteSnapIndexAdvance = 4,
        doorPauseMs = 140,
        allowLeashTeleport = false,
        leashTeleportDistance = 16,
        blockedPenalty = 1.25,
        blockedPenaltyMs = 1100,
        closedDoorCost = 1.8,
        fenceCost = 2.6,
    }
end

function Internal.BuildNavigationConfig(options)
    options = type(options) == "table" and options or {}

    local profile = getNavigationProfile(options.plannerProfile)
    local navigationMode = tostring(options.navigationMode or profile.navigationMode or "direct")
    return {
        navigationMode = navigationMode,
        profileKey = tostring(options.plannerProfile or profile.profileKey or "default"),
        plannerRadius = math.max(6, clampInteger(options.plannerRadius or profile.plannerRadius, 6)),
        routeTTL = math.max(250, math.floor(tonumber(options.routeTTL or profile.routeTTL) or 1200)),
        repathTargetShift = math.max(0.5, tonumber(options.repathTargetShift or profile.repathTargetShift) or 2.0),
        waypointArrivalRadius = math.max(0.15, tonumber(options.waypointArrivalRadius or profile.waypointArrivalRadius) or 0.35),
        goalSearchRadius = math.max(1, clampInteger(options.goalSearchRadius or profile.goalSearchRadius, 1)),
        blockedRepathCount = math.max(1, clampInteger(options.blockedRepathCount or profile.blockedRepathCount, 1)),
        snapAfterFailures = math.max(2, clampInteger(options.snapAfterFailures or profile.snapAfterFailures, 2)),
        maxRouteSnapDistance = math.max(1.0, tonumber(options.maxRouteSnapDistance or profile.maxRouteSnapDistance) or 3.2),
        maxRouteSnapIndexAdvance = math.max(1, clampInteger(options.maxRouteSnapIndexAdvance or profile.maxRouteSnapIndexAdvance, 1)),
        doorPauseMs = math.max(0, math.floor(tonumber(options.doorPauseMs or profile.doorPauseMs) or 140)),
        allowLeashTeleport = options.allowLeashTeleport == true or profile.allowLeashTeleport == true,
        leashTeleportDistance = math.max(3, tonumber(options.leashTeleportDistance or profile.leashTeleportDistance) or 16),
        leashTeleportSearchRadius = math.max(1, clampInteger(options.leashTeleportSearchRadius or profile.leashTeleportSearchRadius or 3, 1)),
        blockedPenalty = math.max(0.5, tonumber(options.blockedPenalty or profile.blockedPenalty) or 1.25),
        blockedPenaltyMs = math.max(500, math.floor(tonumber(options.blockedPenaltyMs or profile.blockedPenaltyMs) or 1100)),
        closedDoorCost = math.max(0.2, tonumber(options.closedDoorCost or profile.closedDoorCost) or 1.8),
        fenceCost = math.max(0.5, tonumber(options.fenceCost or profile.fenceCost) or 2.6),
    }
end

local function isSquareLoadedPassable(square)
    if not square then
        return false
    end
    if square:isSolid() or square:isSolidTrans() then
        return false
    end
    if not square:isFree(false) then
        return false
    end
    return true
end

local function getPlannerSquare(cell, x, y, z)
    return Internal.getSquareAt and Internal.getSquareAt(cell, x, y, z) or nil
end

local function getPassageEdgeCost(fromSquare, toSquare, navigation)
    local passage = Mobility.FindDirectionalPassage and Mobility.FindDirectionalPassage(fromSquare, toSquare) or nil
    if not passage then
        return false, nil, nil
    end

    if passage.kind == "door" then
        local isOpen = Internal.objectBool and Internal.objectBool(passage.object, { "IsOpen", "isOpen" }, false) or false
        return true, isOpen and 1.0 or navigation.closedDoorCost, passage
    end

    if passage.kind == "window" then
        local isOpen = Internal.objectBool and Internal.objectBool(passage.object, { "IsOpen", "isOpen" }, false) or false
        if isOpen then
            return true, 1.05, passage
        end
        return false, nil, nil
    end

    return false, nil, nil
end

local function getFenceEdgeCost(fromSquare, toSquare, navigation)
    local fence = Mobility.FindFenceBetween and Mobility.FindFenceBetween(fromSquare, toSquare) or nil
    if not fence then
        return false, nil, nil
    end

    return true, navigation.fenceCost, fence
end

local function canTraverseEdge(cell, fromX, fromY, toX, toY, z, navigation)
    local fromSquare = getPlannerSquare(cell, fromX, fromY, z)
    local toSquare = getPlannerSquare(cell, toX, toY, z)
    if not fromSquare or not toSquare then
        return false, nil, nil
    end

    if isSquareLoadedPassable(toSquare) then
        return true, 1.0, nil
    end

    local canPassPassage, passageCost, passage = getPassageEdgeCost(fromSquare, toSquare, navigation)
    if canPassPassage then
        return true, passageCost, passage
    end

    local canPassFence, fenceCost = getFenceEdgeCost(fromSquare, toSquare, navigation)
    if canPassFence then
        return true, fenceCost, nil
    end

    return false, nil, nil
end

local function canTraverseStep(cell, fromX, fromY, toX, toY, z, navigation)
    local dx = toX - fromX
    local dy = toY - fromY
    local diagonal = dx ~= 0 and dy ~= 0
    local canPass, moveCost, passage = canTraverseEdge(cell, fromX, fromY, toX, toY, z, navigation)
    if not canPass then
        return false, nil, nil
    end

    if diagonal then
        local canCardinalA = canTraverseEdge(cell, fromX, fromY, fromX + dx, fromY, z, navigation)
        local canCardinalB = canTraverseEdge(cell, fromX, fromY, fromX, fromY + dy, z, navigation)
        if not canCardinalA or not canCardinalB then
            return false, nil, nil
        end
    end

    return true, moveCost * (diagonal and SQRT2 or 1.0), passage
end

local function getHeuristicCost(x1, y1, x2, y2)
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local diagonal = math.min(dx, dy)
    local straight = math.max(dx, dy) - diagonal
    return (diagonal * SQRT2) + straight
end

local function buildRouteNodes(cameFrom, nodeInfo, finalKey)
    local nodes = {}
    local cursor = finalKey
    while cursor do
        local info = nodeInfo[cursor]
        if not info then
            break
        end
        table.insert(nodes, 1, {
            x = info.x,
            y = info.y,
            z = info.z,
            worldX = info.x + 0.5,
            worldY = info.y + 0.5,
            worldZ = info.z,
        })
        cursor = cameFrom[cursor]
    end
    return nodes
end

local function resolveGoalSquare(cell, startTileX, startTileY, targetX, targetY, targetZ, navigation, stopDistance)
    local targetTileX = math.floor(tonumber(targetX) or 0)
    local targetTileY = math.floor(tonumber(targetY) or 0)
    local targetTileZ = math.floor(tonumber(targetZ) or 0)
    local maxRadius = math.max(
        navigation.goalSearchRadius,
        clampInteger((tonumber(stopDistance) or 0) + 1.5, 1)
    )

    local bestCandidate = nil
    local bestTargetDist = nil
    local bestStartDist = nil

    local radius = 0
    while radius <= maxRadius do
        local minX = targetTileX - radius
        local maxX = targetTileX + radius
        local minY = targetTileY - radius
        local maxY = targetTileY + radius
        local x = minX
        while x <= maxX do
            local y = minY
            while y <= maxY do
                local onRing = radius == 0
                    or x == minX
                    or x == maxX
                    or y == minY
                    or y == maxY
                if onRing then
                    local square = getPlannerSquare(cell, x, y, targetTileZ)
                    if isSquareLoadedPassable(square) then
                        local worldX = x + 0.5
                        local worldY = y + 0.5
                        local targetDist = Internal.getDistance(worldX, worldY, targetX, targetY)
                        local startDist = Internal.getDistance(worldX, worldY, startTileX + 0.5, startTileY + 0.5)
                        if not bestCandidate
                            or targetDist < bestTargetDist
                            or (math.abs(targetDist - bestTargetDist) <= 0.05 and startDist < bestStartDist) then
                            bestCandidate = {
                                x = x,
                                y = y,
                                z = targetTileZ,
                                worldX = worldX,
                                worldY = worldY,
                            }
                            bestTargetDist = targetDist
                            bestStartDist = startDist
                        end
                    end
                end
                y = y + 1
            end
            x = x + 1
        end
        if bestCandidate then
            return bestCandidate
        end
        radius = radius + 1
    end

    return nil
end

local function findSafeTeleportPoint(cell, targetX, targetY, targetZ, radius)
    local targetTileX = math.floor(tonumber(targetX) or 0)
    local targetTileY = math.floor(tonumber(targetY) or 0)
    local targetTileZ = math.floor(tonumber(targetZ) or 0)

    local ring = 0
    while ring <= radius do
        local minX = targetTileX - ring
        local maxX = targetTileX + ring
        local minY = targetTileY - ring
        local maxY = targetTileY + ring
        local x = minX
        while x <= maxX do
            local y = minY
            while y <= maxY do
                local onRing = ring == 0
                    or x == minX
                    or x == maxX
                    or y == minY
                    or y == maxY
                if onRing then
                    local square = getPlannerSquare(cell, x, y, targetTileZ)
                    if isSquareLoadedPassable(square) then
                        return {
                            x = x + 0.5,
                            y = y + 0.5,
                            z = targetTileZ,
                        }
                    end
                end
                y = y + 1
            end
            x = x + 1
        end
        ring = ring + 1
    end

    return nil
end

local function buildPlannedRoute(zombie, npcData, target, stopDistance, navigation, reason)
    if not zombie or not target then
        return false, "invalid"
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return false, "no_cell"
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = math.floor(zombie:getZ() or 0)
    local tx = tonumber(target.getX and target:getX())
    local ty = tonumber(target.getY and target:getY())
    local tz = math.floor(tonumber(target.getZ and target:getZ() or zz) or zz)
    if tx == nil or ty == nil then
        return false, "invalid_target"
    end

    local route = getRouteState(npcData, true)
    if math.abs(tz - zz) > 0 then
        clearRoutePath(route)
        route.targetX = tx
        route.targetY = ty
        route.targetZ = tz
        route.rebuildReason = "target_floor"
        return false, "target_floor"
    end

    local startTileX = math.floor(zx)
    local startTileY = math.floor(zy)
    local startSquare = getPlannerSquare(cell, startTileX, startTileY, zz)
    if not startSquare then
        return false, "start_unloaded"
    end

    local goal = resolveGoalSquare(cell, startTileX, startTileY, tx, ty, tz, navigation, stopDistance)
    if not goal then
        clearRoutePath(route)
        route.targetX = tx
        route.targetY = ty
        route.targetZ = tz
        route.rebuildReason = "goal_blocked"
        return false, "goal_blocked"
    end

    local startGoalDistance = Internal.getDistance(zx, zy, goal.worldX, goal.worldY)
    if startGoalDistance > navigation.plannerRadius then
        clearRoutePath(route)
        route.targetX = tx
        route.targetY = ty
        route.targetZ = tz
        route.rebuildReason = "goal_out_of_range"
        return false, "goal_out_of_range"
    end

    local minX = math.min(startTileX, goal.x) - navigation.plannerRadius
    local maxX = math.max(startTileX, goal.x) + navigation.plannerRadius
    local minY = math.min(startTileY, goal.y) - navigation.plannerRadius
    local maxY = math.max(startTileY, goal.y) + navigation.plannerRadius

    clearExpiredBlockedTransitions(npcData)

    local directions = {
        { x = 1, y = 0 },
        { x = -1, y = 0 },
        { x = 0, y = 1 },
        { x = 0, y = -1 },
        { x = 1, y = 1 },
        { x = 1, y = -1 },
        { x = -1, y = 1 },
        { x = -1, y = -1 },
    }

    local openSet = {}
    local openMap = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}
    local nodeInfo = {}
    local closed = {}

    local startKey = getNodeKey(startTileX, startTileY)
    local goalKey = getNodeKey(goal.x, goal.y)
    nodeInfo[startKey] = { x = startTileX, y = startTileY, z = zz }
    gScore[startKey] = 0
    fScore[startKey] = getHeuristicCost(startTileX, startTileY, goal.x, goal.y)
    openSet[1] = startKey
    openMap[startKey] = true

    while #openSet > 0 do
        local currentIndex = 1
        local currentKey = openSet[1]
        local bestScore = tonumber(fScore[currentKey]) or 999999

        local index = 2
        while index <= #openSet do
            local candidateKey = openSet[index]
            local candidateScore = tonumber(fScore[candidateKey]) or 999999
            if candidateScore < bestScore then
                bestScore = candidateScore
                currentKey = candidateKey
                currentIndex = index
            end
            index = index + 1
        end

        table.remove(openSet, currentIndex)
        openMap[currentKey] = nil

        if currentKey == goalKey then
            local nodes = buildRouteNodes(cameFrom, nodeInfo, currentKey)
            route.nodes = nodes
            route.targetX = tx
            route.targetY = ty
            route.targetZ = tz
            route.goalTileX = goal.x
            route.goalTileY = goal.y
            route.goalTileZ = goal.z
            route.goalWorldX = goal.worldX
            route.goalWorldY = goal.worldY
            route.originTileX = startTileX
            route.originTileY = startTileY
            route.builtAt = Internal.getTimeMs()
            route.pathSignature = table.concat({
                tostring(startTileX),
                tostring(startTileY),
                tostring(goal.x),
                tostring(goal.y),
                tostring(goal.z),
            }, ":")
            route.rebuildReason = tostring(reason or "build")
            npcData._dtRouteIndex = math.min(#nodes, 2)
            npcData._dtRouteBuiltAt = route.builtAt
            npcData._dtRouteFailCount = 0
            npcData._dtRouteLastProgressAt = route.builtAt
            if tostring(reason or "build") ~= "route_ttl" and tostring(reason or "build") ~= "target_shift" then
                logNavigation(npcData, "route built reason=" .. tostring(reason or "build")
                    .. " nodes=" .. tostring(#nodes)
                    .. " goal=" .. tostring(goal.x) .. "," .. tostring(goal.y) .. "," .. tostring(goal.z))
            end
            return true, nil
        end

        closed[currentKey] = true
        local currentNode = nodeInfo[currentKey]
        local directionIndex = 1
        while directionIndex <= #directions do
            local direction = directions[directionIndex]
            local nextX = currentNode.x + direction.x
            local nextY = currentNode.y + direction.y
            if nextX >= minX and nextX <= maxX and nextY >= minY and nextY <= maxY then
                local nextKey = getNodeKey(nextX, nextY)
                if not closed[nextKey] then
                    local canPass, stepCost = canTraverseStep(cell, currentNode.x, currentNode.y, nextX, nextY, zz, navigation)
                    if canPass then
                        local penalty = getBlockedTransitionPenalty(npcData, currentNode.x, currentNode.y, nextX, nextY)
                        local tentativeG = (tonumber(gScore[currentKey]) or 999999) + stepCost + penalty
                        local existingG = tonumber(gScore[nextKey]) or 999999
                        if tentativeG < existingG then
                            cameFrom[nextKey] = currentKey
                            nodeInfo[nextKey] = { x = nextX, y = nextY, z = zz }
                            gScore[nextKey] = tentativeG
                            fScore[nextKey] = tentativeG + getHeuristicCost(nextX, nextY, goal.x, goal.y)
                            if not openMap[nextKey] then
                                openSet[#openSet + 1] = nextKey
                                openMap[nextKey] = true
                            end
                        end
                    end
                end
            end
            directionIndex = directionIndex + 1
        end
    end

    clearRoutePath(route)
    route.targetX = tx
    route.targetY = ty
    route.targetZ = tz
    route.rebuildReason = "no_route"
    if tostring(reason or "build") ~= "route_ttl" and tostring(reason or "build") ~= "target_shift" then
        logNavigation(npcData, "route failed reason=" .. tostring(reason or "build"))
    end
    return false, "no_route"
end

local function advanceRouteIfReached(zombie, npcData, navigation)
    local route = getRouteState(npcData, false)
    if type(route) ~= "table" or type(route.nodes) ~= "table" then
        return nil, false
    end

    local routeIndex = math.max(1, math.floor(tonumber(npcData._dtRouteIndex) or 2))
    local movedIndex = false

    while routeIndex <= #route.nodes do
        local node = route.nodes[routeIndex]
        local distance = Internal.getDistance(zombie:getX(), zombie:getY(), node.worldX, node.worldY)
        if distance > navigation.waypointArrivalRadius then
            break
        end
        routeIndex = routeIndex + 1
        movedIndex = true
    end

    if routeIndex > #route.nodes then
        npcData._dtRouteIndex = #route.nodes
        return nil, movedIndex
    end

    npcData._dtRouteIndex = routeIndex
    local node = route.nodes[routeIndex]
    route.nextWaypointX = node.worldX
    route.nextWaypointY = node.worldY
    route.nextWaypointZ = node.worldZ
    return node, movedIndex
end

local function shouldRebuildRoute(zombie, npcData, target, navigation)
    local route = getRouteState(npcData, false)
    if type(route) ~= "table" or type(route.nodes) ~= "table" or #route.nodes <= 0 then
        return true, "missing"
    end

    local currentTime = Internal.getTimeMs()
    local targetX = tonumber(target and target.getX and target:getX())
    local targetY = tonumber(target and target.getY and target:getY())
    local targetZ = math.floor(tonumber(target and target.getZ and target:getZ() or zombie:getZ()) or zombie:getZ())
    if targetX == nil or targetY == nil then
        return true, "invalid_target"
    end

    local recordedTargetX = tonumber(route.targetX)
    local recordedTargetY = tonumber(route.targetY)
    if recordedTargetX == nil or recordedTargetY == nil then
        return true, "missing_target"
    end

    if math.abs(targetZ - math.floor(tonumber(route.targetZ) or targetZ)) > 0 then
        return true, "target_floor"
    end

    local shift = Internal.getDistance(recordedTargetX, recordedTargetY, targetX, targetY)
    if shift >= navigation.repathTargetShift then
        return true, "target_shift"
    end

    local builtAt = tonumber(route.builtAt or npcData._dtRouteBuiltAt) or 0
    if builtAt <= 0 or (currentTime - builtAt) >= navigation.routeTTL then
        return true, "route_ttl"
    end

    local routeIndex = math.max(1, math.floor(tonumber(npcData._dtRouteIndex) or 2))
    local node = route.nodes[routeIndex]
    if not node then
        return true, "route_complete"
    end

    local cell = getCell and getCell() or nil
    local square = cell and getPlannerSquare(cell, node.x, node.y, node.z) or nil
    if not isSquareLoadedPassable(square) then
        local canPassPassage = false
        if routeIndex > 1 then
            local previous = route.nodes[routeIndex - 1]
            if previous then
                canPassPassage = canTraverseEdge(cell, previous.x, previous.y, node.x, node.y, node.z, navigation)
            end
        end
        if not canPassPassage then
            return true, "waypoint_blocked"
        end
    end

    return false, nil
end

local function trySnapToLaterWaypoint(zombie, npcData, navigation)
    local route = getRouteState(npcData, false)
    if type(route) ~= "table" or type(route.nodes) ~= "table" then
        return false, nil
    end

    local currentIndex = math.max(1, math.floor(tonumber(npcData._dtRouteIndex) or 2))
    local maxIndex = math.min(#route.nodes, currentIndex + navigation.maxRouteSnapIndexAdvance)
    local index = currentIndex + 1
    while index <= maxIndex do
        local node = route.nodes[index]
        if node then
            local distance = Internal.getDistance(zombie:getX(), zombie:getY(), node.worldX, node.worldY)
            if distance <= navigation.maxRouteSnapDistance then
                local square = getPlannerSquare(getCell and getCell() or nil, node.x, node.y, node.z)
                if isSquareLoadedPassable(square) then
                    zombie:setX(node.worldX)
                    zombie:setY(node.worldY)
                    zombie:setZ(node.worldZ)
                    npcData._dtRouteIndex = index
                    npcData._dtRouteLastProgressAt = Internal.getTimeMs()
                    logNavigation(npcData, "route snap waypoint=" .. tostring(index))
                    return true, "route_snap"
                end
            end
        end
        index = index + 1
    end

    return false, nil
end

local function tryLeashTeleport(zombie, npcData, target, navigation, reason)
    if not navigation.allowLeashTeleport or not zombie or not target then
        return false, nil
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return false, nil
    end

    local point = findSafeTeleportPoint(
        cell,
        target:getX(),
        target:getY(),
        target:getZ() or zombie:getZ(),
        navigation.leashTeleportSearchRadius
    )
    if not point then
        return false, nil
    end

    zombie:setX(point.x)
    zombie:setY(point.y)
    zombie:setZ(point.z)
    Mobility.Stop(zombie)
    Mobility.ResetRoute(npcData, true)
    logNavigation(npcData, "leash teleport reason=" .. tostring(reason or "teleport")
        .. " target=" .. tostring(math.floor(point.x)) .. "," .. tostring(math.floor(point.y)) .. "," .. tostring(point.z))
    return true, "leash_teleport"
end

function Mobility.ResolveNavigationTarget(zombie, npcData, target, options)
    if not zombie or not target then
        return {
            active = false,
            target = target,
        }
    end

    local navigation = Internal.BuildNavigationConfig(options)
    if navigation.navigationMode ~= "planned" then
        return {
            active = false,
            target = target,
            navigation = navigation,
        }
    end

    local currentDistance = Internal.getDistance(zombie:getX(), zombie:getY(), target:getX(), target:getY())
    if currentDistance <= math.max(0, tonumber(options and options.stopDistance) or 0) then
        return {
            active = false,
            target = target,
            navigation = navigation,
        }
    end

    local targetZ = math.floor(tonumber(target.getZ and target:getZ() or zombie:getZ()) or zombie:getZ())
    local zombieZ = math.floor(tonumber(zombie:getZ()) or 0)
    if math.abs(targetZ - zombieZ) > 0 then
        local teleported, state = tryLeashTeleport(zombie, npcData, target, navigation, "floor_mismatch")
        if teleported then
            return {
                active = true,
                teleported = true,
                state = state,
                target = target,
                navigation = navigation,
            }
        end
        return {
            active = true,
            target = nil,
            navigation = navigation,
            state = "target_floor",
        }
    end

    if navigation.allowLeashTeleport == true and currentDistance >= navigation.leashTeleportDistance then
        local teleported, state = tryLeashTeleport(zombie, npcData, target, navigation, "far_behind")
        if teleported then
            return {
                active = true,
                teleported = true,
                state = state,
                target = target,
                navigation = navigation,
            }
        end
    end

    local rebuild, rebuildReason = shouldRebuildRoute(zombie, npcData, target, navigation)
    if rebuild then
        local ok, routeReason = buildPlannedRoute(
            zombie,
            npcData,
            target,
            tonumber(options and options.stopDistance) or 0,
            navigation,
            rebuildReason
        )
        if not ok then
            if navigation.allowLeashTeleport == true
                and currentDistance >= navigation.leashTeleportDistance then
                local teleported, state = tryLeashTeleport(zombie, npcData, target, navigation, routeReason or rebuildReason)
                if teleported then
                    return {
                        active = true,
                        teleported = true,
                        state = state,
                        target = target,
                        navigation = navigation,
                    }
                end
            end
            return {
                active = true,
                target = nil,
                navigation = navigation,
                state = routeReason or rebuildReason or "route_failed",
            }
        end
    end

    local route = getRouteState(npcData, false)
    if type(route) ~= "table" or type(route.nodes) ~= "table" or #route.nodes <= 0 then
        return {
            active = true,
            target = nil,
            navigation = navigation,
            state = "route_missing",
        }
    end

    if tonumber(route.pauseUntil) and tonumber(route.pauseUntil) > Internal.getTimeMs() then
        return {
            active = true,
            target = nil,
            navigation = navigation,
            state = "waiting_passage",
        }
    end

    local node = advanceRouteIfReached(zombie, npcData, navigation)
    if not node then
        return {
            active = true,
            target = buildPointTarget(route.goalWorldX or target:getX(), route.goalWorldY or target:getY(), route.goalTileZ or targetZ),
            route = route,
            navigation = navigation,
            routeComplete = true,
        }
    end

    return {
        active = true,
        target = buildPointTarget(node.worldX, node.worldY, node.worldZ),
        route = route,
        node = node,
        navigation = navigation,
        goalX = node.worldX,
        goalY = node.worldY,
        goalZ = node.worldZ,
    }
end

function Mobility.HandleNavigationResult(zombie, npcData, navigationState, moveState, currentDistance)
    if not navigationState or navigationState.active ~= true or type(npcData) ~= "table" then
        return false, nil
    end

    local navigation = navigationState.navigation
    local route = navigationState.route or getRouteState(npcData, false)
    if navigationState.teleported == true then
        return true, navigationState.state or "leash_teleport"
    end

    if not route or type(route) ~= "table" then
        return false, nil
    end

    local currentTime = Internal.getTimeMs()
    if moveState == "moving"
        or moveState == "unstuck"
        or moveState == "damage_retreat"
        or moveState == "special_action"
        or moveState == "arrived"
        or moveState == "close_enough" then
        npcData._dtRouteFailCount = 0
        npcData._dtRouteLastProgressAt = currentTime
        return false, nil
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData._dtRouteFailCount = 0
        npcData._dtRouteLastProgressAt = currentTime
        route.pauseUntil = currentTime + navigation.doorPauseMs
        logNavigation(npcData, "passage interaction state=" .. tostring(moveState))
        return false, nil
    end

    local failCount = math.max(0, math.floor(tonumber(npcData._dtRouteFailCount) or 0)) + 1
    npcData._dtRouteFailCount = failCount

    local currentIndex = math.max(1, math.floor(tonumber(npcData._dtRouteIndex) or 2))
    local previousNode = route.nodes and route.nodes[math.max(1, currentIndex - 1)] or nil
    local nextNode = route.nodes and route.nodes[currentIndex] or nil
    if previousNode and nextNode then
        noteBlockedTransition(
            npcData,
            previousNode.x,
            previousNode.y,
            nextNode.x,
            nextNode.y,
            navigation.blockedPenalty,
            navigation.blockedPenaltyMs
        )
    end

    if failCount >= navigation.blockedRepathCount then
        local actualTarget = navigationState.actualTarget
            or buildPointTarget(route.targetX, route.targetY, route.targetZ)
        buildPlannedRoute(
            zombie,
            npcData,
            actualTarget,
            tonumber(navigationState.stopDistance) or 0,
            navigation,
            "blocked_repath"
        )
    end

    if failCount >= navigation.snapAfterFailures then
        local snapped, snappedState = trySnapToLaterWaypoint(zombie, npcData, navigation)
        if snapped then
            npcData._dtRouteFailCount = 0
            return true, snappedState
        end

        if navigation.allowLeashTeleport == true
            and tonumber(currentDistance) ~= nil
            and tonumber(currentDistance) >= navigation.leashTeleportDistance then
            local actualTarget = navigationState.actualTarget
                or buildPointTarget(route.targetX, route.targetY, route.targetZ)
            local teleported, teleportedState = tryLeashTeleport(
                zombie,
                npcData,
                actualTarget,
                navigation,
                "blocked_fallback"
            )
            if teleported then
                npcData._dtRouteFailCount = 0
                return true, teleportedState
            end
        end
    end

    return false, nil
end
