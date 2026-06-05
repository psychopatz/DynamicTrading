DTNPCCorpseCleanup = DTNPCCorpseCleanup or {}
DTNPCCorpseCleanup.Internal = DTNPCCorpseCleanup.Internal or {}

local Cleanup = DTNPCCorpseCleanup
local Internal = Cleanup.Internal

pcall(require, "DC/Common/Zone/DC_ZoneData")

local function isInsideZone(zone, x, y, z)
    if not zone then
        return false
    end

    if DC_ZoneData and DC_ZoneData.isInsideZone then
        return DC_ZoneData.isInsideZone(zone, x, y, z)
    end

    for _, rect in ipairs(zone.rects or {}) do
        if x >= rect[1] and x <= rect[3] and y >= rect[2] and y <= rect[4] then
            if z == nil or rect[5] == nil or z == rect[5] then
                return true
            end
        end
    end

    return false
end

local function registerCandidate(scan, corpse, x, y, z)
    if not corpse or not instanceof or not instanceof(corpse, "IsoDeadBody") then
        return
    end

    local token = Internal.ensureCorpseToken(corpse)
    if not token or token == "" or scan.candidates[token] ~= nil then
        return
    end

    local point = Internal.buildPointXYZ(x, y, z)
    if not point then
        return
    end

    scan.candidates[token] = {
        token = token,
        x = point.x,
        y = point.y,
        z = point.z,
    }
    scan.candidateOrder[#scan.candidateOrder + 1] = token
end

local function beginColonyScan(scope, ownerUsername)
    local zones = DC_ZoneRealBase and DC_ZoneRealBase.GetZonesForOwner and DC_ZoneRealBase.GetZonesForOwner(ownerUsername) or {}
    local baseZone = DC_ZoneRealBase and DC_ZoneRealBase.FindBaseZone and DC_ZoneRealBase.FindBaseZone(zones) or nil
    scope.scan = {
        kind = "colony",
        rects = type(baseZone and baseZone.rects) == "table" and baseZone.rects or {},
        rectIndex = 1,
        x = nil,
        y = nil,
        candidates = {},
        candidateOrder = {},
    }
end

local function beginAIScan(scope, homePoint, radius)
    local resolvedRadius = math.max(4, math.floor(tonumber(radius) or 30))
    scope.scan = {
        kind = "ai",
        rects = {
            {
                math.floor(tonumber(homePoint.x) or 0) - resolvedRadius,
                math.floor(tonumber(homePoint.y) or 0) - resolvedRadius,
                math.floor(tonumber(homePoint.x) or 0) + resolvedRadius,
                math.floor(tonumber(homePoint.y) or 0) + resolvedRadius,
                math.floor(tonumber(homePoint.z) or 0),
            }
        },
        aiCenter = {
            x = math.floor(tonumber(homePoint.x) or 0),
            y = math.floor(tonumber(homePoint.y) or 0),
            z = math.floor(tonumber(homePoint.z) or 0),
            radius = resolvedRadius,
        },
        rectIndex = 1,
        x = nil,
        y = nil,
        candidates = {},
        candidateOrder = {},
    }
end

local function finalizeScan(scope)
    local scan = scope.scan
    scope.scan = nil
    scope.lastScanAt = Internal.nowMillis()
    scope.candidates = scan and scan.candidates or {}
    scope.candidateOrder = scan and scan.candidateOrder or {}
end

local function processScan(scope)
    local scan = scope.scan
    if type(scan) ~= "table" then
        scope.candidates = {}
        scope.candidateOrder = {}
        return
    end

    local processed = 0
    while scan.rectIndex <= #scan.rects and processed < Cleanup.SCAN_BATCH_SQUARES do
        local rect = scan.rects[scan.rectIndex]
        local z = Internal.floorNumber(rect and rect[5]) or 0
        local minX = Internal.floorNumber(rect and rect[1]) or 0
        local minY = Internal.floorNumber(rect and rect[2]) or 0
        local maxX = Internal.floorNumber(rect and rect[3]) or minX
        local maxY = Internal.floorNumber(rect and rect[4]) or minY

        if scan.x == nil then
            scan.x = minX
            scan.y = minY
        end

        while scan.y ~= nil and scan.y <= maxY and processed < Cleanup.SCAN_BATCH_SQUARES do
            while scan.x ~= nil and scan.x <= maxX and processed < Cleanup.SCAN_BATCH_SQUARES do
                local x = scan.x
                local y = scan.y
                processed = processed + 1

                local allowSquare = true
                if scan.kind == "ai" and scan.aiCenter then
                    local dx = x - scan.aiCenter.x
                    local dy = y - scan.aiCenter.y
                    allowSquare = ((dx * dx) + (dy * dy)) <= (scan.aiCenter.radius * scan.aiCenter.radius)
                end

                if allowSquare then
                    local square = Internal.getCellSquare(x, y, z)
                    Internal.forEachCorpseOnSquare(square, function(corpse)
                        registerCandidate(scan, corpse, x, y, z)
                    end)
                end

                scan.x = scan.x + 1
            end

            if scan.x ~= nil and scan.x > maxX then
                scan.x = minX
                scan.y = scan.y + 1
            end
        end

        if scan.y ~= nil and scan.y > maxY then
            scan.rectIndex = scan.rectIndex + 1
            scan.x = nil
            scan.y = nil
        end
    end

    if scan.rectIndex > #scan.rects then
        finalizeScan(scope)
    end
end

local function ensureScanned(policy, npcData)
    local scope = Internal.getScope(policy and policy.scopeKey)
    if not scope then
        return nil
    end

    Internal.clearExpiredClaims(scope)

    local now = Internal.nowMillis()
    if scope.scan == nil and now >= (Internal.floorNumber(scope.nextScanAt) or 0) then
        if tostring(policy and policy.mode or "") == "colony" then
            beginColonyScan(scope, policy.ownerUsername)
        elseif tostring(policy and policy.mode or "") == "ai" then
            local home = policy.homePoint or (DTNPCRoles and DTNPCRoles.ResolveHomeTarget and DTNPCRoles.ResolveHomeTarget(npcData)) or nil
            if type(home) == "table" then
                beginAIScan(scope, home, home.radius)
            else
                scope.candidates = {}
                scope.candidateOrder = {}
            end
        end
        scope.nextScanAt = now + math.max(100, Cleanup.SCAN_INTERVAL_MS)
    end

    if scope.scan ~= nil then
        processScan(scope)
    end

    return scope
end

local function findCorpseByToken(token, x, y, z, radius)
    local resolvedRadius = math.max(0, Internal.floorNumber(radius) or Cleanup.PICKUP_RADIUS)
    local wanted = tostring(token or "")
    if wanted == "" then
        return nil
    end

    for offsetY = -resolvedRadius, resolvedRadius do
        for offsetX = -resolvedRadius, resolvedRadius do
            local square = Internal.getCellSquare((Internal.floorNumber(x) or 0) + offsetX, (Internal.floorNumber(y) or 0) + offsetY, Internal.floorNumber(z) or 0)
            local foundCorpse = nil
            Internal.forEachCorpseOnSquare(square, function(corpse)
                if foundCorpse or not (corpse and corpse.getModData) then
                    return
                end
                local modData = corpse:getModData()
                if tostring(modData and modData.DTCorpseCleanupToken or "") == wanted then
                    foundCorpse = corpse
                end
            end)
            if foundCorpse then
                return foundCorpse
            end
        end
    end

    return nil
end

Internal.isInsideZone = isInsideZone
Internal.ensureScanned = ensureScanned
Internal.findCorpseByToken = findCorpseByToken

return Cleanup
