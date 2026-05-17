DTNPCColonyRuntime = DTNPCColonyRuntime or {}

local Runtime = DTNPCColonyRuntime

if Runtime.CorpseRemovalLoaded then
    return Runtime
end

Runtime.CorpseRemovalLoaded = true
Runtime.CORPSE_SCAN_INTERVAL_MS = Runtime.CORPSE_SCAN_INTERVAL_MS or 250
Runtime.CORPSE_SCAN_BATCH_SQUARES = Runtime.CORPSE_SCAN_BATCH_SQUARES or 80
Runtime.CORPSE_CLAIM_TTL_MS = Runtime.CORPSE_CLAIM_TTL_MS or 4000
Runtime.CORPSE_CARRIED_TTL_MS = Runtime.CORPSE_CARRIED_TTL_MS or 6000
Runtime.CORPSE_PICKUP_RADIUS = Runtime.CORPSE_PICKUP_RADIUS or 1
Runtime.CORPSE_RUNTIME = Runtime.CORPSE_RUNTIME or {
    owners = {},
    nextTokenID = 0,
}

pcall(require, "DC/Common/Zone/DC_ZoneData")

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

local function copyPoint(point)
    return buildPoint(point)
end

local function buildPointTarget(point)
    if type(point) ~= "table" then
        return nil
    end

    return {
        getX = function()
            return point.x
        end,
        getY = function()
            return point.y
        end,
        getZ = function()
            return point.z or 0
        end,
    }
end

local function getOwnerRuntime(owner)
    local key = tostring(owner or "")
    if key == "" then
        return nil
    end

    local owners = Runtime.CORPSE_RUNTIME.owners
    local runtime = owners[key]
    if type(runtime) ~= "table" then
        runtime = {
            ownerUsername = key,
            zoneRevision = "0",
            nextScanAt = 0,
            lastScanAt = 0,
            candidates = {},
            candidateOrder = {},
            claims = {},
            scan = nil,
        }
        owners[key] = runtime
    end

    runtime.zoneRevision = tostring(Runtime.GetZoneRevision and Runtime.GetZoneRevision(key) or runtime.zoneRevision or "0")
    return runtime
end

local function nextCorpseToken()
    local state = Runtime.CORPSE_RUNTIME
    state.nextTokenID = math.max(0, floorNumber(state.nextTokenID) or 0) + 1
    return "dccorpse:" .. tostring(nowMillis()) .. ":" .. tostring(state.nextTokenID)
end

local function ensureCorpseToken(corpse)
    if not corpse or not corpse.getModData then
        return nil
    end

    local modData = corpse:getModData()
    if not modData then
        return nil
    end

    local token = tostring(modData.DC_CorpseRemovalToken or "")
    if token ~= "" then
        return token
    end

    token = nextCorpseToken()
    modData.DC_CorpseRemovalToken = token
    return token
end

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

local function getCellSquare(x, y, z)
    local cell = getCell and getCell() or nil
    if not cell then
        return nil
    end
    return cell:getGridSquare(x, y, z or 0)
end

local function removeCorpseFromWorld(corpse)
    if not corpse then
        return false
    end

    pcall(function()
        corpse:removeFromWorld()
    end)
    pcall(function()
        corpse:removeFromSquare()
    end)
    if isServer and isServer() and corpse.transmitRemoveItemFromSquare then
        pcall(function()
            corpse:transmitRemoveItemFromSquare()
        end)
    end
    return true
end

local function registerCandidate(scan, corpse, x, y, z)
    if not corpse or not instanceof or not instanceof(corpse, "IsoDeadBody") then
        return
    end

    local token = ensureCorpseToken(corpse)
    if not token or token == "" then
        return
    end

    if scan.candidates[token] ~= nil then
        return
    end

    local point = buildPointXYZ(x, y, z)
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

local function beginScan(runtime, owner)
    local zones = DC_ZoneRealBase and DC_ZoneRealBase.GetZonesForOwner and DC_ZoneRealBase.GetZonesForOwner(owner) or {}
    local baseZone = DC_ZoneRealBase and DC_ZoneRealBase.FindBaseZone and DC_ZoneRealBase.FindBaseZone(zones) or nil
    local dumpZone = DC_ZoneRealBase and DC_ZoneRealBase.FindJobTypeZone and DC_ZoneRealBase.FindJobTypeZone(zones, "CorpseRemoval") or nil

    runtime.scan = {
        rects = type(baseZone and baseZone.rects) == "table" and baseZone.rects or {},
        dumpZone = dumpZone,
        rectIndex = 1,
        x = nil,
        y = nil,
        candidates = {},
        candidateOrder = {},
    }
end

local function finalizeScan(runtime)
    local scan = runtime.scan
    runtime.scan = nil
    runtime.lastScanAt = nowMillis()
    runtime.candidates = scan and scan.candidates or {}
    runtime.candidateOrder = scan and scan.candidateOrder or {}
end

local function processScan(runtime, owner)
    local scan = runtime.scan
    if type(scan) ~= "table" then
        beginScan(runtime, owner)
        scan = runtime.scan
    end
    if type(scan) ~= "table" then
        runtime.candidates = {}
        runtime.candidateOrder = {}
        return
    end

    local processed = 0
    while scan.rectIndex <= #scan.rects and processed < Runtime.CORPSE_SCAN_BATCH_SQUARES do
        local rect = scan.rects[scan.rectIndex]
        local z = floorNumber(rect and rect[5]) or 0
        local minX = floorNumber(rect and rect[1]) or 0
        local minY = floorNumber(rect and rect[2]) or 0
        local maxX = floorNumber(rect and rect[3]) or minX
        local maxY = floorNumber(rect and rect[4]) or minY

        if scan.x == nil then
            scan.x = minX
            scan.y = minY
        end

        while scan.y ~= nil and scan.y <= maxY and processed < Runtime.CORPSE_SCAN_BATCH_SQUARES do
            while scan.x ~= nil and scan.x <= maxX and processed < Runtime.CORPSE_SCAN_BATCH_SQUARES do
                local x = scan.x
                local y = scan.y
                processed = processed + 1

                if not isInsideZone(scan.dumpZone, x, y, z) then
                    local square = getCellSquare(x, y, z)
                    local objects = square and square.getStaticMovingObjects and square:getStaticMovingObjects() or nil
                    if objects then
                        for objectIndex = 0, objects:size() - 1 do
                            registerCandidate(scan, objects:get(objectIndex), x, y, z)
                        end
                    end
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
        finalizeScan(runtime)
    end
end

local function sweepClaims(runtime)
    local now = nowMillis()

    for token, claim in pairs(runtime.claims or {}) do
        local expiresAt = floorNumber(claim and claim.expiresAt) or 0
        if expiresAt > now then
            -- claim is still active
        elseif claim and claim.state == "carried" and claim.corpse ~= nil then
            local point = buildPointXYZ(claim.lastX or claim.sourceX, claim.lastY or claim.sourceY, claim.lastZ or claim.sourceZ)
            if point then
                local square = getCellSquare(point.x, point.y, point.z)
                if square then
                    removeCorpseFromWorld(claim.corpse)
                    pcall(function()
                        claim.corpse:setX(point.x + 0.5)
                    end)
                    pcall(function()
                        claim.corpse:setY(point.y + 0.5)
                    end)
                    if claim.corpse.setZ then
                        pcall(function()
                            claim.corpse:setZ(point.z)
                        end)
                    end
                    if claim.corpse.setCurrentSquare then
                        pcall(function()
                            claim.corpse:setCurrentSquare(square)
                        end)
                    elseif claim.corpse.setCurrent then
                        pcall(function()
                            claim.corpse:setCurrent(square)
                        end)
                    end
                    pcall(function()
                        claim.corpse:addToWorld()
                    end)
                    if isServer and isServer() and claim.corpse.transmitCompleteItemToClients then
                        pcall(function()
                            claim.corpse:transmitCompleteItemToClients()
                        end)
                    end
                end
            end
            runtime.claims[token] = nil
        else
            runtime.claims[token] = nil
        end
    end
end

local function ensureScanned(owner)
    local runtime = getOwnerRuntime(owner)
    if not runtime then
        return nil
    end

    if nowMillis() >= (floorNumber(runtime.nextScanAt) or 0) then
        if runtime.scan == nil and tostring(runtime.zoneRevision or "") ~= tostring(runtime.lastScanZoneRevision or "") then
            runtime.lastScanAt = 0
        end

        if runtime.scan ~= nil or (nowMillis() - (floorNumber(runtime.lastScanAt) or 0)) >= 1500 then
            processScan(runtime, owner)
            runtime.nextScanAt = nowMillis() + Runtime.CORPSE_SCAN_INTERVAL_MS
            runtime.lastScanZoneRevision = tostring(runtime.zoneRevision or "0")
        end
    end

    sweepClaims(runtime)
    return runtime
end

local function scoreCorpseCandidate(npcData, entry)
    local originX = floorNumber(npcData and npcData.lastX) or floorNumber(npcData and npcData.workCoords and npcData.workCoords.x) or 0
    local originY = floorNumber(npcData and npcData.lastY) or floorNumber(npcData and npcData.workCoords and npcData.workCoords.y) or 0
    local dx = originX - (entry.x or originX)
    local dy = originY - (entry.y or originY)
    return (dx * dx) + (dy * dy)
end

local function findClaim(runtime, token)
    return runtime and runtime.claims and runtime.claims[token] or nil
end

local function findCorpseByToken(token, x, y, z, radius)
    if token == nil or token == "" then
        return nil
    end

    local searchRadius = math.max(0, floorNumber(radius) or 0)
    for sx = x - searchRadius, x + searchRadius do
        for sy = y - searchRadius, y + searchRadius do
            local square = getCellSquare(sx, sy, z)
            local objects = square and square.getStaticMovingObjects and square:getStaticMovingObjects() or nil
            if objects then
                for objectIndex = 0, objects:size() - 1 do
                    local corpse = objects:get(objectIndex)
                    if corpse and corpse.getModData then
                        local modData = corpse:getModData()
                        if tostring(modData and modData.DC_CorpseRemovalToken or "") == tostring(token) then
                            return corpse
                        end
                    end
                end
            end
        end
    end

    return nil
end

local function findPlacementPoint(point)
    local base = buildPoint(point)
    if not base then
        return nil
    end

    for radius = 0, 2 do
        for x = base.x - radius, base.x + radius do
            for y = base.y - radius, base.y + radius do
                local square = getCellSquare(x, y, base.z)
                if square then
                    return {
                        x = x,
                        y = y,
                        z = base.z,
                    }, square
                end
            end
        end
    end

    return nil, nil
end

local function positionCorpseOnSquare(corpse, point, square)
    if not corpse or not point or not square then
        return false
    end

    removeCorpseFromWorld(corpse)
    pcall(function()
        corpse:setX(point.x + 0.5)
    end)
    pcall(function()
        corpse:setY(point.y + 0.5)
    end)
    if corpse.setZ then
        pcall(function()
            corpse:setZ(point.z)
        end)
    end
    if corpse.setCurrentSquare then
        pcall(function()
            corpse:setCurrentSquare(square)
        end)
    elseif corpse.setCurrent then
        pcall(function()
            corpse:setCurrent(square)
        end)
    end
    if corpse.setCurrentSquareFromPosition then
        pcall(function()
            corpse:setCurrentSquareFromPosition()
        end)
    end

    local ok = pcall(function()
        corpse:addToWorld()
    end)
    if not ok then
        return false
    end

    if isServer and isServer() and corpse.transmitCompleteItemToClients then
        pcall(function()
            corpse:transmitCompleteItemToClients()
        end)
    end
    return true
end

local function appendWorkerLog(worker, message)
    local registry = DC_Colony and DC_Colony.Registry or nil
    local internal = registry and registry.Internal or nil
    if not internal or not internal.AppendActivityLog then
        return
    end

    internal.AppendActivityLog(worker, tostring(message or ""), worldHour(), "jobs")
end

function Runtime.GetCorpseDumpPoint(npcData)
    local worker = Runtime.GetWorker and Runtime.GetWorker(npcData) or nil
    if worker and DC_ZoneRealBase and DC_ZoneRealBase.ResolveCorpseDumpTarget then
        local target = DC_ZoneRealBase.ResolveCorpseDumpTarget(worker)
        if target then
            return buildPoint(target)
        end
    end

    return Runtime.GetWorkPoint and Runtime.GetWorkPoint(npcData) or nil
end

function Runtime.AcquireCorpseRemovalTask(npcData)
    if not isAuthority() or type(npcData) ~= "table" then
        return nil
    end

    local owner = Runtime.GetOwnerUsername and Runtime.GetOwnerUsername(npcData) or ""
    if owner == "" then
        return nil
    end

    local runtime = ensureScanned(owner)
    if not runtime then
        return nil
    end

    local bestEntry = nil
    local bestScore = nil
    for _, token in ipairs(runtime.candidateOrder or {}) do
        local entry = runtime.candidates[token]
        local claim = findClaim(runtime, token)
        if entry and (claim == nil or claim.uuid == npcData.uuid or (floorNumber(claim.expiresAt) or 0) <= nowMillis()) then
            local score = scoreCorpseCandidate(npcData, entry)
            if bestScore == nil or score < bestScore then
                bestEntry = entry
                bestScore = score
            end
        end
    end

    if not bestEntry then
        return nil
    end

    runtime.claims[bestEntry.token] = {
        uuid = npcData.uuid,
        state = "claimed",
        expiresAt = nowMillis() + Runtime.CORPSE_CLAIM_TTL_MS,
        sourceX = bestEntry.x,
        sourceY = bestEntry.y,
        sourceZ = bestEntry.z,
        lastX = bestEntry.x,
        lastY = bestEntry.y,
        lastZ = bestEntry.z,
    }

    return {
        token = bestEntry.token,
        phase = "to_source",
        source = {
            x = bestEntry.x,
            y = bestEntry.y,
            z = bestEntry.z,
        },
    }
end

function Runtime.RefreshCorpseRemovalTask(npcData, task, phase, zombie)
    if not isAuthority() or type(npcData) ~= "table" or type(task) ~= "table" then
        return false
    end

    local owner = Runtime.GetOwnerUsername and Runtime.GetOwnerUsername(npcData) or ""
    local runtime = getOwnerRuntime(owner)
    local claim = runtime and findClaim(runtime, task.token) or nil
    if not claim or tostring(claim.uuid or "") ~= tostring(npcData.uuid or "") then
        return false
    end

    claim.state = tostring(phase or claim.state or "claimed")
    claim.expiresAt = nowMillis() + (claim.state == "carried" and Runtime.CORPSE_CARRIED_TTL_MS or Runtime.CORPSE_CLAIM_TTL_MS)
    if zombie then
        claim.lastX = zombie:getX()
        claim.lastY = zombie:getY()
        claim.lastZ = zombie:getZ()
    end
    return true
end

function Runtime.ReleaseCorpseRemovalTask(npcData, task)
    if type(npcData) ~= "table" or type(task) ~= "table" then
        return false
    end

    local owner = Runtime.GetOwnerUsername and Runtime.GetOwnerUsername(npcData) or ""
    local runtime = getOwnerRuntime(owner)
    local claim = runtime and findClaim(runtime, task.token) or nil
    if claim and tostring(claim.uuid or "") == tostring(npcData.uuid or "") then
        runtime.claims[task.token] = nil
    end

    return true
end

function Runtime.PickupCorpseRemovalTask(npcData, task)
    if not isAuthority() or type(npcData) ~= "table" or type(task) ~= "table" or type(task.source) ~= "table" then
        return false
    end

    local owner = Runtime.GetOwnerUsername and Runtime.GetOwnerUsername(npcData) or ""
    local runtime = getOwnerRuntime(owner)
    local claim = runtime and findClaim(runtime, task.token) or nil
    if not claim or tostring(claim.uuid or "") ~= tostring(npcData.uuid or "") then
        return false
    end

    local corpse = findCorpseByToken(
        task.token,
        floorNumber(task.source.x) or 0,
        floorNumber(task.source.y) or 0,
        floorNumber(task.source.z) or 0,
        Runtime.CORPSE_PICKUP_RADIUS
    )
    if not corpse then
        runtime.claims[task.token] = nil
        return false
    end

    removeCorpseFromWorld(corpse)

    claim.state = "carried"
    claim.expiresAt = nowMillis() + Runtime.CORPSE_CARRIED_TTL_MS
    claim.corpse = corpse
    claim.lastX = task.source.x
    claim.lastY = task.source.y
    claim.lastZ = task.source.z or 0
    runtime.candidates[task.token] = nil
    return true
end

function Runtime.AbortCorpseRemovalTask(npcData, task, dropPoint)
    if type(npcData) ~= "table" or type(task) ~= "table" then
        return false
    end

    local owner = Runtime.GetOwnerUsername and Runtime.GetOwnerUsername(npcData) or ""
    local runtime = getOwnerRuntime(owner)
    local claim = runtime and findClaim(runtime, task.token) or nil
    if not claim or tostring(claim.uuid or "") ~= tostring(npcData.uuid or "") then
        return false
    end

    if claim.state == "carried" and claim.corpse ~= nil then
        local point = buildPoint(dropPoint) or buildPointXYZ(claim.lastX, claim.lastY, claim.lastZ) or buildPointXYZ(claim.sourceX, claim.sourceY, claim.sourceZ)
        local resolvedPoint, square = findPlacementPoint(point)
        if resolvedPoint and square then
            positionCorpseOnSquare(claim.corpse, resolvedPoint, square)
        end
    end

    runtime.claims[task.token] = nil
    return true
end

function Runtime.DropCorpseRemovalTask(npcData, task, dropPoint, zombie)
    if not isAuthority() or type(npcData) ~= "table" or type(task) ~= "table" then
        return false
    end

    local owner = Runtime.GetOwnerUsername and Runtime.GetOwnerUsername(npcData) or ""
    local runtime = getOwnerRuntime(owner)
    local claim = runtime and findClaim(runtime, task.token) or nil
    if not claim or tostring(claim.uuid or "") ~= tostring(npcData.uuid or "") or claim.corpse == nil then
        return false
    end

    local point = buildPoint(dropPoint)
    if not point and zombie then
        point = buildPointXYZ(zombie:getX(), zombie:getY(), zombie:getZ())
    end
    local resolvedPoint, square = findPlacementPoint(point)
    if not resolvedPoint or not square then
        return false
    end

    if not positionCorpseOnSquare(claim.corpse, resolvedPoint, square) then
        return false
    end

    local worker = Runtime.GetWorker and Runtime.GetWorker(npcData) or nil
    if worker then
        worker.corpseRemovalCount = math.max(0, floorNumber(worker.corpseRemovalCount) or 0) + 1
        worker.corpseRemovalLastHour = worldHour()
        appendWorkerLog(worker, "Moved a corpse to the dump zone.")
    end

    runtime.claims[task.token] = nil
    runtime.lastScanAt = 0
    return true
end

return Runtime
