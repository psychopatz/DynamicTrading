require "DT/Common/Config"

local Types = require "DT/Common/Abstract/Normalization/DT_AbstractTypes"
local Buckets = require "DT/Common/Abstract/Normalization/DT_AbstractBuckets"
local Normalizer = require "DT/Common/Abstract/Normalization/DT_AbstractNormalizer"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Abstract = DynamicTrading.Abstract or {}
DynamicTrading.Abstract.Normalization = DynamicTrading.Abstract.Normalization or {}

local Catalog = DynamicTrading.Abstract.Normalization.Catalog or {}
DynamicTrading.Abstract.Normalization.Catalog = Catalog

local State = {
    records = nil,
    byFullType = nil,
    revision = nil,
    buildCount = 0,
    lastBuildReason = "initial",
}

local function getRegistryRevision()
    return math.floor(tonumber(DynamicTrading
        and DynamicTrading.Config
        and DynamicTrading.Config.ItemRegistryRevision) or 0)
end

local function getMasterList()
    return DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList or {}
end

local function normalizeText(value)
    return Types.NormalizeSearchText(value)
end

local function shouldInclude(itemKey, itemData)
    local fullType = tostring(itemData and itemData.item or itemKey or "")
    return fullType ~= "" and string.sub(fullType, 1, 5) == "Base."
end

local function sortRecords(records)
    table.sort(records, function(left, right)
        local leftName = normalizeText(left and left.displayName or left and left.fullType or "")
        local rightName = normalizeText(right and right.displayName or right and right.fullType or "")
        if leftName == rightName then
            return tostring(left and left.fullType or "") < tostring(right and right.fullType or "")
        end
        return leftName < rightName
    end)
end

local function buildCache(reason)
    local records = {}
    local byFullType = {}

    for itemKey, itemData in pairs(getMasterList()) do
        if shouldInclude(itemKey, itemData) then
            local fullType = tostring(itemData and itemData.item or itemKey)
            local record = Normalizer.NormalizeItem(fullType, itemData)
            if record then
                records[#records + 1] = record
                byFullType[record.fullType] = record
            end
        end
    end

    sortRecords(records)

    State.records = records
    State.byFullType = byFullType
    State.revision = getRegistryRevision()
    State.buildCount = State.buildCount + 1
    State.lastBuildReason = tostring(reason or "refresh")

    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log(
            "DTCommons",
            "Abstract",
            "Build",
            "Built abstract normalization catalog records=" .. tostring(#records)
                .. " revision=" .. tostring(State.revision)
                .. " buildCount=" .. tostring(State.buildCount)
                .. " reason=" .. tostring(State.lastBuildReason)
        )
    end
end

local function ensureCache(reason)
    if State.records == nil or State.revision ~= getRegistryRevision() then
        buildCache(reason or "lazy")
    end
end

function Catalog.Invalidate(reason)
    State.records = nil
    State.byFullType = nil
    State.revision = nil
    State.lastBuildReason = tostring(reason or "manual_invalidate")
end

function Catalog.WarmCache()
    ensureCache("warm_cache")
    return State.records
end

function Catalog.GetAllRecords()
    ensureCache("get_all")
    return State.records
end

function Catalog.GetRecord(fullType)
    ensureCache("get_record")
    return State.byFullType and State.byFullType[tostring(fullType or "")] or nil
end

function Catalog.FilterRecords(options)
    ensureCache("filter")
    options = type(options) == "table" and options or {}

    local searchText = normalizeText(options.searchText or "")
    local bucketFilter = tostring(options.bucket or "")
    local filtered = {}

    for _, record in ipairs(State.records or {}) do
        local matchesBucket = bucketFilter == "" or record.primaryBucket == bucketFilter
        local matchesText = true
        if searchText ~= "" then
            local haystack = table.concat({
                normalizeText(record.displayName),
                normalizeText(record.fullType),
                normalizeText(record.primaryBucket),
                normalizeText(table.concat(record.tags or {}, " ")),
                normalizeText(table.concat(record.reasons or {}, " ")),
            }, " ")
            matchesText = string.find(haystack, searchText, 1, true) ~= nil
        end

        if matchesBucket and matchesText then
            filtered[#filtered + 1] = record
        end
    end

    return filtered
end

function Catalog.GetBucketCounts()
    ensureCache("bucket_counts")
    local counts = {}
    for _, bucketID in ipairs(Buckets.GetOrderedIDs()) do
        counts[bucketID] = 0
    end
    for _, record in ipairs(State.records or {}) do
        counts[record.primaryBucket] = (counts[record.primaryBucket] or 0) + 1
    end
    return counts
end

function Catalog.GetDebugState()
    ensureCache("debug_state")
    return {
        revision = State.revision or 0,
        buildCount = State.buildCount or 0,
        lastBuildReason = State.lastBuildReason or "",
        totalRecords = #(State.records or {}),
    }
end

return Catalog
