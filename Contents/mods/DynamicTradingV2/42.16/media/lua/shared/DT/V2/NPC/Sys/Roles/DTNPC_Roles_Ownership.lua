-- ==============================================================================
-- DTNPC_Roles_Ownership.lua
-- Shared ownership and role-context resolution for DT NPC policy.
-- ==============================================================================

DTNPCRoles = DTNPCRoles or {}
DTNPCRoles.Internal = DTNPCRoles.Internal or {}

local Internal = DTNPCRoles.Internal

local function hasAssignedMaster(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    if npcData.masterID ~= nil then
        return true
    end

    return Internal.toText(npcData.master) ~= ""
end

local function isBanditLike(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    return npcData.isBandit == true
        or Internal.toText(npcData.factionID) == "Bandits"
        or npcData.raidHostileFaction == true
        or npcData.banditGroupID ~= nil
        or npcData.hostileNegotiationGroupID ~= nil
        or Internal.toText(npcData.tradeCycleMode) == "hostile_bribe"
end

local function isHostileFaction(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    return isBanditLike(npcData) or npcData.isHostile == true
end

local function isColonyOwned(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    if isBanditLike(npcData) then
        return false
    end

    return Internal.toText(npcData.linkedWorkerID) ~= ""
end

local function isPlayerOwned(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    if isBanditLike(npcData) then
        return false
    end

    if isColonyOwned(npcData) then
        return true
    end
    if npcData.isPlayerFactionTrader == true then
        return true
    end
    if hasAssignedMaster(npcData) then
        return true
    end

    local ownedFaction = Internal.getNPCOwnedFaction(npcData)
    if ownedFaction and ownedFaction.playerOwned == true then
        return true
    end

    return false
end

local function resolveHomeCoords(npcData)
    local home = type(npcData) == "table" and npcData.homeCoords or nil
    if type(home) ~= "table" then
        return nil, nil, nil, false
    end

    local x = tonumber(home.x)
    local y = tonumber(home.y)
    if x == nil or y == nil then
        return nil, nil, nil, false
    end

    return x, y, tonumber(home.z) or 0, true
end

function DTNPCRoles.ResolveContext(npcData)
    if type(npcData) ~= "table" then
        return {
            isColonyOwned = false,
            isPlayerOwned = false,
            isAIFaction = false,
            isFriendlyFaction = false,
            isHostileFaction = false,
            isBanditLike = false,
            hasDirectPlayerAuthority = false,
            usesItemRequirements = false,
            hasHomeAnchor = false,
            homeX = nil,
            homeY = nil,
            homeZ = nil,
            homeVicinityRadius = 30,
            factionID = "",
        }
    end

    local factionID = Internal.toText(npcData.factionID)
    local banditLike = isBanditLike(npcData)
    local colonyOwned = isColonyOwned(npcData)
    local playerOwned = isPlayerOwned(npcData)
    local hostileFaction = isHostileFaction(npcData)
    local homeX, homeY, homeZ, hasHomeAnchor = resolveHomeCoords(npcData)
    local ownedFaction = Internal.getNPCOwnedFaction(npcData)
    local aiFaction = not playerOwned and (
        banditLike
        or factionID ~= ""
        or npcData.contactVisitMode ~= nil
        or npcData.tradeCycleMode ~= nil
        or npcData.homeCoords ~= nil
    )

    local friendlyFaction = false
    if playerOwned then
        friendlyFaction = true
    elseif not hostileFaction and factionID ~= "" and factionID ~= "Independent" then
        friendlyFaction = true
    elseif ownedFaction and ownedFaction.playerOwned == true then
        friendlyFaction = true
    end

    return {
        isColonyOwned = colonyOwned,
        isPlayerOwned = playerOwned,
        isAIFaction = aiFaction,
        isFriendlyFaction = friendlyFaction,
        isHostileFaction = hostileFaction,
        isBanditLike = banditLike,
        hasDirectPlayerAuthority = hasAssignedMaster(npcData),
        usesItemRequirements = playerOwned,
        hasHomeAnchor = hasHomeAnchor,
        homeX = homeX,
        homeY = homeY,
        homeZ = homeZ,
        homeVicinityRadius = math.max(1, tonumber(npcData.homeVicinityRadius) or tonumber(npcData.baseVicinityRadius) or 30),
        factionID = factionID,
    }
end

Internal.hasAssignedMaster = hasAssignedMaster
Internal.isBanditLike = isBanditLike
Internal.isHostileFaction = isHostileFaction
Internal.isColonyOwned = isColonyOwned
Internal.isPlayerOwned = isPlayerOwned
