DTNPCCorpseCleanup = DTNPCCorpseCleanup or {}
DTNPCCorpseCleanup.Internal = DTNPCCorpseCleanup.Internal or {}

local Cleanup = DTNPCCorpseCleanup
local Internal = Cleanup.Internal

local function scoreCorpseCandidate(npcData, entry)
    local originX = tonumber(npcData and (npcData.x or (npcData.lastX or (npcData.homeCoords and npcData.homeCoords.x)))) or 0
    local originY = tonumber(npcData and (npcData.y or (npcData.lastY or (npcData.homeCoords and npcData.homeCoords.y)))) or 0
    local dx = originX - (tonumber(entry and entry.x) or originX)
    local dy = originY - (tonumber(entry and entry.y) or originY)
    return (dx * dx) + (dy * dy)
end

local function claimEntry(scope, npcData, entry)
    scope.claims[entry.token] = {
        uuid = npcData.uuid,
        state = "claimed",
        expiresAt = Internal.nowMillis() + Cleanup.CLAIM_TTL_MS,
        sourceX = entry.x,
        sourceY = entry.y,
        sourceZ = entry.z,
    }

    return {
        token = entry.token,
        phase = "to_source",
        source = {
            x = entry.x,
            y = entry.y,
            z = entry.z,
        },
    }
end

local function refreshClaim(scope, npcData, task, phase)
    local claim = scope and scope.claims and scope.claims[task.token] or nil
    if not claim or tostring(claim.uuid or "") ~= tostring(npcData and npcData.uuid or "") then
        return nil
    end

    claim.state = tostring(phase or claim.state or "claimed")
    claim.expiresAt = Internal.nowMillis() + Cleanup.CLAIM_TTL_MS
    return claim
end

function Cleanup.HasAvailableTask(npcData, context)
    if Internal.isAuthority() ~= true then
        return false
    end

    local policy = Cleanup.ResolvePolicy(npcData, context)
    if not policy then
        return false
    end

    local scope = Internal.ensureScanned(policy, npcData)
    if not scope then
        return false
    end

    for _, token in ipairs(scope.candidateOrder or {}) do
        local entry = scope.candidates[token]
        local claim = scope.claims[token]
        if entry and (claim == nil or tostring(claim.uuid or "") == tostring(npcData and npcData.uuid or "")) then
            return true
        end
    end

    return false
end

function Cleanup.AcquireTask(npcData, context)
    if Internal.isAuthority() ~= true or type(npcData) ~= "table" then
        return nil
    end

    local policy = Cleanup.ResolvePolicy(npcData, context)
    if not policy then
        return nil
    end

    local scope = Internal.ensureScanned(policy, npcData)
    if not scope then
        return nil
    end

    local bestEntry = nil
    local bestScore = nil
    for _, token in ipairs(scope.candidateOrder or {}) do
        local entry = scope.candidates[token]
        local claim = scope.claims[token]
        if entry and (claim == nil or tostring(claim.uuid or "") == tostring(npcData.uuid or "")) then
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

    local task = claimEntry(scope, npcData, bestEntry)
    task.policyMode = policy.mode
    task.allowDebugForce = context and context.allowDebugForce == true or false
    return task
end

function Cleanup.RefreshTask(npcData, task, zombie)
    if Internal.isAuthority() ~= true or type(task) ~= "table" then
        return false
    end

    local policy = Cleanup.ResolvePolicy(npcData, {
        mode = task.policyMode,
        allowDebugForce = task.allowDebugForce == true,
    })
    local scope = Internal.getScope(policy and policy.scopeKey)
    local claim = refreshClaim(scope, npcData, task, task.phase)
    if not claim then
        return false
    end

    if zombie then
        claim.lastX = zombie:getX()
        claim.lastY = zombie:getY()
        claim.lastZ = zombie:getZ()
    end

    return true
end

function Cleanup.AbortTask(npcData, task, zombie)
    if type(task) ~= "table" then
        return false
    end

    local policy = Cleanup.ResolvePolicy(npcData, {
        mode = task.policyMode,
        allowDebugForce = task.allowDebugForce == true,
    })
    local scope = Internal.getScope(policy and policy.scopeKey)
    local claim = scope and scope.claims and scope.claims[task.token] or nil
    if claim and tostring(claim.uuid or "") == tostring(npcData and npcData.uuid or "") then
        scope.claims[task.token] = nil
    end

    if zombie and zombie.getX and zombie.getY then
        npcData.lastX = Internal.floorNumber(zombie:getX()) or npcData.lastX
        npcData.lastY = Internal.floorNumber(zombie:getY()) or npcData.lastY
        npcData.lastZ = Internal.floorNumber(zombie:getZ()) or npcData.lastZ
    end

    return true
end

function Cleanup.CommitTask(npcData, task, zombie)
    if Internal.isAuthority() ~= true or type(npcData) ~= "table" or type(task) ~= "table" then
        return false, "invalid"
    end

    local policy = Cleanup.ResolvePolicy(npcData, {
        mode = task.policyMode,
        allowDebugForce = task.allowDebugForce == true,
    })
    local scope = Internal.getScope(policy and policy.scopeKey)
    local claim = scope and scope.claims and scope.claims[task.token] or nil
    if not claim or tostring(claim.uuid or "") ~= tostring(npcData.uuid or "") then
        return false, "claim_lost"
    end

    local corpse = Internal.findCorpseByToken(
        task.token,
        claim.sourceX or task.source and task.source.x,
        claim.sourceY or task.source and task.source.y,
        claim.sourceZ or task.source and task.source.z,
        Cleanup.PICKUP_RADIUS
    )
    if not corpse then
        scope.claims[task.token] = nil
        scope.lastScanAt = 0
        return false, "missing"
    end

    local corpseClass, corpseInfo = Cleanup.ClassifyCorpse(npcData, corpse, task.source)
    if policy and policy.mode == "colony" then
        local facilities = DC_Colony and DC_Colony.CorpseFacilities or nil
        local accepted = false
        local reason = "unavailable"
        if facilities and facilities.TryAcceptCorpse then
            accepted, reason = facilities.TryAcceptCorpse(policy.ownerUsername, corpseClass, corpseInfo)
        end
        if accepted ~= true then
            scope.claims[task.token] = nil
            scope.lastScanAt = 0
            Internal.log("Blocked cleanup owner=" .. tostring(policy.ownerUsername) .. " class=" .. tostring(corpseClass) .. " reason=" .. tostring(reason))
            return false, reason or "blocked"
        end
    end

    Internal.removeCorpseFromWorld(corpse)

    local worker = DTNPCColonyRuntime and DTNPCColonyRuntime.GetWorker and DTNPCColonyRuntime.GetWorker(npcData) or nil
    if worker then
        worker.corpseRemovalCount = math.max(0, Internal.floorNumber(worker.corpseRemovalCount) or 0) + 1
        worker.corpseRemovalLastHour = Internal.worldHour()
    end

    scope.claims[task.token] = nil
    scope.candidates[task.token] = nil
    scope.lastScanAt = 0
    Internal.log(
        "Committed cleanup mode=" .. tostring(policy and policy.mode or "unknown")
            .. " class=" .. tostring(corpseClass)
            .. " uuid=" .. tostring(npcData.uuid or "")
    )
    return true, corpseClass
end

return Cleanup
