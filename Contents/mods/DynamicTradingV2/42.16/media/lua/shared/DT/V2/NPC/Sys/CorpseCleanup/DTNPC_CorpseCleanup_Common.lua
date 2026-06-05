DTNPCCorpseCleanup = DTNPCCorpseCleanup or {}
DTNPCCorpseCleanup.Internal = DTNPCCorpseCleanup.Internal or {}

local Cleanup = DTNPCCorpseCleanup
local Internal = Cleanup.Internal

Cleanup.SCAN_INTERVAL_MS = Cleanup.SCAN_INTERVAL_MS or 350
Cleanup.SCAN_BATCH_SQUARES = Cleanup.SCAN_BATCH_SQUARES or 96
Cleanup.CLAIM_TTL_MS = Cleanup.CLAIM_TTL_MS or 4500
Cleanup.PICKUP_RADIUS = Cleanup.PICKUP_RADIUS or 1
Cleanup.STATE = Cleanup.STATE or {
    scopes = {},
    nextTokenID = 0,
}

local function floorNumber(value)
    if tonumber(value) == nil then
        return nil
    end
    return math.floor(tonumber(value) or 0)
end

local function buildPoint(source)
    if type(source) ~= "table" then
        return nil
    end

    local x = floorNumber(source.x)
    local y = floorNumber(source.y)
    if x == nil or y == nil then
        return nil
    end

    return {
        x = x,
        y = y,
        z = floorNumber(source.z) or 0,
    }
end

local function buildPointXYZ(x, y, z)
    return buildPoint({
        x = x,
        y = y,
        z = z,
    })
end

local function isAuthority()
    return not (isClient and isClient() and not (isServer and isServer()))
end

local function nowMillis()
    return getTimeInMillis and getTimeInMillis() or 0
end

local function worldHour()
    local gameTime = getGameTime and getGameTime() or nil
    return gameTime and gameTime.getWorldAgeHours and gameTime:getWorldAgeHours() or 0
end

local function getCellSquare(x, y, z)
    local cell = getCell and getCell() or nil
    if not cell then
        return nil
    end
    return cell:getGridSquare(x, y, z or 0)
end

local function forEachCorpseOnSquare(square, callback)
    if not square or type(callback) ~= "function" then
        return
    end

    local seen = {}
    local deadBodies = square.getDeadBodys and square:getDeadBodys() or nil
    if deadBodies then
        for index = 0, deadBodies:size() - 1 do
            local corpse = deadBodies:get(index)
            if corpse ~= nil and not seen[corpse] then
                seen[corpse] = true
                callback(corpse)
            end
        end
    end

    local staticObjects = square.getStaticMovingObjects and square:getStaticMovingObjects() or nil
    if staticObjects then
        for index = 0, staticObjects:size() - 1 do
            local corpse = staticObjects:get(index)
            if corpse ~= nil and not seen[corpse] and instanceof and instanceof(corpse, "IsoDeadBody") then
                seen[corpse] = true
                callback(corpse)
            end
        end
    end
end

local function removeCorpseFromWorld(corpse)
    if not corpse then
        return false
    end

    local square = corpse.getSquare and corpse:getSquare() or nil
    if square and square.transmitRemoveItemFromSquare then
        pcall(function()
            square:transmitRemoveItemFromSquare(corpse)
        end)
    end
    pcall(function()
        corpse:removeFromWorld()
    end)
    pcall(function()
        corpse:removeFromSquare()
    end)
    if corpse.setSquare then
        pcall(function()
            corpse:setSquare(nil)
        end)
    end
    return true
end

local function nextCorpseToken()
    local state = Cleanup.STATE
    state.nextTokenID = math.max(0, floorNumber(state.nextTokenID) or 0) + 1
    return "dtcorpse:" .. tostring(nowMillis()) .. ":" .. tostring(state.nextTokenID)
end

local function ensureCorpseToken(corpse)
    if not corpse or not corpse.getModData then
        return nil
    end

    local modData = corpse:getModData()
    if not modData then
        return nil
    end

    local token = tostring(modData.DTCorpseCleanupToken or "")
    if token ~= "" then
        return token
    end

    token = nextCorpseToken()
    modData.DTCorpseCleanupToken = token
    return token
end

local function getScope(scopeKey)
    local key = tostring(scopeKey or "")
    if key == "" then
        return nil
    end

    local scopes = Cleanup.STATE.scopes
    local scope = scopes[key]
    if type(scope) ~= "table" then
        scope = {
            scopeKey = key,
            nextScanAt = 0,
            lastScanAt = 0,
            candidates = {},
            candidateOrder = {},
            claims = {},
            scan = nil,
        }
        scopes[key] = scope
    end

    return scope
end

local function clearExpiredClaims(scope)
    if type(scope) ~= "table" then
        return
    end

    local now = nowMillis()
    for token, claim in pairs(scope.claims or {}) do
        if type(claim) ~= "table" or (floorNumber(claim.expiresAt) or 0) <= now then
            scope.claims[token] = nil
        end
    end
end

local function getCorpseModData(corpse)
    return corpse and corpse.getModData and corpse:getModData() or nil
end

local function log(message)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTV2", "NPC", "CorpseCleanup", tostring(message or ""))
    end
end

Internal.floorNumber = floorNumber
Internal.buildPoint = buildPoint
Internal.buildPointXYZ = buildPointXYZ
Internal.isAuthority = isAuthority
Internal.nowMillis = nowMillis
Internal.worldHour = worldHour
Internal.getCellSquare = getCellSquare
Internal.forEachCorpseOnSquare = forEachCorpseOnSquare
Internal.removeCorpseFromWorld = removeCorpseFromWorld
Internal.ensureCorpseToken = ensureCorpseToken
Internal.getScope = getScope
Internal.clearExpiredClaims = clearExpiredClaims
Internal.getCorpseModData = getCorpseModData
Internal.log = log

return Cleanup
