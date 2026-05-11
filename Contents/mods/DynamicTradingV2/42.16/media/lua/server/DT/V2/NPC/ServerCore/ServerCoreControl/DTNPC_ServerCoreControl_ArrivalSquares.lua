-- ==============================================================================
-- DTNPC_ServerCoreControl_ArrivalSquares.lua
-- Arrival square and controller helpers for DTNPC server control.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreControl = DTNPCServerCoreControl or {}
DTNPCServerCoreControl.Internal = DTNPCServerCoreControl.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreControl.Internal

local OFFSCREEN_FOLLOW_MIN_RADIUS = 26
local OFFSCREEN_FOLLOW_MAX_RADIUS = 40

function Internal.NormalizeController(controller)
    if controller and controller.getUsername then
        return controller:getUsername(), controller.getOnlineID and controller:getOnlineID() or nil
    end

    if type(controller) == "table" then
        local username = controller.username or controller.master or controller.ownerUsername or controller.leaderUsername
        local onlineID = controller.onlineID or controller.masterID
        if username and tostring(username) ~= "" then
            return tostring(username), tonumber(onlineID)
        end
    end

    return nil, nil
end

local function roundNumber(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function atan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end

    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then
        return math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then
        return math.pi / 2
    elseif x == 0 and y < 0 then
        return -math.pi / 2
    end

    return 0
end

local function isSpawnableSquare(square)
    return square
        and square:isFree(false)
        and not square:isSolid()
        and not square:isSolidTrans()
end

local function findNearbySpawnSquare(cell, x, y, z, searchRadius)
    if not cell then
        return nil
    end

    local baseX = roundNumber(x)
    local baseY = roundNumber(y)
    local baseZ = roundNumber(z)
    local radiusLimit = math.max(0, math.floor(tonumber(searchRadius) or 0))

    for radius = 0, radiusLimit do
        for dx = -radius, radius do
            for dy = -radius, radius do
                if radius == 0 or math.abs(dx) == radius or math.abs(dy) == radius then
                    local square = cell:getGridSquare(baseX + dx, baseY + dy, baseZ)
                    if isSpawnableSquare(square) then
                        return square
                    end
                end
            end
        end
    end

    return nil
end

local function buildArrivalAngles(playerX, playerY, npcData)
    local home = npcData and npcData.homeCoords or nil
    local baseAngle = nil
    if home and home.x ~= nil and home.y ~= nil then
        local dx = tonumber(home.x) - tonumber(playerX)
        local dy = tonumber(home.y) - tonumber(playerY)
        if math.abs(dx or 0) > 0.01 or math.abs(dy or 0) > 0.01 then
            baseAngle = atan2(dy or 0, dx or 0)
        end
    end

    if not baseAngle then
        baseAngle = ZombRandFloat(0, math.pi * 2)
    end

    return {
        baseAngle,
        baseAngle + 0.35,
        baseAngle - 0.35,
        baseAngle + 0.7,
        baseAngle - 0.7,
        baseAngle + 1.05,
        baseAngle - 1.05,
        baseAngle + math.pi,
    }
end

local function findOffscreenArrivalSquare(controller, npcData)
    if not controller then
        return nil
    end

    local cell = getCell()
    if not cell then
        return nil
    end

    local playerX = controller:getX()
    local playerY = controller:getY()
    local playerZ = controller:getZ()
    local angles = buildArrivalAngles(playerX, playerY, npcData)

    for radius = OFFSCREEN_FOLLOW_MAX_RADIUS, OFFSCREEN_FOLLOW_MIN_RADIUS, -4 do
        for _, angle in ipairs(angles) do
            local targetX = playerX + math.cos(angle) * radius
            local targetY = playerY + math.sin(angle) * radius
            local square = findNearbySpawnSquare(cell, targetX, targetY, playerZ, 4)
            if square then
                return square
            end
        end
    end

    for _ = 1, 24 do
        local angle = ZombRandFloat(0, math.pi * 2)
        local radius = OFFSCREEN_FOLLOW_MIN_RADIUS + ZombRand(OFFSCREEN_FOLLOW_MAX_RADIUS - OFFSCREEN_FOLLOW_MIN_RADIUS + 1)
        local square = findNearbySpawnSquare(
            cell,
            playerX + math.cos(angle) * radius,
            playerY + math.sin(angle) * radius,
            playerZ,
            5
        )
        if square then
            return square
        end
    end

    return findNearbySpawnSquare(cell, playerX + 1, playerY + 1, playerZ, 6)
end

local function findNearbyArrivalSquare(controller, minRadius, maxRadius)
    if not controller then
        return nil
    end

    local cell = getCell()
    if not cell then
        return nil
    end

    local playerX = controller:getX()
    local playerY = controller:getY()
    local playerZ = controller:getZ()
    local safeMin = math.max(0, math.floor(tonumber(minRadius) or 2))
    local safeMax = math.max(safeMin, math.floor(tonumber(maxRadius) or math.max(3, safeMin)))

    for radius = safeMin, safeMax do
        for _ = 1, 20 do
            local angle = ZombRandFloat(0, math.pi * 2)
            local square = findNearbySpawnSquare(
                cell,
                playerX + math.cos(angle) * radius,
                playerY + math.sin(angle) * radius,
                playerZ,
                2
            )
            if square then
                return square
            end
        end
    end

    return findNearbySpawnSquare(cell, playerX + 1, playerY + 1, playerZ, 4)
end

DTNPCServerCore.ResolveControllerIdentity = Internal.NormalizeController
DTNPCServerCore.FindOffscreenArrivalSquare = findOffscreenArrivalSquare
DTNPCServerCore.FindNearbyArrivalSquare = findNearbyArrivalSquare
DTNPCServerCore.FindArrivalSquareNearCoords = function(x, y, z, searchRadius)
    local cell = getCell()
    if not cell then
        return nil
    end
    return findNearbySpawnSquare(cell, x, y, z, searchRadius)
end
