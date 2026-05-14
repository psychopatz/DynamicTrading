-- ==============================================================================
-- DTNPC_LootSearchShared_State.lua
-- Loot-search state management helpers.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

if DTNPCLootSearch.Modules.State then
    return
end

DTNPCLootSearch.Modules.State = true

local Internal = DTNPCLootSearch.Internal
local Constants = Internal.Constants

function Internal.pruneRecentCollects(state)
    local recent = type(state and state.recentCollects) == "table" and state.recentCollects or nil
    if not recent then
        return
    end

    local currentTime = Internal.nowMillis()
    for sourceKey, entries in pairs(recent) do
        if type(entries) == "table" then
            for itemKey, expiresAt in pairs(entries) do
                if (tonumber(expiresAt) or 0) <= currentTime then
                    entries[itemKey] = nil
                end
            end
            if Internal.isTableEmpty(entries) then
                recent[sourceKey] = nil
            end
        else
            recent[sourceKey] = nil
        end
    end
end

function Internal.wasRecentlyCollected(state, sourceKey, itemKey)
    if type(state) ~= "table" or not sourceKey or not itemKey then
        return false
    end

    Internal.pruneRecentCollects(state)
    local entries = state.recentCollects and state.recentCollects[tostring(sourceKey)] or nil
    return type(entries) == "table" and (tonumber(entries[tostring(itemKey)]) or 0) > Internal.nowMillis()
end

function Internal.markRecentlyCollected(state, sourceKey, itemKey)
    if type(state) ~= "table" or not sourceKey or not itemKey then
        return
    end

    state.recentCollects = type(state.recentCollects) == "table" and state.recentCollects or {}
    local normalizedSourceKey = tostring(sourceKey)
    local entries = state.recentCollects[normalizedSourceKey]
    if type(entries) ~= "table" then
        entries = {}
        state.recentCollects[normalizedSourceKey] = entries
    end
    entries[tostring(itemKey)] = Internal.nowMillis() + Constants.SEARCH_RECENT_COLLECT_TTL_MS
end

function Internal.setCollectEvent(state, eventType, sourceKey, carryState, requesterUsername)
    if type(state) ~= "table" or tostring(eventType or "") == "" then
        return nil
    end

    state.collectEventCounter = math.max(0, math.floor(tonumber(state.collectEventCounter) or 0)) + 1
    state.lastCollectEvent = {
        id = state.collectEventCounter,
        type = tostring(eventType),
        sourceKey = sourceKey and tostring(sourceKey) or nil,
        requestedBy = requesterUsername and tostring(requesterUsername) or nil,
        createdAt = Internal.nowMillis(),
        carryState = type(carryState) == "table" and Internal.copyTableShallow(carryState) or nil,
    }
    return state.lastCollectEvent
end

function Internal.getVisualCollectTarget(state)
    local target = type(state and state.visualCollectTarget) == "table" and state.visualCollectTarget or nil
    if not target then
        return nil
    end

    if (tonumber(target.expiresAt) or 0) <= Internal.nowMillis() then
        state.visualCollectTarget = nil
        return nil
    end

    return target
end

function Internal.setVisualCollectTarget(state, source)
    if type(state) ~= "table" or type(source) ~= "table" then
        return nil
    end

    local target = {
        key = source.key,
        sourceKey = source.key,
        kind = source.kind,
        label = source.label,
        x = source.x,
        y = source.y,
        z = source.z,
        approachX = source.approachX,
        approachY = source.approachY,
        approachZ = source.approachZ,
        stopDistance = source.stopDistance,
        expiresAt = Internal.nowMillis() + Constants.SEARCH_VISUAL_COLLECT_MS,
    }
    state.visualCollectTarget = target
    return target
end

function Internal.clearVisualCollectTarget(state)
    if type(state) == "table" then
        state.visualCollectTarget = nil
    end
end

function DTNPCLootSearch.IsDynamicColoniesCompanion(npcData)
    return type(npcData) == "table"
        and tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
        and tostring(npcData.linkedWorkerID or "") ~= ""
end

function DTNPCLootSearch.EnsureState(npcData)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) then
        return {}
    end

    npcData.dcLootSearch = type(npcData and npcData.dcLootSearch) == "table" and npcData.dcLootSearch or {}
    local state = npcData.dcLootSearch
    state.searchedSources = type(state.searchedSources) == "table" and state.searchedSources or {}
    state.discoveredSources = type(state.discoveredSources) == "table" and state.discoveredSources or {}
    state.pendingCollects = type(state.pendingCollects) == "table" and state.pendingCollects or {}
    state.recentCollects = type(state.recentCollects) == "table" and state.recentCollects or {}
    state.currentSourceKey = state.currentSourceKey or nil
    state.lastSyncAt = tonumber(state.lastSyncAt) or 0
    state.collectEventCounter = math.max(0, math.floor(tonumber(state.collectEventCounter) or 0))
    state.lastCollectEvent = type(state.lastCollectEvent) == "table" and state.lastCollectEvent or nil
    state.visualCollectTarget = type(state.visualCollectTarget) == "table" and state.visualCollectTarget or nil
    state.scanCacheNonce = math.max(0, math.floor(tonumber(state.scanCacheNonce) or 0))
    Internal.pruneRecentCollects(state)
    Internal.getVisualCollectTarget(state)
    return state
end

function DTNPCLootSearch.HasQueuedCollects(npcData)
    local state = DTNPCLootSearch.EnsureState(npcData)
    for _, queue in pairs(state.pendingCollects or {}) do
        if type(queue) == "table" and #queue > 0 then
            return true
        end
    end
    return false
end

function DTNPCLootSearch.GetQueuedSourceKey(npcData)
    local state = DTNPCLootSearch.EnsureState(npcData)
    for sourceKey, queue in pairs(state.pendingCollects or {}) do
        if type(queue) == "table" and #queue > 0 then
            return sourceKey
        end
    end
    return nil
end

function DTNPCLootSearch.GetVisualCollectTarget(npcData)
    local state = DTNPCLootSearch.EnsureState(npcData)
    local target = Internal.getVisualCollectTarget(state)
    return target and Internal.copyTableShallow(target) or nil
end

function DTNPCLootSearch.QueueCollectRequest(npcData, sourceKey, itemKeys, requesterUsername)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) or not sourceKey or type(itemKeys) ~= "table" then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local queue = state.pendingCollects[sourceKey]
    if type(queue) ~= "table" then
        queue = {}
        state.pendingCollects[sourceKey] = queue
    end

    local seen = {}
    for _, existingKey in ipairs(queue) do
        seen[tostring(existingKey)] = true
    end

    local changed = false
    for _, itemKey in ipairs(itemKeys) do
        local normalized = tostring(itemKey or "")
        if normalized ~= "" and not seen[normalized] and not Internal.wasRecentlyCollected(state, sourceKey, normalized) then
            queue[#queue + 1] = normalized
            seen[normalized] = true
            changed = true
        end
    end

    state.requestedBy = requesterUsername or state.requestedBy
    state.currentSourceKey = sourceKey
    if changed then
        state.lastCollectEvent = nil
    end
    return changed
end

function DTNPCLootSearch.DiscoverSource(npcData, source)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) or not source then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local serialized = Internal.serializeSource(source)
    local existing = state.discoveredSources[source.key]
    state.searchedSources[source.key] = true
    state.discoveredSources[source.key] = serialized
    state.currentSourceKey = source.key
    return existing == nil or #((existing and existing.items) or {}) ~= #(serialized.items or {})
end

function DTNPCLootSearch.UpdateDiscoveredSource(npcData, source)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) or not source then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    state.discoveredSources[source.key] = Internal.serializeSource(source)
    return true
end
