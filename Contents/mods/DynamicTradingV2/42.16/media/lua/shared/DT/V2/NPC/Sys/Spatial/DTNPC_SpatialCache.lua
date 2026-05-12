-- ==============================================================================
-- DTNPC_SpatialCache.lua
-- Lightweight reusable spatial bucket cache for DT NPC runtime queries.
-- ==============================================================================

DTNPCSpatialCache = DTNPCSpatialCache or {}

local SpatialCache = DTNPCSpatialCache

local function tableHasEntries(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    for _, _ in pairs(tbl) do
        return true
    end

    return false
end

local function getCellSize(index)
    if type(index) ~= "table" then
        return 8
    end

    return math.max(1, math.floor(tonumber(index.cellSize) or 8))
end

local function getCellKeyForPosition(index, x, y)
    local cellSize = getCellSize(index)
    local cellX = math.floor((tonumber(x) or 0) / cellSize)
    local cellY = math.floor((tonumber(y) or 0) / cellSize)
    return tostring(cellX) .. ":" .. tostring(cellY), cellX, cellY
end

local function getNeighborKeys(index, x, y, radius)
    local keys = {}
    local _, centerX, centerY = getCellKeyForPosition(index, x, y)
    local cellRadius = math.max(1, math.ceil((tonumber(radius) or 0) / getCellSize(index)))

    for dx = -cellRadius, cellRadius do
        for dy = -cellRadius, cellRadius do
            keys[#keys + 1] = tostring(centerX + dx) .. ":" .. tostring(centerY + dy)
        end
    end

    return keys
end

function SpatialCache.New(config)
    config = type(config) == "table" and config or {}

    return {
        cellSize = math.max(1, math.floor(tonumber(config.cellSize) or 8)),
        entries = {},
        buckets = {},
        lastRebuildAt = 0,
        needsFullRebuild = true,
    }
end

function SpatialCache.Clear(index)
    if type(index) ~= "table" then
        return
    end

    index.entries = {}
    index.buckets = {}
    index.needsFullRebuild = true
end

function SpatialCache.Get(index, key)
    if type(index) ~= "table" or key == nil then
        return nil
    end

    local entries = type(index.entries) == "table" and index.entries or nil
    return entries and entries[key] or nil
end

function SpatialCache.Remove(index, key)
    if type(index) ~= "table" or key == nil then
        return false
    end

    local entries = type(index.entries) == "table" and index.entries or nil
    local entry = entries and entries[key] or nil
    if not entry then
        return false
    end

    if entry.bucketKey and type(index.buckets) == "table" then
        local bucket = index.buckets[entry.bucketKey]
        if type(bucket) == "table" then
            bucket[key] = nil
            if not tableHasEntries(bucket) then
                index.buckets[entry.bucketKey] = nil
            end
        end
    end

    entries[key] = nil
    return true
end

function SpatialCache.Upsert(index, key, data)
    if type(index) ~= "table" or key == nil or type(data) ~= "table" then
        return nil
    end

    index.entries = type(index.entries) == "table" and index.entries or {}
    index.buckets = type(index.buckets) == "table" and index.buckets or {}

    SpatialCache.Remove(index, key)

    local entry = data
    entry.key = key
    entry.bucketKey = getCellKeyForPosition(index, entry.x, entry.y)

    index.entries[key] = entry

    local bucket = index.buckets[entry.bucketKey]
    if type(bucket) ~= "table" then
        bucket = {}
        index.buckets[entry.bucketKey] = bucket
    end
    bucket[key] = entry

    index.needsFullRebuild = false
    return entry
end

function SpatialCache.ForEachNearby(index, x, y, radius, callback)
    if type(index) ~= "table" or type(callback) ~= "function" then
        return
    end

    local keys = getNeighborKeys(index, x, y, radius)
    for i = 1, #keys do
        local bucket = index.buckets and index.buckets[keys[i]] or nil
        if type(bucket) == "table" then
            for key, entry in pairs(bucket) do
                local shouldBreak = callback(entry, key)
                if shouldBreak == true then
                    return
                end
            end
        end
    end
end

function SpatialCache.FindNearest(index, x, y, z, radius, options)
    if type(index) ~= "table" then
        return nil, 9999
    end

    options = type(options) == "table" and options or {}
    local safeRadius = math.max(0.25, tonumber(radius) or 0)
    local radiusSq = safeRadius * safeRadius
    local floorTolerance = math.max(0, tonumber(options.floorTolerance) or 0)
    local predicate = type(options.predicate) == "function" and options.predicate or nil
    local bestEntry = nil
    local bestDistSq = nil

    SpatialCache.ForEachNearby(index, x, y, safeRadius, function(entry)
        if type(entry) ~= "table" then
            return false
        end
        if math.abs((tonumber(entry.z) or 0) - (tonumber(z) or 0)) > floorTolerance then
            return false
        end
        if predicate and predicate(entry) ~= true then
            return false
        end

        local dx = (tonumber(entry.x) or 0) - (tonumber(x) or 0)
        local dy = (tonumber(entry.y) or 0) - (tonumber(y) or 0)
        local distSq = (dx * dx) + (dy * dy)
        if distSq <= radiusSq and (bestDistSq == nil or distSq < bestDistSq) then
            bestEntry = entry
            bestDistSq = distSq
        end
        return false
    end)

    return bestEntry, bestDistSq and math.sqrt(bestDistSq) or 9999
end

SpatialCache.GetCellKeyForPosition = getCellKeyForPosition
SpatialCache.GetNeighborKeys = getNeighborKeys
