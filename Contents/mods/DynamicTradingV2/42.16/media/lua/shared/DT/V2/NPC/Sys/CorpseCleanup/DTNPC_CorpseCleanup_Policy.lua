DTNPCCorpseCleanup = DTNPCCorpseCleanup or {}
DTNPCCorpseCleanup.Internal = DTNPCCorpseCleanup.Internal or {}

local Cleanup = DTNPCCorpseCleanup

local function resolveColonyPolicy(npcData)
    if type(npcData) ~= "table" or npcData.linkedWorkerID == nil then
        return nil
    end

    local owner = tostring(npcData.ownerUsername or "")
    if owner == "" then
        return nil
    end

    return {
        mode = "colony",
        ownerUsername = owner,
        scopeKey = "owner:" .. owner,
    }
end

local function resolveAIPolicy(npcData, allowDebugForce)
    if type(npcData) ~= "table" or not DTNPCRoles or not DTNPCRoles.ResolveContext then
        return nil
    end

    local context = DTNPCRoles.ResolveContext(npcData)
    if context.isPlayerOwned == true then
        return nil
    end
    if allowDebugForce ~= true and (context.isAIFaction ~= true or context.isHostileFaction == true) then
        return nil
    end

    local home = DTNPCRoles.ResolveHomeTarget and DTNPCRoles.ResolveHomeTarget(npcData) or nil
    if type(home) ~= "table" or home.x == nil or home.y == nil then
        return nil
    end

    return {
        mode = "ai",
        scopeKey = "ai:" .. tostring(npcData.uuid or ""),
        homePoint = home,
    }
end

function Cleanup.ResolvePolicy(npcData, context)
    local requested = tostring(context and context.mode or "")
    local allowDebugForce = context and context.allowDebugForce == true
    if requested == "colony" then
        return resolveColonyPolicy(npcData)
    end
    if requested == "ai" then
        return resolveAIPolicy(npcData, allowDebugForce)
    end

    return resolveColonyPolicy(npcData) or resolveAIPolicy(npcData, allowDebugForce)
end

function Cleanup.GetCleanupAnchor(npcData, context)
    local policy = Cleanup.ResolvePolicy(npcData, context)
    if not policy then
        return nil
    end

    if policy.mode == "colony" then
        if DTNPCColonyRuntime and DTNPCColonyRuntime.GetWorkPoint then
            return DTNPCColonyRuntime.GetWorkPoint(npcData)
        end
    end

    if policy.mode == "ai" then
        return policy.homePoint
    end

    return nil
end

function Cleanup.CanAutonomousCleanup(npcData)
    local policy = resolveAIPolicy(npcData)
    return policy ~= nil
end

return Cleanup
